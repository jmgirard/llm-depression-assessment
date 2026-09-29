# LLM Depression Assessment: Supplemental Materials

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23029765.svg)](https://doi.org/10.5281/zenodo.23029765)

Supplemental analysis reports and source code for:

> Girard, J. M., Kebe, G. Y., Morency, L.-P., De la Torre, F., Liebenthal, E., & Baker, J. T. (in press). Evaluating open-weight large language models for structured depression assessment from clinical interviews. *Journal of Psychopathology and Clinical Science*.

Preprint: https://osf.io/preprints/psyarxiv/63sw4

**Website:** https://jmgirard.github.io/llm-depression-assessment/

## Contents

- `data/` — model predictions, with a codebook ([data/README.md](data/README.md))
- `analyses/` — rendered analysis reports (HTML, with supporting files in `*_files/`)
- `src/` — Quarto source files (`.qmd`) for each report, and the shared data loader (`load_data.R`)
- `index.qmd`, `_quarto.yml` — website source
- `docs/` — rendered website (served by GitHub Pages)

## Reproducing the analyses

The model predictions are in `data/` (see [data/README.md](data/README.md)).
The human MADRS ratings and participant characteristics they are evaluated
against are available under controlled access from the NIMH Data Archive
(NDA), collection 3860.

1. Obtain NDA access and download the `madrs01` and `ndar_subject01`
   structures for collection 3860 as `madrs01.txt` and `ndar_subject01.txt`.
2. Store them on storage approved under your NDA Data Use Certification, and
   point `NDA_DIR` at that folder. Fitted models embed the analysis data, so
   point `FITS_DIR` at approved storage too. For example, in `~/.Renviron`:
   ```
   NDA_DIR=/secure/path/nda
   FITS_DIR=/secure/path/fits
   ```
3. Render the reports from `src/`, e.g. `quarto render src/performance_analyses.qmd`.

The performance and ensemble analyses are deterministic. The fairness and
ablation analyses fit Bayesian models by MCMC, so a fresh fit reproduces the
reported estimates up to Monte Carlo error.

## Rendering the site

```
quarto render
```

## License

- **Code** (the `.qmd` source files in `src/` and the website configuration):
  [MIT License](LICENSE)
- **Content** (rendered reports in `analyses/` and `docs/`, website text, and
  any data files): [CC BY 4.0](LICENSE-CC-BY.md)

## Citation

Please cite the article above. The version of these materials cited in the
article is archived on Zenodo as **v1.1.0**
([doi:10.5281/zenodo.23029765](https://doi.org/10.5281/zenodo.23029765)), which adds the model predictions to
the code and reports archived in v1.0.0. See also [CITATION.cff](CITATION.cff).
