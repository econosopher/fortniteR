#' Get list of Fortnite Creative islands
#'
#' @param limit Maximum number of results (default: 50)
#' @param offset Number of results to skip
#' @param order_by Field to order by ("plays", "lastPlayed", etc.)
#' @param order Sort order ("asc" or "desc")
#'
#' @return A tibble with island data
#' @export
#'
#' @examples
#' \dontrun{
#' islands <- get_islands(limit = 50)
#' }
get_islands <- function(limit = 50, offset = 0, order_by = "plays", order = "desc") {
  # Create request
  req <- fortnite_request("islands")
  
  # Add query parameters
  resp <- req |>
    httr2::req_url_query(
      limit = limit,
      offset = offset,
      orderBy = order_by,
      order = order
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  
  # Parse results
  if (length(resp$islands) == 0) {
    return(tibble::tibble())
  }
  
  islands_data <- resp$islands |>
    purrr::map_df(~ {
      tibble::tibble(
        island_code = .x$code %||% NA_character_,
        island_name = .x$name %||% NA_character_,
        description = .x$description %||% NA_character_,
        creator_name = .x$creatorName %||% NA_character_,
        is_featured = .x$isFeatured %||% FALSE,
        is_favorite = .x$isFavorite %||% FALSE,
        image_url = .x$imageUrl %||% NA_character_,
        total_plays = .x$totalPlays %||% NA_integer_,
        last_played = if (!is.null(.x$lastPlayed)) as.POSIXct(.x$lastPlayed) else NA
      )
    })
  
  return(islands_data)
}

#' Get specific island metadata
#'
#' @param code Island code (e.g., "XXXX-XXXX-XXXX")
#'
#' @return A list with detailed island metadata
#' @export
#'
#' @examples
#' \dontrun{
#' island <- get_island_metadata("1234-5678-9012")
#' }
get_island_metadata <- function(code) {
  # Create request
  req <- fortnite_request(paste0("islands/", code))
  
  # Make request
  resp <- req |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  
  return(resp)
}

#' Get island engagement metrics
#'
#' @param code Island code
#' @param start_date Start date for metrics (Date or character)
#' @param end_date End date for metrics (Date or character)
#' @param interval Time interval ("minute", "hour", "day")
#'
#' @return A tibble with engagement metrics
#' @export
#'
#' @examples
#' \dontrun{
#' metrics <- get_island_metrics(
#'   code = "1234-5678-9012",
#'   start_date = Sys.Date() - 7,
#'   end_date = Sys.Date(),
#'   interval = "day"
#' )
#' }
get_island_metrics <- function(code, start_date, end_date, interval = "day") {
  # Convert dates to ISO 8601 format
  if (inherits(start_date, "Date")) {
    start_date <- format(start_date, "%Y-%m-%dT00:00:00Z")
  }
  if (inherits(end_date, "Date")) {
    end_date <- format(end_date, "%Y-%m-%dT23:59:59Z")
  }
  
  # Create request
  req <- fortnite_request(paste0("islands/", code, "/metrics"))
  
  # Add query parameters
  resp <- req |>
    httr2::req_url_query(
      startDate = start_date,
      endDate = end_date,
      interval = interval
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  
  # Parse metrics
  if (length(resp$metrics) == 0) {
    return(tibble::tibble())
  }
  
  metrics_data <- resp$metrics |>
    purrr::map_df(~ {
      tibble::tibble(
        timestamp = as.POSIXct(.x$timestamp %||% NA_character_),
        unique_players = .x$uniquePlayers %||% NA_integer_,
        plays = .x$plays %||% NA_integer_,
        average_play_time_seconds = .x$averagePlayTimeSeconds %||% NA_real_,
        retention_1_day = .x$retention1Day %||% NA_real_,
        retention_7_days = .x$retention7Days %||% NA_real_,
        retention_30_days = .x$retention30Days %||% NA_real_
      )
    })
  
  return(metrics_data)
}

#' Helper function to handle NULL values
#' @noRd
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}