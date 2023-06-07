# tsfreqband
Frequency Band Model Evaluation for Air Pollution Predictions

Data and functions to conduct overall and frequency band model evaluation of air pollution prediction models as described in [Krall, Keller & Peng (2022)](https://doi.org/10.1186/s12940-022-00844-0)

## Installation

To install `tsfreqband`, run:

```
remotes::install_github("kralljr/tsfreqband")
```

## Data

PM2.5 monitor concentrations and FAQSD model predictions from Krall, Keller, and Peng (2022) can be loaded using:

```
library(tsfreqband)
data(PM25)
```

The help page (`?PM25`) provides more details on this dataset

## Analysis

The file `pm-analysis.html` provides the overall and frequency band model evaluation results from the PM2.5 data described in Krall, Keller, and Peng (2022).

## Usage

The main function to apply frequency band model evaluation is `fbEval`.  See the help page (`?fbEval`) for details.  The dataset must have a date column labelled "date" indicating the day of observation, which should be formatted as a date.  

Other columns must include: location ID ("id", e.g., monitor ID), gold standard or reference pollution concentrations ("truth", e.g., monitoring values), and predictions ("pred", e.g., those we want to test against a reference).  These three names are specified as arguments to the function `fbEval`.  For example, the dataset `PM25` has columns of `date`, `monid`, `monitor`, and `FAQSD`.  We would specify `fbEval` as:

```
fbEval(PM25, id = "monid", truth = "monitor", pred = "FAQSD")
```

`fbEval` finds the frequency band comparison at the acute ([104,183) cycles per year), monthly ([6,12) cycles per year), and seasonal ([1,6) cycles per year) time bands.

The results from `fbEval` are a list of two items: `ts` and `meval`:

- `ts`: A data frame with the time series at the acute, monthly, and seasonal frequency bands for both the gold standard (truth) and the predictions (pred), as well as the overall time series.
- `meval`: A dataframe with the model evaluation results including the correlation (cor), log variance ratio (lvr) and root mean squared error (rmse) between the gold standard (truth) and predictions (pred) at the acute, monthly, seasonal frequency time bands and for the overall time series.

## Citation

Krall, J.R., Keller, J.P. & Peng, R.D. Assessing the health estimation capacity of air pollution exposure prediction models. Environ Health 21, 35 (2022). [https://doi.org/10.1186/s12940-022-00844-0](https://doi.org/10.1186/s12940-022-00844-0)