# Lessons learned

- **CHARMM-GUI glycan recognition is fragile.** Check `CONECT` records and residue names before upload. Broken glycan `CONECT` chains caused the minimisation failures in the sialylated systems; removing them fixed it.
- **Residue names differ between tools.** HADDOCK3 needs AGA→A2G, BGA→GAL, BGL→NAG, ANE→SIA (`00_inputs/residue_renaming.tsv`).
- **CHARMM-GUI water is `TIP3`, not `SOL`.** Make custom index groups with `gmx make_ndx`.
- **Use double precision (`gmx_d`) for minimisation** if single precision fails, as the CHARMM-GUI README suggests.
- **Plan storage early.** 4 × 500 ns plus controls reached ~336 GB against a ~100 GB quota. Strip water as soon as a run finishes.
- **Always fix PBC before RMSD or visualisation** (nojump → cluster → mol).
- **Subsample and strip water** before opening trajectories on a 16 GB laptop.
