#!/usr/bin/env bash
set -eu

require_file() {
  if ! test -f "$1"; then
    echo "Missing required artifact: $1" >&2
    exit 1
  fi
}

for page in \
  _site/index.html \
  _site/journal/index.html \
  _site/journal/community-bonding/index.html \
  _site/journal/final-submission/index.html \
  _site/progress.html \
  _site/about.html \
  _site/contact.html
do
  require_file "$page"
done

require_file _site/_redirects
require_file _site/assets/click-003.mp3
require_file _site/assets/gaurav-chaudhary-profile.jpeg

grep -q 'AudioContext || window.webkitAudioContext' _site/index.html
grep -q 'decodeAudioData' _site/index.html
grep -q 'createBufferSource' _site/index.html
grep -q 'gain.gain.value = 1;' _site/index.html
grep -q 'fallbackSound.cloneNode' _site/index.html
grep -q 'document.addEventListener("pointerdown"' _site/index.html
grep -q 'document.addEventListener("keydown"' _site/index.html
if grep -q 'document.addEventListener("click"' _site/index.html; then
  echo "Global sound handling must not listen for click events." >&2
  exit 1
fi

for week in 1 2 3 4 5 6 7 8 9 10 11 12
do
  require_file "_site/journal/week-${week}/index.html"
  old_week=$(printf '%02d' "$week")
  grep -Eq "^/posts/week-${old_week}/ +/journal/week-${week}/ +301!?$" _site/_redirects
done

test "$(find _site/journal -mindepth 1 -maxdepth 1 -type d -name 'week-*' | wc -l)" -eq 12
if test -e _site/journal/pre-gsoc/index.html; then
  echo "A removed Pre-GSoC route was generated." >&2
  exit 1
fi
if find _site/posts -type f -print -quit 2>/dev/null | grep -q .; then
  echo "Legacy /posts/ pages were generated." >&2
  exit 1
fi

grep -q "Welcome to my GSoC 2026 Journey" _site/index.html
grep -q "OPEN JOURNAL" _site/index.html
grep -q "Development journey" _site/index.html
grep -q "CI isolation and legend control" _site/index.html
grep -q "Interactive histogram proof of concept" _site/index.html
grep -q "LASTING MERGES BY AUG 24" _site/index.html
grep -q "OPEN PRS AT CUTOFF" _site/index.html
grep -q "FINAL STATUS" _site/index.html
grep -q '<strong>12</strong>' _site/index.html
grep -q '<strong>11</strong>' _site/index.html
grep -q '<strong>5</strong>' _site/index.html

for removed_home_copy in \
  "Reserved for verified progress" \
  "PLANNED" \
  "21 workstreams does not mean 21 merged pull requests"
do
  if grep -q "$removed_home_copy" _site/index.html; then
    echo "Removed or placeholder Home copy is still present: ${removed_home_copy}" >&2
    exit 1
  fi
done

for page in _site/journal/community-bonding/index.html _site/journal/week-*/index.html _site/journal/final-submission/index.html
do
  grep -q "Outcome" "$page"
  grep -q "What I Did" "$page"
  grep -q "Learnings" "$page"
  grep -q "Challenges / Notes" "$page"
  grep -q "Next Week Targets" "$page"
  grep -q "Demo / Media" "$page"
  grep -q "Evidence and Links" "$page"
done

for page in _site/journal/index.html _site/journal/week-*/index.html _site/journal/final-submission/index.html
do
  grep -q 'class="week-nav-shell"' "$page"
  grep -q 'data-week="1"' "$page"
  grep -q 'data-week="12"' "$page"
  grep -q 'data-entry="final"' "$page"
  grep -q 'href="[^"]*journal/final-submission/">Final</a>' "$page"
done

for page in _site/journal/index.html _site/journal/week-*/index.html
do
  grep -q 'class="week-header"' "$page"
  grep -q 'class="week-badge"' "$page"
  grep -q 'class="metric-grid"' "$page"
done

for page in _site/journal/index.html _site/journal/week-1/index.html
do
  grep -q "A strong start: CI isolation, facet tests, clearer errors, and legend control" "$page"
  grep -q '/journal/week-1/week1-legend-optout-demo/index.html' "$page"
done

for removed_journal_copy in \
  "Where I was when GSoC started" \
  'class="journey-jump-select"' \
  'class="journey-phase-nav"'
do
  if grep -q "$removed_journal_copy" _site/journal/index.html _site/journal/week-*/index.html; then
    echo "Removed Journal navigation or landing content is still present: ${removed_journal_copy}" >&2
    exit 1
  fi
done

grep -q "Progress Report" _site/progress.html
grep -q "Timeline of Contributions" _site/progress.html
grep -q ">CB<" _site/progress.html
grep -q ">W01<" _site/progress.html
grep -q ">W12<" _site/progress.html
grep -q ">FS<" _site/progress.html
grep -q "11 → 12" _site/progress.html

for removed_progress_copy in \
  "Technical areas" \
  "Issue → PR map" \
  "Post-cutoff note" \
  'class="technical-area-list"' \
  'class="issue-pr-map"' \
  'class="progress-cutoff-note"'
do
  if grep -q "$removed_progress_copy" _site/progress.html; then
    echo "Removed Progress content is still present: ${removed_progress_copy}" >&2
    exit 1
  fi
done

timeline_entries=$(grep -c 'class="progress-timeline-entry' _site/progress.html || true)
test "$timeline_entries" -eq 14
timeline_links=$(grep -c 'class="progress-journal-link' _site/progress.html || true)
test "$timeline_links" -eq 14

for week in 1 2 3 4 5 6 7 8 9 10 11 12
do
  grep -q "journal/week-${week}/" _site/progress.html
done
grep -q "journal/community-bonding/" _site/progress.html
grep -q "journal/final-submission/" _site/progress.html

grep -Eq 'class="[^"]*about-profile' _site/about.html
grep -q 'alt="Portrait of Gaurav Chaudhary"' _site/about.html
grep -q 'href="https://github.com/ANAMASGARD"' _site/about.html
grep -q "Advancing Animint2 — Performance, Renderer and New Features" _site/about.html

grep -Eq 'class="[^"]*contact-method-grid' _site/contact.html
grep -q 'href="mailto:chaudharygaurav2004@gmail.com"' _site/contact.html
grep -q 'href="https://www.linkedin.com/in/gaurav-chaudhary-680baa215/"' _site/contact.html
grep -q 'href="https://x.com/ANAMASGARD"' _site/contact.html
grep -q 'href="https://summerofcode.withgoogle.com/programs/2026/projects/49BpsyvL"' _site/contact.html

if grep -R -n --include='*.html' -E 'UPDATE PENDING|Schedule pending|Reserved for verified|Add Week [0-9]+ title|>PLANNED<' _site; then
  echo "Generated site still contains placeholder journal content." >&2
  exit 1
fi
if grep -R -n --include='*.html' '/posts/week-' _site; then
  echo "Generated content still references a legacy weekly route." >&2
  exit 1
fi

echo "Verified Home, Journal, 14-entry Progress, About, Contact, audio, routes, metrics, and placeholder removal."

while IFS=, read -r id profile sha status route bundle function_name; do
  if [ "$id" = "id" ]; then
    continue
  fi

  for asset in index.html animint.js animint.css animint-responsive.css animint-responsive.js plot.json; do
    test -f "_site/$bundle/$asset"
  done

  page="_site/$route/index.html"
  grep -q "$(basename "$bundle")/index.html" "$page"
  grep -q 'class="animint-demo-reference"' "$page"
  grep -q 'class="animint-demo-label"' "$page"
done < visualizations/manifest.csv

grep -q 'href="https://github.com/animint/animint2/pull/292"' _site/journal/week-1/index.html
grep -q 'Interactive Animint2 demo — click a legend entry.' _site/journal/week-1/index.html

grep -q 'href="https://github.com/animint/animint2/pull/336"' _site/journal/week-2/index.html
grep -q 'PR #336' _site/journal/week-2/index.html
grep -q 'merged Aug 25' _site/journal/week-2/index.html
grep -q 'OPEN AT AUG 24 CUTOFF · MERGED AUG 25' _site/journal/week-2/index.html
grep -q 'Interactive Animint2 demo — select a year and observe the filtering semantics.' _site/journal/week-2/index.html

grep -q 'href="https://github.com/animint/animint2/pull/286"' _site/journal/week-10/index.html
grep -q 'Live Animint2 layout demo.' _site/journal/week-10/index.html

grep -q 'href="https://github.com/animint/animint2/pull/261"' _site/journal/final-submission/index.html
grep -q 'Live Animint2 multiline rendering demo.' _site/journal/final-submission/index.html

if grep -R -n --include='*.html' -E 'LIVE · MERGED BY AUGUST 24|LIVE · POST-CUTOFF MERGE' \
  _site/journal; then
  echo "Generated journal still contains a removed Animint provenance banner." >&2
  exit 1
fi

grep -q '"selectors": \[\]' _site/journal/week-10/week10-panel-margin-demo/plot.json
grep -q '"showSelected1": "comparison"' _site/journal/week-1/week1-legend-optout-demo/plot.json
grep -q '"showSelected1": "year"' _site/journal/week-2/week2-showselected-legend-demo/plot.json
if grep -q 'region_variable_selector_widget' \
  _site/journal/week-2/week2-showselected-legend-demo/index.html; then
  echo "Week 2 unexpectedly injects a region selector." >&2
  exit 1
fi

echo "Verified responsive Animint assets, compact PR references, and truth-first labels."
