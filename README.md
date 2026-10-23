# SiiE–MUC1 structural project (docking + MD)

> **Status: scrapped, Sept 2026.** Kept as a record and so the pipeline can be reused.

**Question:** does the *Salmonella* Typhimurium giant adhesin **SiiE** bind the mucin **MUC1**, and how do **terminal sialic acids** and **Ca²⁺** change that binding?

## Design (2 × 2)

| Condition | MUC1 glycans | Ca²⁺ |
|---|---|---|
| `sial_Ca` | sialylated | + |
| `sial_noCa` | sialylated | − |
| `desial_Ca` | desialylated | + |
| `desial_noCa` | desialylated | − |

Controls (baseline RMSD): SiiE alone ±Ca²⁺, MUC1 alone sialylated / desialylated (10 tandem repeats).
CHARMM36m, 310 K, KCl, 2 fs step. Complexes: 500 ns each. Controls: 10 × 1 ns. See `MANIFEST.tsv`.

## Pipeline

```
SiiE PDB ──────────┐
                   ├─► ZDOCK ─► fix PDB columns ─► top pose per condition
MUC1 (glycosylator)┘                                  │
                                                      ▼
                    CHARMM-GUI Glycan Reader & Modeler (build + solvate)
                                                      ▼
            GROMACS (HPC, H100): minimise ► equilibrate ► 500 ns production
                                                      ▼
            PBC fix (nojump ► cluster ► mol) ► strip water ► RMSD ► ChimeraX
```

## Layout

| Folder | What's in it |
|---|---|
| `00_inputs/siie/` | Cleaned SiiE structures (with / without Ca²⁺), AlphaFill Ca²⁺ model |
| `00_inputs/muc1/` | Native 10-repeat MUC1, core 1/core 2 glycan templates, glycosylated sial/desial MUC1, `scripts/` (glycosylator) |
| `00_inputs/residue_renaming.tsv` | AGA→A2G, BGA→GAL, BGL→NAG, ANE→SIA |
| `01_docking/zdock/` | ZDOCK output files for each run |
| `01_docking/top_poses/` | The four poses taken forward into MD |
| `01_docking/scripts/` | `fix_zdock_pdb_columns.py`: repairs squashed chain/residue columns in ZDOCK complexes |
| `01_docking/haddock3/` | HADDOCK3 global-docking config + `prepare_muc1_haddock.sh` (chain/glycan/terminal renaming) |
| `02_system_build/` | CHARMM-GUI glycan specs per condition, topology-merge script, index-group notes |
| `03_md/complex/<cond>/` | mdp files, `topol.top`, `toppar/`, minimisation + SLURM scripts (`*_cont.sbatch` = resume from checkpoint) |
| `03_md/controls/<cond>/` | Same, for the monomer controls |
| `04_postprocessing/` | `pbc_correct.sh`, `strip_water.sh`, `subsample.sh` |
| `05_analysis/rmsd/` | RMSD `.xvg` data, plots, and plotting scripts (full run and 200 ns window) |
| `docs/` | Lessons learned, project status |

Trajectories, checkpoints, `.tpr`, `.psf` and index files are **not** in git (≈32 GB). They live in the original project folder; `MANIFEST.tsv` maps each condition to it.

## Reproducing a step

```bash
# MUC1 glycosylation (run inside 00_inputs/muc1, needs glycosylator)
python scripts/sial_glycosylation_script.py

# ZDOCK column fix (run inside a folder of complex.N.pdb files)
python 01_docking/scripts/fix_zdock_pdb_columns.py

# MD on the cluster (inside a 03_md/... folder holding the CHARMM-GUI step3_input.gro)
bash minim.sh            # local; set GMX_D to your double-precision gmx_d
sbatch sial_cal.sbatch   # equilibration + production

# Post-processing + RMSD
bash 04_postprocessing/pbc_correct.sh <run_dir>
bash 04_postprocessing/strip_water.sh <run_dir>
python 05_analysis/rmsd/scripts/200ns_rmsd.py 05_analysis/rmsd/complex_with_glycans
```
