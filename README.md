Overview

This project investigates how Airbnb activity intersects with climate vulnerability across major U.S. cities. Using Airbnb listing and calendar data, FEMA National Risk Index data, Google Trends search activity, and U.S. Census data, I analyzed how short-term rental markets operate within environmentally exposed urban landscapes.

The project combines:

spatial analysis
climate risk mapping
regression modeling
clustering analysis
time-series forecasting
urban comparative analysis

Cities analyzed:

Los Angeles
New York
Miami
Chicago
Phoenix
Denver
New Orleans
Research Question

How does climate risk relate to Airbnb density, tourism activity, and short-term rental behavior across U.S. cities?

Null Hypothesis (H₀)

Climate risk has no significant relationship with Airbnb density, pricing, occupancy, or tourism search behavior across cities and census tracts.

Alternative Hypothesis (H₁)

Higher climate risk is associated with measurable differences in Airbnb density, pricing, occupancy, and tourism search behavior across U.S. cities and neighborhoods.

Why This Matters

Tourism economies increasingly overlap with environmentally vulnerable urban regions. Cities continue to expand tourism infrastructure and short-term rental activity in places exposed to flooding, heat, hurricanes, drought, and wildfire.

This project explores:

whether climate risk already affects Airbnb market behavior
how tourism demand changes across risky geographies
how environmental exposure differs across urban tourism systems
whether vulnerable places continue attracting investment and visitors despite increasing climate stress

The project treats Airbnb not only as a tourism platform, but also as a spatial indicator of urban economic behavior under climate pressure.

Data Sources
Airbnb Data

Airbnb listing, review, and calendar data were downloaded from:

AirROI Data Portal
https://www.airroi.com/data-portal/regions/north-america
Inside Airbnb
https://insideairbnb.com/get-the-data/

The datasets include:

listing characteristics
pricing
occupancy
reviews
future availability
calendar activity

Because AirROI uses rolling historical and future calendar windows, downloading the data at a different time may produce slightly different results from those shown in this repository.

Climate Risk Data
FEMA National Risk Index (NRI)
Hazard-specific variables:
wildfire
coastal flooding
inland flooding
hurricanes
heat waves
drought

https://hazards.fema.gov/nri/

Census Data

American Community Survey (ACS) 5-Year Estimates:

median household income
median gross rent
housing units

Downloaded using the tidycensus R package.

https://www.census.gov/programs-surveys/acs

Google Trends Data

Google Trends search interest data for:

“Airbnb Miami”
“Airbnb New Orleans”
etc.

Downloaded manually from:
https://trends.google.com/

How to Download the Airbnb Data
Go to:
https://www.airroi.com/data-portal/regions/north-america
Select a city.
Download:
Listings CSV
Reviews CSV
Calendar CSV
Place all downloaded files inside:
data/raw/
Update file paths if needed before running the scripts.

Note:
Calendar-based metrics continuously update over time. Results may vary slightly depending on when the data is downloaded.

Methodology
1. Data Cleaning
cleaned and standardized Airbnb datasets
corrected coordinate parsing issues
merged listing, review, and calendar data
2. Spatial Integration
converted Airbnb listings into spatial points
joined listings to census tracts using sf
aggregated Airbnb metrics by tract
integrated ACS demographic variables
integrated FEMA climate risk variables
3. Exploratory Analysis
compared nightly rates across cities
visualized climate hazard profiles
mapped climate exposure spatially
4. Regression Modeling
tested relationships between:
Airbnb density
pricing
occupancy
climate risk
evaluated hazard-specific relationships
5. Clustering Analysis
used k-means clustering
grouped census tracts into urban typologies based on:
income
rent
Airbnb density
occupancy
climate risk
6. Time-Series Forecasting
analyzed Google Trends search interest
decomposition analysis
autocorrelation testing
Holt-Winters forecasting
7. Spatial Diagnostics
Moran’s I spatial autocorrelation
spatial lag regression
OLS vs spatial model comparison
Key Insights
Higher climate risk was associated with lower Airbnb density overall.
Climate exposure did not consistently reduce occupancy or revenue.
Wildfire-prone areas still showed high nightly rates.
Tourism demand continued in environmentally vulnerable locations.
Miami and New Orleans showed strong seasonal tourism patterns.
Climate vulnerability clustered spatially more strongly than Airbnb density itself.
Different cities displayed distinct climate-tourism profiles.
Repository Structure
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
│   ├── tables/
│
├── README.md
├── LICENSE
Tools & Libraries
Software
R
RStudio
ArcGIS Pro
GitHub
Main R Libraries
tidyverse
sf
tigris
tidycensus
ggplot2
forecast
TTR
factoextra
spdep
spatialreg
patchwork
Main Visualizations
FEMA climate risk maps
hazard-specific spatial maps
climate hazard heatmaps
Airbnb density vs risk scatterplots
occupancy by climate risk tier
clustering visualizations
Google Trends temporal comparisons
Holt-Winters forecasting plots
Conclusion

This project shows that tourism economies increasingly operate inside environmentally vulnerable urban regions rather than outside them. Climate exposure does not uniformly reduce Airbnb activity, and some high-risk areas continue to remain economically active tourism zones.

The analysis suggests that climate vulnerability and tourism development coexist in uneven and sometimes contradictory ways across cities. Rather than producing a simple relationship between risk and decline, the project reveals how urban tourism systems continue adapting to — and sometimes ignoring — environmental exposure.

Next Steps

Potential future directions:

incorporate longitudinal Airbnb pricing data
compare international tourism cities
integrate sea-level rise projections
analyze post-disaster tourism recovery
build interactive web maps and dashboards
examine policy differences between cities
Author

Uttara Parekh
M.S. Data Analytics & Visualization
Pratt Institute School of Information
