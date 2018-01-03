#' Function to compute overall spillovers
#' 
#' Taking in list_of_spillovers, the function computes the overall spillovers
#' for all the individual spillover_table.
#' 
#' @param spillover_table a list_of_spills object, ideally from rolling window estimation
#' @param within whether to compute the within spillovers if the spillover
#'      tables are frequency based.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return a list containing the overall spillovers
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
overall.list_of_spills <- function(spillover_table, within = F, ...) {
    T <- length(spillover_table$list_of_tables)
    n_bands <- (length((spillover_table$list_of_tables[[1]])$bounds)-1)
    if (check_that_it_is_not_fft(spillover_table[[1]][[1]]) & within) warning("You are setting within to FALSE. In DY case, the within and absolute spillovers are the same.")
    temp <- lapply(spillover_table$list_of_tables, function(tab) overall(tab, within))
    out <- lapply(1:n_bands, function(j) t(t(sapply(1:T, function(i) temp[[i]][[j]]))))
    dates <- do.call(c, lapply(spillover_table$list_of_tables, function(i) i$date))
    if (length(dates)==nrow(out[[1]])) {
        for (i in 1:length(out)) {
            out[[i]] <- zoo::zoo(out[[i]], order.by = dates)
        }
    }
    return(out)
}

#' Function to compute to spillovers
#' 
#' Taking in list_of_spillovers, the function computes the to spillovers
#' for all the individual spillover_table.
#' 
#' @param spillover_table a list_of_spills object, ideally from rolling window estimation
#' @param within whether to compute the within spillovers if the spillover
#'      tables are frequency based.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return a list containing the to spillovers
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
to.list_of_spills <- function(spillover_table, within = F, ...) {
    T <- length(spillover_table$list_of_tables)
    n_bands <- (length((spillover_table$list_of_tables[[1]])$bounds)-1)
    if (check_that_it_is_not_fft(spillover_table[[1]][[1]]) & within) warning("You are setting within to FALSE. In DY case, the within and absolute spillovers are the same.")
    temp <- lapply(spillover_table$list_of_tables, function(tab) to(tab, within))
    out <- lapply(1:n_bands, function(j) t(sapply(1:T, function(i) temp[[i]][[j]])))
    dates <- do.call(c, lapply(spillover_table$list_of_tables, function(i) i$date))
    if (length(dates)==nrow(out[[1]])) {
        for (i in 1:length(out)) {
            out[[i]] <- zoo::zoo(out[[i]], order.by = dates)
        }
    }
    return(out)
}

#' Function to compute from spillovers
#' 
#' Taking in list_of_spillovers, the function computes the from spillovers
#' for all the individual spillover_table.
#' 
#' @param spillover_table a list_of_spills object, ideally from rolling window estimation
#' @param within whether to compute the within spillovers if the spillover
#'      tables are frequency based.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return a list containing the from spillovers
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
from.list_of_spills <- function(spillover_table, within = F, ...) {
    T <- length(spillover_table$list_of_tables)
    n_bands <- (length((spillover_table$list_of_tables[[1]])$bounds)-1)
    if (check_that_it_is_not_fft(spillover_table[[1]][[1]]) & within) warning("You are setting within to FALSE. In DY case, the within and absolute spillovers are the same.")
    temp <- lapply(spillover_table$list_of_tables, function(tab) from(tab, within))
    out <- lapply(1:n_bands, function(j) t(sapply(1:T, function(i) temp[[i]][[j]])))
    dates <- do.call(c, lapply(spillover_table$list_of_tables, function(i) i$date))
    if (length(dates)==nrow(out[[1]])) {
        for (i in 1:length(out)) {
            out[[i]] <- zoo::zoo(out[[i]], order.by = dates)
        }
    }
    return(out)
}

#' Function to compute net spillovers
#' 
#' Taking in list_of_spillovers, the function computes the net spillovers
#' for all the individual spillover_table.
#' 
#' @param spillover_table a list_of_spills object, ideally from rolling window estimation
#' @param within whether to compute the within spillovers if the spillover
#'      tables are frequency based.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return a list containing the net spillovers
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
net.list_of_spills <- function(spillover_table, within = F, ...) {
    T <- length(spillover_table$list_of_tables)
    n_bands <- (length((spillover_table$list_of_tables[[1]])$bounds)-1)
    if (check_that_it_is_not_fft(spillover_table[[1]][[1]]) & within) warning("You are setting within to FALSE. In DY case, the within and absolute spillovers are the same.")
    temp <- lapply(spillover_table$list_of_tables, function(tab) net(tab, within))
    out <- lapply(1:n_bands, function(j) t(sapply(1:T, function(i) temp[[i]][[j]])))
    dates <- do.call(c, lapply(spillover_table$list_of_tables, function(i) i$date))
    if (length(dates)==nrow(out[[1]])) {
        for (i in 1:length(out)) {
            out[[i]] <- zoo::zoo(out[[i]], order.by = dates)
        }
    }
    return(out)
}

#' Function to compute pairwise spillovers
#' 
#' Taking in list_of_spillovers, the function computes the pairwise spillovers
#' for all the individual spillover_table.
#' 
#' @param spillover_table a list_of_spills object, ideally from rolling window estimation
#' @param within whether to compute the within spillovers if the spillover
#'      tables are frequency based.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return a list containing the pairwise spillovers
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
pairwise.list_of_spills <- function(spillover_table, within = F, ...) {
    T <- length(spillover_table$list_of_tables)
    n_bands <- (length((spillover_table$list_of_tables[[1]])$bounds)-1)
    if (check_that_it_is_not_fft(spillover_table[[1]][[1]]) & within) warning("You are setting within to FALSE. In DY case, the within and absolute spillovers are the same.")
    temp <- lapply(spillover_table$list_of_tables, function(tab) pairwise(tab, within))
    out <- lapply(1:n_bands, function(j) t(sapply(1:T, function(i) temp[[i]][[j]])))
    dates <- do.call(c, lapply(spillover_table$list_of_tables, function(i) i$date))
    if (length(dates)==nrow(out[[1]])) {
        for (i in 1:length(out)) {
            out[[i]] <- zoo::zoo(out[[i]], order.by = dates)
        }
    }
    return(out)
}

#' Function to collapse bounds
#' 
#' Taking in list_of_spills, if the individual spillover_tables are frequency 
#' based, it allows you to collapse several frequency bands into one.
#' 
#' @param spillover_table a list_of_spills object, ideally from the provided estimation 
#'      functions
#' @param which which frequency bands to collapse. Should be a sequence like 1:2
#'      or 1:5, etc.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return list_of_spills with less frequency bands.
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
collapseBounds.list_of_spills <- function(spillover_table, which) {
    spillover_table$lists_of_tables <- lapply(spillover_table$lists_of_tables, function(i) collapseBounds(i, which))
    return(spillover_table)
}

#' Function to plot overall spillovers
#' 
#' Taking in list_of_spillovers, the function plots the overall spillovers
#' using the zoo::plot.zoo function
#' 
#' @param spillover_table a list_of_spills object, ideally from rolling window estimation
#' @param within whether to compute the within spillovers if the spillover
#'      tables are frequency based.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return a plot of overall spillovers
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
plotOverall.list_of_spills <- function(spillover_table, within = F, ...) {
    spills <- overall(spillover_table, within)
    if (length(spills)==1) {
        zoo::plot.zoo(spills[[1]], main = "Overall spillovers", ylab = "")
    } else {
        for (i in 1:length(spills)) {
            zoo::plot.zoo(spills[[i]], main = sprintf("Overall spillovers on band: %.2f to %.2f.", spillover_table$list_of_tables[[1]]$bounds[i], spillover_table$list_of_tables[[1]]$bounds[i+1]), ylab = "")
            invisible(readline(prompt="Press [enter] to continue"))
        }
    }
}

#' Function to plot to spillovers
#' 
#' Taking in list_of_spillovers, the function plots the to spillovers
#' using the zoo::plot.zoo function
#' 
#' @param spillover_table a list_of_spills object, ideally from rolling window estimation
#' @param within whether to compute the within spillovers if the spillover
#'      tables are frequency based.
#' @param which a vector with indices specifying which plots to plot.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return a plot of to spillovers
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
plotTo.list_of_spills <- function(spillover_table, within = F, which = 1:nrow(spillover_table$list_of_tables[[1]]$tables[[1]]), ...) {
    spills <- to(spillover_table, within)
    if (length(spills)==1) {
        zoo::plot.zoo(spills[[1]][,which], main = "To spillovers")
    } else {
        for (i in 1:length(spills)) {
            zoo::plot.zoo(spills[[i]][,which], main = sprintf("To spillovers on band: %.2f to %.2f.", spillover_table$list_of_tables[[1]]$bounds[i], spillover_table$list_of_tables[[1]]$bounds[i+1]))
            invisible(readline(prompt="Press [enter] to continue"))
        }
    }
}

#' Function to plot from spillovers
#' 
#' Taking in list_of_spillovers, the function plots the from spillovers
#' using the zoo::plot.zoo function
#' 
#' @param spillover_table a list_of_spills object, ideally from rolling window estimation
#' @param within whether to compute the within spillovers if the spillover
#'      tables are frequency based.
#' @param which a vector with indices specifying which plots to plot.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return a plot of from spillovers
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
plotFrom.list_of_spills <- function(spillover_table, within = F, which = 1:nrow(spillover_table$list_of_tables[[1]]$tables[[1]]), ...) {
    spills <- from(spillover_table, within)
    if (length(spills)==1) {
        zoo::plot.zoo(spills[[1]][,which], main = "From spillovers")
    } else {
        for (i in 1:length(spills)) {
            zoo::plot.zoo(spills[[i]][,which], main = sprintf("From spillovers on band: %.2f to %.2f.", spillover_table$list_of_tables[[1]]$bounds[i], spillover_table$list_of_tables[[1]]$bounds[i+1]))
            invisible(readline(prompt="Press [enter] to continue"))
        }
    }
}

#' Function to plot net spillovers
#' 
#' Taking in list_of_spillovers, the function plots the net spillovers
#' using the zoo::plot.zoo function
#' 
#' @param spillover_table a list_of_spills object, ideally from rolling window estimation
#' @param within whether to compute the within spillovers if the spillover
#'      tables are frequency based.
#' @param which a vector with indices specifying which plots to plot.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return a plot of net spillovers
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
plotNet.list_of_spills <- function(spillover_table, within = F, which = 1:nrow(spillover_table$list_of_tables[[1]]$tables[[1]]), ...) {
    spills <- net(spillover_table, within)
    if (length(spills)==1) {
        zoo::plot.zoo(spills[[1]][,which], main = "Net spillovers")
    } else {
        for (i in 1:length(spills)) {
            zoo::plot.zoo(spills[[i]][,which], main = sprintf("Net spillovers on band: %.2f to %.2f.", spillover_table$list_of_tables[[1]]$bounds[i], spillover_table$list_of_tables[[1]]$bounds[i+1]))
            invisible(readline(prompt="Press [enter] to continue"))
        }
    }
}


#' Function to plot pairwise spillovers
#' 
#' Taking in list_of_spillovers, the function plots the pairwise spillovers
#' using the zoo::plot.zoo function
#' 
#' @param spillover_table a list_of_spills object, ideally from rolling window estimation
#' @param within whether to compute the within spillovers if the spillover
#'      tables are frequency based.
#' @param which a vector with indices specifying which plots to plot.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return a plot of pairwise spillovers
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
plotPairwise.list_of_spills <- function(spillover_table, within = F, which = 1:ncol(utils::combn(nrow(spillover_table$list_of_tables[[1]]$tables[[1]]), 2)), ...) {
    spills <- pairwise(spillover_table, within)
    if (length(spills)==1) {
        zoo::plot.zoo(spills[[1]][,which], main = "Pairwise spillovers")
    } else {
        for (i in 1:length(spills)) {
            zoo::plot.zoo(spills[[i]][,which], main = sprintf("Pairwise spillovers on band: %.2f to %.2f.", spillover_table$list_of_tables[[1]]$bounds[i], spillover_table$list_of_tables[[1]]$bounds[i+1]))
            invisible(readline(prompt="Press [enter] to continue"))
        }
    }
}

#' Function to not print the list_of_spills object
#' 
#' Usually it is not a good idea to print the list_of_spills object, hence
#' this function implements warning and shows how to print them individually
#' if the user really wants to.
#' 
#' @param x a list_of_spills object, ideally from the provided estimation 
#'      functions
#' @param ... for the sake of CRAN not to complain
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
print.list_of_spills <- function(x, ...) {
    cat("Surpressing printing of all the spillover tables, usually it is not a good\n
idea to print them all. (Too many of them.) If you want to do that\n
anyway use: lapply(\"..name..\", print).")
}