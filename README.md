# GSoC 2026 Animint2 Development Journal

A Quarto website for Gaurav Chaudhary's Google Summer of Code 2026 development journal. It uses native Quarto pages and navigation, SCSS themes, R/knitr, and static interactive Animint2 output. No SPA framework or runtime application server is required.

## Live website

[gaurav-anamasgard.netlify.app](https://gaurav-anamasgard.netlify.app)

The production site is deployed from the rendered `_site/` directory. It includes the responsive weekly journal, light and dark themes, and browser-ready Animint2 visualizations.

## Local setup

Install [Quarto](https://quarto.org/docs/get-started/) and R 4.6 or later, then restore the locked R environment:

```bash
Rscript -e 'renv::restore()'
```

The lockfile pins Animint2 2026.7.29 from commit `a112290eb5df72b60c4afd6c09eb1062d50bc44e`.

## Preview website

```bash
quarto preview
```

## Production render

```bash
Rscript scripts/validate-weeks.R
quarto render
scripts/verify-site.sh
```

The static production artifact is written to `_site/`, which is intentionally ignored by Git.

## Add a weekly journal entry

Edit the matching `posts/week-NN/index.qmd`. Keep this front matter contract:

```yaml
---
title: "Verified weekly title"
week: 1
date-start: "May 26, 2026"
date-end: "June 1, 2026"
status: "Complete"
sprint: "Week 1"
pull-requests: 0
issues: 0
categories: [Animint2]
---
```

Allowed statuses are `Planned`, `In Progress`, `Complete`, and `Blocked`. Replace the reserved copy only with verified work and retain the standard Outcome, What I Did, Learnings, Confusions / Issues, Next Week Targets, Demo / Media, and Links headings.

## Animint2

Reusable plots live in `R/animint-demos.R`. The Home and Visualizations pages execute those functions during the Quarto render. Animint2 writes `plot.json`, tabular data, CSS, JavaScript, and vendored browser dependencies into the static site, so Netlify serves the interactions without Shiny or an iframe.

## Netlify deployment

The repository is linked locally to the `gaurav-anamasgard` Netlify project. For automated deployments:

1. In the GitHub repository, add Actions secrets named `NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID`.
2. Confirm that `site-url` in `_quarto.yml` remains `https://gaurav-anamasgard.netlify.app`.
3. Push to `main` for production deployment. Same-repository pull requests receive a draft deployment and an updated preview comment; fork pull requests build without receiving secrets.

Netlify publishes `_site/`. The workflow restores R dependencies, installs Quarto, validates all weekly entries, renders the site, verifies the artifact, and deploys it.

For a verified manual deployment:

```bash
quarto render
scripts/verify-site.sh
netlify deploy --dir _site --prod --no-build
```

The OAuth token created by `netlify login` remains in Netlify CLI's global configuration and must not be copied into the repository. Local `.env` and `.netlify/` files are Git-ignored.

## Editable placeholders

Update the contact placeholders in `contact.qmd`, the project copy in `about.qmd`, and weekly entries as verified information becomes available. No contribution statistics or achievements are fabricated in the starter content.
