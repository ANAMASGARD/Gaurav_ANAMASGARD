# GSoC 2026 Animint2 Development Journal

Gaurav Chaudhary's evidence-backed Google Summer of Code 2026 journal for Animint2 and the R Project for Statistical Computing. The static Quarto site covers Community Bonding, all 12 coding weeks, the August 17–24 final-submission period, and the exact August 24 evaluation cutoff.

The site distinguishes lasting merges, open work, closed or reprioritized experiments, collaborative work, and the August 25 post-cutoff merge. The headline metric is **21 authored PR workstreams, including 11 lasting merges by August 24**—not 21 merged PRs.

## Site structure

- `/journal/` — story-map landing page and 14 official-program entries.
- `/progress/` — concise 14-node timeline, final metrics, technical areas, and issue-to-PR map.
- `/about/` — contributor, project, mentors, technologies, and focus areas.
- `/contact/` — contact cards and project links.

There is no separate Pre-GSoC route. Earlier work appears only as concise context when it explains a workstream continued during the official program.

## Local setup

Install Quarto and R, then restore the cutoff environment when required:

```bash
Rscript -e 'renv::restore()'
```

The root `renv.lock` pins the August 24 cutoff commit:

```text
a112290eb5df72b60c4afd6c09eb1062d50bc44e
```

PR #336 is intentionally isolated at its August 25 merge commit:

```text
8f009edb9556e6acf10059d01a76d2d99a06b39c
```

## Rebuild the live Animint2 evidence

Prepare both exact source trees and temporary R libraries:

```bash
scripts/prepare-animint-environments.sh
```

Then generate the bundles declared in `visualizations/manifest.csv`:

```bash
R_PROFILE_USER=/dev/null Rscript --vanilla scripts/build-animint-demos.R .
```

Each demo is built from one `animint()` object. The manifest records its route, historical status, exact commit, output bundle, and generating function. The current priority live demos cover:

- Week 1 — historical PR #292 legend opt-out behavior at the cutoff commit.
- Week 2 — `showSelected.legend = FALSE` in an isolated August 25 environment.
- Week 10 — merged positive `panel.margin` behavior.
- Final Submission — merged multiline plot, axis, legend, and `geom_text()` output.

Open or collaborative branches are represented by clearly labeled static evidence unless a branch-pinned artifact is available; they are never rendered from current `master` and presented as shipped.

## Validate and render

```bash
Rscript --vanilla scripts/validate-weeks.R
R_PROFILE_USER=/dev/null Rscript --vanilla render.R
git diff --check
```

`render.R` runs Quarto, mirrors every expected Animint bundle into its matching `_site/journal/...` route, and runs `scripts/verify-site.sh`. The verifier fails when a route, date, required journal section, metric, iframe, SHA label, or core Animint asset is missing.

For a read-only local demo of the verified artifact:

```bash
python3 -m http.server 4311 --bind 127.0.0.1 --directory _site
```

Then open <http://127.0.0.1:4311/>.

## Writing contract

Every official entry uses:

```text
Outcome
Context (only when needed)
What I Did
Learnings
Challenges / Notes
Next Week Targets
Demo / Media
Evidence and Links
```

Do not assign an entire long-running implementation to its merge week. State when it began earlier, what changed in the current week, and the status reached during that week.

## Deployment boundary

The site can be deployed from `_site`, but local rendering does not stage, commit, push, create a Netlify preview, or deploy production. Those actions are separate, explicit publication steps. Never copy local `.env` or `.netlify/` credentials into the repository.
