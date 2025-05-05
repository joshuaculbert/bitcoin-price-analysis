# Bitcoin Price Analysis (2019–2025)

## Overview

This project analyses Bitcoin price trends using R (`quantmod`, `zoo`, `TTR`, `ggplot2`). It includes time series analysis, volatility, and Fourier analysis to detect periodicities.

## Setup

```R
install.packages("renv")
renv::restore() # Installs exact package versions
```

## Data 
Bitcoin closing prices (USD) from Yahoo Finance, 2019-2025. The 2019 start focuses on recent market dynamics, but the code supports other ranges (e.g., 2015–2025).

## Objectives
- Analyse price trends and moving averages.
- Compute volatility (30-day rolling SD of log-returns).
- Apply FFT and periodogram to identify cycles.
- Produce a polished R Markdown report.

## Tools
- R: quantmod, zoo, xts, TTR, ggplot2, stats
- GitHub Pages: HTML report
- License: MIT