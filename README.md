# Wildlife Tracking Data Analysis

A comprehensive R-based project for analyzing **wildlife GPS tracking data**, performing **Exploratory Data Analysis (EDA)**, **spatial clustering**, and **ARIMA forecasting** of animal movements.  
This project uses **`ggplot2`**, **`dplyr`**, **`leaflet`**, and **`forecast`** to visualize animal migration patterns and predict future positions.

---

## Project Structure
```
├── migration_original.csv        # Input wildlife GPS data
├── wildlife_analysis.R           # Main analysis script
├── arima_forecast.png            # Saved ARIMA forecast plot
├── wildlife_cleaned.csv          # Cleaned dataset
├── daily_distance_summary.csv    # Daily distance summary
├── forecast_results.csv          # Forecasted coordinates
└── README.md                     # Project documentation
```

---

## Objectives
- Clean and process raw wildlife GPS data  
- Explore animal movement patterns through EDA  
- Cluster geographic coordinates to identify key habitat zones  
- Forecast animal movement trends using ARIMA time series models  
- Create interactive maps and visual summaries

---

## Requirements

Make sure you have **R (≥ 4.0)** installed.  
You’ll also need the following R packages:

```r
install.packages(c(
  "dplyr", "ggplot2", "leaflet", "lubridate",
  "geosphere", "forecast", "cluster", "factoextra", "tidyr"
))
```

---

## How to Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/wildlife-tracking-analysis.git
   cd wildlife-tracking-analysis
   ```

2. **Open the project in R or RStudio**

3. **Place your dataset**
   Save your CSV file (e.g. `migration_original.csv`) in the same folder as the script.

4. **Run the analysis**
   In R or RStudio:
   ```r
   source("wildlife_analysis.R")
   ```

5. **Check outputs**
   After execution, you’ll find:
   - `wildlife_cleaned.csv` — cleaned and processed dataset  
   - `daily_distance_summary.csv` — daily travel summaries  
   - `forecast_results.csv` — ARIMA 24-hour forecast results  
   - `arima_forecast.png` — saved movement forecast plot  

---

## Key Features

### Data Cleaning
- Handles missing coordinates and timestamps  
- Normalizes column names for consistency  

### Exploratory Data Analysis (EDA)
- Summary statistics of movement data  
- Daily activity trends per animal  
- Speed and distance distribution plots  

### Spatial Clustering
- Uses **K-Means clustering** to identify core habitat zones  
- Visualized with color-coded scatter plots and interactive maps  

### ARIMA Forecasting
- Builds time-series models for latitude and longitude  
- Predicts the **next 24 hours** of animal movement  
- Automatically saves the forecast visualization as `arima_forecast.png`  

---

## Interactive Map
The script creates an interactive **Leaflet** map displaying:
- Animal GPS positions  
- Color-coded by individual ID  
- Hover popups showing timestamp and movement speed  

---

## Example Output (ARIMA Forecast)
![ARIMA Forecast Example](arima_forecast.png)

> Blue points = historical movement  
> Red points = forecasted movement (next 24 hours)

---

## Customization

You can easily modify:
- The **number of clusters** (`k_clusters` in the script)
- The **forecast horizon** (currently 24 hours)
- The **top tracked animal** for focused analysis

---

## Acknowledgments
- Movebank Data Repository for wildlife tracking datasets  
- R community for packages that power this analysis (`ggplot2`, `forecast`, `leaflet`, etc.)  
- Contributors supporting open science in wildlife research



