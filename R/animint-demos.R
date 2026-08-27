gsoc_legend_optout_demo <- function() {
  legend_data <- data.frame(
    x = rep(1:5, 2),
    y = c(1.0, 1.7, 2.2, 3.1, 4.0, 1.4, 2.0, 2.8, 3.4, 4.5),
    comparison = rep(c("control", "treatment"), each = 5)
  )

  default_plot <- animint2::ggplot(
    legend_data,
    animint2::aes(x, y, colour = comparison)
  ) +
    animint2::geom_line(size = 3) +
    animint2::geom_point(size = 5) +
    animint2::ggtitle("Default legend behavior") +
    animint2::xlab("Click a legend entry") +
    animint2::ylab("Selected series remains") +
    animint2::theme_animint(width = 760, height = 420, last_in_row = TRUE)

  opted_out_plot <- animint2::ggplot(
    legend_data,
    animint2::aes(x, y, colour = comparison)
  ) +
    animint2::geom_line(showSelected = character(), size = 3) +
    animint2::geom_point(showSelected = character(), size = 5) +
    animint2::ggtitle("PR #292 opt-out behavior") +
    animint2::xlab("Legend remains clickable") +
    animint2::ylab("Both series remain visible") +
    animint2::theme_animint(width = 760, height = 420, last_in_row = TRUE)

  animint2::animint(
    default = default_plot,
    optedout = opted_out_plot,
    selector.types = list(comparison = "single"),
    first = list(comparison = "control")
  )
}

gsoc_showselected_legend_demo <- function() {
  data("WorldBank", package = "animint2", envir = environment())
  countries <- c("Canada", "France", "India", "Japan", "Mexico", "United States")
  years <- seq(1960, 2010, by = 10)
  demo_data <- WorldBank[
    WorldBank$country %in% countries & WorldBank$year %in% years,
  ]
  demo_data <- demo_data[stats::complete.cases(
    demo_data[, c("fertility.rate", "life.expectancy", "population")]
  ), ]

  scatter <- animint2::ggplot() +
    animint2::geom_point(
      animint2::aes(
        fertility.rate,
        life.expectancy,
        colour = region,
        size = population,
        key = country
      ),
      showSelected = "year",
      showSelected.legend = FALSE,
      clickSelects = "country",
      data = demo_data
    ) +
    animint2::geom_text(
      animint2::aes(
        fertility.rate,
        life.expectancy,
        label = country,
        key = country
      ),
      showSelected = c("year", "country"),
      data = demo_data
    ) +
    animint2::scale_size_animint(pixel.range = c(3, 18)) +
    animint2::ggtitle("Year filtering without region injection") +
    animint2::xlab("Fertility rate") +
    animint2::ylab("Life expectancy") +
    animint2::theme_animint(width = 760, height = 520, last_in_row = TRUE)

  year_selector <- animint2::ggplot() +
    animint2::make_tallrect(demo_data, "year") +
    animint2::geom_line(
      animint2::aes(year, life.expectancy, group = country, colour = region),
      clickSelects = "country",
      data = demo_data,
      alpha = 0.75
    ) +
    animint2::ggtitle("Select a year") +
    animint2::xlab("Year") +
    animint2::ylab("Life expectancy") +
    animint2::theme_animint(width = 760, height = 360, last_in_row = TRUE) +
    animint2::guides(colour = "none")

  animint2::animint(
    scatter = scatter,
    timeline = year_selector,
    selector.types = list(year = "single", country = "multiple"),
    first = list(year = min(demo_data$year), country = c("Canada", "India", "Japan")),
    duration = list(year = 650)
  )
}

gsoc_panel_margin_demo <- function() {
  margin_plot <- function(lines, last_in_row = FALSE) {
    animint2::ggplot() +
      animint2::geom_point(
        animint2::aes(Sepal.Width, Sepal.Length, colour = Species),
        data = iris,
        size = 3
      ) +
      animint2::facet_wrap(~Species, nrow = 1) +
      animint2::theme_bw() +
      animint2::theme(panel.margin = grid::unit(lines, "lines")) +
      animint2::theme_animint(width = 760, height = 360, last_in_row = TRUE) +
      animint2::ggtitle(sprintf("panel.margin = %s line%s", lines, if (lines == 1) "" else "s")) +
      animint2::guides(colour = "none")
  }

  animint2::animint(
    zero = margin_plot(0),
    one = margin_plot(1),
    two = margin_plot(2)
  )
}

gsoc_multiline_demo <- function() {
  label_data <- data.frame(
    x = c(1.4, 2.6, 3.8),
    y = c(2.2, 3.6, 2.8),
    label_y = c(2.45, 3.85, 3.05),
    group = c("Compiler", "Renderer", "Tests"),
    label = c("Compiler\nconversion", "SVG\nline layout", "Browser\ncoverage")
  )

  feature_plot <- animint2::ggplot(
    label_data,
    animint2::aes(x, y, colour = group)
  ) +
    animint2::geom_point(
      animint2::aes(key = group, colour = group),
      clickSelects = "group",
      size = 9
    ) +
    animint2::geom_text(
      animint2::aes(y = label_y, label = label, key = group, colour = group),
      clickSelects = "group",
      showSelected = character(),
      vjust = 0,
      size = 5
    ) +
    animint2::scale_color_discrete(name = "Feature\nworkstream") +
    animint2::ggtitle("Multi-line text in Animint2\nMerged in PR #261") +
    animint2::xlab("Interactive labels\nclick a point or legend entry") +
    animint2::ylab("Renderer output\nwith measured spacing") +
    animint2::theme_animint(width = 760, height = 620, last_in_row = TRUE) +
    animint2::theme(text = animint2::element_text(size = 17))

  animint2::animint(
    multiline = feature_plot,
    selector.types = list(group = "single"),
    first = list(group = "Renderer")
  )
}
