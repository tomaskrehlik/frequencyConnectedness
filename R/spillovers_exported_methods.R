#' Method for computing overall spillovers
#'
#'
#' @param spillover_table the output of spillover estimation function 
#'        or rolling spillover estimation function
#' @param ... other arguments like whether it is within or absolute spillover
#'        in case of the frequency spillovers
#'
#' @return Value for overall spillover
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
overall <- function(spillover_table, ...) UseMethod("overall", spillover_table)

#' Method for computing TO spillovers
#'
#'
#' @param spillover_table the output of spillover estimation function 
#'        or rolling spillover estimation function
#' @param ... other arguments like whether it is within or absolute spillover
#'        in case of the frequency spillovers
#'
#' @return Value for TO spillover
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
to <- function(spillover_table, ...) UseMethod("to", spillover_table)

#' Method for computing FROM spillovers
#'
#'
#' @param spillover_table the output of spillover estimation function 
#'        or rolling spillover estimation function
#' @param ... other arguments like whether it is within or absolute spillover
#'        in case of the frequency spillovers
#'
#' @return Value for FROM spillover
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
from <- function(spillover_table, ...) UseMethod("from", spillover_table)

#' Method for computing PAIRWISE spillovers
#'
#'
#' @param spillover_table the output of spillover estimation function 
#'        or rolling spillover estimation function
#' @param ... other arguments like whether it is within or absolute spillover
#'        in case of the frequency spillovers
#'
#' @return Value for PAIRWISE spillover
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
pairwise <- function(spillover_table, ...) UseMethod("pairwise", spillover_table)

#' Method for computing NET spillovers
#'
#'
#' @param spillover_table the output of spillover estimation function 
#'        or rolling spillover estimation function
#' @param ... other arguments like whether it is within or absolute spillover
#'        in case of the frequency spillovers
#'
#' @return Value for NET spillover
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
net <- function(spillover_table, ...) UseMethod("net", spillover_table)

#' Method for ploting overall spillovers
#'
#'
#' @param spillover_table the output of rolling spillover estimation function 
#' @param ... other arguments like whether it is within or absolute spillover
#'        in case of the frequency spillovers
#'
#' @return The plot
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
plotOverall <- function(spillover_table, ...) UseMethod("plotOverall", spillover_table)

#' Method for ploting TO spillovers
#'
#'
#' @param spillover_table the output of rolling spillover estimation function 
#' @param ... other arguments like whether it is within or absolute spillover
#'        in case of the frequency spillovers
#'
#' @return The plot
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
plotTo <- function(spillover_table, ...) UseMethod("plotTo", spillover_table)

#' Method for ploting FROM spillovers
#'
#'
#' @param spillover_table the output of rolling spillover estimation function 
#' @param ... other arguments like whether it is within or absolute spillover
#'        in case of the frequency spillovers
#'
#' @return The plot
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
plotFrom <- function(spillover_table, ...) UseMethod("plotFrom", spillover_table)

#' Method for ploting NET spillovers
#'
#'
#' @param spillover_table the output of rolling spillover estimation function 
#' @param ... other arguments like whether it is within or absolute spillover
#'        in case of the frequency spillovers
#'
#' @return The plot
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
plotNet <- function(spillover_table, ...) UseMethod("plotNet", spillover_table)

#' Method for ploting PAIRWISE spillovers
#'
#'
#' @param spillover_table the output of rolling spillover estimation function 
#' @param ... other arguments like whether it is within or absolute spillover
#'        in case of the frequency spillovers
#'
#' @return The plot
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
plotPairwise <- function(spillover_table, ...) UseMethod("plotPairwise", spillover_table)

#' Method for for collapsing bound for frequency spillovers
#'
#'
#' @param spillover_table the output of spillover estimation function 
#'        or rolling spillover estimation function
#' @param which integer vector indicating which of the frequency bounds
#'        we want to have collapsed
#'
#' @return New spillover object with collapsed bounds
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
collapseBounds <- function(spillover_table, which) UseMethod("collapseBounds")
