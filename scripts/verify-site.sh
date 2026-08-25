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
  _site/progress.html \
  _site/about.html \
  _site/contact.html
do
  require_file "$page"
done

require_file _site/_redirects
require_file _site/assets/click-003.mp3

grep -q 'AudioContext || window.webkitAudioContext' _site/index.html
grep -q 'decodeAudioData' _site/index.html
grep -q 'createBufferSource' _site/index.html
grep -q 'createGain' _site/index.html
grep -q 'gain.gain.value = 1;' _site/index.html
grep -q 'fallbackSound.cloneNode' _site/index.html
grep -q 'document.addEventListener("pointerdown"' _site/index.html
grep -q 'document.addEventListener("keydown"' _site/index.html
grep -q 'input\[type="checkbox"\]' _site/index.html
grep -q 'input\[type="radio"\]' _site/index.html
grep -q 'input\[type="reset"\]' _site/index.html
grep -q 'label\[for\]' _site/index.html
grep -q '\[role="link"\]' _site/index.html
grep -q '\[role="tab"\]' _site/index.html

if grep -q 'document.addEventListener("click"' _site/index.html; then
  echo "Global sound handling must not listen for click events." >&2
  exit 1
fi

for legacy_visualization_route in /visualizations /visualizations/ /visualizations.html
do
  grep -Eq "^${legacy_visualization_route} +/ +301!?$" _site/_redirects
done

if test -f _site/visualizations.html; then
  echo "Removed Visualizations page was generated." >&2
  exit 1
fi

for week in 1 2 3 4 5 6 7 8 9 10 11 12
do
  require_file "_site/journal/week-${week}/index.html"
  old_week=$(printf '%02d' "$week")
  grep -Eq "^/posts/week-${old_week}/ +/journal/week-${week}/ +301!?$" _site/_redirects
done

test "$(find _site/journal -mindepth 1 -maxdepth 1 -type d -name 'week-*' | wc -l)" -eq 12

if find _site/posts -type f -print -quit 2>/dev/null | grep -q .; then
  echo "Legacy /posts/ pages were generated." >&2
  exit 1
fi

grep -q "Welcome to my GSoC 2026 Journey" _site/index.html
grep -q "OPEN JOURNAL" _site/index.html
grep -q "GAURAV CHAUDHARY" _site/index.html
grep -q "Gaurav Chaudhary" _site/index.html
grep -q "ANAMASGARD" _site/index.html
grep -q 'rel="canonical" href="https://gaurav-anamasgard.netlify.app/journal/"' _site/journal/week-1/index.html
grep -Eq 'class="[^"]*progress-report-heading' _site/progress.html
grep -Eq 'class="[^"]*progress-intro-panel' _site/progress.html
grep -q "Progress Report" _site/progress.html
grep -q "Timeline of Contributions" _site/progress.html
grep -q "A week-by-week record of my work, contributions, and verified progress throughout Google Summer of Code 2026." _site/progress.html

if grep -q 'class="progress-hero"' _site/progress.html; then
  echo "Oversized Progress hero is still present." >&2
  exit 1
fi

grep -q '>W01<' _site/progress.html
grep -q '>W12<' _site/progress.html

timeline_entries=$(grep -c 'class="progress-timeline-entry' _site/progress.html || true)
test "$timeline_entries" -eq 12

timeline_links=$(grep -c 'class="progress-journal-link' _site/progress.html || true)
test "$timeline_links" -eq 12

for week in 1 2 3 4 5 6 7 8 9 10 11 12
do
  grep -q "journal/week-${week}/" _site/progress.html
done

for removed_home_copy in "Visualizations" "Latest progress" "Interactive Animint2" "homepopulationanimint"
do
  if grep -q "$removed_home_copy" _site/index.html; then
    echo "Removed homepage content is still present: ${removed_home_copy}" >&2
    exit 1
  fi
done

if grep -R -n --include='*.html' '/posts/week-' _site; then
  echo "Generated content still references a legacy weekly route." >&2
  exit 1
fi

if grep -E -R -n --include='*.html' 'class="week-nav-link"[^>]*>W(0?[1-9]|1[0-2])<' _site; then
  echo "Generated week navigation still contains an abbreviated label." >&2
  exit 1
fi

echo "Verified homepage contract, journal routes, redirects, labels, and canonical URL."
