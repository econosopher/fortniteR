# Generate Top 10 Islands table from real API data
# This script fetches current island data and creates a GT table

# Load packages using pacman
if (!require(pacman)) install.packages("pacman")
pacman::p_load(devtools, dplyr, gt, scales)

# Load the fortniteR package from current directory
devtools::load_all(".")

# Create output directory if it doesn't exist
if (!dir.exists("output")) {
  dir.create("output")
}

# Fetch top 10 islands from the API
message("Fetching Top 10 Fortnite Creative islands from API...")
top_islands <- get_islands(limit = 10)

# Display what we got
message(paste("Found", nrow(top_islands), "islands"))

# Create a GT table with the real data
gt_table <- top_islands %>%
  select(island_code, island_name, creator_name, created_in, category) %>%
  gt() %>%
  tab_header(
    title = "Top 10 Fortnite Creative Islands",
    subtitle = paste("Current islands as of", format(Sys.Date(), '%B %d, %Y'))
  ) %>%
  cols_label(
    island_code = "Island Code",
    island_name = "Island Name",
    creator_name = "Creator",
    created_in = "Platform",
    category = "Category"
  ) %>%
  cols_width(
    island_code ~ px(140),
    island_name ~ px(280),
    creator_name ~ px(120),
    created_in ~ px(80),
    category ~ px(140)
  ) %>%
  tab_style(
    style = list(
      cell_fill(color = "#1e3a5f"),
      cell_text(color = "white", weight = "bold")
    ),
    locations = cells_column_labels()
  ) %>%
  tab_style(
    style = cell_fill(color = "#f0f9ff"),
    locations = cells_body(
      rows = seq(1, nrow(top_islands), 2)
    )
  ) %>%
  # Highlight top 3 islands
  tab_style(
    style = list(
      cell_fill(color = "#ffd700"),
      cell_text(weight = "bold")
    ),
    locations = cells_body(
      columns = island_name,
      rows = 1
    )
  ) %>%
  tab_style(
    style = list(
      cell_fill(color = "#c0c0c0"),
      cell_text(weight = "bold")
    ),
    locations = cells_body(
      columns = island_name,
      rows = 2
    )
  ) %>%
  tab_style(
    style = list(
      cell_fill(color = "#cd7f32"),
      cell_text(weight = "bold")
    ),
    locations = cells_body(
      columns = island_name,
      rows = 3
    )
  ) %>%
  tab_options(
    table.font.size = px(14),
    heading.title.font.size = px(24),
    heading.subtitle.font.size = px(16),
    column_labels.font.weight = "bold",
    table.width = pct(100)
  ) %>%
  tab_source_note(
    source_note = "Data from Fortnite Ecosystem API (https://api.fortnite.com/ecosystem/v1)"
  )

# Save the table as PNG only
gtsave(gt_table, "output/real_top_10_islands.png", vwidth = 1200, vheight = 600)

message("Real Top 10 islands GT table saved to output/real_top_10_islands.png")

# Display the table
gt_table