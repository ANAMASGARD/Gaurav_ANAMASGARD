# Compact Green Homepage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current homepage opening with a compact, centered GSoC 2026 hero, remove the published Visualizations route and homepage visualization blocks, retain all twelve week cards, and align the journal week selector over the article-side region.

**Architecture:** Keep Quarto as the sole page and navigation system. Remove the unused visualization page from the render graph and redirect all of its public URL forms to `/`. Express the visual refresh through the shared SCSS tokens and components so light/dark themes and responsive behavior remain native to the existing site.

**Tech Stack:** Quarto, Markdown/QMD, SCSS, Bash artifact verification, Netlify redirects

---

## Task 1: Encode the new artifact contract

- [ ] Update `scripts/verify-site.sh` so it requires the homepage, journal, progress, about, contact, and all twelve week pages but rejects `_site/visualizations.html`.
- [ ] Add checks for the exact hero heading, `OPEN JOURNAL`, `Gaurav Chaudhary`, and `ANAMASGARD` in `_site/index.html`.
- [ ] Add negative checks for the removed navigation label, Latest Progress copy, Interactive Animint2 copy, and homepage Animint bundle reference.
- [ ] Require exact permanent redirects for `/visualizations`, `/visualizations/`, and `/visualizations.html` to `/`.
- [ ] Remove the obsolete Animint bundle requirements from the verifier while retaining all weekly-route, canonical, and stale-route checks.
- [ ] Run `scripts/verify-site.sh` against the current artifact and confirm it fails on the old contract before implementation.

## Task 2: Remove the Visualizations route and build-only publishing work

- [ ] Remove the Visualizations navbar entry and Animint post-render hook from `_quarto.yml`.
- [ ] Delete `visualizations.qmd` and `scripts/copy-animint-assets.sh`.
- [ ] Preserve `R/animint-demos.R` and the locked R environment as reusable project assets.
- [ ] Add the three permanent Visualizations redirects to `_redirects`.
- [ ] Update `README.md` to describe the current static journal and retained reusable Animint helper without claiming that visualizations are published.

## Task 3: Build the compact green homepage

- [ ] Replace the existing `index.qmd` hero with the exact `Welcome to my GSoC 2026 Journey` heading, the approved description naming Gaurav Chaudhary and GitHub user ANAMASGARD, and one primary `OPEN JOURNAL` button linking to `/journal/`.
- [ ] Retain About the project, all Week 1–12 cards, and Project snapshot.
- [ ] Remove only Latest progress and Interactive Animint2 from the homepage.
- [ ] Change light and dark accent tokens in `styles/theme-light.scss` and `styles/theme-dark.scss` from blue to accessible green values.
- [ ] Tighten the shared navbar height in `styles/_variables.scss` and matching navbar spacing in `styles/_base.scss` without changing its structure.
- [ ] Center and compact the homepage hero in `styles/_layout.scss`, using an editorial serif heading and restrained green accents.
- [ ] Center hero actions and style the primary button, active navigation underline, focus states, and outlines through `var(--journal-accent)` in `styles/_components.scss` and `styles/_base.scss`.

## Task 4: Align the weekly selector responsively

- [ ] On desktop, make `.week-nav-shell` a 70/30 grid matching the article/INDEX split and center `.week-nav` in the first region.
- [ ] Below the desktop TOC breakpoint, reset the shell to block layout.
- [ ] On mobile, keep the existing left-started horizontal scrolling and minimum-width week links.

## Task 5: Render and verify

- [ ] Run `Rscript scripts/validate-weeks.R` and confirm all twelve entries pass.
- [ ] Run `quarto render` and confirm the site renders without a Visualizations page or homepage Animint execution.
- [ ] Run `scripts/verify-site.sh` and confirm the full artifact contract passes.
- [ ] Run `git diff --check` and inspect `git status --short` so only intended source changes are present.
- [ ] Preview the generated homepage and journal at desktop and mobile widths, checking hero density, all twelve cards, theme contrast, week-selector alignment, and `/visualizations` redirect behavior.

## Publication boundary

Do not commit, push, or deploy this implementation until the user explicitly requests publication after reviewing the verified local result.
