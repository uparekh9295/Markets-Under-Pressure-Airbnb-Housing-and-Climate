# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# CODE PART 2: CLIMATE DATA
# ------------------------------------------------------------------------------


# ----------------------------------------------
# SECTION 11: I load the FEMA National Risk Index (NRI) data
# ------------------------------------------------
# Downloaded from: https://www.fema.gov/about/openfema/data-sets/national-risk-index-data
# File: "NRI_Table_CensusTracts.csv" (national file, one row per tract)
# TRACTFIPS in the NRI = GEOID in my census data — this is how I join them.
#
# I select only the columns relevant to my cities:
#   RISK_SCORE = overall composite risk (0-100 scale)
#   HWAV_RISKS = extreme heat (important for Phoenix, LA, Chicago)
#   CFLD_RISKS = coastal flooding (Miami, NYC, New Orleans)
#   RFLD_RISKS = riverine/inland flooding (Chicago, New Orleans)
#   HRCN_RISKS = hurricane (Miami, New Orleans, NYC)
#   WFIR_RISKS = wildfire (LA, Denver)
#   DRGT_RISKS = drought (Phoenix, Denver, LA)

names(nri_raw <- read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/NRI_Table_CensusTracts/NRI_Table_CensusTracts.csv", 
                          show_col_types = FALSE)) %>% 
  grep("HEAT|CFLD|RFLD|HRCN|WFIR|DRGT|RISK", ., value = TRUE)

nri <- nri_raw %>%
  select(
    GEOID      = TRACTFIPS,
    RISK_SCORE,
    RISK_RATNG,
    HWAV_RISKS,   # extreme heat / heat wave
    CFLD_RISKS,   # coastal flood
    IFLD_RISKS,   # inland/riverine flood (was RFLD_RISKS — doesn't exist)
    HRCN_RISKS,   # hurricane
    WFIR_RISKS,   # wildfire
    DRGT_RISKS    # drought
  ) %>%
  mutate(GEOID = as.character(GEOID))

# --------------------------------------------------------------
# SECTION 12: define the ACS demographic variables from the Census
# -------------------------------------------
acs_vars <- c(
  median_household_income = "B19013_001",
  median_gross_rent       = "B25064_001",
  total_housing_units     = "B25001_001"
)


# --------------------------------------------
# SECTION 13: defining the core city-processing function
# ----------------------------------------
# This is the heart of the pipeline. For each city, it:
# 1. Converts listings to map points using lat/lon
# 2. Downloads census tract boundaries for that city
# 3. Figures out which tract each Airbnb listing falls inside (spatial join)
# 4. Aggregates all listing-level data up to the tract level
# 5. Downloads Census income/rent/housing data and joins it
# 6. Joins the NRI climate risk scores
# 7. Returns one clean tract-level table for that city

process_city <- function(listings_df, state, county, city_name) {
  
  # Step 1: Converting listing rows into geographic points on a map
  listings_sf <- listings_df %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326, remove = FALSE)
  
  # Step 2: Download the official census tract boundary shapes for this city
  tracts_sf <- tracts(state = state, county = county, year = 2022) %>%
    st_transform(4326)
  
  # Step 3: Spatial join — assign each listing to the tract it falls within
  listings_tract <- st_join(listings_sf, tracts_sf %>% select(GEOID), join = st_within)
  
  # Step 4: Collapse from listing-level to tract-level averages
  airbnb_tract <- listings_tract %>%
    st_drop_geometry() %>%           # remove the geographic info (no longer needed)
    filter(!is.na(GEOID)) %>%        # drop listings that didn't land inside any tract
    group_by(GEOID) %>%
    summarise(
      airbnb_listings         = n(),
      avg_airbnb_rate         = mean(ttm_avg_rate,           na.rm = TRUE),
      avg_airbnb_occ          = mean(ttm_occupancy,          na.rm = TRUE),
      avg_reviews             = mean(review_count,           na.rm = TRUE),
      avg_past_availability   = mean(past_availability_rate, na.rm = TRUE),
      avg_past_price          = mean(past_avg_price,         na.rm = TRUE),
      avg_future_occupancy    = mean(future_avg_occupancy,   na.rm = TRUE),
      avg_future_rate         = mean(future_avg_rate,        na.rm = TRUE),
      avg_future_revenue      = mean(future_avg_revenue,     na.rm = TRUE),
      avg_booking_lead_time   = mean(avg_booking_lead_time,  na.rm = TRUE),
      .groups = "drop"
    )
  
  # Step 5: Download ACS Census data for this city's tracts
  acs <- get_acs(
    geography = "tract",
    state     = state,
    county    = county,
    variables = acs_vars,
    year      = 2022,
    survey    = "acs5",
    output    = "wide"
  ) %>%
    transmute(
      GEOID,
      median_household_income = median_household_incomeE,
      median_gross_rent       = median_gross_rentE,
      total_housing_units     = total_housing_unitsE
    )
  
  # Step 6: Joining everything together and add climate risk and city label
  airbnb_tract %>%
    left_join(acs, by = "GEOID") %>%
    left_join(nri, by = "GEOID") %>%     # joining NRI climate scores on tract GEOID
    mutate(
      city           = city_name,
      airbnb_density = (airbnb_listings / total_housing_units) * 1000  # listings per 1,000 housing units
    )
}

# ---------------------------------------------------------
# SECTION 14: run process_city() for all 7 cities and stack the results
# ------------------------------------------
# NYC spans 5 boroughs = 5 counties, so I pass them all as a vector.
# Every other city maps to one county.

merged_tract_all <- bind_rows(
  process_city(all_listings %>% filter(city == "Los Angeles"), "CA", "Los Angeles",                                     "Los Angeles"),
  process_city(all_listings %>% filter(city == "Chicago"),     "IL", "Cook",                                            "Chicago"),
  process_city(all_listings %>% filter(city == "Miami"),       "FL", "Miami-Dade",                                      "Miami"),
  process_city(all_listings %>% filter(city == "Phoenix"),     "AZ", "Maricopa",                                        "Phoenix"),
  process_city(all_listings %>% filter(city == "Denver"),      "CO", "Denver",                                          "Denver"),
  process_city(all_listings %>% filter(city == "New Orleans"), "LA", "Orleans",                                         "New Orleans"),
  process_city(all_listings %>% filter(city == "New York"),    "NY", c("New York", "Kings", "Queens", "Bronx", "Richmond"), "New York")
)


# -------------------------------------------------------
# SECTION 15: I build additional variables for analysis
# ------------------------------------------
merged_tract_all <- merged_tract_all %>%
  mutate(
    # Housing affordability stress: rent as a share of monthly income
    rent_to_income = median_gross_rent / (median_household_income / 12),
    
    # Composite climate risk: simple average of the 6 hazard scores
    # I use rowMeans and na.rm=TRUE so tracts with only some hazards still get a score
    composite_climate_risk = rowMeans(
      cbind(HWAV_RISKS, CFLD_RISKS, IFLD_RISKS, HRCN_RISKS, WFIR_RISKS, DRGT_RISKS),
      na.rm = TRUE
    ),
    
    # Risk tier: I divide tracts into 4 equal groups (quartiles) based on overall risk score
    # This lets me compare "Low Risk" vs "Very High Risk" tracts directly
    risk_tier = ntile(RISK_SCORE, 4),
    risk_tier_label = case_when(
      risk_tier == 1 ~ "Low Risk",
      risk_tier == 2 ~ "Moderate Risk",
      risk_tier == 3 ~ "High Risk",
      risk_tier == 4 ~ "Very High Risk",
      TRUE           ~ NA_character_
    )
  ) %>%
  filter(total_housing_units > 0)  # remove tracts with no housing data
