#!/usr/bin/env bash
set -euo pipefail

cutoff_sha="a112290eb5df72b60c4afd6c09eb1062d50bc44e"
postcutoff_sha="8f009edb9556e6acf10059d01a76d2d99a06b39c"
cutoff_source="${ANIMINT_CUTOFF_SOURCE:-/tmp/animint2-cutoff}"
postcutoff_source="${ANIMINT_POSTCUTOFF_SOURCE:-/tmp/animint2-postcutoff}"
cutoff_library="${ANIMINT_CUTOFF_LIB:-/tmp/animint2-lib-cutoff}"
postcutoff_library="${ANIMINT_POSTCUTOFF_LIB:-/tmp/animint2-lib-postcutoff}"
repository="https://github.com/animint/animint2.git"

prepare_source() {
  local source_path="$1"
  local revision="$2"

  if [ ! -d "$source_path/.git" ]; then
    git clone "$repository" "$source_path"
  fi

  git -C "$source_path" fetch origin "$revision"
  git -C "$source_path" checkout --detach "$revision"

  actual_revision="$(git -C "$source_path" rev-parse HEAD)"
  if [ "$actual_revision" != "$revision" ]; then
    echo "Expected $revision but found $actual_revision in $source_path" >&2
    exit 1
  fi
}

prepare_source "$cutoff_source" "$cutoff_sha"
prepare_source "$postcutoff_source" "$postcutoff_sha"

mkdir -p "$cutoff_library" "$postcutoff_library"
R_PROFILE_USER=/dev/null R CMD INSTALL --library="$cutoff_library" "$cutoff_source"
R_PROFILE_USER=/dev/null R CMD INSTALL --library="$postcutoff_library" "$postcutoff_source"

echo "Prepared exact cutoff and post-cutoff Animint2 environments."
