# Climate at Checkout: Airbnb, Climate Exposure, and Urban Vulnerability Across U.S. Cities

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
