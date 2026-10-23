# GROMACS notes

- HPC: CUDA-enabled GROMACS 2026, installed offline into a conda env named `gromacs` (SLURM, H100 GPUs). The sbatch scripts run `conda activate gromacs`.
- Laptop (Apple Silicon): conda GROMACS for analysis, plus a separate double-precision build (`gmx_d`) for minimisation. Point `GMX_D` at it, e.g. `export GMX_D=~/gromacs_2026_double/bin/gmx_d`.
- CHARMM-GUI's `README` is a csh script; `minim.sh` and the `.sbatch` files are the bash versions.
