#!/bin/bash
# Keep every Nth frame so a 16 GB laptop can open the trajectory in ChimeraX.
# Usage: bash subsample.sh <in.xtc> <out.xtc> [skip=10] [ref=nowater.gro]
set -e
GMX=${GMX:-gmx}
echo System | $GMX trjconv -f "$1" -o "$2" -skip "${3:-10}" -s "${4:-nowater.gro}"
