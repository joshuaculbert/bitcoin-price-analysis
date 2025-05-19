# Bitcoin Price Analysis
# Author: Joshua Culbert
# Date: May 19, 2025

# Load packages
library(ggplot2)
library(quantmod)
library(TTR)
library(xts)
library(zoo)
library(plotly)
library(scatterplot3d)
library(rgl)
library(plot3D)

# Data retrieval 
set.seed(123) # For reproducibility 
start_date <- as.Date('2015-01-01')
getSymbols('BTC-USD', src = 'yahoo', from = start_date, to = '2025-05-05')
btc <- `BTC-USD`[, "BTC-USD.Close"] # Extract closing prices
saveRDS(btc, 'btc_data.rds') # Save for reproducibility
summary(coredata(btc))
sum(is.na(btc)) # Verify no missing values

# Initial plot
btc_df <- data.frame(Date = index(btc), Price = coredata(btc))
ggplot(btc_df, aes(x = Date, y = BTC.USD.Close)) +
  geom_line(colour = "#F7931A") + # Bitcoin orange
  theme_minimal() +
  labs(title = 'Bitcoin Closing Prices (2015-2025)',
       x = 'Date', y = 'Price (USD)') +
  annotate('text', x = min(btc_df$Date), y = max(btc_df$BTC.USD.Close),
           label = 'P_t = Closing Price at Time t',
           hjust = 0, vjust = 1)
ggsave('figures/btc_price_plot.png')

# Calculate 30-day and 90-day moving averages
btc_ma30 <- rollmean(btc, k = 30, fill = NA, align = 'right')
btc_ma90 <- rollmean(btc, k = 90, fill = NA, align = 'right')
btc_combined <- merge(btc, btc_ma30, btc_ma90)
colnames(btc_combined) <- c('Price', 'MA30', 'MA90')

# Visualise price with moving averages and custom palette
btc_ma_df <- data.frame(Date = index(btc_combined), coredata(btc_combined))
my_palette <- c('Price' = '#F7931A', 
                '30-day MA' = '#333333', '90-day MA' = '#666666')
ggplot(btc_ma_df, aes(x = Date)) +
  geom_line(aes(y = Price, colour = 'Price')) +
  geom_line(aes(y = MA30, colour = '30-day MA')) +
  geom_line(aes(y = MA90, colour = '90-day MA')) +
  theme_minimal() +
  labs(title = 'Bitcoin Price with Moving Averages',
       x = 'Date', y = 'Price (USD)') +
  scale_colour_manual(values = my_palette)
ggsave('figures/btc_ma_plot.png')

# Enhance moving averages plot with a LOESS trend
ggplot(btc_ma_df, aes(x = Date)) +
  geom_line(aes(y = Price, colour = 'Price')) +
  geom_line(aes(y = MA30, colour = '30-day MA')) +
  geom_smooth(aes(y = Price), method = 'loess', colour = 'purple', se = TRUE) +
  theme_minimal() +
  labs(title = 'Bitcoin Price with LOESS Trend')
ggsave('figures/btc_loess_plot.png')

# Calculate daily returns and volatility
btc_returns <- diff(log(btc))[-1] # Log-returns
btc_volatility <- rollapply(btc_returns, width = 30, FUN = sd, 
                            fill = NA, align = 'right')
vol_df <- data.frame(Date = index(btc_volatility), 
                     Volatility = coredata(btc_volatility))
ggplot(vol_df, aes(x = Date, y = BTC.USD.Close)) +
  geom_line() +
  theme_minimal() +
  labs(title = 'Bitcoin 30-Day Volatility', x = 'Date', y = 'Volatility')
ggsave('figures/btc_volatility_plot.png')

# Faceted plot of volatility by year
vol_df$Year <- format(vol_df$Date, '%Y')
ggplot(vol_df, aes(x = Date, y = BTC.USD.Close)) +
  geom_line() +
  facet_wrap(~Year, scales = 'free_x') +
  scale_x_date(date_labels = '%b', date_breaks = '2 months') + 
  theme_minimal() +
  labs(title = 'Bitcoin Volatility by Year', y = 'Volatility') 
ggsave('figures/btc_volatility_faceted.png')

# 3D scatterplot (price, volatility, volume)
btc_volume <- `BTC-USD`[, 'BTC-USD.Volume']
vol_df_aligned <- vol_df[vol_df$Date %in% btc_df$Date, ]
# Ensure same length by merging data
plot_data <- merge(btc_df, vol_df_aligned, by = 'Date')
plot_data <- merge(plot_data, btc_volume, by.x = 'Date', by.y = 'row.names')
scatterplot3d(plot_data$BTC.USD.Close.x, plot_data$BTC.USD.Close.y,
              coredata(plot_data$`BTC-USD.Volume`),
              color = as.numeric(factor(plot_data$Year)),
              main = 'Bitcoin Price, Volatility, Volume (2015-2025)',
              xlab = 'Price (USD)', ylab = 'Volatility', zlab = 'Volume')
pdf('figures/btc_3d_scatter.pdf')
scatterplot3d(plot_data$BTC.USD.Close.x, plot_data$BTC.USD.Close.y,
              coredata(plot_data$`BTC-USD.Volume`),
              color = as.numeric(factor(plot_data$Year)),
              main = 'Bitcoin Price, Volatility, Volume (2015-2025)',
              xlab = 'Price (USD)', ylab = 'Volatility', zlab = 'Volume')
dev.off()

# Perform FFT for periodicity detection
btc_detrended <- diff(btc)[-1] # Remove trend
fft_result <- fft(btc_detrended)
n <- length(btc_detrended)
freq <- (0:(n - 1)) / n # Normalised frequencies
amplitude <- Mod(fft_result) / n # Normalise amplitude
spectrum_df <- data.frame(Frequency = freq[1:(n / 2)], 
                          Amplitude = amplitude[1:(n / 2)])
ggplot(spectrum_df, aes(x = Frequency, y = BTC.USD.Close)) +
  geom_line() +
  theme_minimal() +
  labs(title = 'Bitcoin Price FFT Spectrum', x = 'Frequency', y = 'Amplitude')
ggsave('figures/btc_fft_plot.png')

# Compute periodogram 
spec <- spec.pgram(btc_detrended, plot = FALSE)
spec_df <- data.frame(Freq = spec$freq, Spec = spec$spec)
ggplot(spec_df, aes(x = Freq, y = Spec)) +
  geom_line() +
  theme_minimal() +
  labs(title = 'Bitcoin Price Periodogram', 
       x = 'Frequency', y = 'Spectral Density')
ggsave('figures/btc_periodogram_plot.png')

# Create interactive plot
plot_ly(btc_df, x = ~Date, y = ~BTC.USD.Close, 
        type = 'scatter', mode = 'lines') %>%
  layout(title = 'Interactive Bitcoin Price Trend', 
         xaxis = list(title = 'Date'), yaxis = list(title = 'Price (USD)'))

# Create interactive 3D point cloud
plot3d(plot_data$BTC.USD.Close.x, plot_data$BTC.USD.Close.y,
       coredata(plot_data$`BTC-USD.Volume`),
       col = as.numeric(factor(plot_data$Year)),,
       xlab = 'Price', ylab = 'Volatility', zlab = 'Volume')
if (capabilities('X11') && rgl::rgl.useNULL() == FALSE) {
  rgl.snapshot('figures/btc_3d_cloud.png')
} else {
  rgl::writeWebGL(dir = 'figures', filename = 'btc_3d_cloud.html')
  warning('rgl snapshots not supported; 
          saved WebGL output to btc_3d_cloud.html')
}