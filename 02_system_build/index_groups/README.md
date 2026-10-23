# Index groups

`*.ndx` files are not in git (5–15 MB each). They stay in each run folder of the original project and can be rebuilt with `gmx make_ndx`.

CHARMM-GUI names water `TIP3` (not `SOL`), so GROMACS's default "Water" group doesn't exist. Custom groups used:

| Group | Meaning | Used for |
|---|---|---|
| `SOLU` / `SOLV` | solute / solvent (from CHARMM-GUI) | thermostat coupling |
| `!TIP3_&_!CLA_&_!POT` | everything except water and K+/Cl- | water stripping (`nowater_index.ndx`) |

Glycan residue groups: sialylated = `AGALN BGAL ANE5A BGALN BGLCN`; desialylated = `AGALN BHEP BGALN BGLCN BGAL`. `CAL` = Ca2+.

Rebuild the strip group:
```
gmx make_ndx -f step3_input.gro -o nowater_index.ndx
> !r TIP3 & !r CLA & !r POT
> q
```
