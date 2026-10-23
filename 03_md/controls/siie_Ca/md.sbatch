#!/bin/bash
#SBATCH --job-name=siie_cal_md
#SBATCH --output=md_%j.log
#SBATCH --error=md_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --partition=long
#SBATCH --gres=gpu:H100:1

source /opt/ohpc/pub/anaconda3/etc/profile.d/conda.sh
conda activate gromacs

set -e

init=step3_input
mini_prefix=step4.0_minimization
equi_prefix=step4.1_equilibration
prod_prefix=step5_production
prod_step=step5


# Equilibration
gmx grompp -f ${equi_prefix}.mdp -o ${equi_prefix}.tpr -c ${mini_prefix}.gro \
    -r ${init}.gro -p topol.top -n index.ndx
gmx mdrun -v -deffnm ${equi_prefix} -ntmpi 1 -ntomp $SLURM_CPUS_PER_TASK \
    -gpu_id 0 -nb gpu -pme gpu -bonded gpu

# Production (10 x segments, continuing from each previous)
cnt=1
cntmax=10

while [ $cnt -le $cntmax ]; do
    pcnt=$((cnt - 1))
    istep=${prod_step}_${cnt}
    pstep=${prod_step}_${pcnt}

    if [ $cnt -eq 1 ]; then
        pstep=${equi_prefix}
        gmx grompp -f ${prod_prefix}.mdp -o ${istep}.tpr -c ${pstep}.gro \
            -p topol.top -n index.ndx
    else
        gmx grompp -f ${prod_prefix}.mdp -o ${istep}.tpr -c ${pstep}.gro \
            -t ${pstep}.cpt -p topol.top -n index.ndx
    fi

    gmx mdrun -v -deffnm ${istep} -ntmpi 1 -ntomp $SLURM_CPUS_PER_TASK \
        -gpu_id 0 -nb gpu -pme gpu -bonded gpu

    cnt=$((cnt + 1))
done

