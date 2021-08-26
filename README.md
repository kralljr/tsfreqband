# tsfreqband
Frequency Band Model Evaluation for Air Pollution Predictions

Data and functions to conduct overall and frequency band model evaluation of air pollution prediction models

## Installation

To install `tsfreqband`, run:

```
remotes::install_github("kralljr/tsfreqband")
```

## Data

PM2.5 monitor concentrations and FAQSD model predictions from Krall, Keller, and Peng (2021+) can be loaded using:

```
library(tsfreqband)
data(PM25)
```

The help page (`?PM25`) provides more details on this dataset

## Analysis

The file `pm-analysis.html` provides the overall and frequency band model evaluation results from the PM2.5 data described in Krall, Keller, and Peng (2021+).
