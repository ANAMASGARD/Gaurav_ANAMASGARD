compact_animint_demo <- function() {
  data("worldPop", package = "animint2", envir = environment())

  bars <- animint2::ggplot() +
    animint2::geom_bar(
      animint2::aes(x = subcontinent, y = population),
      showSelected = "year",
      data = worldPop,
      stat = "identity",
      position = "identity",
      fill = "#2563eb"
    ) +
    animint2::make_text(worldPop, 1, 3e6, "year") +
    animint2::coord_flip() +
    animint2::theme_animint(width = 620, height = 360)

  animint2::animint(
    population = bars,
    time = list(variable = "year", ms = 1800),
    duration = list(year = 800),
    first = list(year = min(worldPop$year))
  )
}

linked_animint_demo <- function() {
  data("WorldBank", package = "animint2", envir = environment())

  available_countries <- sort(unique(stats::na.omit(WorldBank$country)))
  selected_countries <- utils::head(available_countries, 12)
  demo_data <- WorldBank[WorldBank$country %in% selected_countries, ]
  demo_data$Region <- sub(
    " (all income levels)",
    "",
    demo_data$region,
    fixed = TRUE
  )
  scatter_data <- demo_data[
    stats::complete.cases(
      demo_data[, c("fertility.rate", "life.expectancy", "population")]
    ),
  ]
  years <- unique(demo_data[, "year", drop = FALSE])

  time_series <- animint2::ggplot() +
    animint2::make_tallrect(demo_data, "year") +
    animint2::geom_line(
      animint2::aes(
        year,
        life.expectancy,
        group = country,
        colour = Region
      ),
      clickSelects = "country",
      data = demo_data,
      size = 3,
      alpha = 3 / 5
    ) +
    animint2::theme_animint(width = 500, height = 380) +
    animint2::guides(colour = "none")

  scatter <- animint2::ggplot() +
    animint2::geom_point(
      animint2::aes(
        fertility.rate,
        life.expectancy,
        key = country,
        colour = Region,
        size = population
      ),
      clickSelects = "country",
      showSelected = "year",
      data = scatter_data
    ) +
    animint2::geom_text(
      animint2::aes(
        fertility.rate,
        life.expectancy,
        key = country,
        label = country
      ),
      showSelected = c("country", "year"),
      data = scatter_data
    ) +
    animint2::geom_text(
      animint2::aes(5, 82, key = 1, label = paste("year =", year)),
      showSelected = "year",
      data = years
    ) +
    animint2::scale_size_animint(
      pixel.range = c(2, 18),
      breaks = 10^(4:9)
    ) +
    animint2::theme_animint(width = 500, height = 380)

  animint2::animint(
    timeseries = time_series,
    scatter = scatter,
    time = list(variable = "year", ms = 2200),
    duration = list(country = 700, year = 900),
    first = list(
      country = selected_countries[[1]],
      year = min(scatter_data$year)
    )
  )
}
