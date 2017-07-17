
#' Function to compute overall spillovers
#' 
#' Taking in spillover_table or list_of spills object, the function computes 
#' the overall spillover.
#' 
#' @param ... this argument can contain within = F or T as to whether to 
#' compute the within spillovers if the spillover tables are frequency based.
#' @param x either the spillover_table or list_of_spills object.
#' 
#' @return a list containing the overall spillover
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
overall <- function(x, ...) UseMethod("overall", x)

#' Function to compute overall spillovers
#' 
#' Taking in spillover_table or list_of spills object, the function computes 
#' the overall spillover.
#' 
#' @param ... this argument can contain within = F or T as to whether to 
#' compute the within spillovers if the spillover tables are frequency based.
#' @param x either the spillover_table or list_of_spills object.
#' 
#' @return a list containing the overall spillover
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
to <- function(x, ...) UseMethod("to", x)

#' Function to compute overall spillovers
#' 
#' Taking in spillover_table or list_of spills object, the function computes 
#' the overall spillover.
#' 
#' @param ... this argument can contain within = F or T as to whether to 
#' compute the within spillovers if the spillover tables are frequency based.
#' @param x either the spillover_table or list_of_spills object.
#' 
#' @return a list containing the overall spillover
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
from <- function(x, ...) UseMethod("from", x)

#' Function to compute overall spillovers
#' 
#' Taking in spillover_table or list_of spills object, the function computes 
#' the overall spillover.
#' 
#' @param ... this argument can contain within = F or T as to whether to 
#' compute the within spillovers if the spillover tables are frequency based.
#' @param x either the spillover_table or list_of_spills object.
#' 
#' @return a list containing the overall spillover
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
pairwise <- function(x, ...) UseMethod("pairwise", x)

#' Function to compute overall spillovers
#' 
#' Taking in spillover_table or list_of spills object, the function computes 
#' the overall spillover.
#' 
#' @param ... this argument can contain within = F or T as to whether to 
#' compute the within spillovers if the spillover tables are frequency based.
#' @param x either the spillover_table or list_of_spills object.
#' 
#' @return a list containing the overall spillover
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
net <- function(x, ...) UseMethod("net", x)

#' Function to plot overall spillovers
#' 
#' Taking in list_of_spillovers, the function plots the overall spillovers
#' using the zoo::plot.zoo function
#' 
#' @param x a list_of_spills object, ideally from rolling window estimation
#' @param ... contains two arguments within and which, for details see mtehod
#'      plotOverall.list_of_spills
#' 
#' @return a plot of overall spillovers
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
plotOverall <- function(x, ...) UseMethod("plotOverall", x)

#' Function to plot to spillovers
#' 
#' Taking in list_of_spillovers, the function plots the to spillovers
#' using the zoo::plot.zoo function
#' 
#' @param x a list_of_spills object, ideally from rolling window estimation
#' @param ... contains two arguments within and which, for details see mtehod
#'      plotTo.list_of_spills
#' 
#' @return a plot of to spillovers
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
plotTo <- function(x, ...) UseMethod("plotTo", x)

#' Function to plot from spillovers
#' 
#' Taking in list_of_spillovers, the function plots the from spillovers
#' using the zoo::plot.zoo function
#' 
#' @param x a list_of_spills object, ideally from rolling window estimation
#' @param ... contains two arguments within and which, for details see mtehod
#'      plotFrom.list_of_spills
#' 
#' @return a plot of from spillovers
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
plotFrom <- function(x, ...) UseMethod("plotFrom", x)

#' Function to plot net spillovers
#' 
#' Taking in list_of_spillovers, the function plots the net spillovers
#' using the zoo::plot.zoo function
#' 
#' @param x a list_of_spills object, ideally from rolling window estimation
#' @param ... contains two arguments within and which, for details see mtehod
#'      plotNet.list_of_spills
#' 
#' @return a plot of net spillovers
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
plotNet <- function(x, ...) UseMethod("plotNet", x)

#' Function to plot pairwise spillovers
#' 
#' Taking in list_of_spillovers, the function plots the pairwise spillovers
#' using the zoo::plot.zoo function
#' 
#' @param x a list_of_spills object, ideally from rolling window estimation
#' @param ... contains two arguments within and which, for details see mtehod
#'      plotPairwise.list_of_spills
#' 
#' @return a plot of pairwise spillovers
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
plotPairwise <- function(x, ...) UseMethod("plotPairwise", x)

#' Function to collapse bounds
#' 
#' Taking in spillover_table, if the spillover_table is frequency based, it 
#' allows you to collapse several frequency bands into one.
#' 
#' @param x a spillover_table object, ideally from the provided estimation 
#'      functions
#' @param ... contains which saying which bounds to collapse
#' 
#' @return spillover_table with less frequency bands.
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
collapseBounds <- function(x, ...) UseMethod("collapseBounds", x)