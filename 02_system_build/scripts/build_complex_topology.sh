#!/bin/bash
# ============================================================
# Build GROMACS MD system from HADDOCK sial_zdock_final.pdb
#
# Inputs needed in working directory:
#   sial_zdock_final.pdb            - top HADDOCK docked pose (MUC1 chain A + SiiE chain B)
#   topol.top                 - MUC1 glycoprotein topology from CHARMM-GUI
#   toppar/                   - CHARMM36m parameter folder from CHARMM-GUI
#
# Output:
#   complex.gro + topol_complex.top -> ready for gmx solvate
# ============================================================

set -e
GMX="gmx"
INPUT="sial_zdock_final.pdb"

# ============================================================
# Step 1: Convert full complex to .gro (single coordinate frame)
# ============================================================
echo "--- Step 1: Convert HADDOCK pose to .gro ---"

$GMX editconf -f "$INPUT" -o complex_raw.gro

echo "complex_raw.gro written."

# ============================================================
# Step 2: Extract SiiE (chain B, ATOM only) for pdb2gmx
# Use column 22 for chain ID - avoids matching B in atom names
# ============================================================
echo ""
echo "--- Step 2: Extract SiiE chain B ---"

awk 'substr($0,1,4)=="ATOM" && substr($0,22,1)=="B"' "$INPUT" > siie_docked.pdb
echo "END" >> siie_docked.pdb

echo "SiiE atoms: $(grep '^ATOM' siie_docked.pdb | wc -l)"

# ============================================================
# Step 3: Generate SiiE topology with pdb2gmx
# ============================================================
echo ""
echo "--- Step 3: SiiE topology via pdb2gmx ---"

$GMX pdb2gmx \
    -f siie_docked.pdb \
    -o siie.gro \
    -p siie.top \
    -i siie_posre.itp \
    -ff charmm36m \
    -water tip3p \
    -ignh \
    -ter << TERMINI
0
0
TERMINI

echo "SiiE topology generated."

# ============================================================
# Step 4: Merge topologies
# Insert siie_mol.itp into MUC1 topol.top
# ============================================================
echo ""
echo "--- Step 4: Merging topologies ---"

python3 - << 'PYEOF'
import re

# Extract SiiE moleculetype block
with open("siie.top") as f:
    siie_content = f.read()

start = siie_content.find("[ moleculetype ]")
end   = siie_content.find("[ system ]")
if start == -1:
    raise ValueError("Could not find [ moleculetype ] in siie.top")

siie_mol_block = siie_content[start:end].strip()

with open("siie_mol.itp", "w") as f:
    f.write("; SiiE molecule topology\n")
    f.write(siie_mol_block)
    f.write("\n")

# Get SiiE moleculetype name
mol_match = re.search(r'\[\s*moleculetype\s*\]\s*\n[;\s]*\n(\S+)', siie_mol_block)
siie_molname = mol_match.group(1) if mol_match else "Protein_chain_B"
print(f"SiiE molecule name: {siie_molname}")

# Build topol_complex.top
with open("topol.top") as f:
    muc1_content = f.read()

system_idx = muc1_content.find("[ system ]")
if system_idx == -1:
    raise ValueError("Could not find [ system ] in topol.top")

new_content = (
    muc1_content[:system_idx]
    + '\n#include "siie_mol.itp"\n\n'
    + muc1_content[system_idx:]
    + f"\n{siie_molname}         1\n"
)

with open("topol_complex.top", "w") as f:
    f.write(new_content)

print("topol_complex.top written.")
PYEOF

# ============================================================
# Step 5: Verify atom counts match between gro and topology
# ============================================================
echo ""
echo "--- Step 5: Atom count check ---"

python3 - << 'PYEOF'
# Get atom count from complex_raw.gro
with open("complex_raw.gro") as f:
    lines = f.readlines()
gro_atoms = int(lines[1].strip())

# Get expected atom count from topol_complex.top
# MUC1 atoms from CHARMM-GUI gro header
with open("step4.0_minimization.gro") as f:  
    muc1_atoms = int(f.readlines()[1].strip())

# SiiE atoms from siie.gro
with open("siie.gro") as f:
    siie_atoms = int(f.readlines()[1].strip())

print(f"complex_raw.gro atoms : {gro_atoms}")
print(f"MUC1 topology atoms   : {muc1_atoms}")
print(f"SiiE topology atoms   : {siie_atoms}")
print(f"Topology total        : {muc1_atoms + siie_atoms}")

if gro_atoms != muc1_atoms + siie_atoms:
    print("\nWARNING: atom count mismatch!")
    print("This likely means HADDOCK added/removed atoms vs your input structures.")
    print("The .gro atom count must match topology exactly before proceeding.")
else:
    print("\nAtom counts match. Good to proceed.")
PYEOF

# ============================================================
# Step 6: Sanity check with grompp
# ============================================================
echo ""
echo "--- Step 6: grompp sanity check ---"

cat > check.mdp << 'MDP'
integrator = steep
nsteps     = 0
MDP

$GMX grompp \
    -f check.mdp \
    -c complex_raw.gro \
    -p topol_complex.top \
    -o check.tpr \
    -maxwarn 5 \
    2>&1 | tail -20

echo ""
echo "============================================================"
echo "If grompp succeeded, proceed with:"
echo ""
echo "1. Solvate:"
echo "   gmx solvate -cp complex_raw.gro -cs spc216.gro -p topol_complex.top -o solvated.gro"
echo ""
echo "2. Add ions:"
echo "   gmx grompp -f check.mdp -c solvated.gro -p topol_complex.top -o ions.tpr -maxwarn 5"
echo "   gmx genion -s ions.tpr -o ionized.gro -p topol_complex.top -pname NA -nname CL -neutral -conc 0.15"
echo ""
echo "3. Transfer to HPC:"
echo "   ionized.gro, topol_complex.top, toppar/, run_md_complex.sh"
echo "   sbatch run_md_complex.sh"
echo "============================================================"