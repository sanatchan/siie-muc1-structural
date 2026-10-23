"""
Find atoms with duplicate coordinates in a PDB file.
Usage: python3 find_duplicates.py step3_input.pdb
"""
import sys

pdb = sys.argv[1] if len(sys.argv) > 1 else "step3_input.pdb"

coords = {}
duplicates = []

with open(pdb) as f:
    for i, line in enumerate(f):
        if not line.startswith("ATOM") and not line.startswith("HETATM"):
            continue
        try:
            x = float(line[30:38])
            y = float(line[38:46])
            z = float(line[46:54])
            coord = (x, y, z)
            atom   = line[12:16].strip()
            resname = line[17:20].strip()
            resnum  = line[22:26].strip()
            chain   = line[21]
            key = f"{chain}:{resname}{resnum}:{atom} (line {i+1})"
            if coord in coords:
                duplicates.append(f"{key}  ==  {coords[coord]}")
            else:
                coords[coord] = key
        except ValueError:
            pass

print(f"Total atoms checked: {len(coords)}")
print(f"Total duplicate coordinates: {len(duplicates)}")
if duplicates:
    print("\nFirst 30 duplicates:")
    for d in duplicates[:30]:
        print(" ", d)
else:
    print("\nNo duplicate coordinates found.")
