# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# CODE PART 5: REGRESSION & CLUSTERING
# ------------------------------------------------------------------------------



# ---------------------------------------------------------
# SECTION 19: STATISTICAL MODELS — Core 
# ----------------------------------

# Does Airbnb density vary with neighborhood income and rent? (controlling for city)
model_density <- lm(
  airbnb_density ~ median_household_income + median_gross_rent + city,
  data = merged_tract_all
)
summary(model_density)



# -------------------------------------------
# SECTION 20: STATISTICAL MODELS — Climate Risk
# ------------------------
# The core research question: does climate risk affect Airbnb business performance?

# Does overall climate risk affect how many Airbnbs exist in a neighborhood?
model_density_climate <- lm(
  airbnb_density ~ RISK_SCORE + median_household_income + median_gross_rent + city,
  data = merged_tract_all
)
summary(model_density_climate)

# Does climate risk affect the nightly rate hosts charge?
# (Do hosts in risky areas charge more as compensation, or less due to weaker demand?)
model_rate_climate <- lm(
  avg_airbnb_rate ~ RISK_SCORE + airbnb_density + city,
  data = merged_tract_all
)
summary(model_rate_climate)

# Does climate risk affect PAST occupancy? (revealed behavior)
model_pastocc_climate <- lm(
  avg_past_availability ~ RISK_SCORE + city,
  data = merged_tract_all
)
summary(model_pastocc_climate)

# Does climate risk affect FUTURE occupancy? 
# If significant, this means the market is already pricing in climate risk forward-looking
model_futureocc_climate <- lm(
  avg_future_occupancy ~ RISK_SCORE + city,
  data = merged_tract_all
)
summary(model_futureocc_climate)

# Does climate risk affect forward-looking revenue?
model_futurerev_climate <- lm(
  avg_future_revenue ~ RISK_SCORE + city,
  data = merged_tract_all
)
summary(model_futurerev_climate)


# --- HAZARD-SPECIFIC MODELS ---
# Instead of composite risk, test each hazard type individually.
# This tells me WHICH type of risk matters most for each outcome.

# Heat risk on future occupancy (Phoenix, LA, Chicago angle)
model_heat <- lm(avg_future_occupancy ~ HWAV_RISKS + city, data = merged_tract_all)
summary(model_heat)

# Coastal flood risk on future occupancy (Miami, NYC, NOLA angle)
model_flood <- lm(avg_future_occupancy ~ IFLD_RISKS + city, data = merged_tract_all)
summary(model_flood)

# Wildfire risk on nightly rate (LA, Denver angle)
model_wildfire_rate <- lm(avg_airbnb_rate ~ WFIR_RISKS + city, data = merged_tract_all)
summary(model_wildfire_rate)

# Hurricane risk on density (NOLA, Miami angle)
model_hurricane_density <- lm(airbnb_density ~ HRCN_RISKS + city, data = merged_tract_all)
summary(model_hurricane_density)


# -----------------------------------------------------------------------------
# SECTION 21: CLUSTERING — to include climate risk
# -----------------------------------------------------------------------------
# K-means clustering groups tracts into natural "types" based on multiple variables.
# Adding climate risk lets me find clusters like:
# "High-income, high-risk, high-density" vs "Low-income, high-risk, low-density"

cluster_data <- merged_tract_all %>%
  select(
    median_household_income,
    median_gross_rent,
    airbnb_density,
    avg_airbnb_rate,
    avg_airbnb_occ,
    RISK_SCORE,           # ADDED
    composite_climate_risk # ADDED
  ) %>%
  drop_na()

cluster_scaled <- scale(cluster_data)  # normalize so no variable dominates due to scale

set.seed(123)
kmeans_result <- kmeans(cluster_scaled, centers = 4)

# Visualize the clusters
fviz_cluster(kmeans_result, data = cluster_scaled,
             geom = "point", ellipse.type = "convex",
             ggtheme = theme_minimal(),
             main = "Tract Clusters: Airbnb Performance + Climate Risk")

# Add cluster labels back to the tract data for further analysis
cluster_data$cluster <- as.factor(kmeans_result$cluster)

# What does each cluster look like on average?
cluster_data %>%
  group_by(cluster) %>%
  summarise(across(everything(), \(x) mean(x, na.rm = TRUE))) %>%
  print(width = Inf)
