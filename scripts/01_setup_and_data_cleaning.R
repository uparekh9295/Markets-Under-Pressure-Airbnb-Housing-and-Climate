# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# CODE PART 1: SETUP & DATA CLEANING
# ------------------------------------------------------------------------------

# -------------------------------------------------------------------
# DATA SOURCE NOTE
#
# Airbnb listing, review, and calendar data used in this project were
# downloaded from the AirROI data portal:
#
# AirROI:
# [AirROI Data Portal](https://www.airroi.com/data-portal/regions/north-america)
#
# These datasets include rolling historical and forward-looking calendar
# availability data (including future 12-month booking/activity fields).
# Because the platforms continuously update listings, availability,
# occupancy, and pricing metrics, downloading the data at a different
# time may produce slightly different analytical results from those
# shown in this project.
#
# This analysis therefore represents a snapshot of Airbnb market
# conditions at the time the datasets were collected.
#
# If you would like the exact datasets used to reproduce the results
# in this repository, please contact me directly.
# -------------------------------------------------------------------


# -----------------------------------------
# SECTION 1: I load all the libraries I need
# -----------------------------------------------------------------------------
# tidyverse  = general data wrangling and plotting
# sf         = working with geographic/map data (spatial features)
# tigris     = downloads US census tract boundary shapes
# tidycensus = downloads ACS (Census) demographic data
# factoextra = makes nicer cluster plots
# ggrepel    = keeps map labels from overlapping each other
# viridis    = colorblind-friendly color scales for maps
# spdep      = builds the neighbor structure between tracts
# spatialreg = runs the spatial lag regression model


library(tidyverse)
library(sf)
library(tigris)
library(tidycensus)
library(factoextra)
library(ggrepel)
library(viridis)
library(patchwork)
library(spdep)
library(spatialreg)

options(tigris_use_cache = TRUE)  # saves downloaded shapefiles so I don't re-download each run


# --------------------------------
# SECTION 2: setting my Census API key
# ---------------------


census_api_key("Enter your API key here", install = TRUE)

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# CODE PART 1: PRELIMINIARY DATA PREP & CLEANING
# ------------------------------------------------------------------------------

# -----------------------------------------------------------
# SECTION 3: read in all Airbnb listing files
# ------------------------------
# Each city has its own CSV from AirDNA. Chicago needs special handling
# because its lat/lon columns contain messy non-numeric characters.

listings_LA    <- read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/listings LA.csv")
listings_NYC   <- read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/listings NYC.csv")
listings_MIAMI <- read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/listings Miami.csv")
listings_CHI   <- read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/listings CHIGO.csv")
problems(listings_CHI)
listings_CHI[298, ]
listings_PHX   <- read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/listings PNIX.csv")
listings_DEN   <- read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/listings DENVR.csv")
listings_NOLA  <- read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/listings NOLA.csv")


# -----------------------------------------------
# SECTION 4: cleaning all city listing datasets
# ---------------------------------------------------------------
# The fix_coords argument handles Chicago's messy coordinate columns.
# For all cities, I make sure lat/lon and performance metrics are numeric.

clean_city <- function(df, fix_coords = FALSE) {
  
  if (fix_coords) {
    # Chicago has stray characters in lat/lon, so I strip everything
    # except digits, dots, and minus signs before converting to numeric
    df <- df %>%
      mutate(
        latitude  = as.numeric(gsub("[^0-9.-]", "", latitude)),
        longitude = as.numeric(gsub("[^0-9.-]", "", longitude))
      )
  } else {
    df <- df %>%
      mutate(
        latitude  = as.numeric(latitude),
        longitude = as.numeric(longitude)
      )
  }
  
  df %>%
    mutate(
      ttm_avg_rate  = as.numeric(ttm_avg_rate),
      ttm_occupancy = as.numeric(ttm_occupancy)
    ) %>%
    filter(!is.na(latitude), !is.na(longitude))  # drop any rows with missing coords
}

listings_LA    <- clean_city(listings_LA)
listings_NYC   <- clean_city(listings_NYC)
listings_MIAMI <- clean_city(listings_MIAMI)
listings_CHI   <- clean_city(listings_CHI, fix_coords = TRUE)
listings_PHX   <- clean_city(listings_PHX)
listings_DEN   <- clean_city(listings_DEN)
listings_NOLA  <- clean_city(listings_NOLA)


# ------------------------------------
# SECTION 5: I add a city label column to each dataset
# --------------------------------
listings_LA$city    <- "Los Angeles"
listings_NYC$city   <- "New York"
listings_MIAMI$city <- "Miami"
listings_CHI$city   <- "Chicago"
listings_PHX$city   <- "Phoenix"
listings_DEN$city   <- "Denver"
listings_NOLA$city  <- "New Orleans"


# --------------------------------------
# SECTION 6: stacking all city listings into one big table
# -----------------------------------------------------
# I convert every column to character first so that column type mismatches
# between cities don't cause errors when stacking. Then I convert the
# numeric columns I need back to numbers.

all_listings <- bind_rows(
  mutate_all(listings_LA,    as.character),
  mutate_all(listings_NYC,   as.character),
  mutate_all(listings_MIAMI, as.character),
  mutate_all(listings_CHI,   as.character),
  mutate_all(listings_PHX,   as.character),
  mutate_all(listings_DEN,   as.character),
  mutate_all(listings_NOLA,  as.character)
) %>%
  mutate(
    listing_id    = as.numeric(listing_id),
    ttm_avg_rate  = as.numeric(ttm_avg_rate),
    ttm_occupancy = as.numeric(ttm_occupancy),
    latitude      = as.numeric(latitude),
    longitude     = as.numeric(longitude)
  )


# --------------------------------------------------
# SECTION 7: I load and summarize the reviews data
# -------------------------------------------
# Reviews tell me how active each listing is (more reviews = more bookings over time).
# I count total reviews per listing and join that onto the main listings table.

reviews_all <- bind_rows(
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/reviews LA.csv"),    city = "Los Angeles"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/reviews NYC.csv"),   city = "New York"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/reviews MIAMI.csv"), city = "Miami"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/reviews CHIGO.csv"), city = "Chicago"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/reviews PNIX.csv"),  city = "Phoenix"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/reviews DENVR.csv"), city = "Denver"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/reviews NOLA.csv"),  city = "New Orleans")
)

reviews_summary <- reviews_all %>%
  group_by(listing_id) %>%
  summarise(review_count = n(), .groups = "drop")

# ----------------------------------
# SECTION 8: I load and summarize the PAST calendar data
# ------------------------------------------------
# Past calendar = what actually happened (was the listing booked? at what price?).
# to calculate: (1) how often the listing was available, (2) average listed price.

past_calendar_all <- bind_rows(
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/past calendar rates LA.csv"),    city = "Los Angeles"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/past calendar rates NYC.csv"),   city = "New York"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/past calendar rates MIAMI.csv"), city = "Miami"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/past calendar rates CHIGO.csv"), city = "Chicago"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/past calendar rates PNIX.csv"),  city = "Phoenix"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/past calendar rates DENVR.csv"), city = "Denver"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/past calendar rates NOLA.csv"),  city = "New Orleans")
)

past_calendar_summary <- past_calendar_all %>%
  group_by(listing_id) %>%
  summarise(
    past_availability_rate = mean(occupancy, na.rm = TRUE),
    past_avg_price         = mean(rate_avg,  na.rm = TRUE),
    .groups = "drop"
  )


# -------------------------------------------
# SECTION 9: loading and summarize the FUTURE calendar data
# ------------------------------
# Future calendar = forward bookings (what's already reserved in coming months).
# it captures whether demand is ALREADY being
# affected by climate risk before events even happen.
# I also pull avg booking lead time: do people in risky areas book later/less?

future_calendar_all <- bind_rows(
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/future calendar rates LA.csv"),    city = "Los Angeles"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/future calendar rates NYC.csv"),   city = "New York"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/future calendar rates MIAMI.csv"), city = "Miami"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/future calendar rates CHIGO.csv"), city = "Chicago"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/future calendar rates PNIX.csv"),  city = "Phoenix"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/future calendar rates DENVR.csv"), city = "Denver"),
  mutate(read_csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/future calendar rates NOLA.csv"),  city = "New Orleans")
)

future_calendar_summary <- future_calendar_all %>%
  group_by(listing_id) %>%
  summarise(
    future_avg_occupancy    = mean(occupancy,             na.rm = TRUE),
    future_avg_rate         = mean(rate_avg,              na.rm = TRUE),
    future_avg_revenue      = mean(revenue,               na.rm = TRUE),
    avg_booking_lead_time   = mean(booking_lead_time_avg, na.rm = TRUE),
    .groups = "drop"
  )


# ------------------------------------------------
# SECTION 10: joining all supplementary data onto the main listings table
# --------------------------
all_listings <- all_listings %>%
  left_join(reviews_summary,         by = "listing_id") %>%
  left_join(past_calendar_summary,   by = "listing_id") %>%
  left_join(future_calendar_summary, by = "listing_id")
