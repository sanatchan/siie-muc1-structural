#!/bin/bash
# Prepare pdbtools_sial_muc.pdb for HADDOCK docking
# Fixes: chain IDs, glycan residue names, terminal atom names
# Usage: bash prepare_muc1_haddock.sh

INPUT="cleaned_siie_em.pdb"
OUTPUT="pdbtools_siie.pdb"

if [ ! -f "$INPUT" ]; then
    echo "ERROR: $INPUT not found. Run this script from the same directory as the PDB file."
    exit 1
fi

echo "Processing $INPUT..."

pdb_chain -A "$INPUT" \
| sed 's/\(.\{17\}\)AGA/\1A2G/' \
| sed 's/\(.\{17\}\)BGA/\1GAL/' \
| sed 's/\(.\{17\}\)BGL/\1NAG/' \
| sed 's/\(.\{17\}\)ANE/\1SIA/' \
| sed '/^ATOM/s/ HT1 / H   /' \
| sed '/^ATOM/s/ HT2 / H2  /' \
| sed '/^ATOM/s/ HT3 / H3  /' \
| sed '/^ATOM/s/ OT1 / O   /' \
| sed '/^ATOM/s/ OT2 / OXT /' \
> "$OUTPUT"

echo "Done. Output written to $OUTPUT"
echo ""
echo "Quick checks:"
echo "  Unique HETATM residue names (should be A2G, GAL, NAG, SIA):"
grep "^HETATM" "$OUTPUT" | awk '{print $4}' | sort -u
echo "  LINK records (should be 90):"
grep -c "^LINK" "$OUTPUT"
echo "  Chain IDs present:"
grep "^ATOM\|^HETATM" "$OUTPUT" | cut -c22 | sort -u | tr -d ' '
echo "  Terminal atoms renamed:"
grep "^ATOM" "$OUTPUT" | awk '$3~/^H$|^H2$|^H3$|^O$|^OXT$/{print $3}' | sort -u
