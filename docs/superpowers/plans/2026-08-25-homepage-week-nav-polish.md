# Homepage and Week Navigation Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Center the desktop week navigation, apply the established green accent to the homepage hero title, round the Open Journal button, and publish these refinements together with the completed click-sound work.

**Architecture:** Keep the change within the existing Quarto SCSS system. Reuse `--journal-accent` for theme-aware color, alter only the desktop weekly rail grid, preserve the mobile overflow rule, and publish the existing local MP3 through Quarto resources.

**Tech Stack:** Quarto 1.10, SCSS, HTML5 Audio, Bash verification, GitHub Actions, Netlify

---

### Task 1: Add source-level regression checks

**Files:**
- Modify: `styles/_layout.scss`
- Modify: `styles/_components.scss`
- Verify: `index.qmd`

- [ ] **Step 1: Confirm the requested CSS is initially absent**

Run:

```bash
rg -n "color: var\(--journal-accent\)" styles/_layout.scss
rg -n "border-radius: 8px" styles/_components.scss
rg -n "grid-template-columns: 1fr" styles/_components.scss
```

Expected: none of the three requested declarations is present in the target rules.

- [ ] **Step 2: Confirm the requested GitHub username is already correct**

Run:

```bash
rg -n "GitHub: \*\*ANAMASGARD\*\*" index.qmd
```

Expected: one match in the homepage introduction; no content edit is needed.

### Task 2: Implement the minimal SCSS changes

**Files:**
- Modify: `styles/_layout.scss`
- Modify: `styles/_components.scss`

- [ ] **Step 1: Color the homepage hero heading with the existing accent token**

Add this declaration to `.journal-hero h1` in `styles/_layout.scss`:

```scss
color: var(--journal-accent);
```

- [ ] **Step 2: Round the shared journal button**

Add this declaration to `.journal-button` in `styles/_components.scss`:

```scss
border-radius: 8px;
```

- [ ] **Step 3: Center the weekly rail across the desktop viewport**

Replace the desktop shell columns in `.week-nav-shell`:

```scss
grid-template-columns: 1fr;
```

Keep `.week-nav` in column 1. Do not change the existing mobile rule:

```scss
@media (max-width: 767px) {
  .week-nav {
    width: 100%;
    padding: 0 1rem;
    justify-content: flex-start;
  }
}
```

- [ ] **Step 4: Run source assertions**

Run:

```bash
rg -n "color: var\(--journal-accent\)" styles/_layout.scss
rg -n "border-radius: 8px" styles/_components.scss
rg -n "grid-template-columns: 1fr" styles/_components.scss
```

Expected: all three declarations are present once in their intended rules.

### Task 3: Render and verify behavior

**Files:**
- Verify: `_site/index.html`
- Verify: `_site/journal/week-2/index.html`
- Verify: `_site/assets/click-003.mp3`

- [ ] **Step 1: Render the complete Quarto site**

Run:

```bash
XDG_CACHE_HOME=/tmp/gaurav-quarto-build-cache quarto render
```

Expected: 17 pages render and Quarto reports `Output created: _site/index.html`.

- [ ] **Step 2: Run the repository verification**

Run:

```bash
scripts/verify-site.sh
git diff --check
```

Expected: the site contract passes and Git reports no whitespace errors.

- [ ] **Step 3: Verify rendered content and audio packaging**

Run:

```bash
rg -n "Welcome to my GSoC 2026 Journey|ANAMASGARD" _site/index.html
test -f _site/assets/click-003.mp3
cmp assets/click-003.mp3 _site/assets/click-003.mp3
```

Expected: both homepage strings exist, and the deployed MP3 is byte-identical to the source asset.

- [ ] **Step 4: Verify the rendered UI in a local browser**

Start `quarto preview` with an isolated cache. At desktop width, compare the bounding-box center of `.week-nav` with `window.innerWidth / 2`; allow at most 2px difference. Confirm `.journal-hero h1` computes to `var(--journal-accent)`, `.journal-button-primary` has `8px` corner radius, and About, Week 2, and the theme toggle each invoke the audio playback handler. At mobile width, confirm `.week-nav` has `justify-content: flex-start` and `scrollWidth >= clientWidth`.

### Task 4: Review, commit, push, and verify deployment

**Files:**
- Add: `assets/click-003.mp3`
- Add: `docs/superpowers/specs/2026-08-25-homepage-week-nav-polish-design.md`
- Add: `docs/superpowers/plans/2026-08-25-homepage-week-nav-polish.md`
- Modify: `_quarto.yml`
- Modify: `assets/site.js`
- Modify: `styles/_components.scss`
- Modify: `styles/_layout.scss`

- [ ] **Step 1: Review the complete publication diff**

Run:

```bash
git status --short
git diff -- _quarto.yml assets/site.js styles/_components.scss styles/_layout.scss docs/superpowers/specs/2026-08-25-homepage-week-nav-polish-design.md docs/superpowers/plans/2026-08-25-homepage-week-nav-polish.md
```

Expected: only the sound-effect work, approved UI changes, and their design/plan documents are in scope.

- [ ] **Step 2: Stage only reviewed paths**

Run:

```bash
git add _quarto.yml assets/site.js assets/click-003.mp3 styles/_components.scss styles/_layout.scss docs/superpowers/specs/2026-08-25-homepage-week-nav-polish-design.md docs/superpowers/plans/2026-08-25-homepage-week-nav-polish.md
git diff --cached --check
git diff --cached --stat
```

Expected: the index contains exactly seven reviewed paths and has no whitespace errors.

- [ ] **Step 3: Commit the verified change**

Run:

```bash
git commit -m "feat: add interface sounds and polish journal navigation"
```

Expected: one commit is created on `main`.

- [ ] **Step 4: Push the production branch**

Run:

```bash
git push origin main
```

Expected: GitHub accepts the new commit without a non-fast-forward error.

- [ ] **Step 5: Verify GitHub Actions and Netlify**

Use the workflow run created by the pushed commit. Wait for it to complete successfully, then verify the live homepage contains `ANAMASGARD`, the rendered CSS contains the new declarations, the MP3 returns HTTP 200, and `/journal/week-2/` shows the centered weekly rail.
