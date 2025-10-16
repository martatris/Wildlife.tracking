library(dplyr)
library(ggplot2)
library(lubridate)
library(leaflet)
library(geosphere)
library(skimr)

# ===============================================================
# 🐾 Wildlife GPS Tracking Data Analysis (EDA + Clustering + ARIMA)
# ===============================================================

# 1️⃣ Install and load necessary packages
required_packages <- c("dplyr", "ggplot2", "leaflet", "lubridate", "geosphere", 
                       "forecast", "cluster", "factoextra", "tidyr")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

lapply(required_packages, library, character.only = TRUE)

# 2️⃣ Import data (make sure your working directory points to where the file is)
# Example: setwd("~/Desktop")
data <- read.csv("migration_original.csv")

# 3️⃣ Inspect structure
cat("✅ Data imported successfully\n")
cat("Columns detected:\n")
print(colnames(data))

# 4️⃣ Rename columns to simpler names
data <- data %>%
  rename(
    animal_id = `individual.local.identifier`,
    latitude = `location.lat`,
    longitude = `location.long`,
    timestamp = `timestamp`
  )

# 5️⃣ Convert and clean data
data <- data %>%
  mutate(
    timestamp = ymd_hms(timestamp, tz = "UTC"),
    latitude = as.numeric(latitude),
    longitude = as.numeric(longitude)
  ) %>%
  filter(!is.na(latitude), !is.na(longitude), !is.na(timestamp))

cat("Number of records after cleaning:", nrow(data), "\n")

# 6️⃣ Exploratory Data Analysis
cat("\n📈 Basic Summary:\n")
summary(data)

cat("\nUnique Animals Tracked:", length(unique(data$animal_id)), "\n")

# Record count per animal
record_counts <- data %>%
  group_by(animal_id) %>%
  summarise(records = n()) %>%
  arrange(desc(records))
print(record_counts)

# 7️⃣ Time Range
cat("\n⏳ Time range across all data:\n")
print(range(data$timestamp))

# 8️⃣ Daily record counts visualization
data %>%
  mutate(date = as.Date(timestamp)) %>%
  group_by(animal_id, date) %>%
  summarise(records = n(), .groups = "drop") %>%
  ggplot(aes(x = date, y = records, color = animal_id)) +
  geom_line(linewidth = 1.1) +
  theme_minimal() +
  labs(title = "Daily GPS Record Counts per Animal",
       x = "Date", y = "Record Count")

# 9️⃣ Calculate distance and speed
data <- data %>%
  arrange(animal_id, timestamp) %>%
  group_by(animal_id) %>%
  mutate(
    prev_lat = lag(latitude),
    prev_lon = lag(longitude),
    time_diff_hr = as.numeric(difftime(timestamp, lag(timestamp), units = "hours")),
    distance_m = distHaversine(cbind(longitude, latitude),
                               cbind(prev_lon, prev_lat)),
    speed_kmh = (distance_m / 1000) / time_diff_hr
  ) %>%
  ungroup() %>%
  mutate(speed_kmh = ifelse(speed_kmh > 80, NA, speed_kmh))

# 10️⃣ Speed distribution plot
ggplot(data, aes(x = speed_kmh, fill = animal_id)) +
  geom_histogram(bins = 40, alpha = 0.7, position = "identity") +
  theme_minimal() +
  labs(title = "Distribution of Movement Speeds",
       x = "Speed (km/h)", y = "Frequency")

# 11️⃣ Daily distance summary
daily_distance <- data %>%
  group_by(animal_id, date = as.Date(timestamp)) %>%
  summarise(total_km = sum(distance_m, na.rm = TRUE) / 1000, .groups = "drop")

ggplot(daily_distance, aes(x = date, y = total_km, color = animal_id)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2) +
  theme_minimal() +
  labs(title = "Daily Distance Traveled per Animal",
       x = "Date", y = "Distance (km)")

# 12️⃣ Interactive Map of Tracks
leaflet(data) %>%
  addTiles() %>%
  addCircleMarkers(
    lng = ~longitude, lat = ~latitude,
    color = ~factor(animal_id),
    popup = ~paste("<b>Animal:</b>", animal_id,
                   "<br><b>Time:</b>", timestamp,
                   "<br><b>Speed:</b>", round(speed_kmh, 2), "km/h"),
    radius = 3, opacity = 0.8, fillOpacity = 0.7
  ) %>%
  addLegend("bottomright", title = "Animal ID",
            colors = rainbow(length(unique(data$animal_id))),
            labels = unique(data$animal_id))

# 13️⃣ K-Means Clustering (Habitat Zone Detection)
# Choose one animal for demonstration (highest record count)
top_animal <- record_counts$animal_id[1]
cat("Top tracked animal:", top_animal, "\n")

subset_data <- data %>% filter(animal_id == top_animal)

set.seed(42)
k_clusters <- 3
kmeans_result <- kmeans(subset_data[, c("longitude", "latitude")], centers = k_clusters, nstart = 10)
subset_data$cluster <- as.factor(kmeans_result$cluster)

ggplot(subset_data, aes(x = longitude, y = latitude, color = cluster)) +
  geom_point(size = 2) +
  theme_minimal() +
  labs(title = paste("Habitat Clusters for", top_animal),
       x = "Longitude", y = "Latitude")

# 14️⃣ ARIMA Forecasting (Next 24 Hours)
# Aggregate hourly positions for the top animal
time_series <- subset_data %>%
  group_by(hour = floor_date(timestamp, "hour")) %>%
  summarise(lat = mean(latitude, na.rm = TRUE),
            lon = mean(longitude, na.rm = TRUE))

# Fit ARIMA models for latitude and longitude
lat_model <- auto.arima(time_series$lat)
lon_model <- auto.arima(time_series$lon)

lat_forecast <- forecast(lat_model, h = 24)
lon_forecast <- forecast(lon_model, h = 24)

# Combine forecasts
forecast_data <- data.frame(
  hour = seq(max(time_series$hour) + hours(1), by = "hour", length.out = 24),
  pred_latitude = as.numeric(lat_forecast$mean),
  pred_longitude = as.numeric(lon_forecast$mean)
)

cat("\n📅 24-Hour Forecast for", top_animal, ":\n")
print(forecast_data)

# 15️⃣ Plot Forecast Results
ggplot() +
  geom_point(data = time_series, aes(x = lon, y = lat), color = "blue", alpha = 0.6) +
  geom_point(data = forecast_data, aes(x = pred_longitude, y = pred_latitude), color = "red", size = 2) +
  theme_minimal() +
  labs(title = paste("ARIMA Forecast of Movement -", top_animal),
       x = "Longitude", y = "Latitude",
       caption = "Blue = historical | Red = forecast")

# 16️⃣ Save outputs
write.csv(data, "wildlife_cleaned.csv", row.names = FALSE)
write.csv(daily_distance, "daily_distance_summary.csv", row.names = FALSE)
write.csv(forecast_data, "forecast_results.csv", row.names = FALSE)

cat("✅ Analysis complete. Files saved in your working directory.\n")