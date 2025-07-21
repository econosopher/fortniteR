# Test GT table creation with mock data
# This script demonstrates the GT table visualization without requiring API credentials

if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman")
}

pacman::p_load(
  tidyverse,
  gt,
  scales,
  glue
)

# Create mock data for top 10 islands
set.seed(42)

island_details <- tibble(
  title = c(
    "Zone Wars - Desert",
    "Box Fight Champions",
    "1v1 Build Battles",
    "Red vs Blue Team Rumble",
    "Zombie Survival Island",
    "Prop Hunt Paradise",
    "Racing Circuit Pro",
    "Hide and Seek Mall",
    "Tycoon Simulator",
    "Battle Royale Mini"
  ),
  code = paste0("XXXX-XXXX-", sample(1000:9999, 10)),
  creator_code = c("Creator1", "ProBuilder", "FNMaster", "TeamEpic", 
                   "ZombieKing", "PropMaster", "SpeedRacer", 
                   "HideExpert", "TycoonDev", "BRCreator"),
  category = sample(c("Combat", "Creative", "Racing", "Survival", "Social"), 10, replace = TRUE),
  total_uniquePlayers = sample(50000:500000, 10),
  total_plays = sample(100000:1000000, 10),
  avg_peakCCU = sample(500:5000, 10),
  avg_averageMinutesPerPlayer = runif(10, 15, 45),
  total_favorites = sample(1000:20000, 10),
  avg_d1_retention = runif(10, 0.15, 0.45),
  avg_d7_retention = runif(10, 0.05, 0.25)
) |>
  arrange(desc(total_uniquePlayers))

# Create GT table
gt_table <- island_details |>
  gt() |>
  tab_header(
    title = "Top 10 Fortnite Islands - Mock Performance Metrics",
    subtitle = glue("Mock data demonstration - {format(Sys.Date(), '%B %d, %Y')}")
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
      cell_fill(color = "#1e3a5f"),
      cell_text(color = "white", weight = "bold")
    ),
    locations = cells_column_labels()
  ) |>
  tab_style(
    style = cell_fill(color = "#f0f9ff"),
    locations = cells_body(
      rows = seq(1, 10, 2)
    )
  ) |>
  tab_style(
    style = list(
      cell_fill(color = "#ffd700"),
      cell_text(weight = "bold")
    ),
    locations = cells_body(
      columns = title,
      rows = 1
    )
  ) |>
  tab_style(
    style = list(
      cell_fill(color = "#c0c0c0"),
      cell_text(weight = "bold")
    ),
    locations = cells_body(
      columns = title,
      rows = 2
    )
  ) |>
  tab_style(
    style = list(
      cell_fill(color = "#cd7f32"),
      cell_text(weight = "bold")
    ),
    locations = cells_body(
      columns = title,
      rows = 3
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
  tab_source_note(
    source_note = "Note: This is mock data for demonstration purposes"
  ) |>
  tab_footnote(
    footnote = "CCU = Concurrent Users; D1/D7 = 1-day/7-day retention rates",
    locations = cells_column_labels(columns = c(avg_peakCCU, avg_d1_retention))
  ) |>
  tab_options(
    table.font.size = px(12),
    heading.title.font.size = px(24),
    heading.subtitle.font.size = px(16),
    column_labels.font.weight = "bold",
    table.width = pct(100)
  )

# Save the table as PNG only
dir.create("output", showWarnings = FALSE)
gtsave(gt_table, "output/mock_top_10_islands.png", vwidth = 1400, vheight = 600)

message("Mock GT table saved to output/mock_top_10_islands.png")

# Display the table
gt_table