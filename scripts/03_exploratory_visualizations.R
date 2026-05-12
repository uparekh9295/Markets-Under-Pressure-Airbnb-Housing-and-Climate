# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# CODE PART 3: EXPLORATORY VISUALIZATIONS
# ------------------------------------------------------------------------------

# ------------------------------------------------------
# SECTION 16: EXPLORATORY PLOTS — getting to know the data
# --------------------------------------------

# Distribution of nightly rates by city (capped at $500 to remove extreme outliers)
ggplot(all_listings, aes(x = ttm_avg_rate)) +
  geom_histogram(bins = 40, fill = "steelblue", color = "white") +
  coord_cartesian(xlim = c(0, 500)) +
  facet_wrap(~city, scales = "free_y") +
  labs(title = "Distribution of Nightly Rates by City",
       x = "Average Nightly Rate (USD)", y = "Number of Listings") +
  theme_minimal()

# Median nightly rate comparison across cities
all_listings %>%
  group_by(city) %>%
  summarise(median_price = median(ttm_avg_rate, na.rm = TRUE)) %>%
  ggplot(aes(x = reorder(city, median_price), y = median_price)) +
  geom_col(fill = "coral") +
  coord_flip() +
  labs(title = "Median Nightly Rate by City",
       x = NULL, y = "Median Nightly Rate (USD)") +
  theme_minimal()



# ------------------------------------------
# SECTION 17: CLIMATE RISK EXPLORATORY PLOTS
# -----------------------------------

# Average NRI risk score by city — gives a quick city-level climate profile
merged_tract_all %>%
  group_by(city) %>%
  summarise(mean_risk = mean(RISK_SCORE, na.rm = TRUE)) %>%
  ggplot(aes(x = reorder(city, mean_risk), y = mean_risk, fill = mean_risk)) +
  geom_col() +
  scale_fill_viridis_c(option = "C") +
  coord_flip() +
  labs(title = "Average FEMA Climate Risk Score by City",
       x = NULL, y = "Mean NRI Risk Score", fill = "Risk Score") +
  theme_minimal()

# Airbnb density vs climate risk score (scatter, by city)
ggplot(merged_tract_all, aes(x = RISK_SCORE, y = airbnb_density, color = city)) +
  geom_point(alpha = 0.4, size = 1) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Airbnb Density vs Climate Risk Score by City",
       x = "FEMA NRI Risk Score", y = "Airbnb Listings per 1,000 Housing Units") +
  theme_minimal()

# Future occupancy by risk tier — do high-risk tracts already show depressed bookings?
merged_tract_all %>%
  filter(!is.na(risk_tier_label)) %>%
  ggplot(aes(x = risk_tier_label, y = avg_future_occupancy, fill = risk_tier_label)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_viridis_d(option = "C") +
  scale_x_discrete(limits = c("Low Risk", "Moderate Risk", "High Risk", "Very High Risk")) +
  labs(title = "Forward Booking Occupancy by Climate Risk Tier",
       x = "Risk Tier", y = "Average Future Occupancy Rate") +
  theme_minimal() +
  theme(legend.position = "none")

# Hazard profile heatmap: which cities face which specific hazards?
merged_tract_all %>%
  group_by(city) %>%
  summarise(
    Heat         = mean(HWAV_RISKS, na.rm = TRUE),
    CoastalFlood = mean(CFLD_RISKS, na.rm = TRUE),
    InlandFlood  = mean(IFLD_RISKS, na.rm = TRUE),
    Hurricane    = mean(HRCN_RISKS, na.rm = TRUE),
    Wildfire     = mean(WFIR_RISKS, na.rm = TRUE),
    Drought      = mean(DRGT_RISKS, na.rm = TRUE)
  ) %>%
  pivot_longer(-city, names_to = "hazard", values_to = "score") %>%
  ggplot(aes(x = hazard, y = city, fill = score)) +
  geom_tile(color = "white") +
  scale_fill_viridis_c(option = "B") +
  labs(title = "Climate Hazard Profile by City",
       x = "Hazard Type", y = NULL, fill = "Avg Score") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))
