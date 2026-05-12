# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# CODE PART 7: SPATIAL REGRESSION & DIAGNOSTICS
# ------------------------------------------------------------------------------



# -----------------------------------
# SECTION 22: SPATIAL REGRESSION
# --------------------------------------
# So far my OLS models treat every census tract as independent of its neighbors.
# a high-Airbnb tract is likely surrounded by other high-Airbnb tracts. 
#Spatial regression accounts for this neighbor effect.
#  I run this city by city because Chicago tracts
# cannot be neighbors of Miami tracts
# I focus on Chicago (strongest density finding) and Miami (flood/hurricane).

# ------------------------------------
# STEP 1: PREPARE CITY DATA FOR SPATIAL REGRESSION
# ------------------------------
# I need my data attached to the actual tract geometries (shapes), not just
# as a flat table. I filter to only tracts that have Airbnb data and no
# missing values in the variables I'm modeling.
# I also run st_make_valid() to fix any slightly broken polygon shapes
# which would otherwise crash the neighbor calculation.

chi_spatial <- chi_map %>%
  filter(!is.na(airbnb_density),
         !is.na(RISK_SCORE.x),
         !is.na(median_household_income),
         !is.na(median_gross_rent)) %>%
  st_make_valid()

mia_spatial <- mia_map %>%
  filter(!is.na(airbnb_density),
         !is.na(RISK_SCORE.x),
         !is.na(median_household_income),
         !is.na(median_gross_rent)) %>%
  st_make_valid()


# ----------------------------------
# STEP 2: BUILDING THE SPATIAL WEIGHTS MATRIX — CHICAGO
# ---------------------------
#  defines what counts as a "neighbor."
#   weights matrix tells R: when calculating spatial effects,
# these are the tracts that can influence each other.

neighborlist_chi <- poly2nb(pl = chi_spatial, queen = TRUE)

listweights_chi <- nb2listw(neighbours = neighborlist_chi,
                            style = "W",          # row-standardized: each neighbor weighted equally
                            zero.policy = TRUE)   # allow tracts with no neighbors (islands)


# ---------------------------------------------------
# STEP 3: MORAN'S I TEST — IS AIRBNB DENSITY SPATIALLY CLUSTERED IN CHICAGO?
# ---------------------------------------
# Before running spatial regression, I need to check WHETHER spatial clustering
# actually exists. 
# If the result is positive and significant (p < 0.05), it means high-density
# tracts cluster together and low-density tracts cluster together-
# they are NOT randomly scattered. This JUSTIFIES using spatial regression.
# If it's not significant, regular OLS is fine and spatial regression adds nothing.

global_moran_chi <- moran.test(x = chi_spatial$airbnb_density,
                               listw = listweights_chi,
                               randomisation = TRUE,
                               alternative = "greater",
                               na.action = na.omit,
                               zero.policy = TRUE)
print(global_moran_chi)

# Visual version: points in top-right = high density surrounded by high density
# points in bottom-left = low density surrounded by low density
# A clear diagonal pattern means strong spatial clustering exists
moran.plot(x = chi_spatial$airbnb_density,
           listw = listweights_chi,
           zero.policy = TRUE,
           xlab = "Airbnb Density (tract)",
           ylab = "Average Density of Neighboring Tracts",
           main = "Moran's I — Chicago Airbnb Density")


# --------------------------------------
# STEP 4: MORAN'S I FOR CLIMATE RISK — CHICAGO
# -------------------------------
# I also check whether climate risk itself clusters spatially in Chicago.
# If high-risk tracts are surrounded by other high-risk tracts, that supports
# my argument that climate risk is geographically concentrated- not random.

global_moran_risk_chi <- moran.test(x = chi_spatial$RISK_SCORE.x,
                                    listw = listweights_chi,
                                    randomisation = TRUE,
                                    alternative = "greater",
                                    na.action = na.omit,
                                    zero.policy = TRUE)
print(global_moran_risk_chi)


# -----------------------------
# STEP 5: OLS BASELINE - CHICAGO
# --------------------
# I run regular OLS first as a baseline to compare against the spatial model.
# This is the same logic as my Section 20 models but now only for Chicago
# and using RISK_SCORE.x because that's the column name in the joined shapefile.

formula_chi <- as.formula(
  airbnb_density ~ RISK_SCORE.x + median_household_income + median_gross_rent
)

ols_chi <- lm(formula = formula_chi, data = chi_spatial)
summary(ols_chi)


# -------------------------------
# STEP 6: SPATIAL LAG MODEL — CHICAGO
# -----------------------
# it asks:
# does having HIGH DENSITY NEIGHBORS predict your own tract's density,
# even after controlling for climate risk and income?
#
# The new coefficient to look for is called Rho (ρ).
# If Rho is positive and significant:
#   - neighboring tracts genuinely influence each other
#   - Airbnb activity spreads across tract boundaries
#   - my OLS models were technically underspecified
#
# If RISK_SCORE.x stays negative and significant even in this model,
# it means my earlier finding is ROBUST- it holds up even after
# accounting for spatial spillover effects between neighborhoods.

spatial_lag_chi <- lagsarlm(formula = formula_chi,
                            data = chi_spatial,
                            listw = listweights_chi,
                            zero.policy = TRUE,
                            na.action = na.omit)
summary(spatial_lag_chi)


# ----------------------------------------------
# STEP 7: Repeating for MIAMI
# ---------------------------------
# Miami is my second city because it has coastal flood and hurricane.
# I follow the exact same steps as Chicago above.

# Build neighbor structure
neighborlist_mia <- poly2nb(pl = mia_spatial, queen = TRUE)

listweights_mia <- nb2listw(neighbours = neighborlist_mia,
                            style = "W",
                            zero.policy = TRUE)

# Moran's I for Airbnb density in Miami
global_moran_mia <- moran.test(x = mia_spatial$airbnb_density,
                               listw = listweights_mia,
                               randomisation = TRUE,
                               alternative = "greater",
                               na.action = na.omit,
                               zero.policy = TRUE)
print(global_moran_mia)

moran.plot(x = mia_spatial$airbnb_density,
           listw = listweights_mia,
           zero.policy = TRUE,
           xlab = "Airbnb Density (tract)",
           ylab = "Average Density of Neighboring Tracts",
           main = "Moran's I — Miami Airbnb Density")

# OLS baseline for Miami
# I use CFLD_RISKS.x here instead of overall RISK_SCORE because
# coastal flood is the specific hazard relevant to Miami
formula_mia <- as.formula(
  airbnb_density ~ RISK_SCORE.x + CFLD_RISKS.x + median_household_income + median_gross_rent
)

ols_mia <- lm(formula = formula_mia, data = mia_spatial)
summary(ols_mia)

# Spatial lag model for Miami
spatial_lag_mia <- lagsarlm(formula = formula_mia,
                            data = mia_spatial,
                            listw = listweights_mia,
                            zero.policy = TRUE,
                            na.action = na.omit)
summary(spatial_lag_mia)


AIC(ols_chi)
AIC(spatial_lag_chi)

AIC(ols_mia)
AIC(spatial_lag_mia)
