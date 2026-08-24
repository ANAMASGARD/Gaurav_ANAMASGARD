# Compact Green Homepage and Visualization Route Removal

## Objective

Refresh the homepage with a compact, centered GSoC introduction inspired by
the supplied reference, while preserving the existing Quarto navbar structure
and technical journal identity. Remove the standalone visualization route and
the homepage sections that no longer support the desired landing experience.

## Homepage Hero

The homepage uses the approved reference-led centered composition. Its first
viewport contains:

1. The eyebrow `GOOGLE SUMMER OF CODE 2026`.
2. The display heading `Welcome to my GSoC 2026 Journey`.
3. A centered introduction based on the supplied copy:

   > Follow my journey through Google Summer of Code 2026, where I'll share
   > weekly updates, progress reports, and insights into the Animint2 project
   > I'm passionate about. I'm Gaurav Chaudhary—ANAMASGARD on GitHub—and this
   > journal documents my growth, challenges, and achievements throughout this
   > incredible opportunity.

4. One primary action labelled `OPEN JOURNAL`, linked to `/journal/`.
5. The beginning of the About the Project section at common laptop heights.

The hero is centered, uses an editorial serif display face with the existing
sans-serif body typography, and avoids viewport-height sizing or vertical
centering that creates empty space.

## Header

The existing logo, `GAURAV CHAUDHARY` identity, navigation model, GitHub link,
theme switch, search, and mobile collapse behavior remain. The navbar becomes
slightly shorter through tighter vertical dimensions. The Visualizations item
is removed; the remaining order is Home, Journal, Progress, About, Contact.

## Green Accent System

Green replaces blue as the restrained accent in both themes. It is used for
active navigation underlines, focus outlines, links, the primary button,
eyebrow text, and selected borders or rules. Page backgrounds, body copy, the
construction grid, and large content surfaces remain neutral. Dark mode uses a
lighter green with sufficient contrast.

## Homepage Content

All twelve Week 1 through Week 12 cards remain in the Development Journey grid.
The About the Project panel, Development Journey grid, and Project Snapshot
remain below the hero.

The following homepage content is removed completely:

- Latest Progress
- Verified updates placeholder
- Interactive Animint2 heading, explanatory copy, embedded demonstration, and
  visualization-lab link

## Visualization Route Removal

`visualizations.qmd` is removed and the Visualizations navbar item disappears.
`/visualizations`, `/visualizations/`, and `/visualizations.html` permanently
redirect to `/` through Netlify `_redirects`. No `_site/visualizations.html`
page is generated.

With both rendered visualization consumers removed, Quarto no longer runs or
copies Animint2 bundles during the website build. Obsolete post-render copying
and artifact-verification requirements are removed. The reusable R helper and
locked R environment remain available for future verified visualization work;
they are not published by this change.

## Responsive Behavior

At desktop sizes, the centered hero and its primary action fit comfortably
above the About section with the next section visibly beginning around a
900-pixel-high laptop viewport. At mobile sizes, the heading scales down, the
button remains a usable touch target, and the page has no horizontal overflow.
The twelve-card grid continues to collapse through its existing responsive
breakpoints.

## Validation

Implementation is accepted only when:

- `quarto render` completes successfully from a clean output directory.
- `_site/index.html` contains the approved heading, identity copy, and
  `OPEN JOURNAL` action.
- The homepage contains all twelve full `Week N` cards.
- The homepage contains neither Latest Progress nor Interactive Animint2.
- `_site/visualizations.html` and generated Animint2 bundles are absent.
- `_site/_redirects` permanently maps all three visualization URL forms to `/`.
- The navbar has no Visualizations item and retains all other controls.
- Light and dark themes use readable green accents.
- A 1440 by 900 viewport reveals the start of About the Project.
- A 390 by 844 viewport has no page-level horizontal overflow.
- `git diff --check` passes and ignored credentials/build artifacts remain
  unstaged.

## Delivery Boundary

Implementation, commit, push, and production deployment are separate actions.
This design approval authorizes source implementation and validation; Git
publication or deployment occurs only when explicitly requested.
