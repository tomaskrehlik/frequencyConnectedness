#' Computing rolling spillover
#'
#' This function computes the rolling spillover using the standard VAR estimate.
#' We implement the parallel version for faster processing. The window is of fixed window
#' and is rolled over the data. Interpretation of the other parameters is the same as in the
#' standard computation of spillover. For usage, see how spilloverRollingDY09, etc. are implemented.
#' 
#' @param func_spill name of the function that returns FEVD for the estimtate est
#' @param params_spill parameters from spillover estimation function as a list
#' @param func_est name of the estimation function
#' @param params_est parameters from the estimation function as a list
#' @param window length of the window to be rolled
#' @param data variable containing the dataset
#' @param cluster either NULL for no parallel processing or the variable containing the cluster.
#'
#' @return A corresponding spillover value on a given freqeuncy band, ordering of bands corresponds to the ordering of original bounds.
#'
#' @import pbapply
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverRolling <- function(func_spill, params_spill, func_est, params_est, data, window, cluster = NULL) {
    # Get the spillover estimation function
    spill <- get(func_spill)
    # Get the estimation function
    est <- get(func_est)

    # Make the estimation call that is dependent on the offset only
    spill_est_call <- function(j) {
        est_call <- function(j) do.call(est, c(list(data[(1:window)+j,]), params_est))
        return(do.call(spill, c(list(est_call(j)), params_spill)))
    }

    if (!is.null(cluster)) {
        parallel::clusterExport(cluster, c("data", "spill_est_call"), envir=environment())
    }

    out <- pbapply::pblapply(0:(nrow(data)-window), spill_est_call, cl = cluster)

    if ("zoo" %in% class(data)) {
        dates <- zoo::index(data)[window:nrow(data)]
        for (i in 1:length(out)) {
            out[[i]]$date <- as.POSIXct(dates[i])
        }
    }

    return(structure(list(list_of_tables = out), class = "list_of_spills"))
}

#' Computing rolling spillover according to Diebold Yilmaz (2009)
#'
#' This function computes the rolling spillover using the standard VAR estimate.
#' We implement the parallel version for faster processing. The window is of fixed window
#' and is rolled over the data. Interpretation of the other parameters is the same as in the
#' standard computation of spillover.
#' 
#' @param data variable containing the dataset
#' @param window length of the window to be rolled
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#'      should be high enough so that it won't change with additional period
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#'      set to zero
#' @param func_est estimation function, usually would be VAR or BigVAR function to estimate
#'      the multivariate system
#' @param params_est parameters passed to the estimation function, as a list, for parameters
#'      refer to documentation of the estimating function
#' @param cluster either NULL for no parallel processing or the variable containing the cluster.
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverRollingDY09 <- function(data, n.ahead = 100, no.corr, func_est, params_est, window, cluster = NULL) {
    return(spilloverRolling("spilloverDY09", params_spill = list(n.ahead = n.ahead, no.corr = no.corr), func_est, params_est, data, window, cluster = cluster))
}

#' Computing rolling spillover from the generalized fevd according to Diebold Yilmaz (2012)
#'
#' This function computes the rolling spillover using the standard VAR estimate.
#' We implement the parallel version for faster processing. The window is of fixed window
#' and is rolled over the data. Interpretation of the other parameters is the same as in the
#' standard computation of spillover.
#' 
#' @param data variable containing the dataset
#' @param window length of the window to be rolled
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#'      should be high enough so that it won't change with additional period
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#'      set to zero
#' @param func_est estimation function, usually would be VAR or BigVAR function to estimate
#'      the multivariate system
#' @param params_est parameters passed to the estimation function, as a list, for parameters
#'      refer to documentation of the estimating function
#' @param cluster either NULL for no parallel processing or the variable containing the cluster.
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverRollingDY12 <- function(data, n.ahead = 100, no.corr, func_est, params_est, window, cluster = NULL) {
    return(spilloverRolling("spilloverDY12", params_spill = list(n.ahead = n.ahead, no.corr = no.corr), func_est, params_est, data, window, cluster = cluster))
}

#' Computing rolling frequency spillover from a fevd as defined by Barunik, Krehlik (2018)
#'
#' This function computes the rolling spillover using the standard VAR estimate.
#' We implement the parallel version for faster processing. The window is of fixed window
#' and is rolled over the data. Interpretation of the other parameters is the same as in the
#' standard computation of spillover.
#' 
#' @param data variable containing the dataset
#' @param window length of the window to be rolled
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#'      should be high enough so that it won't change with additional period
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#'      set to zero
#' @param partition how to split up the estimated spillovers into frequency bands. Should be
#'      a vector of bound points that starts with 0 and ends with pi+0.00001.
#' @param func_est estimation function, usually would be VAR or BigVAR function to estimate
#'      the multivariate system
#' @param params_est parameters passed to the estimation function, as a list, for parameters
#'      refer to documentation of the estimating function
#' @param cluster either NULL for no parallel processing or the variable containing the cluster.
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverRollingBK09 <- function(data, n.ahead = 100, no.corr, partition, func_est, params_est, window, cluster = NULL) {
    return(spilloverRolling("spilloverBK09", params_spill = list(n.ahead = n.ahead, no.corr = no.corr, partition = partition), func_est, params_est, data, window, cluster = cluster))
}

#' Computing rolling frequency spillover from a generalized fevd as defined by Barunik, Krehlik (2018)
#'
#' This function computes the rolling spillover using the standard VAR estimate.
#' We implement the parallel version for faster processing. The window is of fixed window
#' and is rolled over the data. Interpretation of the other parameters is the same as in the
#' standard computation of spillover.
#' 
#' @param data variable containing the dataset
#' @param window length of the window to be rolled
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#'      should be high enough so that it won't change with additional period
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#'      set to zero
#' @param cluster either NULL for no parallel processing or the variable containing the cluster.
#' @param func_est a name of the function to estimate with, for example "var" for VAR from vars package
#' @param params_est a list of the parameters to pass to the function besides the data that are passed as a first element.
#' @param partition defines the frequency partitions to which the spillover should be decomposed
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverRollingBK12 <- function(data, n.ahead = 100, no.corr, partition, func_est, params_est, window, cluster = NULL) {
    return(spilloverRolling("spilloverBK12", params_spill = list(n.ahead = n.ahead, no.corr = no.corr, partition = partition), func_est, params_est, data, window, cluster = cluster))
}

#' The simulated time-series
#'
#' The dataset includes three simulated processes with spillover dynamics.
#'
#' @name exampleSim
#' @docType data
#' @author Tomas Krehlik \email{tomas.krehlik@@gmail.com}
#' @keywords data
NULL

#' Volatilities from Ox Man Institute
#'
#' The dataset includes median realised volatilities of some financial indices
#'
#' @name volatilities
#' @docType data
#' @author Tomas Krehlik \email{tomas.krehlik@@gmail.com}
#' @keywords data
NULL