#' Get the indeces for the individual intervals
#'
#' This function returns the indeces of the vector coming from DFT of time series
#' of length n.ahead that correspond to frequencies in the interval (up, down].
#'
#' @param n.ahead the length of the vector coming out of the DFT
#' @param up the upper boundary of the interval
#' @param down the lower boundary of the interval
#'
#' @author Tomas Krehlik \email{tomas.krehlik@@sorgmail.com}

getIndeces <- function(n.ahead, up, down) {
	space <- (0:floor(n.ahead/2))/((floor(n.ahead/2)))*pi
	# print(space)
	lb <- space >= down
	ub <- space < up
	# print(lb)
	# print(ub)
	output = (lb & ub)*1
	if (n.ahead%%2 == 0) {
		output <- c(output, rev(output[2:(length(output)-1)]))
	}
	else {
		output <- c(output, rev(output[2:length(output)]))
	}
	return(which(output==1))
}

#' Get a list of indeces corresponding to parts of frequency partition
#'
#' This function takes in a vector of numbers denoting the breaks in partition of an interval
#' and returns a list of indeces that correspond to indeces that are contained within an individual
#' intervals. The individual parts then contain (a,b] for all pairs in the interval. Hence if you
#' want pi to be included, the partition should start with something slightly bigger than pi.
#'
#' @param partition breaking points of partition of frequency interval, should be ordered decreasingly.
#' @param n.ahead how many observations is the FFT done on.
#' @return a list of vectors of indeces corresponding to individual partitions
#'	 
#' @export
#' @author Tomas Krehlik \email{tomas.krehlik@@sorgmail.com}

getPartition <- function(partition, n.ahead) {
	if (!all(sort(partition, decreasing = T)==partition)) {
		stop("The bounds must be in decreasing order.")
	}
	part <- lapply(1:(length(partition)-1), function(i) getIndeces(n.ahead+1, partition[i], partition[i+1]))
	if (length(unique(do.call(c, part))) != (n.ahead + 1)) {
			warning("The selected partition does not cover the whole range.")
	}
	if (any(sapply(part, length)==0)) {
		sprintf("The n.ahead steps does not allow to infer anything about the following interval (%f, %f).", partition[which(sapply(part, length)==0)], partition[which(sapply(part, length)==0)+1])
		stop("Change the partition.")
	}
	return(part)
}

check_that_it_is_not_fft <- function(sp_tab) {
    return(length(sp_tab$bounds)<3)
}