<img src="package_logo.png" width="200" alt="fortniteR logo">

# fortniteR

R client for the Fortnite Ecosystem API, providing access to island metadata and engagement metrics.

## Installation

```r
# Install from local directory
devtools::install(".")

# Or load for development
devtools::load_all(".")
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

Here's an example of a GT table generated using the package:

![Top 10 Fortnite Islands Table](output/mock_top_10_islands.png)

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