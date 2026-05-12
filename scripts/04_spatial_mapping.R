# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# CODE PART 4: SPATIAL MAPPING
# ------------------------------------------------------------------------------


# -----------------------------------------
# SECTION 18: MAP VISUALIZATIONS
# --------------------------------------------------
# I download tract shapefiles for each city, merge in my data, and map it.
# Each map shows a different variable spatially — letting me see WHERE in each
# city the patterns are concentrated.

# Rebuild city shapes joining NRI directly instead of through merged_tract_all
get_city_shapes <- function(state, county, city_name) {
  tracts(state = state, county = county, year = 2022) %>%
    st_transform(4326) %>%
    left_join(nri, by = "GEOID") %>%                    # join climate risk to ALL tracts
    left_join(                                           # join Airbnb data only where it exists
      merged_tract_all %>% filter(city == city_name),
      by = "GEOID"
    ) %>%
    mutate(city = city_name)                             # force city label on every row
}

# Rebuild all city shapes
chi_map  <- get_city_shapes("IL", "Cook",        "Chicago")
mia_map  <- get_city_shapes("FL", "Miami-Dade",  "Miami")
nola_map <- get_city_shapes("LA", "Orleans",      "New Orleans")
phx_map  <- get_city_shapes("AZ", "Maricopa",     "Phoenix")
den_map  <- get_city_shapes("CO", "Denver",       "Denver")
la_map   <- get_city_shapes("CA", "Los Angeles",  "Los Angeles")
nyc_map  <- get_city_shapes("NY", c("New York","Kings","Queens","Bronx","Richmond"), "New York")

# Stack them — now every tract has a city label and a risk score
all_city_shapes <- rbind(chi_map, mia_map, nola_map, phx_map, den_map, la_map, nyc_map)

# Verify it still has geometry
st_geometry_type(all_city_shapes) %>% table()



# --- MAP 1: Climate Risk Score across all cities ---
# Shows which neighborhoods face the highest overall climate risk

# Create individual maps for each city
map_chi  <- ggplot(chi_map)  + geom_sf(aes(fill = RISK_SCORE.x), color = NA) + scale_fill_viridis_c(option = "C", na.value = "grey90") + labs(title = "Chicago")  + theme_void() + theme(legend.position = "none")
map_mia  <- ggplot(mia_map)  + geom_sf(aes(fill = RISK_SCORE.x), color = NA) + scale_fill_viridis_c(option = "C", na.value = "grey90") + labs(title = "Miami")    + theme_void() + theme(legend.position = "none")
map_nola <- ggplot(nola_map) + geom_sf(aes(fill = RISK_SCORE.x), color = NA) + scale_fill_viridis_c(option = "C", na.value = "grey90") + labs(title = "New Orleans") + theme_void() + theme(legend.position = "none")
map_phx  <- ggplot(phx_map)  + geom_sf(aes(fill = RISK_SCORE.x), color = NA) + scale_fill_viridis_c(option = "C", na.value = "grey90") + labs(title = "Phoenix")  + theme_void() + theme(legend.position = "none")
map_den  <- ggplot(den_map)  + geom_sf(aes(fill = RISK_SCORE.x), color = NA) + scale_fill_viridis_c(option = "C", na.value = "grey90") + labs(title = "Denver")   + theme_void() + theme(legend.position = "none")
map_la   <- ggplot(la_map)   + geom_sf(aes(fill = RISK_SCORE.x), color = NA) + scale_fill_viridis_c(option = "C", na.value = "grey90") + labs(title = "Los Angeles") + theme_void() + theme(legend.position = "none")
map_nyc  <- ggplot(nyc_map)  + geom_sf(aes(fill = RISK_SCORE.x), color = NA) + scale_fill_viridis_c(option = "C", na.value = "grey90") + labs(title = "New York") + theme_void() + theme(legend.position = "none")

# Combine into one figure with a shared legend
(map_chi + map_den + map_la) /
  (map_mia + map_nola + map_nyc) /
  (map_phx + plot_spacer() + plot_spacer()) +
  plot_annotation(title = "FEMA Climate Risk Score by Census Tract",
                  theme = theme(plot.title = element_text(face = "bold", size = 14)))


# --- MAP 2: Specific hazard maps for the highest-risk cities ---
# Miami: Coastal Flood Risk
ggplot(mia_map) +
  geom_sf(aes(fill = CFLD_RISKS.x), color = NA) +
  scale_fill_viridis_c(option = "C", na.value = "grey90") +
  labs(title = "Miami: Coastal Flood Risk Score by Tract", fill = "Score") +
  theme_void()

# New Orleans: Hurricane Risk
ggplot(nola_map) +
  geom_sf(aes(fill = HRCN_RISKS.x), color = NA) +
  scale_fill_viridis_c(option = "C", na.value = "grey90") +
  labs(title = "New Orleans: Hurricane Risk Score by Tract", fill = "Score") +
  theme_void()

# Phoenix: Extreme Heat Risk — also fixing column name from HEAT_RISKS to HWAV_RISKS
ggplot(phx_map) +
  geom_sf(aes(fill = HWAV_RISKS.x), color = NA) +
  scale_fill_viridis_c(option = "C", na.value = "grey90") +
  labs(title = "Phoenix: Extreme Heat Risk Score by Tract", fill = "Score") +
  theme_void()

# LA: Wildfire Risk
ggplot(la_map) +
  geom_sf(aes(fill = WFIR_RISKS.x), color = NA) +
  scale_fill_viridis_c(option = "C", na.value = "grey90") +
  labs(title = "Los Angeles: Wildfire Risk Score by Tract", fill = "Score") +
  theme_void()
