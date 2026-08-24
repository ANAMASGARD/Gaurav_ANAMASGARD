# Journal Routes, Theme Toggle, and Home Layout Design

## Objective

Refine the GSoC journal into a compact, native Quarto experience with a deliberate animated theme control, less empty space on the home page, the contributor's complete name in the navbar, and weekly content owned by the Journal route instead of the Posts route.

## Design Direction

The existing monochrome engineering-journal aesthetic remains unchanged. New work must preserve the dotted construction grid, technical typography, narrow reading column, right-side Quarto index, and light/dark palette. The update removes excess space and improves interaction without adding a frontend framework.

## Information Architecture

Weekly content moves from `posts/` to `journal/` and uses these public routes:

```text
/journal/          Week 1 content and the default Journal destination
/journal/week-1/   Week 1 content
/journal/week-2/   Week 2 content
...
/journal/week-12/  Week 12 content
```

The main navbar's Journal link points to `/journal/`. The `Week 1` through `Week 12` rail links to the corresponding `/journal/week-N/` route. `/journal/` and `/journal/week-1/` share one Week 1 content source so their displayed content cannot drift.

The existing `posts/week-XX` source directories are removed. Netlify permanent redirects preserve inbound links:

```text
/posts/week-01/  /journal/week-1/   301
...
/posts/week-12/  /journal/week-12/  301
```

The old listing content currently shown on the Journal page is removed completely.

The journal listing feed is intentionally removed with that listing. It can be
reintroduced later only from the canonical `journal/` entries.

`/journal/` is the canonical Week 1 URL. `/journal/week-1/` remains a navigable
alias and emits a canonical link to `/journal/` so the shared body does not
create duplicate search entries.

## Weekly Content Architecture

Week 1's reusable article body lives in a Quarto include consumed by both `/journal/` and `/journal/week-1/`. Weeks 2 through 12 use the existing shared planned-entry include until verified progress replaces it.

Every weekly page retains the metadata contract:

- `week`
- `title`
- `date-start`
- `date-end`
- `status`
- `sprint`
- `pull-requests`
- `issues`
- `categories`

Every weekly page retains the semantic headings Outcome, What I Did, Learnings, Confusions / Issues, Next Week Targets, Demo / Media, and Links so Quarto continues to generate the right-side INDEX.

The homepage development cards, weekly navigation rail, labels, active states, validation scripts, RSS/listing references, and internal links use `Week 1` through `Week 12`; abbreviated `W1` or zero-padded `W01` labels are removed from the visible interface.

## Navbar Identity

The navbar title changes from `GAURAV / GSOC 2026` to `GAURAV CHAUDHARY`. The existing logo remains. Navigation links, repository link, search, mobile collapse behavior, and compact technical typography remain intact.

## Home Page Spacing

The home hero no longer reserves most of the initial viewport height. Its minimum viewport height and vertical centering are removed. The new layout uses a compact top padding below the navbar, a smaller bottom margin before About the Project, and responsive spacing based on `clamp()`.

The hierarchy remains:

1. Google Summer of Code 2026 eyebrow
2. Main Animint2 heading
3. Introductory paragraph
4. Contributor and project metadata
5. Journal and progress actions
6. About the Project

The main heading remains visually dominant, but the next section should be discoverable without scrolling through an empty screen. Mobile spacing stays smaller than desktop spacing and must not create horizontal overflow.

## Animated Precision Theme Toggle

Quarto's built-in light/dark stylesheets and preference persistence remain authoritative. The existing `.quarto-color-scheme-toggle` anchor is progressively enhanced instead of replaced with a separate theme engine.

The control becomes a compact 54 by 28 pixel pill:

- A bordered track uses the current journal surface and text variables.
- Sun and moon indicators remain visible inside the track.
- A circular thumb slides between states and rotates during a 280 millisecond spring-like transition.
- Hover and focus states strengthen the border without changing layout.
- The control updates `role="switch"`, `aria-checked`, `aria-label`, and its tooltip after every state change.
- Space and Enter activate the control.

When supported, the View Transitions API cross-fades the root document around Quarto's native theme switch. Unsupported browsers use the existing CSS color transitions. `prefers-reduced-motion: reduce` disables thumb travel animation, icon rotation, and document transition while preserving the immediate theme change.

The enhancement must not interfere with theme persistence, Quarto navigation, search, the GitHub link, or Animint2 interaction.

## Responsive Behavior

At desktop widths, all twelve full week labels fit in a widened centered rail where space permits. On narrower screens the rail scrolls horizontally, keeps the active week visible, and never wraps.

The right-side INDEX remains visible and sticky on wide weekly pages and remains hidden under the existing tablet breakpoint. The animated theme switch remains available in the collapsed mobile navbar and preserves a minimum touch target.

## Redirect and Deployment Behavior

Redirect rules are stored in a Netlify `_redirects` file included as a Quarto project resource so they are copied into `_site/`. The production artifact remains `_site/`, and deployment continues through the linked `gaurav-anamasgard` Netlify project.

The canonical `site-url` remains `https://gaurav-anamasgard.netlify.app`. After local validation, the new artifact is deployed with `netlify deploy --dir _site --prod --no-build`.

## Validation

Implementation is accepted only when all of these checks pass:

- The weekly metadata validator recognizes twelve Journal routes.
- `quarto render` succeeds without warnings or errors.
- `_site/journal/index.html` and `_site/journal/week-1/index.html` through `_site/journal/week-12/index.html` exist.
- `_site/posts/week-XX` pages are not generated.
- `_site/_redirects` contains all twelve permanent redirects.
- The static Animint2 JSON, data, CSS, and JavaScript bundles remain present.
- The home page has materially reduced vertical whitespace at desktop and mobile sizes.
- The navbar shows `GAURAV CHAUDHARY`.
- Every visible week selector uses the full `Week N` form.
- The theme switch works with pointer, Enter, and Space input.
- Theme state persists after reload.
- Both themes retain readable contrast and usable Animint2 controls.
- Reduced-motion mode changes the theme without animated movement.
- `git diff --check` passes and ignored credentials or build artifacts are not staged.

## Delivery

The implementation will be committed on `feat/quarto-gsoc-journal`, pushed to its existing remote branch, and manually redeployed to the current production Netlify project after all validation succeeds.
