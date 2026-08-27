required <- c(
  "entry", "title", "date-start", "date-end", "status", "sprint",
  "pull-requests", "issues", "categories"
)
statuses <- c("Complete", "In Progress", "Blocked")

read_front_matter <- function(path) {
  lines <- readLines(path, warn = FALSE)
  fences <- which(trimws(lines) == "---")
  stopifnot(length(fences) >= 2L, fences[1] == 1L)
  yaml::yaml.load(paste(lines[(fences[1] + 1):(fences[2] - 1)], collapse = "\n"))
}

week_paths <- Sys.glob("journal/week-*/index.qmd")
phase_paths <- c(
  "journal/community-bonding/index.qmd",
  "journal/final-submission/index.qmd"
)
entry_paths <- c(phase_paths[1], week_paths, phase_paths[2])

stopifnot(length(week_paths) == 12L)
stopifnot(length(entry_paths) == 14L)
stopifnot(all(file.exists(entry_paths)))
stopifnot(!dir.exists("journal/pre-gsoc"))

entries <- lapply(entry_paths, read_front_matter)
for (i in seq_along(entries)) {
  missing <- setdiff(required, names(entries[[i]]))
  if (length(missing)) {
    stop(entry_paths[[i]], " is missing: ", paste(missing, collapse = ", "))
  }
  if (!entries[[i]]$status %in% statuses) {
    stop(entry_paths[[i]], " has an invalid status")
  }
}

week_entries <- lapply(week_paths, read_front_matter)
weeks <- vapply(week_entries, function(entry) as.integer(entry$week), integer(1))
stopifnot(identical(sort(weeks), 1:12))

expected_dates <- list(
  `1` = c("2026-05-25", "2026-05-31"),
  `2` = c("2026-06-01", "2026-06-07"),
  `3` = c("2026-06-08", "2026-06-14"),
  `4` = c("2026-06-15", "2026-06-21"),
  `5` = c("2026-06-22", "2026-06-28"),
  `6` = c("2026-06-29", "2026-07-05"),
  `7` = c("2026-07-06", "2026-07-12"),
  `8` = c("2026-07-13", "2026-07-19"),
  `9` = c("2026-07-20", "2026-07-26"),
  `10` = c("2026-07-27", "2026-08-02"),
  `11` = c("2026-08-03", "2026-08-09"),
  `12` = c("2026-08-10", "2026-08-16")
)
for (entry in week_entries) {
  expected <- expected_dates[[as.character(entry$week)]]
  actual <- c(as.character(entry$`date-start`), as.character(entry$`date-end`))
  if (!identical(actual, expected)) {
    stop("Week ", entry$week, " has incorrect dates: ", paste(actual, collapse = " to "))
  }
}

community <- read_front_matter(phase_paths[1])
final <- read_front_matter(phase_paths[2])
stopifnot(
  identical(as.character(community$`date-start`), "2026-05-01"),
  identical(as.character(community$`date-end`), "2026-05-24"),
  identical(as.character(final$`date-start`), "2026-08-17"),
  identical(as.character(final$`date-end`), "2026-08-24")
)

sections <- c(
  "Outcome", "What I Did", "Learnings", "Challenges / Notes",
  "Next Week Targets", "Demo / Media", "Evidence and Links"
)

shared_week_one_path <- "journal/_includes/week-1-body.qmd"
stopifnot(file.exists(shared_week_one_path))
shared_week_one <- readLines(shared_week_one_path, warn = FALSE)

for (path in entry_paths) {
  lines <- readLines(path, warn = FALSE)
  if (identical(path, "journal/week-1/index.qmd")) {
    lines <- c(lines, shared_week_one)
  }
  for (section in sections) {
    heading <- paste0("## ", section)
    if (!heading %in% lines) stop(path, " is missing section: ", section)
  }
}

journal_home <- paste(readLines("journal/index.qmd", warn = FALSE), collapse = "\n")
week_one <- paste(readLines("journal/week-1/index.qmd", warn = FALSE), collapse = "\n")
stopifnot(
  grepl("_includes/week-nav.html", journal_home, fixed = TRUE),
  grepl("_includes/week-1-body.qmd", journal_home, fixed = TRUE),
  grepl("../_includes/week-1-body.qmd", week_one, fixed = TRUE),
  !grepl("Where I was when GSoC started", journal_home, fixed = TRUE),
  !grepl("journey-jump-select", journal_home, fixed = TRUE)
)

progress <- paste(readLines("progress.qmd", warn = FALSE), collapse = "\n")
stopifnot(length(gregexpr("progress-timeline-entry", progress, fixed = TRUE)[[1]]) == 14L)
stopifnot(length(gregexpr("progress-journal-link", progress, fixed = TRUE)[[1]]) == 14L)

source_files <- c(
  "index.qmd", "progress.qmd", "journal/index.qmd", entry_paths,
  "journal/_includes/week-nav.html", shared_week_one_path
)
placeholder_pattern <- "UPDATE PENDING|Schedule pending|Reserved for verified|Add Week [0-9]+ title|`PLANNED`"
for (path in source_files) {
  text <- paste(readLines(path, warn = FALSE), collapse = "\n")
  if (grepl(placeholder_pattern, text, ignore.case = TRUE)) {
    stop(path, " still contains placeholder content")
  }
}

cat("Validated the shared Week 1 Journal alias, 14 official-program entries, exact dates, section contract, and Progress timeline.\n")
