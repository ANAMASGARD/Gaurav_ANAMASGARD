#!/usr/bin/env Rscript

root <- normalizePath(".", mustWork = TRUE)
manifest <- utils::read.csv(
  file.path(root, "visualizations", "manifest.csv"),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

status <- system2(
  "quarto",
  c("render"),
  env = c("XDG_CACHE_HOME=/tmp/gaurav-journal-cache")
)
if (!identical(status, 0L)) stop("Quarto render failed", call. = FALSE)

required_assets <- c(
  "index.html",
  "animint.js",
  "animint.css",
  "animint-responsive.css",
  "animint-responsive.js",
  "plot.json"
)
for (row_number in seq_len(nrow(manifest))) {
  row <- manifest[row_number, ]
  source_bundle <- file.path(root, row$bundle)
  target_bundle <- file.path(root, "_site", row$bundle)
  dir.create(target_bundle, recursive = TRUE, showWarnings = FALSE)

  bundle_files <- list.files(source_bundle, recursive = TRUE, full.names = TRUE)
  if (!length(bundle_files)) stop("Empty Animint bundle: ", row$id, call. = FALSE)
  relative_files <- substring(bundle_files, nchar(source_bundle) + 2L)
  target_files <- file.path(target_bundle, relative_files)
  invisible(vapply(
    unique(dirname(target_files)),
    dir.create,
    logical(1),
    recursive = TRUE,
    showWarnings = FALSE
  ))
  copied <- file.copy(bundle_files, target_files, overwrite = TRUE)
  if (!all(copied)) stop("Failed to copy Animint bundle: ", row$id, call. = FALSE)

  missing <- required_assets[!file.exists(file.path(target_bundle, required_assets))]
  if (length(missing)) {
    stop(row$id, " missing rendered assets: ", paste(missing, collapse = ", "), call. = FALSE)
  }
}

verify_status <- system2(file.path(root, "scripts", "verify-site.sh"))
if (!identical(verify_status, 0L)) stop("Site verification failed", call. = FALSE)
message("Rendered Quarto and mirrored all expected Animint bundles into _site.")
