# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# CODE PART 6: TEMPORAL ANALYSIS & FORECASTING
# ------------------------------------------------------------------------------


# ----------------------------------------
# SECTION 23: TEMPORAL ANALYSIS — Google Trends for Airbnb Search Interest
# ----------------------------------------------------
# I use Google Trends data to examine how traveler interest in Airbnb
# has changed over time across my seven cities (Jan 2019 to present).
# The search index (0-100) shows relative monthly search popularity.
# 100 = peak month for that search term, 50 = half as popular as peak.
# This adds a demand-side temporal perspective to my supply-side
# analysis of listings and climate risk.
# I focus on comparing high climate risk cities (Miami, New Orleans)
# against lower risk cities (Denver, Chicago) to see if seasonal
# patterns differ between them.
# ------------------------------------

library(TTR)
library(forecast)

# -----------------------------------------------
# 1: I load the Google Trends data for each city

# Each file was downloaded from https://trends.google.com
# Search terms: "Airbnb Miami", "Airbnb New Orleans" etc.
# Geography: United States | Time: 2019-present | Frequency: Monthly

trends_miami  <- read.csv('/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/Miami_Trends.csv')
trends_nola   <- read.csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/NOLA_Trends.csv")
trends_chi    <- read.csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/Chicago_Trends.csv")
trends_phx    <- read.csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/Phoenix_trends.csv")
trends_la     <- read.csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/LA_trends.csv")
trends_nyc    <- read.csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/NY_trends.csv")
trends_den    <- read.csv("/Users/uttaraparekh/Desktop/DAV/SEM 2/Stats 2/final project/Denver_Trends.csv")

# ---------------------------------------------------
#  2: I check what the columns are called before doing anything

# Google Trends CSVs sometimes have messy headers — I check first
# so I know what column name to use for the search index

head(trends_miami)
names(trends_miami)

names(trends_nola)
names(trends_chi)
names(trends_phx)
names(trends_la)
names(trends_nyc)
names(trends_den)


# -----------------------------------------------
# 3: I standardize all column names so I can work with them consistently

# Google Trends gave inconsistent capitalization across cities, so I rename
# the search index column to "search_index" in every dataframe

trends_miami$search_index <- trends_miami$airbnb.miami
trends_nola$search_index  <- trends_nola$Airbnb.New.Orleans
trends_chi$search_index   <- trends_chi$Airbnb.Chicago
trends_phx$search_index   <- trends_phx$Airbnb.Phoenix
trends_la$search_index    <- trends_la$Airbnb.Los.Angeles
trends_nyc$search_index   <- trends_nyc$Airbnb.New.York
trends_den$search_index   <- trends_den$Airbnb.Denver

# -------------------------------------
# 4: I adding city labels and stack all cities into one table for plotting

trends_miami$city <- "Miami"
trends_nola$city  <- "New Orleans"
trends_chi$city   <- "Chicago"
trends_phx$city   <- "Phoenix"
trends_la$city    <- "Los Angeles"
trends_nyc$city   <- "New York"
trends_den$city   <- "Denver"

trends_all <- bind_rows(
  trends_miami  %>% select(Time, search_index, city),
  trends_nola   %>% select(Time, search_index, city),
  trends_chi    %>% select(Time, search_index, city),
  trends_phx    %>% select(Time, search_index, city),
  trends_la     %>% select(Time, search_index, city),
  trends_nyc    %>% select(Time, search_index, city),
  trends_den    %>% select(Time, search_index, city)
) %>%
  mutate(Time = as.Date(Time))  # make sure Time is read as a date not text

# -------------------------------------------
# 5: PLOT — Search interest over time for all cities

# This gives a visual overview of how Airbnb search interest has evolved.
# The COVID dip in 2020 will be visible as a sharp drop across all cities.
# Differences in recovery speed and seasonal patterns are the key story.

ggplot(trends_all, aes(x = Time, y = search_index, color = city)) +
  geom_line(linewidth = 0.8, alpha = 0.8) +
  scale_color_viridis_d(option = "C") +
  labs(title = "Google Search Interest for Airbnb by City (2019–Present)",
       subtitle = "Search index: 100 = peak month, values are relative not absolute",
       x = NULL, y = "Search Index", color = "City") +
  theme_minimal()

# --------------------------------
# 6: PLOT — High vs Low climate risk cities compared directly

# I split cities into high risk (Miami, New Orleans) and lower risk
# (Denver, Chicago) to visually compare their temporal patterns.
# This is the most directly relevant plot for my project's argument.

trends_all %>%
  filter(city %in% c("Miami", "New Orleans", "Denver", "Chicago")) %>%
  mutate(risk_group = ifelse(city %in% c("Miami", "New Orleans"),
                             "High Climate Risk", "Lower Climate Risk")) %>%
  ggplot(aes(x = Time, y = search_index, color = city, linetype = risk_group)) +
  geom_line(linewidth = 0.9) +
  scale_color_manual(values = c("Miami" = "#E31A1C", "New Orleans" = "#FF7F00",
                                "Denver" = "#1F78B4", "Chicago" = "#33A02C")) +
  labs(title = "Airbnb Search Interest: High vs Lower Climate Risk Cities",
       subtitle = "High risk = Miami, New Orleans | Lower risk = Denver, Chicago",
       x = NULL, y = "Search Index", color = "City", linetype = "Risk Group") +
  theme_minimal()


# -----------------------------
# 7: FORMAT AS TIME SERIES — I focus on Miami for the detailed analysis

# I use Miami as my primary case because it has the strongest climate risk
# story (coastal flood + hurricane) and is one of my most data-rich cities.
# I follow the same steps for New Orleans below as a comparison.
#
# ts() converts a regular column of numbers into a proper time series object.
# start = c(2019, 1) means January 2019.
# frequency = 12 means monthly data (12 months per year).

ts_miami <- ts(data = trends_miami$search_index,
               start = c(2019, 1),
               frequency = 12)

# plot to check it looks right
autoplot(ts_miami) +
  ylim(0, 100) +
  labs(title = 'Google Search Interest: "Airbnb Miami" (2019–Present)',
       y = "Search Index", x = NULL) +
  theme_minimal()


# ------------------------------
#  8: DECOMPOSE THE TIME SERIES — Miami

# Decomposition breaks the time series into three separate components:
# 1. TREND     = the long-term direction (going up, down, or flat overall)
# 2. SEASONAL  = the repeating pattern within each year (e.g. summer peaks)
# 3. REMAINDER = what's left after removing trend and season (random noise)
#
# For my project, the seasonal component is the most interesting —
# does Miami show a dip during hurricane season (June-November)?

decomposed_miami <- decompose(ts_miami)

autoplot(decomposed_miami) +
  labs(title = 'Decomposed Time Series: "Airbnb Miami" Search Interest') +
  theme_minimal()


# -----------------------------------
# 9: TEMPORAL AUTOCORRELATION — Miami

# Autocorrelation tests whether this month's search interest predicts
# next month's search interest. Does interest carry
# over from month to month, or does it reset randomly each month?
#
# The ACF plot shows vertical bars. Bars outside the blue dashed lines
# are statistically significant lags.
# Lag 1 = does this month predict next month?
# Lag 12 = does January this year predict January next year? (seasonal pattern)
#
# H0 (null): search interest is temporally random month to month
# HA (alternative): search interest is NOT random — past months predict future months

ggAcf(ts_miami) +
  labs(title = "Temporal Autocorrelation — Airbnb Miami Search Interest",
       subtitle = "Bars outside blue lines indicate significant autocorrelation at that lag") +
  theme_minimal()

# Formal statistical test for autocorrelation
# If p < 0.05, I reject the null and conclude the series is NOT random
Box.test(ts_miami, type = "Ljung-Box")


# ------------------------
# 10: FORECASTING — Miami

# I use three forecasting methods
# Each builds on the previous in complexity.
#
# SES (Single Exponential Smoothing): 
#   Weights recent observations more than older ones.
#   Good for series with no clear trend or season.
#
# Holt (Double Exponential Smoothing):
#   Adds a trend component — captures whether interest is growing or declining.
#
# Holt-Winters (Triple Exponential Smoothing):
#   Adds both trend AND seasonal components.
#   Best fit for monthly data with repeating yearly patterns like mine.
#
# h = 24 means I'm forecasting 24 months (2 years) ahead.

# Single exponential smoothing
ses_miami <- ses(y = ts_miami, h = 24)
autoplot(ses_miami) +
  labs(title = "Forecast: Airbnb Miami Search Interest — Single Exponential Smoothing",
       y = "Search Index") +
  theme_minimal()
summary(ses_miami)

# Double exponential smoothing (Holt)
holt_miami <- holt(y = ts_miami, h = 24)
autoplot(holt_miami) +
  labs(title = "Forecast: Airbnb Miami Search Interest — Holt Linear",
       y = "Search Index") +
  theme_minimal()
summary(holt_miami)

# Triple exponential smoothing (Holt-Winters) — my preferred model
# because it captures both the trend and the seasonal hurricane season dip
hw_miami <- hw(y = ts_miami, h = 24)
autoplot(hw_miami) +
  labs(title = "Forecast: Airbnb Miami Search Interest — Holt-Winters",
       y = "Search Index") +
  theme_minimal()
summary(hw_miami)
checkresiduals(hw_miami)


# -----------------------------------------
#  11: Repeating FOR NEW ORLEANS - the comparison high-risk city

# I repeat the same analysis for New Orleans to compare with Miami.
# Both are high hurricane/flood risk cities. If they show similar
# seasonal dips and similar forecast trajectories, that strengthens
# the argument that climate risk shapes Airbnb demand patterns over time.

ts_nola <- ts(data = trends_nola$search_index,
              start = c(2019, 1),
              frequency = 12)

autoplot(ts_nola) +
  ylim(0, 100) +
  labs(title = 'Google Search Interest: "Airbnb New Orleans" (2019–Present)',
       y = "Search Index", x = NULL) +
  theme_minimal()

decomposed_nola <- decompose(ts_nola)
autoplot(decomposed_nola) +
  labs(title = 'Decomposed Time Series: "Airbnb New Orleans" Search Interest') +
  theme_minimal()

ggAcf(ts_nola) +
  labs(title = "Temporal Autocorrelation — Airbnb New Orleans Search Interest") +
  theme_minimal()

Box.test(ts_nola, type = "Ljung-Box")

hw_nola <- hw(y = ts_nola, h = 24)
autoplot(hw_nola) +
  labs(title = "Forecast: Airbnb New Orleans — Holt-Winters",
       y = "Search Index") +
  theme_minimal()
summary(hw_nola)
checkresiduals(hw_nola)


# -------------------------------------------------------
# 12: short COMPARISON — average seasonal pattern across risk groups

# This extracts just the seasonal component from each city's decomposition
# and plots them together — showing whether high-risk cities have a
# distinctly different seasonal shape than lower-risk cities.
# A dip in the June-November window for Miami and NOLA would directly
# support my project's climate risk argument.

# Extract seasonal components
seasonal_miami <- data.frame(
  month = 1:12,
  seasonal = decomposed_miami$seasonal[1:12],
  city = "Miami"
)

seasonal_nola <- data.frame(
  month = 1:12,
  seasonal = decomposed_nola$seasonal[1:12],
  city = "New Orleans"
)

# Doing the same for Chicago and Denver as lower-risk comparisons
ts_chi <- ts(data = trends_chi$search_index, start = c(2019,1), frequency = 12)
ts_den <- ts(data = trends_den$search_index, start = c(2019,1), frequency = 12)

decomposed_chi <- decompose(ts_chi)
decomposed_den <- decompose(ts_den)

seasonal_chi <- data.frame(
  month = 1:12,
  seasonal = decomposed_chi$seasonal[1:12],
  city = "Chicago"
)

seasonal_den <- data.frame(
  month = 1:12,
  seasonal = decomposed_den$seasonal[1:12],
  city = "Denver"
)

# Combining and plotting seasonal patterns
bind_rows(seasonal_miami, seasonal_nola, seasonal_chi, seasonal_den) %>%
  mutate(month_label = month.abb[month]) %>%
  mutate(month_label = factor(month_label, levels = month.abb)) %>%
  ggplot(aes(x = month_label, y = seasonal, color = city, group = city)) +
  geom_line(linewidth = 1) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = c("Miami" = "#E31A1C", "New Orleans" = "#FF7F00",
                                "Denver" = "#1F78B4", "Chicago" = "#33A02C")) +
  labs(title = "Seasonal Pattern in Airbnb Search Interest by City",
       subtitle = "Positive = above average for that month | Negative = below average\nShaded area = hurricane season (June–November)",
       x = "Month", y = "Seasonal Component", color = "City") +
  annotate("rect", xmin = 6, xmax = 11, ymin = -Inf, ymax = Inf,
           alpha = 0.1, fill = "red") +
  theme_minimal()

