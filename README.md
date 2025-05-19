# Bitcoin Price Analysis (2015-2025)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-4.5.x-blue.svg)](https://www.r-project.org/)

## Overview

This project analyses Bitcoin price trends from 2015 to 2025 using R. It focuses on time series analysis, volatility, and Fourier transforms, using data from Yahoo Finance via `quantmod`. View the full report: [Bitcoin Price Analysis Report](https://joshuaculbert.github.io/bitcoin-price-analysis/report.html).

## Features
- **Price Trends**: Visualises Bitcoin closing prices with moving averages and LOESS trends.
- **Volatility Analysis**: Computes and plots 30-day rolling volatility.
- **Fourier Analysis**: Identifies periodicities using FFT and periodograms.
- **3D Visualisations**: Interactive 3D scatterplots of price, volatility, and volume.
- **Reproducibility**: Uses `renv` for package management and a custom bash script (`copy_to_renv.sh`) for dependency copying.
  
## Setup
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/joshuaculbert/bitcoin-price-analysis
   cd bitcoin_price_analysis
   ```
2. **Install R and Dependencies**:
   - Ensure R 4.5.x is installed.
   - Restore packages:
     ```R
     install.packages("renv")
     renv::restore() # Installs exact package versions
     ```
3. **Run the Analysis**:
   ```R
   source("bitcoin_price_analysis.R")
   ```
4. **Generate the Report**:
   ```R
   rmarkdown::render("report.Rmd", output_dir = "docs")
   ```

## Directory Structure
- `bitcoin_price_analysis.R`: Main R script for data retrieval and visualisations.
- `report.Rmd`: R Markdown report summarising findings.
- `figures/`: Output directory for plots (PNG, PDF).
- `docs/`: Output directory for the report (`report.html`).
- `scripts/copy_to_renv.sh`: Bash script for copying R pagckages to `renv`.
- `btc_data.rds`: Saved Bitcoin price data.
- `renv/`: `renv` environment for package management.

## Data 
Bitcoin closing prices (USD) from Yahoo Finance, 2015-2025. The 2015 start captures a decade of market dynamics, but the code supports other ranges (e.g., 2020–2025).

## Requirements
- R 4.5.x
- Packages: `ggplot2`, `quantmod`, `TTR`, `xts`, `zoo`, `plotly`, `scatterplot3d`, `rgl`, `plot3D`
- Ubuntu 22.04.5 or compatible OS

## Future Extensions
- **Volatility Contour Plot**: Visualise volatility as a 2D contour plot to highlight market turbulence patterns, replacing the 3D volatility surface.
- **GARCH Volatility Forecasting**: Implement a GARCH model to predict future volatility.
- **Interactive Dashboard**: Develop a `flexdashboard` with `plotly` visualisations for an interactive user experience.
- **Alternative Detrending for FFT**: Use advanced detrending (e.g., Hodrick-Prescott filter) to improve periodicity detection.
- **Outlier Detection**: Add statistical tests to identify and handle price data outliers for robust analysis.
- **Wavelet Transform Analysis**: Apply wavelet transforms to decompose price series into time-frequency components, capturing localised trends and volatility patterns.

## Author

Joshua Culbert
- Email: joshuaculbert@outlook.com.au
- GitHub: https://github.com/joshuaculbert
- Linkedin: https://www.linkedin.com/in/joshua-culbert/
  
## License 

MIT License

