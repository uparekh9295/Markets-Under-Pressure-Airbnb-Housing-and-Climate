# Markets Under Pressure: Airbnb, Housing and Climate Vulnerability Across U.S. Cities

## Overview

This project investigates how Airbnb activity intersects with climate vulnerability across major U.S. cities. Using Airbnb listing and calendar data, FEMA National Risk Index data, Google Trends search activity, and U.S. Census data, I analyzed how short-term rental markets operate within environmentally exposed urban landscapes.

The project combines:
- Spatial analysis
- Climate risk mapping
- Regression modeling
- Clustering analysis
- Time-series forecasting
- Urban comparative analysis

### Cities Analyzed
- Los Angeles
- New York
- Miami
- Chicago
- Phoenix
- Denver
- New Orleans

---

# Research Question

How does climate risk relate to Airbnb density, tourism activity, and short-term rental behavior across U.S. cities?

## Null Hypothesis (H₀)

Climate risk has no significant relationship with Airbnb density, pricing, occupancy, or tourism search behavior across cities and census tracts.

## Alternative Hypothesis (H₁)

Higher climate risk is associated with measurable differences in Airbnb density, pricing, occupancy, and tourism search behavior across U.S. cities and neighborhoods.

---

# Why This Matters

Tourism economies increasingly overlap with environmentally vulnerable urban regions. Cities continue to expand tourism infrastructure and short-term rental activity in places exposed to flooding, heat, hurricanes, drought, and wildfire.

This project explores:
- Whether climate risk already affects Airbnb market behavior
- How tourism demand changes across risky geographies
- How environmental exposure differs across urban tourism systems
- Whether vulnerable places continue attracting investment and visitors despite increasing climate stress

The project treats Airbnb not only as a tourism platform, but also as a spatial indicator of urban economic behavior under climate pressure.

---

# Data Sources

## Airbnb Data

Airbnb listing, review, and calendar data were downloaded from:

- AirROI Data Portal  
  https://www.airroi.com/data-portal/regions/north-america

The datasets include:
- Listing characteristics
- Pricing
- Occupancy
- Reviews
- Future availability
- Calendar activity

Because AirROI uses rolling historical and future calendar windows, downloading the data at a different time may produce slightly different results from those shown in this repository.

---

## Climate Risk Data

- FEMA National Risk Index (NRI)
- Hazard-specific variables:
  - Wildfire
  - Coastal flooding
  - Inland flooding
  - Hurricanes
  - Heat waves
  - Drought

https://hazards.fema.gov/nri/

---

## Census Data

American Community Survey (ACS) 5-Year Estimates:
- Median household income
- Median gross rent
- Housing units

Downloaded using the `tidycensus` R package.

https://www.census.gov/programs-surveys/acs

---

## Google Trends Data

Google Trends search interest data for:
- “Airbnb Miami”
- “Airbnb New Orleans”
- etc.

Downloaded manually from:
https://trends.google.com/

---

# How to Download the Airbnb Data

1. Go to:  
   https://www.airroi.com/data-portal/regions/north-america

2. Select a city.

3. Download:
   - Listings CSV
   - Reviews CSV
   - Calendar CSV

4. Place all downloaded files inside:

```plaintext
data/raw/

```

5. Update file paths if needed before running the scripts.

### Note

Calendar-based metrics continuously update over time. Results may vary slightly depending on when the data is downloaded.

---

# Methodology

## 1. Data Cleaning
- Cleaned and standardized Airbnb datasets
- Corrected coordinate parsing issues
- Merged listing, review, and calendar data

## 2. Spatial Integration
- Converted Airbnb listings into spatial points
- Joined listings to census tracts using `sf`
- Aggregated Airbnb metrics by tract
- Integrated ACS demographic variables
- Integrated FEMA climate risk variables

## 3. Exploratory Analysis
- Compared nightly rates across cities
- Visualized climate hazard profiles
- Mapped climate exposure spatially

## 4. Regression Modeling
- Tested relationships between:
  - Airbnb density
  - Pricing
  - Occupancy
  - Climate risk
- Evaluated hazard-specific relationships

## 5. Clustering Analysis
- Used k-means clustering
- Grouped census tracts into urban typologies based on:
  - Income
  - Rent
  - Airbnb density
  - Occupancy
  - Climate risk

## 6. Time-Series Forecasting
- Analyzed Google Trends search interest
- Decomposition analysis
- Autocorrelation testing
- Holt-Winters forecasting

## 7. Spatial Diagnostics
- Moran’s I spatial autocorrelation
- Spatial lag regression
- OLS vs spatial model comparison

---

# Key Insights

- Higher climate risk was associated with lower Airbnb density overall.
- Climate exposure did not consistently reduce occupancy or revenue.
- Wildfire-prone areas still showed high nightly rates.
- Tourism demand continued in environmentally vulnerable locations.
- Miami and New Orleans showed strong seasonal tourism patterns.
- Climate vulnerability clustered spatially more strongly than Airbnb density itself.
- Different cities displayed distinct climate-tourism profiles.

---

# Repository Structure

```plaintext
project-folder/
│
├── data/
│   ├── raw/
│   ├── processed/
│
├── scripts/
│   ├── 01_setup_and_data_cleaning.R
│   ├── 02_spatial_data_integration.R
│   ├── 03_exploratory_visualization.R
│   ├── 04_spatial_mapping.R
│   ├── 05_regression_and_clustering.R
│   ├── 06_temporal_analysis_and_forecasting.R
│   ├── 07_spatial_diagnostics_optional.R
│
├── outputs/
│   ├── maps/
│   ├── plots/
│   
├── README.md
├── LICENSE
```

---

# Tools & Libraries

## Software
- R
- RStudio
- ArcGIS Pro
- GitHub

## Main R Libraries
- tidyverse
- sf
- tigris
- tidycensus
- ggplot2
- forecast
- TTR
- factoextra
- spdep
- spatialreg
- patchwork

---

# Main Visualizations

- FEMA climate risk maps
- Hazard-specific spatial maps
- Climate hazard heatmaps
- Airbnb density vs risk scatterplots
- Occupancy by climate risk tier
- Clustering visualizations
- Google Trends temporal comparisons
- Holt-Winters forecasting plots

---

# Conclusion

This project shows that tourism economies increasingly operate inside environmentally vulnerable urban regions rather than outside them. Climate exposure does not uniformly reduce Airbnb activity, and some high-risk areas continue to remain economically active tourism zones.

The analysis suggests that climate vulnerability and tourism development coexist in uneven and sometimes contradictory ways across cities. Rather than producing a simple relationship between risk and decline, the project reveals how urban tourism systems continue adapting to — and sometimes ignoring — environmental exposure.

---

# Next Steps

Potential future directions:
- Incorporate longitudinal Airbnb pricing data
- Compare international tourism cities
- Integrate sea-level rise projections
- Analyze post-disaster tourism recovery
- Build interactive web maps and dashboards
- Examine policy differences between cities

---

# Author

**Uttara Parekh**  
M.S. Data Analytics & Visualization  
Pratt Institute School of Information


```
