# Install necessary packages if you don't have them
# install.packages(c("tidyverse", "fitzR", "sf"))
library(tidyverse)
library(sf)
library(FITfileR)
library(R.utils)
library(ggplot2)
library(ggmap)

# Set the path to my downloaded Strava activities folder
activities_path <- "C:/Users/mwebe/OneDrive/GitProjects/mhweber.github.io/posts/2025-11-01-first-topic/strava_download/activities/"

setwd(activities_path)

gpx_files <- list.files(path = activities_path, pattern = "*.fit.gz", full.names = TRUE)

# Loop through each .gz file and decompress it
for (file_path in gpx_files) {
  gunzip(file_path, remove = FALSE)
}

# Optional: Verify that the .gz files are gone and uncompressed files exist
fit_files <- list.files(path = activities_path, full.names = TRUE)

process_fit_files <- function(file_path) {
  if (!file.exists(file_path)) {
    warning(paste("File not found:", file_path))
    return(NULL)
  }

  tryCatch({
    # Read the FIT file
    fit_file <- readFitFile(file_path)

    # Extract 'record' messages, which contain GPS data
    records_list <- records(fit_file)

    if (is.null(records_list) || (is.list(records_list) && length(records_list) == 0)) {
      message(paste("No 'record' messages found in", basename(file_path)))
      return(NULL)
    }

    # Combine potential multiple tibbles (due to different message definitions) into one
    # If it's a single tibble, it's put in a list for consistent processing
    if (is_tibble(records_list)) {
        combined_records <- records_list
    } else {
        combined_records <- bind_rows(records_list)
    }

    # Select key coordinate information and convert to a tibble
    coordinates_data <- combined_records %>%
      select(
        timestamp,
        position_lat,
        position_long,
        # Optional fields, include if they exist
        if ("enhanced_altitude" %in% names(combined_records)) "enhanced_altitude" else if ("altitude" %in% names(combined_records)) "altitude" else NULL,
        if ("distance" %in% names(combined_records)) "distance" else NULL
      ) %>%
      # Remove rows where location data is missing
      na.omit()

    return(coordinates_data)

  }, error = function(e) {
    warning(paste("Error processing file", file_path, ":", e$message))
    return(NULL)
  })
}

# Process all files (this can take a while if you have many activities)
all_data <- map_dfr(fit_files, process_fit_files)

# View the combined data
head(all_data)

# Truncate to local area
filtered_df <- all_data |> 
  filter(position_lat > 44.2 & position_lat < 44.9) |> 
  filter(position_long > -123.5 & position_long < -123.0)


# Bin the data (example uses 100 bins for lat/lon, adjust binwidth for desired resolution)
binned_data <- filtered_df %>%
  mutate(
    lon_bin = cut(position_long, breaks = 100),
    lat_bin = cut(position_lat, breaks = 100)
  ) %>%
  group_by(lon_bin, lat_bin) %>%
  summarise(count = n(), .groups = 'drop') %>%
  # Convert bin factors back to numeric midpoints for plotting
  mutate(
    lon_mid = as.numeric(sub(',.*', '', sub('\\(', '', lon_bin))) + (as.numeric(sub('.*,', '', sub('\\]', '', lon_bin))) - as.numeric(sub(',.*', '', sub('\\(', '', lon_bin))))/2,
    lat_mid = as.numeric(sub(',.*', '', sub('\\(', '', lat_bin))) + (as.numeric(sub('.*,', '', sub('\\]', '', lat_bin))) - as.numeric(sub(',.*', '', sub('\\(', '', lat_bin))))/2
  )

# Get the map tiles
map_bbox <-c(left = -123.5, bottom = 44.2, right = -123, top = 44.9)
base_map <- get_stadiamap(bbox = map_bbox, zoom = 12, maptype = "stamen_terrain_lines")

ggmap(base_map) +
  geom_tile(data=binned_data, aes(x = lon_mid, y = lat_mid, fill = count)) +
  scale_fill_gradientn(colors = c("blue", "green", "yellow", "red")) + # Customize color scale
  theme_minimal() +
  labs(title = "Strava Activity Density Heatmap", fill = "Activity Count") +
  coord_fixed(ratio = 1.3)
