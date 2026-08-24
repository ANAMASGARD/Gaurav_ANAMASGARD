required <- c(
  "week", "title", "date-start", "date-end", "status", "sprint",
  "pull-requests", "issues", "categories"
)
statuses <- c("Planned", "In Progress", "Complete", "Blocked")
paths <- Sys.glob("journal/week-*/index.qmd")

stopifnot(length(paths) == 12L)

read_front_matter <- function(path) {
  lines <- readLines(path, warn = FALSE)
  fences <- which(trimws(lines) == "---")
  stopifnot(length(fences) >= 2L, fences[1] == 1L)
  yaml::yaml.load(paste(lines[(fences[1] + 1):(fences[2] - 1)], collapse = "\n"))
}

entries <- lapply(paths, read_front_matter)
for (i in seq_along(entries)) {
  missing <- setdiff(required, names(entries[[i]]))
  if (length(missing)) stop(paths[[i]], " is missing: ", paste(missing, collapse = ", "))
  if (!entries[[i]]$status %in% statuses) stop(paths[[i]], " has an invalid status")
}

weeks <- vapply(entries, function(entry) as.integer(entry$week), integer(1))
stopifnot(identical(sort(weeks), 1:12))

sections <- c(
  "Outcome", "What I Did", "Learnings", "Confusions / Issues",
  "Next Week Targets", "Demo / Media", "Links"
)
week_one <- readLines("journal/_includes/week-1-body.qmd", warn = FALSE)
planned <- readLines("journal/_includes/planned-week.qmd", warn = FALSE)
for (section in sections) {
  heading <- paste0("## ", section)
  stopifnot(heading %in% week_one, heading %in% planned)
}

journal_home <- read_front_matter("journal/index.qmd")
missing <- setdiff(required, names(journal_home))
if (length(missing)) stop("journal/index.qmd is missing: ", paste(missing, collapse = ", "))
stopifnot(as.integer(journal_home$week) == 1L)

cat("Validated 12 weekly entries and the shared section contract.\n")
