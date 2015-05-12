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
#' and returns a list of indeces that correspond to indeces that are contained within an indibidual
#' intervals.
#'
#' @param partition breaking points of partition of frequency interval
#' @param n.ahead how many observations is the FFT done on.
#' @return a list of vectors of indeces corresponding to individual partitions
#'	 
#' @export
#' @author Tomas Krehlik \email{tomas.krehlik@gmail.com}

getPartition <- function(partition, n.ahead) {
	part <- lapply(1:(length(partition)-1), function(i) getIndeces(n.ahead+1, partition[i], partition[i+1]))
	if (!all(sort(unique(do.call(c, part)))==(1:(n.ahead+1)))) {
		warning("The selected partition does not cover the whole range.")
	}
	return(part)
}