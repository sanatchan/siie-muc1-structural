#!/bin/bash
source $HOME/gromacs_2026_double/bin/GMXRC
export PATH="$HOME/.local/bin:$PATH"

init=step3_input
mini_prefix=step4.0_minimization
equi_prefix=step4.1_equilibration
prod_prefix=step5_production
prod_step=step5

# Minimization
gmx grompp -f ${mini_prefix}.mdp -o ${mini_prefix}.tpr -c ${init}.gro -r ${init}.gro -p topol.top -n index.ndx -maxwarn 5
gmx_d mdrun -v -deffnm ${mini_prefix}
