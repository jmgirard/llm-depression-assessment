# LLM Depression Assessment: Supplemental Materials

Supplemental analysis reports and source code for:

> Girard, J. M., Kebe, G. Y., Morency, L.-P., De la Torre, F., Liebenthal, E., & Baker, J. T. (in press). Evaluating open-weight large language models for structured depression assessment from clinical interviews. *Journal of Psychopathology and Clinical Science*.

**Website:** https://jmgirard.github.io/llm-depression-assessment/

## Contents

- `analyses/` — rendered analysis reports (self-contained HTML)
- `src/` — Quarto source files (`.qmd`) for each report
- `index.qmd`, `_quarto.yml` — website source
- `docs/` — rendered website (served by GitHub Pages)

## Reproducing the site

```
quarto render
```

The analysis reports themselves require access to the study data, which
contains protected health information and cannot be publicly shared; see the
Data Availability statement on the site.
