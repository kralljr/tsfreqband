

#' @name fbEval
#' @title Apply frequency band model evaluation
#' @param dat Dataset with columns of date, id (monid), truth (e.g., monitoring data), and pred (e.g., model predictions).  All other columns must refer to spatial location/model 
#' @param id Name of id column (e.g., monitor ID)
#' @param truth Name of column of true concentrations
#' @param pred Name of column of model predictions
#' @author Jenna Krall
#' @export
#' @examples  
#' data(PM25)
#' fbresult <- fbEval(pm)
#' fbresult$meval
fbEval <-  function(dat, id = "monid", truth = "monitor", pred = "FAQSD") {
    
    # rename columns
    dat <- dplyr::rename(dat, truth = all_of(truth),
                         pred = all_of(pred),
                         id = all_of(id)) %>%
        # check contunous ts
        na.omit() %>%
        dplyr::group_by(id) %>% 
        dplyr::mutate(lag = lag(date), diff = as.numeric(date - lag)) %>%
        dplyr::ungroup()
    # If gaps in data, need to impute
    maxdiff <- max(dat$diff, na.rm = T)
    if(maxdiff > 1) {
        stop("Need to impute data for continuous time series")
    }
    
    
    # remove extra columns 
    dat <- dplyr::select(dat, -c(lag, diff))

    # get time series
    ts <- fbTimeSeries(dat, id)
    
    # evaluate
    meval <- dplyr::group_by(ts, id, cut) %>%
        # get metrics
        dplyr::summarize(cor = cor(pred, truth, use = "pair"), 
                         lvr = lvr(truth, pred), 
                         rmse =  rmsefun(truth, pred, sd = T))
    
    # ts pivot to long
    ts <- tidyr::pivot_longer(ts, truth  : pred, names_to = "model")
    
    # return decomposed time series and model evaluation
    return(list(ts = ts, meval = meval))
}





#' @name fbTimeSeries
#' @title Frequency band time series
#' @param dat Dataset with columns of date, id (monid), and value.  All other columns must refer to spatial location/model 
#' @param id Name of id column (e.g., monitor ID)
#' @author Jenna Krall, Joshua P. Keller
fbTimeSeries <- function(dat, id = "monid") {
    
    # pivot longer
    dat <- tidyr::pivot_longer(dat, truth: pred, names_to = "model")
    
    # overall
    overall <- dplyr::mutate(dat, cut = "overall")
    
    # nest by location/model
    fbts <- tidyr::nest(dat, data = c(date, value)) %>%
        # decomp breaks null = default (seasonal, monthly, acute)
        dplyr::mutate(ts = purrr::map(data, ~ wrap_tsdecomp_dat(dat = .))) %>%
        dplyr::select(-data) %>%
        tidyr::unnest(ts) %>%
        # merge in overall time series
        dplyr::full_join(overall) %>%
        na.omit() %>%
        dplyr::ungroup() %>%
        tidyr::pivot_wider(names_from = "model")
    
    
    
    # return overall and fb time series
    return(fbts)
}

#' @name wrap_tsdecomp_dat
#' @title Wrapper function to run tsdecomp for PM2.5 data
#' @param dat Dataset with column named value indicating time series
#' @param decomp_breaks Vector of breaks for decomposition (if null, specify to see seasonal, monthly, acute in simulated data)
#' @param season Whether to return season, month, acute (as in Krall et al. 2021+)
#' @author Jenna Krall, Joshua P. Keller
wrap_tsdecomp_dat <- function(dat, decomp_breaks = NULL, season = T) {
    # number of days
    n_days <- nrow(dat)
    
    # remove missing data
    dat <- dat[complete.cases(dat), ]
    # arrange by date
    dat <- dplyr::arrange(dat, date)
    
    # find breaks for time series decomposition
    if(is.null(decomp_breaks)) {
        #dominici 2003 harvesting paper
        breaks <- floor(n_days / (c(60, 30, 14, 7, 3.5)))
        decomp_breaks <- c(1, breaks, n_days)
    }
    
    
    # get time series decomposition
    ts1 <- tsModel::tsdecomp(dat$value, breaks = decomp_breaks)
    ts1 <- as.matrix(ts1)
    
    #restrict to seasonal, monthly, acute
    if(season)  {
        ts1 <- ts1[, c(1,  2, ncol(ts1))]
        colnames(ts1) <- c("seasonal", "monthly", "acute")
    }
    
    # format output
    dat <- dplyr::select(dat, -value)
    ts1 <- data.frame(dat, ts1)
    
    # fix range
    ts1 <- tidyr::pivot_longer(ts1, names_to = "cut", -date) 
    
    return(ts1)
}










#' \code{lvr} Log variance ratio
#' 
#' @param truth True time series
#' @param error Error-prone (predicted) time series
lvr <- function(truth, error) {
    dat <- data.frame(truth, error)
    wh <- complete.cases(dat)
    log(var(error[wh]) / var(truth[wh]))
}




#' \code{rmsefun} Root mean square error
#' 
#' @param truth True time series
#' @param error Error-prone (predicted) time series
#' @param sd Whether to standardize by true standard deviation
rmsefun <- function(truth, error, sd = F) {
    mn <- sqrt(mean((truth - error)^2, na.rm = T))
    if(sd) {
        mn <- mn / sd(truth)
    }
    mn
}
