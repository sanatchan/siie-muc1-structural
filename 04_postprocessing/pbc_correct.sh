#!/bin/bash
# PBC correction: nojump -> cluster -> mol.
# NOTE: reconstructed from project notes; the original commands were typed interactively.
# Usage: bash pbc_correct.sh <run_dir> [tpr] [xtc]
set -e
cd "${1:-.}"
TPR=${2:-step5_1.tpr}; XTC=${3:-step5_1.xtc}; GMX=${GMX:-gmx}
echo System | $GMX trjconv -s $TPR -f $XTC -o md_nojump.xtc -pbc nojump
printf "Protein\nSystem\n" | $GMX trjconv -s $TPR -f md_nojump.xtc -o md_cluster.xtc -pbc cluster -n index.ndx
printf "Protein\nSystem\n" | $GMX trjconv -s $TPR -f md_cluster.xtc -o md_pbc.xtc -pbc mol -center -n index.ndx
