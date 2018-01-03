#' Computing spillover from a fevd
#'
#' This function is an internal implementation of the spillover.
#' The spillover is in general defined as the contribution of the other variables
#' to the fevd of the self variable. This function computes the spillover as the 
#' contribution of the diagonal elements of the fevd to the total sum of the matrix.
#' The other functions are just wrappers around this function. In general, other spillovers
#' could be implemented using this function.
#'
#' @param func name of the function that returns FEVD for the estimtate est
#' @param est the estimate of a system, typically VAR estimate in our case
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#' 		should be high enough so that it won't change with additional period
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#' @return spillover_table object
#'
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spillover <- function(func, est, n.ahead, no.corr = F) {
	f <- get(func)
	tab <- f(est, n.ahead, no.corr = no.corr)
	if (class(est)%in%c("varest","vec2var")) {
		rownames(tab) <- colnames(tab) <- colnames(est$y)
	} else if (class(est)=="BigVAR.results") {
		rownames(tab) <- colnames(tab) <- colnames(est@Data)
	}
	return(structure(list(tables = list(tab), bounds = c(pi+0.00001, 0), date = NULL), class = "spillover_table"))
}

#' Computing the decomposed spillover from a fevd
#'
#' This function is an internal implementation of the frequency spillover.
#' We apply the identification scheme suggested by fevd to the frequency
#' decomposition of the transfer functions from the estimate est.
#'
#' @param func name of the function that returns FEVD for the estimtate est
#' @param est the estimate of a system, typically VAR estimate in our case
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#' 		should be high enough so that it won't change with additional period
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#' @param partition defines the frequency partitions to which the spillover should be decomposed
#'
#' @return spillover_table object
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverFft <- function(func, est, n.ahead, partition, no.corr = F) {
	f <- get( func )
	new_p <- getPartition( partition, n.ahead )
	
	range <- sort( unique( do.call(c, new_p) ) )
	
	decomp <- f(est, n.ahead, no.corr = no.corr, range = range)
	if (class(est)%in%c("varest","vec2var")) {
		for (i in 1:length(decomp)) {
			rownames(decomp[[i]]) <- colnames(decomp[[i]]) <- colnames(est$y)
		}
	} else if (class(est)=="BigVAR.results") {
		for (i in 1:length(decomp)) {
			rownames(decomp[[i]]) <- colnames(decomp[[i]]) <- colnames(est@Data)
		}
	}
	tables <- lapply(new_p, function(j) Reduce('+', decomp[j]))
	
	return(structure(list(tables = tables, bounds = partition, date = NULL), class = "spillover_table"))
}

#' Computing spillover from a fevd according to Diebold Yilmaz (2009)
#'
#' This function is an internal implementation of the spillover.
#' The spillover is in general defined as the contribution of the other variables
#' to the fevd of the self variable. This function computes the spillover as the 
#' contribution of the diagonal elements of the fevd to the total sum of the matrix.
#' The other functions are just wrappers around this function. In general, other spillovers
#' could be implemented using this function.
#'
#' @param est the estimate of a system, typically VAR estimate in our case
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#' 		should be high enough so that it won't change with additional period
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#' @return spillover_table object
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverDY09 <- function(est, n.ahead = 100, no.corr) {
	return(spillover("fevd", est, n.ahead, no.corr = no.corr))
}

#' Computing spillover from a generalized fevd according to Diebold Yilmaz (2012)
#'
#' This function is an internal implementation of the spillover.
#' The spillover is in general defined as the contribution of the other variables
#' to the fevd of the self variable. This function computes the spillover as the 
#' contribution of the diagonal elements of the fevd to the total sum of the matrix.
#' The other functions are just wrappers around this function. In general, other spillovers
#' could be implemented using this function.
#'
#' @param est the estimate of a system, typically VAR estimate in our case
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#' 		should be high enough so that it won't change with additional period
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#' @return spillover_table object
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverDY12 <- function(est, n.ahead = 100, no.corr) {
	return(spillover("genFEVD", est, n.ahead, no.corr = no.corr))
}

#' Computing the decomposed spillover from a fevd as defined by Barunik, Krehlik (2018)
#'
#' This function is an internal implementation of the frequency spillover.
#' We apply the identification scheme suggested by fevd to the frequency
#' decomposition of the transfer functions from the estimate est.
#'
#' @param est the estimate of a system, typically VAR estimate in our case
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#' 		should be high enough so that it won't change with additional period
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#' @param partition defines the frequency partitions to which the spillover should be decomposed
#'
#' @return spillover_table object
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverBK09 <- function(est, n.ahead = 100, no.corr, partition) {
	return(spilloverFft("fftFEVD", est = est, n.ahead = n.ahead, partition = partition, no.corr = no.corr))
}

#' Computing the decomposed spillover from a generalized fevd as defined by Barunik, Krehlik (2018)
#'
#' This function is an internal implementation of the frequency spillover.
#' We apply the identification scheme suggested by fevd to the frequency
#' decomposition of the transfer functions from the estimate est.
#'
#' @param est the estimate of a system, typically VAR estimate in our case
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#' 		should be high enough so that it won't change with additional period
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#' @param partition defines the frequency partitions to which the spillover should be decomposed
#'
#' @return spillover_table object
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverBK12 <- function(est, n.ahead = 100, no.corr, partition) {
	return(spilloverFft("fftGenFEVD", est, n.ahead, partition, no.corr = no.corr))
}

