<img src="package_logo.png" width="200" alt="fortniteR logo">

# fortniteR

R client for the Fortnite Ecosystem API, providing access to island metadata and engagement metrics.

## Installation

```r
# Install from GitHub
devtools::install_github("econosopher/fortniteR")

# Or using pacman
if (!require(pacman)) install.packages("pacman")
pacman::p_load_gh("econosopher/fortniteR")
```

## Usage

No authentication required! The Fortnite Ecosystem API is public.

### Fetching Island Data

```r
library(fortniteR)

# Get list of islands
islands <- get_islands(limit = 50)

# Get specific island metadata
island_info <- get_island_metadata("XXXX-XXXX-XXXX")

# Get island metrics
metrics <- get_island_metrics(
  code = "XXXX-XXXX-XXXX",
  start_date = Sys.Date() - 7,
  end_date = Sys.Date(),
  interval = "day"
)
```

### Creating Visualizations

See `scripts/top_islands_gt_table.R` for a complete example of fetching data and creating a GT table.

### Example Output

Here's an example of a GT table generated using mock data to demonstrate visualization capabilities:

![Top 10 Fortnite Islands Table](output/mock_top_10_islands.png)

*Note: This mock example shows hypothetical performance metrics. The actual API provides basic island information including name, code, creator, and play counts.*

### Fetching Real Island Data

The package includes a script (`scripts/pull_real_top_islands.R`) that demonstrates fetching real data from the Fortnite API:

```r
# Load packages using pacman
if (!require(pacman)) install.packages("pacman")
pacman::p_load(fortniteR, dplyr, gt, ggplot2)

# Fetch top islands from the API
top_islands <- get_islands(limit = 10)

# Create a GT table with the data
gt_table <- top_islands %>%
  select(island_code, island_name, description) %>%
  gt() %>%
  tab_header(
    title = "Featured Fortnite Creative Islands",
    subtitle = paste("Popular islands as of", Sys.Date())
  )
```

This script will:
- Fetch current island data from the Fortnite Ecosystem API
- Create a formatted GT table
- Generate a visualization chart
- Save outputs to the `output/` directory

## Features

- Fetch island listings with pagination
- Get detailed island metadata
- Retrieve engagement metrics (players, plays, retention, etc.)
- Support for different time intervals (day, hour, minute)
- Create beautiful GT tables with metrics
- No authentication required

## API Limitations

- Historical data limited to 7 days
- Only public/discoverable islands available
- Minimum 5 unique players required for data
- Some Epic games don't support favorites/recommendations