
#' @export
overall <- function(spillover_table, ...) UseMethod("overall", spillover_table)

#' @export
to <- function(spillover_table, ...) UseMethod("to", spillover_table)

#' @export
from <- function(spillover_table, ...) UseMethod("from", spillover_table)

#' @export
pairwise <- function(spillover_table, ...) UseMethod("pairwise", spillover_table)

#' @export
net <- function(spillover_table, ...) UseMethod("net", spillover_table)

#' @export
plotOverall <- function(list_of_spills, ...) UseMethod("plotOverall", list_of_spills)

#' @export
plotTo <- function(list_of_spills, ...) UseMethod("plotTo", list_of_spills)

#' @export
plotFrom <- function(list_of_spills, ...) UseMethod("plotFrom", list_of_spills)

#' @export
plotNet <- function(list_of_spills, ...) UseMethod("plotNet", list_of_spills)

#' @export
plotPairwise <- function(list_of_spills, ...) UseMethod("plotPairwise", list_of_spills)

#' @export
collapseBounds <- function(spillover_table, ...) UseMethod("collapseBounds", spillover_table)