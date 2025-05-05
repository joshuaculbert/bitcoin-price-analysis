# Bitcoin Price Analysis
# Author: Joshua Culbert
# Date: May 5, 2025

# Load packages
library(ggplot2)
library(quantmod)
library(TTR)
library(xts)
library(zoo)

# Data retrieval 
set.seed(123) # For reproducibility 
start_date <- as.Date('2019-01-01')
getSymbols('BTC-USD', src = 'yahoo', from = start_date, to = '2025-05-05')
btc <- `BTC-USD`[, "BTC-USD.Close"] # Extract closing prices
saveRDS(btc, 'btc_data.rds') # Save for reproducibility
summary(coredata(btc))
sum(is.na(btc)) # Verify no missing values

# Initial plot
btc_df <- data.frame(Date = index(btc), BTC.USD.Close = coredata(btc))
ggplot(btc_df, aes(x = Date, y = BTC.USD.Close)) +
  geom_line(colour = "#F7931A") + # Bitcoin orange
  theme_minimal() +
  labs(title = 'Bitcoin Closing Prices (2019-2025)',
       x = 'Date', y = 'Price (USD)') +
  annotate('text', x = min(btc_df$Date), y = max(btc_df$BTC.USD.Close),
           label = expression(P[t] == 'Closing Price at Time' ~ t),
           hjust = 0, vjust = 1)
ggsave('btc_price_plot.png')