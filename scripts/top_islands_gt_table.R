# Load required libraries
if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman")
}

pacman::p_load(
  devtools,
  tidyverse,
  gt,
  scales,
  glue
)

# Load the package functions
devtools::load_all(".")

# No authentication required - the API is public!

# Fetch the first batch of islands
message("Fetching island data...")
islands <- get_islands(limit = 50)

# Get metrics for top 10 islands
message("Fetching metrics for top islands...")
top_10_codes <- islands$code[1:10]

# Get metadata and recent metrics for each island
island_details <- map_df(top_10_codes, function(code) {
  message(glue("Getting metrics for island: {code}"))
  
  # Get island metadata
  metadata <- get_island_metadata(code)
  
  # Get metrics for the last 7 days
  metrics <- get_island_metrics(
    code = code,
    start_date = Sys.Date() - 7,
    end_date = Sys.Date(),
    interval = "day"
  )
  
  # Aggregate metrics
  metrics_summary <- metrics |>
    group_by(metric_type) |>
    summarise(
      total = sum(value, na.rm = TRUE),
      avg = mean(value, na.rm = TRUE),
      .groups = "drop"
    ) |>
    pivot_wider(
      names_from = metric_type,
      values_from = c(total, avg)
    )
  
  # Get retention data if available
  retention_attr <- attr(metrics, "retention")
  avg_d1_retention <- NA_real_
  avg_d7_retention <- NA_real_
  
  if (!is.null(retention_attr) && nrow(retention_attr) > 0) {
    avg_d1_retention <- mean(retention_attr$d1_retention, na.rm = TRUE)
    avg_d7_retention <- mean(retention_attr$d7_retention, na.rm = TRUE)
  }
  
  # Combine island info with metrics
  tibble(
    code = code,
    title = metadata$title %||% NA_character_,
    creator_code = metadata$creatorCode %||% NA_character_,
    category = metadata$category %||% NA_character_,
    tags = paste(unlist(metadata$tags), collapse = ", ")
  ) |>
    bind_cols(metrics_summary) |>
    mutate(
      avg_d1_retention = avg_d1_retention,
      avg_d7_retention = avg_d7_retention
    )
})

# Create GT table
message("Creating GT table visualization...")

gt_table <- island_details |>
  select(
    title,
    code,
    creator_code,
    category,
    total_uniquePlayers,
    total_plays,
    avg_peakCCU,
    avg_averageMinutesPerPlayer,
    total_favorites,
    avg_d1_retention,
    avg_d7_retention
  ) |>
  gt() |>
  tab_header(
    title = "Top 10 Fortnite Islands - Weekly Performance Metrics",
    subtitle = glue("Data from {format(Sys.Date() - 7, '%B %d')} to {format(Sys.Date(), '%B %d, %Y')}")
  ) |>
  cols_label(
    title = "Island Name",
    code = "Island Code",
    creator_code = "Creator",
    category = "Category",
    total_uniquePlayers = "Total Players",
    total_plays = "Total Plays",
    avg_peakCCU = "Avg Peak CCU",
    avg_averageMinutesPerPlayer = "Avg Minutes/Player",
    total_favorites = "Total Favorites",
    avg_d1_retention = "D1 Retention",
    avg_d7_retention = "D7 Retention"
  ) |>
  fmt_number(
    columns = c(total_uniquePlayers, total_plays, total_favorites),
    decimals = 0,
    use_seps = TRUE
  ) |>
  fmt_number(
    columns = c(avg_peakCCU),
    decimals = 0
  ) |>
  fmt_number(
    columns = c(avg_averageMinutesPerPlayer),
    decimals = 1
  ) |>
  fmt_percent(
    columns = c(avg_d1_retention, avg_d7_retention),
    decimals = 1
  ) |>
  tab_style(
    style = list(
      cell_fill(color = "#f0f0f0"),
      cell_text(weight = "bold")
    ),
    locations = cells_column_labels()
  ) |>
  tab_style(
    style = cell_fill(color = "#e8f4f8"),
    locations = cells_body(
      rows = seq(1, 10, 2)
    )
  ) |>
  cols_align(
    align = "right",
    columns = where(is.numeric)
  ) |>
  cols_align(
    align = "left",
    columns = where(is.character)
  ) |>
  tab_options(
    table.font.size = px(12),
    heading.title.font.size = px(20),
    heading.subtitle.font.size = px(14),
    column_labels.font.weight = "bold"
  ) |>
  tab_footnote(
    footnote = "CCU = Concurrent Users; D1/D7 = 1-day/7-day retention rates",
    locations = cells_column_labels(columns = c(avg_peakCCU, avg_d1_retention))
  )

# Save the table
dir.create("output", showWarnings = FALSE)
gtsave(gt_table, "output/top_10_islands_metrics.html")
gtsave(gt_table, "output/top_10_islands_metrics.png", vwidth = 1200, vheight = 800)

message("GT table saved to output/top_10_islands_metrics.html and .png")

# Display the table
gt_table