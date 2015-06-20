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
#' @param table boolean whether the full spillover table should be returned
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#'
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spillover <- function(func, est, n.ahead, table, no.corr = F) {
	f <- get(func)
	if (table) {
		return(f(est, n.ahead, no.corr = no.corr))
	} else {
		return(100*(1 - sum(diag(f(est, n.ahead, no.corr = no.corr)))/est$K))
	}
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
#' @param table boolean whether the full spillover table should be returned
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#' @param partition defines the frequency partitions to which the spillover should be decomposed
#' @param absolute boolean defining whether to compute the within or absolute spillover
#'
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverFft <- function(func, est, n.ahead, partition, table, absolute, no.corr = F) {
	f <- get(func)
	range <- sort(unique(do.call(c, getPartition(partition, n.ahead))))
	if (table) {
		decomp <- f(est, n.ahead, no.corr = no.corr, range = range)
		return(lapply(getPartition(partition, n.ahead), function(j) Reduce('+', decomp[j])))
	} else {
		if (absolute) {
			decomp <- f(est, n.ahead, no.corr = no.corr, range = range)
			# print(sum(Reduce('+', decomp)))
			# print(sum(Reduce('+', decomp[-1])))
			# print(unique(unlist(getPartition(partition, n.ahead))))
			# return(100*sapply(lapply(getPartition(partition, n.ahead), function(j) Reduce('+', decomp[j])), function(i) sum(i)/est$K  - sum(diag(i))/sum(Reduce('+', decomp[unique(unlist(getPartition(partition, n.ahead)))])) ))
			
			return(100*sapply(lapply(getPartition(partition, n.ahead), function(j) Reduce('+', decomp[j])), function(i) sum(i)/est$K  - sum(diag(i))/sum(Reduce('+', decomp[range])) ))
		} else {
			decomp <- f(est, n.ahead, no.corr = no.corr, range = range)
			return(100*sapply(lapply(getPartition(partition, n.ahead), function(j) Reduce('+', decomp[j])), function(i) 1  - sum(diag(i))/sum(i) ))
		}
		
	}
}

#' Computing rolling spillover
#'
#' This function computes the rolling spillover using the standard VAR estimate.
#' We implement the parallel version for faster processing. The window is of fixed window
#' and is rolled over the data. Interpretation of the other parameters is the same as in the
#' standard computation of spillover.
#' 
#' @param func name of the function that returns FEVD for the estimtate est
#' @param data variable containing the dataset
#' @param p lags in the VAR estimate.
#' @param type which type of VAR to use, see help for VAR from vars package
#' @param window length of the window to be rolled
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#' 		should be high enough so that it won't change with additional period
#' @param table boolean whether the full spillover table should be returned
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#' @param cluster either NULL for no parallel processing or the variable containing the cluster.
#'
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverRolling <- function(func, data, p, type, window, n.ahead, no.corr, table = F, cluster = NULL) {
	f <- get(func)
	if (table) {
		if (is.null(cluster)) {
			return(lapply(0:(nrow(data)-window), function(j) f(vars::VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table, no.corr = no.corr)))
		} else {
			parallel::clusterExport(cluster, c("data", "p", "type", "window", "n.ahead", "table", "f", "VAR", "fevd", "irf", "no.corr"), envir=environment())
			return(parallel::parLapply(cl = cluster, 0:(nrow(data)-window), function(j) f(vars::VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table, no.corr = no.corr)))
		}
	} else {
		if (is.null(cluster)) {
			return(sapply(0:(nrow(data)-window), function(j) f(vars::VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table, no.corr = no.corr)))
		} else {
			parallel::clusterExport(cluster, c("data", "p", "type", "window", "n.ahead", "table", "f", "VAR", "fevd", "irf", "no.corr"), envir=environment())
			return(parallel::parSapply(cl = cluster, 0:(nrow(data)-window), function(j) f(vars::VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table, no.corr = no.corr)))
		}
	}
}

#' Computing rolling frequency spillover
#'
#' This function computes the rolling spillover using the standard VAR estimate.
#' We implement the parallel version for faster processing. The window is of fixed window
#' and is rolled over the data. Interpretation of the other parameters is the same as in the
#' standard computation of spillover.
#' 
#' @param func name of the function that returns FEVD for the estimtate est
#' @param data variable containing the dataset
#' @param p lags in the VAR estimate.
#' @param type which type of VAR to use, see help for VAR from vars package
#' @param window length of the window to be rolled
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#' 		should be high enough so that it won't change with additional period
#' @param partition defines the frequency partitions to which the spillover should be decomposed
#' @param table boolean whether the full spillover table should be returned
#' @param absolute boolean defining whether to compute the within or absolute spillover
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#' @param cluster either NULL for no parallel processing or the variable containing the cluster.
#'
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>


spilloverRollingFft <- function(func, data, p, type, window, n.ahead, partition, absolute, no.corr, table = F, cluster = NULL) {
	f <- get(func)
	if (table) {
		if (is.null(cluster)) {
			return(lapply(0:(nrow(data)-window), function(j) f(vars::VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table, partition = partition, absolute = absolute, no.corr = no.corr)))
		} else {
			parallel::clusterExport(cluster, c("data", "p", "type", "window", "n.ahead", "table", "f", "VAR", "fevd", "irf", "absolute", "bounds", "no.corr"), envir=environment())
			return(parallel::parLapply(cl = cluster, 0:(nrow(data)-window), function(j) f(vars::VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, partition = partition, table = table, absolute = absolute, no.corr = no.corr)))
		}	
	} else {
		if (is.null(cluster)) {
			return(sapply(0:(nrow(data)-window), function(j) f(vars::VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table, partition = partition, absolute = absolute, no.corr = no.corr)))
		} else {
			parallel::clusterExport(cluster, c("data", "p", "type", "window", "n.ahead", "table", "f", "VAR", "fevd", "irf", "absolute", "bounds", "no.corr"), envir=environment())
			return(parallel::parSapply(cl = cluster, 0:(nrow(data)-window), function(j) f(vars::VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, partition = partition, table = table, absolute = absolute, no.corr = no.corr)))
		}
	}
	
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
#' @param table boolean whether the full spillover table should be returned
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverDY09 <- function(est, n.ahead = 100, no.corr, table = F) {
	return(spillover("fevd", est, n.ahead, table, no.corr = no.corr))
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
#' @param table boolean whether the full spillover table should be returned
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverDY12 <- function(est, n.ahead = 100, no.corr, table = F) {
	return(spillover("genFEVD", est, n.ahead, table, no.corr = no.corr))
}

#' Computing the decomposed spillover from a fevd as defined by Barunik, Krehlik (2015)
#'
#' This function is an internal implementation of the frequency spillover.
#' We apply the identification scheme suggested by fevd to the frequency
#' decomposition of the transfer functions from the estimate est.
#'
#' @param est the estimate of a system, typically VAR estimate in our case
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#' 		should be high enough so that it won't change with additional period
#' @param table boolean whether the full spillover table should be returned
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#' @param partition defines the frequency partitions to which the spillover should be decomposed
#' @param absolute boolean defining whether to compute the within or absolute spillover
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverBK09 <- function(est, n.ahead = 100, no.corr, partition, table = F, absolute = T) {
	return(spilloverFft("fftFEVD", est = est, n.ahead = n.ahead, partition = partition, table = table, absolute = absolute, no.corr = no.corr))
}

#' Computing the decomposed spillover from a generalized fevd as defined by Barunik, Krehlik (2015)
#'
#' This function is an internal implementation of the frequency spillover.
#' We apply the identification scheme suggested by fevd to the frequency
#' decomposition of the transfer functions from the estimate est.
#'
#' @param est the estimate of a system, typically VAR estimate in our case
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#' 		should be high enough so that it won't change with additional period
#' @param table boolean whether the full spillover table should be returned
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#' @param partition defines the frequency partitions to which the spillover should be decomposed
#' @param absolute boolean defining whether to compute the within or absolute spillover
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverBK12 <- function(est, n.ahead = 100, no.corr, partition, table = F, absolute = T) {
	return(spilloverFft("fftGenFEVD", est, n.ahead, partition, table, absolute, no.corr = no.corr))
}

#' Computing rolling spillover according to Diebold Yilmaz (2009)
#'
#' This function computes the rolling spillover using the standard VAR estimate.
#' We implement the parallel version for faster processing. The window is of fixed window
#' and is rolled over the data. Interpretation of the other parameters is the same as in the
#' standard computation of spillover.
#' 
#' @param data variable containing the dataset
#' @param p lags in the VAR estimate.
#' @param type which type of VAR to use, see help for VAR from vars package
#' @param window length of the window to be rolled
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#' 		should be high enough so that it won't change with additional period
#' @param table boolean whether the full spillover table should be returned
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#' @param cluster either NULL for no parallel processing or the variable containing the cluster.
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverRollingDY09 <- function(data, p, type, window, n.ahead, table = F, no.corr, cluster = NULL) {
	return(spilloverRolling("spilloverDY09", data, p, type, window, n.ahead, table = table, cluster = cluster, no.corr = no.corr))
}

#' Computing rolling spillover from the generalized fevd according to Diebold Yilmaz (2012)
#'
#' This function computes the rolling spillover using the standard VAR estimate.
#' We implement the parallel version for faster processing. The window is of fixed window
#' and is rolled over the data. Interpretation of the other parameters is the same as in the
#' standard computation of spillover.
#' 
#' @param data variable containing the dataset
#' @param p lags in the VAR estimate.
#' @param type which type of VAR to use, see help for VAR from vars package
#' @param window length of the window to be rolled
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#' 		should be high enough so that it won't change with additional period
#' @param table boolean whether the full spillover table should be returned
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#' @param cluster either NULL for no parallel processing or the variable containing the cluster.
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @examples
#' w<-c(0,0)
#' C<-rbind(c(1,0.0),c(0.0,1))
#' A1<-rbind(c(0.9,0.09),c(0.09,0.9))
#' A2<-rbind(c(0.9,0.03),c(0.03,0.9))
#' data <- rbind(mAr.sim(w,A1,C,N=1000), mAr.sim(w,A2,C,N=1000))
#' plot(spilloverRollingDY12(data, p = 1, type = "const", window = 200, n.ahead = 100, table = F, no.corr = F), type="l")

spilloverRollingDY12 <- function(data, p, type, window, n.ahead, table = F, no.corr, cluster = NULL) {
	return(spilloverRolling("spilloverDY12", data, p, type, window, n.ahead, table = table, cluster = cluster, no.corr = no.corr))
}

#' Computing rolling frequency spillover from a fevd as defined by Barunik, Krehlik (2015)
#'
#' This function computes the rolling spillover using the standard VAR estimate.
#' We implement the parallel version for faster processing. The window is of fixed window
#' and is rolled over the data. Interpretation of the other parameters is the same as in the
#' standard computation of spillover.
#' 
#' @param data variable containing the dataset
#' @param p lags in the VAR estimate.
#' @param type which type of VAR to use, see help for VAR from vars package
#' @param window length of the window to be rolled
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#' 		should be high enough so that it won't change with additional period
#' @param partition defines the frequency partitions to which the spillover should be decomposed
#' @param table boolean whether the full spillover table should be returned
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#' @param absolute boolean defining whether to compute the within or absolute spillover
#' @param cluster either NULL for no parallel processing or the variable containing the cluster.
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @examples
#' w<-c(0,0)
#' C<-rbind(c(1,0.0),c(0.0,1))
#' A1<-rbind(c(0.9,0.09),c(0.09,0.9))
#' A2<-rbind(c(-0.9,-0.09),c(-0.09,-0.9))
#' data <- rbind(mAr.sim(w,A1,C,N=1000), mAr.sim(w,A2,C,N=1000))
#' bounds <- c(1.0001, 0.5, 0.25, 0)*pi
#' plot.ts(t(spilloverRollingBK12(data, p = 1, type = "const", window = 200, n.ahead = 100, partition = bounds, absolute = F, table = F, no.corr = F)), type="l", plot.type = "single", col = c("red","blue","green"))

spilloverRollingBK09 <- function(data, p, type, window, n.ahead, partition, table = F, no.corr, absolute, cluster = NULL) {
	return(spilloverRollingFft("spilloverBK09", data, p, type, window, n.ahead, partition, table = table, absolute = absolute, cluster = cluster, no.corr = no.corr))
}

#' Computing rolling frequency spillover from a generalized fevd as defined by Barunik, Krehlik (2015)
#'
#' This function computes the rolling spillover using the standard VAR estimate.
#' We implement the parallel version for faster processing. The window is of fixed window
#' and is rolled over the data. Interpretation of the other parameters is the same as in the
#' standard computation of spillover.
#' 
#' @param data variable containing the dataset
#' @param p lags in the VAR estimate.
#' @param type which type of VAR to use, see help for VAR from vars package
#' @param window length of the window to be rolled
#' @param n.ahead how many periods ahead should the FEVD be computed, generally this number
#' 		should be high enough so that it won't change with additional period
#' @param partition defines the frequency partitions to which the spillover should be decomposed
#' @param table boolean whether the full spillover table should be returned
#' @param no.corr boolean parameter whether the off-diagonal in the covariance matrix should be
#' 		set to zero
#' @param absolute boolean defining whether to compute the within or absolute spillover
#' @param cluster either NULL for no parallel processing or the variable containing the cluster.
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

spilloverRollingBK12 <- function(data, p, type, window, n.ahead, partition, table = F, no.corr, absolute, cluster = NULL) {
	return(spilloverRollingFft("spilloverBK12", data, p, type, window, n.ahead, partition, table = table, absolute = absolute, cluster = cluster, no.corr = no.corr))
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