# Homepage and Week Navigation Polish

## Goal

Refine the existing Quarto journal UI in three focused ways:

1. Center the Week 1–Week 12 navigation rail across the desktop viewport.
2. Color the homepage heading “Welcome to my GSoC 2026 Journey” with the existing theme-aware green accent.
3. Give the Open Journal button restrained rounded corners.

The homepage must continue to show the GitHub username exactly as `ANAMASGARD`.

## Visual design

The site keeps its current compact editorial aesthetic, typography, spacing, and responsive behavior. The homepage heading uses `var(--journal-accent)`, which resolves to the existing dark-theme mint and the existing accessible light-theme green. The primary button receives an 8px border radius: visibly rounded without becoming a pill.

On desktop, the weekly rail is centered relative to the full viewport instead of the article and sidebar grid. Week labels remain `Week 1` through `Week 12`. On screens below 768px, the existing left-aligned horizontal scrolling behavior remains unchanged so every week stays reachable.

## Implementation boundaries

- Update `styles/_components.scss` to make the desktop weekly rail use the full-width shell for centering and to add the button radius.
- Update `styles/_layout.scss` to apply the theme-aware accent to `.journal-hero h1`.
- Do not change `index.qmd`; it already contains `GitHub: ANAMASGARD` exactly as requested.
- Do not alter journal routes, content, typography, theme variables, the table of contents, or existing click-sound work.

## Responsive behavior

- Desktop: all twelve week links are centered across the viewport.
- Tablet: the rail remains centered when the links fit and retains horizontal overflow when necessary.
- Mobile below 768px: preserve `justify-content: flex-start` and horizontal scrolling.

## Accessibility

The heading uses the theme’s established accent token rather than a fixed green, preserving the intended light- and dark-theme contrast. Navigation markup, focus styles, active-week indication, link labels, and keyboard behavior remain unchanged.

## Verification

- Render all Quarto pages with an isolated writable cache.
- Run `scripts/verify-site.sh` and `git diff --check`.
- Confirm the desktop weekly rail’s visual center matches the viewport center.
- Confirm mobile week navigation remains horizontally scrollable.
- Confirm the heading uses the correct theme accent in light and dark modes.
- Confirm the Open Journal button has an 8px radius.
- Confirm the rendered homepage still contains `ANAMASGARD`.
- Preserve the existing uncommitted sound-effect files and changes.
