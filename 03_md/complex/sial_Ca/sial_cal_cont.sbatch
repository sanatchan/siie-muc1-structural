#!/bin/bash
#SBATCH --job-name=sial_cal_resume
#SBATCH --output=md_resume_%j.log
#SBATCH --error=md_resume_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --partition=long
#SBATCH --gres=gpu:H100:1
source /opt/ohpc/pub/anaconda3/etc/profile.d/conda.sh
conda activate gromacs
set -e

gmx mdrun -v -deffnm step5_1 -ntmpi 1 -ntomp $SLURM_CPUS_PER_TASK \
    -gpu_id 0 -nb gpu -pme gpu -bonded gpu -cpi step5_1.cpt
