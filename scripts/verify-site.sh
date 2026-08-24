#!/usr/bin/env bash
set -eu

for page in \
  _site/index.html \
  _site/journal.html \
  _site/progress.html \
  _site/visualizations.html \
  _site/about.html \
  _site/contact.html
do
  test -f "$page"
done

for week in 01 02 03 04 05 06 07 08 09 10 11 12
do
  test -f "_site/posts/week-${week}/index.html"
done

test -f _site/homepopulationanimint/plot.json
test -f _site/linkedworldbankanimint/plot.json
grep -q "homepopulationanimint" _site/index.html
grep -q "linkedworldbankanimint" _site/visualizations.html

echo "Verified pages, weekly routes, and static Animint2 assets."
