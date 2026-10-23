#!/bin/bash
# Remove water + ions (storage, ChimeraX). Needs nowater_index.ndx (see 02_system_build/index_groups).
# NOTE: reconstructed from project notes.
# Usage: bash strip_water.sh <run_dir> [tpr] [xtc]
set -e
cd "${1:-.}"
TPR=${2:-step5_1.tpr}; XTC=${3:-md_pbc.xtc}; GMX=${GMX:-gmx}
G='!TIP3_&_!CLA_&_!POT'
echo "$G" | $GMX trjconv -s $TPR -f $XTC -n nowater_index.ndx -o traj_nowater.xtc
echo "$G" | $GMX trjconv -s $TPR -f $XTC -n nowater_index.ndx -o nowater.gro -dump 0
