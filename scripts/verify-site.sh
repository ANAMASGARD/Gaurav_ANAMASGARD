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
  _site/visualizations.html \
  _site/about.html \
  _site/contact.html
do
  require_file "$page"
done

require_file _site/_redirects
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

for bundle in homepopulationanimint linkedworldbankanimint
do
  require_file "_site/${bundle}/plot.json"
  require_file "_site/${bundle}/animint.css"
  require_file "_site/${bundle}/animint.js"
  if ! find "_site/${bundle}" -maxdepth 1 -name '*.tsv' -print -quit | grep -q .; then
    echo "Missing Animint2 data in _site/${bundle}." >&2
    exit 1
  fi
done

grep -q "homepopulationanimint" _site/index.html
grep -q "linkedworldbankanimint" _site/visualizations.html
grep -q "GAURAV CHAUDHARY" _site/index.html
grep -q 'rel="canonical" href="https://gaurav-anamasgard.netlify.app/journal/"' _site/journal/week-1/index.html

if grep -R -n --include='*.html' '/posts/week-' _site; then
  echo "Generated content still references a legacy weekly route." >&2
  exit 1
fi

if grep -E -R -n --include='*.html' '>W(0?[1-9]|1[0-2])<' _site; then
  echo "Generated content still contains an abbreviated week label." >&2
  exit 1
fi

echo "Verified journal routes, redirects, labels, canonical URL, and static Animint2 assets."
