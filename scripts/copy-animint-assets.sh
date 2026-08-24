#!/usr/bin/env bash
set -eu

for bundle in homepopulationanimint linkedworldbankanimint
do
  if ! test -f "${bundle}/plot.json"; then
    echo "Animint2 did not generate ${bundle}/plot.json." >&2
    exit 1
  fi
  rm -rf "_site/${bundle}"
  cp -R "$bundle" _site/
done

echo "Copied generated Animint2 bundles into _site/."
