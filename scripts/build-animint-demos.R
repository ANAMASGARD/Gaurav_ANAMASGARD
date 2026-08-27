#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
root <- normalizePath(if (length(args)) args[[1]] else ".", mustWork = TRUE)
manifest_path <- file.path(root, "visualizations", "manifest.csv")
manifest <- utils::read.csv(
  manifest_path,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

required_columns <- c("id", "profile", "sha", "status", "route", "bundle", "function")
if (!identical(names(manifest), required_columns)) {
  stop("Unexpected visualization manifest columns", call. = FALSE)
}

profile_config <- list(
  cutoff = list(
    library = Sys.getenv("ANIMINT_CUTOFF_LIB", "/tmp/animint2-lib-cutoff"),
    source = Sys.getenv("ANIMINT_CUTOFF_SOURCE", "/tmp/animint2-cutoff")
  ),
  postcutoff = list(
    library = Sys.getenv("ANIMINT_POSTCUTOFF_LIB", "/tmp/animint2-lib-postcutoff"),
    source = Sys.getenv("ANIMINT_POSTCUTOFF_SOURCE", "/tmp/animint2-postcutoff")
  )
)

git_head <- function(path) {
  output <- system2("git", c("-C", shQuote(path), "rev-parse", "HEAD"), stdout = TRUE)
  if (!length(output)) stop("Unable to read source revision: ", path, call. = FALSE)
  trimws(output[[1]])
}

source(file.path(root, "R", "animint-demos.R"), local = .GlobalEnv)

for (row_number in seq_len(nrow(manifest))) {
  row <- manifest[row_number, ]
  config <- profile_config[[row$profile]]
  if (is.null(config)) stop("Unknown profile: ", row$profile, call. = FALSE)
  if (!dir.exists(config$library)) stop("Missing exact library: ", config$library, call. = FALSE)
  if (!dir.exists(config$source)) stop("Missing exact source: ", config$source, call. = FALSE)

  actual_sha <- git_head(config$source)
  if (!identical(actual_sha, row$sha)) {
    stop(row$id, " expected ", row$sha, " but source is ", actual_sha, call. = FALSE)
  }

  .libPaths(unique(c(config$library, .libPaths())))
  if ("animint2" %in% loadedNamespaces()) unloadNamespace("animint2")
  loadNamespace("animint2", lib.loc = config$library)

  demo_function <- get(row[["function"]], mode = "function", inherits = TRUE)
  visualization <- demo_function()
  bundle_path <- file.path(root, row$bundle)
  animint2::animint2dir(visualization, bundle_path, open.browser = FALSE)

  responsive_assets <- c("animint-responsive.css", "animint-responsive.js")
  copied <- file.copy(
    file.path(root, "visualizations", responsive_assets),
    file.path(bundle_path, responsive_assets),
    overwrite = TRUE
  )
  if (!all(copied)) stop(row$id, " failed to copy responsive assets", call. = FALSE)

  index_path <- file.path(bundle_path, "index.html")
  index_lines <- readLines(index_path, warn = FALSE)
  index_lines <- index_lines[
    !grepl("animint-responsive.css", index_lines, fixed = TRUE) &
      !grepl("animint-responsive.js", index_lines, fixed = TRUE)
  ]
  head_close <- which(grepl("</head>", index_lines, fixed = TRUE))[[1]]
  responsive_tags <- c(
    '    <link rel="stylesheet" type="text/css" href="animint-responsive.css" />',
    '    <script type="text/javascript" src="animint-responsive.js"></script>'
  )
  index_lines <- append(index_lines, responsive_tags, after = head_close - 1L)
  writeLines(index_lines, index_path, useBytes = TRUE)

  required_assets <- c(
    "index.html",
    "animint.js",
    "animint.css",
    "animint-responsive.css",
    "animint-responsive.js",
    "plot.json"
  )
  missing_assets <- required_assets[!file.exists(file.path(bundle_path, required_assets))]
  if (length(missing_assets)) {
    stop(row$id, " missing assets: ", paste(missing_assets, collapse = ", "), call. = FALSE)
  }
  message("Built ", row$id, " at ", row$sha)
}

message("Built and validated ", nrow(manifest), " historically pinned Animint bundles.")
