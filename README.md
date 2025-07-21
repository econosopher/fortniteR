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

# Get island metrics (plays, retention, etc.)
metrics <- get_island_metrics(
  code = "XXXX-XXXX-XXXX",
  start_date = Sys.Date() - 7,
  end_date = Sys.Date(),
  interval = "day"  # Options: "minute", "hour", "day"
)
```

### Creating Visualizations

See `scripts/top_islands_gt_table.R` for a complete example of fetching data and creating a GT table.

### Example Output

Here's an example of a GT table generated using real data from the Fortnite Ecosystem API:

![Top 10 Fortnite Islands Table](output/real_top_10_islands.png)

*This table shows actual islands retrieved from the API, displaying island codes, names, creators, platforms (UEFN/FNC), and categories.*

### Fetching Real Island Data

The package includes scripts that demonstrate fetching real data from the Fortnite API:
- `scripts/generate_real_top_islands.R` - Creates the GT table shown above with current island data
- `scripts/pull_real_top_islands.R` - Fetches islands and creates various visualizations

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

## API Endpoints

- `/islands` - Returns basic island metadata (code, name, creator, platform, tags)
- `/islands/{code}` - Returns detailed metadata for a specific island
- `/islands/{code}/metrics` - Returns engagement metrics (plays, retention, etc.)

## API Limitations

- Historical metrics data limited to 7 days
- Only public/discoverable islands available
- Minimum 5 unique players required for metrics data
- Some Epic games don't support favorites/recommendations