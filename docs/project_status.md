# Project status

**Scrapped, September 2026.**

Completed:
- Glycosylated MUC1 models (sialylated and desialylated, 10 repeats)
- ZDOCK docking and pose selection for all four conditions
- 500 ns production MD for all four complexes
- Monomer controls: SiiE + Ca²⁺, MUC1 sial, MUC1 desial (10 ns each). SiiE − Ca²⁺ was minimised only.
- RMSD analysis (full run and first 200 ns)

Reason for stopping: _to fill in._

## Known gaps in this repo
- Files that were cloud-only on the Mac and couldn't be copied: `50_51_52_siie.fasta`, `pdbtools_cleaned_muc_sial.pdb`, HADDOCK `data/configurations/README.txt`.
- `04_postprocessing/*.sh` were rewritten from notes. The original trjconv commands were run by hand.
- Which ZDOCK run (`01_docking/zdock/*`) fed which final pose isn't recorded in the files themselves.
