#' Collapsing bounds into less elements
#'
#' Given that your estimate is saved as an object from makeStructure function
#' this function allows you to collapse the estimates from several bounds. Esentially,
#' the GFEVD is linear in frequencies so we can just sum up parts of the object.
#' It is especially useful, when we have estimated too many bounds and want to use only
#' several of them. This function is especially useful for plotting. See github for examples.
#'
#' @param estimate the object of class connectedness_estimate
#' @param index_start from where to start collapsing
#' @param index_end where to end the collapsing
#' @return object of class connectedness_estimate
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

collapseBounds <- function(estimate, index_start, index_end) {
	if (class(estimate) != "connectedness_estimate") stop("Provided object is not of class connectedness_estimate.")
	if (index_start>=index_end) stop("Provided indeces do not make sense.")

	if ((index_start == 1) && (index_end == length(estimate[["Bounds"]])-1)) {
		estimate[["Estimates"]] <- lapply(estimate[["Estimates"]], function(i) c(list(Reduce('+', i[index_start:index_end]))))
		estimate[["Bounds"]] <- NA
		return(estimate)
	}
	if (index_start == 1) {
		# At least one at the end
		estimate[["Estimates"]] <- lapply(estimate[["Estimates"]], function(i) c(list(Reduce('+', i[index_start:index_end])), i[(index_end+1):length(estimate[["Bounds"]])]))
		estimate[["Bounds"]] <- c(estimate[["Bounds"]][1:index_start],estimate[["Bounds"]][(index_end+1):length(estimate[["Bounds"]])])
		return(estimate)
	}
	if (index_end == length(estimate[["Bounds"]])-1) {
		# At least one at the begining 
		estimate[["Estimates"]] <- lapply(estimate[["Estimates"]], function(i) c(i[1:(index_start-1)],list(Reduce('+', i[index_start:index_end]))))
		estimate[["Bounds"]] <- c(estimate[["Bounds"]][1:index_start],estimate[["Bounds"]][(index_end+1):length(estimate[["Bounds"]])])
		return(estimate)
	} else {
		estimate[["Estimates"]] <- lapply(estimate[["Estimates"]], function(i) c(i[1:(index_start-1)],list(Reduce('+', i[index_start:index_end])), i[(index_end+1):length(estimate[["Bounds"]])]))
		estimate[["Bounds"]] <- c(estimate[["Bounds"]][1:index_start],estimate[["Bounds"]][(index_end+1):length(estimate[["Bounds"]])])
		return(estimate)
	}
}

#' Collapsing all bounds
#'
#'
#' @param estimate the object of class connectedness_estimate
#' @return object of class connectedness_estimate
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

collapseAll <- function(estimate) {
	if (class(estimate) != "connectedness_estimate") stop("Provided object is not of class connectedness_estimate.")

	return(collapseBounds(estimate, 1, length(estimate[["Bounds"]])-1))
}

#' Making structured object
#'
#' The function returns a structured object that is useful for plotting
#' and extracting other types of spillovers, such as TO, FROM, etc. types
#' of spillovers. The same structure is also the output of rolled BK spillovers
#' estimates.
#'
#' @param estimate a list of lists of (G)FEVD tables on given frequency in a given day.
#' @param dates the dates vector of the same length as the estimate object
#' @param bounds numeric vector giving bounds of the frequency bounds.
#' @return object of class connectedness_estimate
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

makeStructure <- function(estimate, dates, bounds) {
	return(structure(list(Estimates = estimate, Dates = dates, Bounds = bounds), class = "connectedness_estimate"))
}


# THESE FUNCTIONS ARE ONLY HELPERS AND ARE NOT EXPORTED

#' Computation of within from spillovers at time T
#'
#' @param listAtT takes in a list containing (G)FEVD decomposed at frequencies at time t
#' @return list with within from spillovers at frequencies
#'
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

within_from <- function(listAtT) {
  	assets <- colnames(listAtT[[1]])
  	return(lapply(listAtT, function(i) sapply(assets, function(j) 100*sum(i[j,-which(assets==j)])/sum(i))))
}

#' Computation of within to spillovers at time T
#'
#' @param listAtT takes in a list containing (G)FEVD decomposed at frequencies at time t
#' @return list with within to spillovers at frequencies
#'
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

within_to <- function(listAtT) {
  	assets <- colnames(listAtT[[1]])
  	return(lapply(listAtT, function(i) sapply(assets, function(j) 100*sum(i[-which(assets==j),j])/sum(i))))
}

#' Computation of absolute from spillovers at time T
#'
#' @param listAtT takes in a list containing (G)FEVD decomposed at frequencies at time t
#' @return list with absolute from spillovers at frequencies
#'
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

absolute_from <- function(listAtT) {
  	assets <- colnames(listAtT[[1]])
  	return(lapply(listAtT, function(i) sapply(assets, function(j) sum(i[j,-which(assets==j)])/length(assets))))
}

#' Computation of absolute to spillovers at time T
#'
#' @param listAtT takes in a list containing (G)FEVD decomposed at frequencies at time t
#' @return list with absolute to spillovers at frequencies
#'
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

absolute_to <- function(listAtT) {
  	assets <- colnames(listAtT[[1]])
  	return(lapply(listAtT, function(i) sapply(assets, function(j) sum(i[-which(assets==j),j])/length(assets))))
}

#' Computation of within pairwise spillovers at time T
#'
#' @param listAtT takes in a list containing (G)FEVD decomposed at frequencies at time t
#' @return list with within pairwise spillovers at frequencies
#'
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

within_pairwise <- function(listAtT) {
	k <- nrow(listAtT[[1]])
	nams <- colnames(listAtT[[1]])
	combinations <- utils::combn(nams, 2)
	out <- lapply(listAtT, function(tab) apply(combinations, 2, function(i) 100 * (tab[i[1],i[2]] - tab[i[2],i[1]])/sum(tab)  ))
	for (i in 1:length(out)) {
		names(out[[i]]) <- apply(combinations, 2, function(i) paste(i, collapse = "-"))
	}
	return(out)
}

#' Computation of absolute pairwise spillovers at time T
#'
#' @param listAtT takes in a list containing (G)FEVD decomposed at frequencies at time t
#' @return list with absolute pairwise spillovers at frequencies
#'
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

absolute_pairwise <- function(listAtT) {
	k <- nrow(listAtT[[1]])
	nams <- colnames(listAtT[[1]])
	combinations <- utils::combn(nams, 2)
	out <- lapply(listAtT, function(tab) apply(combinations, 2, function(i) (tab[i[1],i[2]] - tab[i[2],i[1]])/k  ))
	for (i in 1:length(out)) {
		names(out[[i]]) <- apply(combinations, 2, function(i) paste(i, collapse = "-"))
	}
	return(out)
}

#' Computation of a given type of spillover
#'
#' @param f function that is specific for the type
#' @param ce the object of class connectedness_estimate
#' @return list with within from spillovers at frequencies, useful for plotting
#'
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

get_type <- function(f, ce) {
	list <- ce[["Estimates"]]
	if (!is.na(ce[["Bounds"]])) {
		nams <- as.character(round(pi/ce[["Bounds"]]))
	}
	
	est_type <- lapply(1:length(list[[1]]), function(h) zoo::zoo(t(sapply(lapply(list, function(k) f(k)), function(i) i[[h]])), order.by = ce[["Dates"]]))
	if (all(!is.na(ce[["Bounds"]]))) {
		names(est_type) <- paste(nams[1:(length(nams)-1)], nams[2:length(nams)], sep = "-")
	} else {
		names(est_type) <- "Overall"
	}
	
  	return(est_type)
}

#####################################################

#' Computation of within from spillovers at time T
#'
#' @param ce takes in a structure of class connectedness_estimate
#' @return list with within from spillovers at frequencies
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

get_within_from <- function(ce) {
  	return(get_type(within_from, ce))
}

#' Computation of within to spillovers at time T
#'
#' @param ce takes in a structure of class connectedness_estimate
#' @return list with within to spillovers at frequencies
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

get_within_to <- function(ce) {
	return(get_type(within_to, ce))	
}

#' Computation of absolute from spillovers at time T
#'
#' @param ce takes in a structure of class connectedness_estimate
#' @return list with absolute from spillovers at frequencies
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

get_absolute_from <- function(ce) {
	return(get_type(absolute_from, ce))
}

#' Computation of absolute to spillovers at time T
#'
#' @param ce takes in a structure of class connectedness_estimate
#' @return list with absolute to spillovers at frequencies
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

get_absolute_to <- function(ce) {
	return(get_type(absolute_to, ce))
}

#' Computation of within net spillovers at time T
#'
#' @param ce takes in a structure of class connectedness_estimate
#' @return list with within net spillovers at frequencies
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

get_within_net <- function(ce) {
	t <- get_within_to(ce)
  	f <- get_within_from(ce)
  	out <- lapply(1:length(t), function(i) t[[i]] - f[[i]])
  	names(out) <- names(t)
  	return(out)
}

#' Computation of absolute net spillovers at time T
#'
#' @param ce takes in a structure of class connectedness_estimate
#' @return list with absolute net spillovers at frequencies
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

get_absolute_net <- function(ce) {
  	t <- get_absolute_to(ce)
  	f <- get_absolute_from(ce)
  	out <- lapply(1:length(t), function(i) t[[i]] - f[[i]])
  	names(out) <- names(t)
  	return(out)
}

#' Computation of absolute pairwise spillovers at time T
#'
#' @param ce takes in a structure of class connectedness_estimate
#' @return list with absolute pairwise spillovers at frequencies
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

get_absolute_pairwise <- function(ce) {
	return(get_type(absolute_pairwise, ce))
}

#' Computation of within pairwise spillovers at time T
#'
#' @param ce takes in a structure of class connectedness_estimate
#' @return list with within pairwise spillovers at frequencies
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

get_within_pairwise <- function(ce) {
	return(get_type(within_pairwise, ce))
}

#' Function that plots various types of spillovers
#'
#' @param s an object from the makeStructure function
#' @param otherAttributes other attributes that can be used to enhance plot
#'
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
plot_spills <- function(s, otherAttributes = NULL) {
	pltdata <- do.call(rbind, lapply(1:length(names(s)), function(i) data.frame(s[[i]], freq = names(s)[i], index = 1:nrow(s[[1]]))))
	pltdata <- reshape2::melt(pltdata, id.vars = c("index", "freq"))
	pltdata$freq <- factor(pltdata$freq, levels = names(s))
	p <- ggplot2::ggplot(data = pltdata, ggplot2::aes_string(x = "index", y = "value")) + ggplot2::facet_grid(freq ~ variable) + ggplot2::xlab("Time") + ggplot2::ylab("Spillover")
	if (is.null(otherAttributes)) {
		print(p + ggplot2::geom_line())	
	} else {
		print(p + ggplot2::geom_line() + otherAttributes)
	}
}

#' Function for convenient plotting
#'
#' @param ce takes in a structure of class connectedness_estimate
#' @param which is either "absolute" or "within"
#' @param type is one of the following: to, from, net, pairwise.
#' @param otherAttributes other attributes that can be used to enhance plot
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

plotSpills <- function(ce, which = "absolute", type = "to", otherAttributes = NULL) {
	f <- match.fun(paste("get", which, type, sep = "_"))
	s <- f(ce)
	if (is.null(otherAttributes)) {
		otherAttributes <- list(ggplot2::labs(title = get_title(which, type)))
	} else {
		otherAttributes <- c(otherAttributes, list(ggplot2::labs(title = get_title(which, type))))
	}
	plot_spills(s, otherAttributes)
}

get_title <- function(which, type) {
	return(paste(paste(toupper(substr(which,1,1)), substr(which,2,nchar(which)), sep = ""), type, "connectedness.", sep = " "))
}

#' Function for convenient plotting
#'
#' This function takes in a path to a file and plots all possible combinations
#' of spillovers.
#'
#' @param ce takes in a structure of class connectedness_estimate
#' @param file where the final plot should go
#' @param otherAttributes other attributes that can be used to enhance plot
#' @param height height of the plot
#' @param width width of the plot
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

plotSpillsAll <- function(ce, file, otherAttributes = NULL, height = 7, width = 7) {
	grDevices::cairo_pdf(file, onefile = T, height = height, width = width)
	apply(expand.grid(c("from", "to", "net", "pairwise"), c("absolute","within")), 1, function(i) plotSpills(ce, i[2], i[1], otherAttributes))
	grDevices::dev.off()
}
