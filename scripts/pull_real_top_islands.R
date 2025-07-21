# Load packages using pacman
if (!require(pacman)) install.packages("pacman")
pacman::p_load(fortniteR, dplyr, gt, ggplot2)

# Create output directory if it doesn't exist
if (!dir.exists("output")) {
  dir.create("output")
}

# Get the featured islands from the public API
message("Fetching Fortnite Creative islands from API...")
top_islands <- get_islands(limit = 10)

# Display the data
print(top_islands)
message(paste("Found", nrow(top_islands), "featured islands"))

# Create a GT table
gt_table <- top_islands %>%
  select(island_code, island_name, description) %>%
  gt() %>%
  tab_header(
    title = "Featured Fortnite Creative Islands",
    subtitle = paste("Popular islands as of", Sys.Date())
  ) %>%
  cols_label(
    island_code = "Island Code",
    island_name = "Island Name", 
    description = "Description"
  ) %>%
  cols_width(
    island_code ~ px(120),
    island_name ~ px(200),
    description ~ px(400)
  ) %>%
  tab_options(
    table.font.size = px(14),
    heading.title.font.size = px(20),
    heading.subtitle.font.size = px(16)
  ) %>%
  opt_interactive()

# Save the table
gtsave(gt_table, "output/real_top_10_islands.html")

# Create a simple visualization showing island names
if (nrow(top_islands) > 0) {
  p <- top_islands %>%
    slice_head(n = min(10, nrow(top_islands))) %>%
    mutate(
      island_name = substr(island_name, 1, 30),  # Truncate long names
      island_name = factor(island_name, levels = rev(island_name))
    ) %>%
    ggplot(aes(x = island_name, y = seq_len(n()))) +
    geom_col(fill = "#0080FF") +
    coord_flip() +
    labs(
      title = "Featured Fortnite Creative Islands",
      subtitle = paste("Data as of", Sys.Date()),
      x = NULL,
      y = "Rank"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold"),
      plot.subtitle = element_text(size = 12),
      axis.text.y = element_text(size = 10),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank()
    ) +
    scale_y_reverse()
  
  # Save the plot
  ggsave(
    "output/real_top_10_islands_chart.png",
    plot = p,
    width = 10,
    height = 6,
    dpi = 300
  )
}

# Note: Additional discovery endpoints could be added in future versions

message("\nData fetched and visualizations created successfully!")
message("Files saved to output/ directory")