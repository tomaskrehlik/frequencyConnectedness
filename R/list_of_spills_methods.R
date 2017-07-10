#' @export
overall.list_of_spills <- function(x, within = F) {
    T <- length(x$list_of_tables)
    n_bands <- (length((x$list_of_tables[[1]])$bounds)-1)
    if (check_that_it_is_not_fft(x[[1]][[1]]) & within) warning("You are setting within to FALSE. In DY case, the within and absolute spillovers are the same.")
    temp <- lapply(x$list_of_tables, function(tab) overall(tab, within))
    out <- lapply(1:n_bands, function(j) t(t(sapply(1:T, function(i) temp[[i]][[j]]))))
    dates <- do.call(c, lapply(x$list_of_tables, function(i) i$date))
    if (length(dates)==nrow(out[[1]])) {
        for (i in 1:length(out)) {
            out[[i]] <- zoo(out[[i]], order.by = dates)
        }
    }
    return(out)
}

#' @export
to.list_of_spills <- function(x, within = F) {
    T <- length(x$list_of_tables)
    n_bands <- (length((x$list_of_tables[[1]])$bounds)-1)
    if (check_that_it_is_not_fft(x[[1]][[1]]) & within) warning("You are setting within to FALSE. In DY case, the within and absolute spillovers are the same.")
    temp <- lapply(x$list_of_tables, function(tab) to(tab, within))
    out <- lapply(1:n_bands, function(j) t(sapply(1:T, function(i) temp[[i]][[j]])))
    dates <- do.call(c, lapply(x$list_of_tables, function(i) i$date))
    if (length(dates)==nrow(out[[1]])) {
        for (i in 1:length(out)) {
            out[[i]] <- zoo(out[[i]], order.by = dates)
        }
    }
    return(out)
}

#' @export
from.list_of_spills <- function(x, within = F) {
    T <- length(x$list_of_tables)
    n_bands <- (length((x$list_of_tables[[1]])$bounds)-1)
    if (check_that_it_is_not_fft(x[[1]][[1]]) & within) warning("You are setting within to FALSE. In DY case, the within and absolute spillovers are the same.")
    temp <- lapply(x$list_of_tables, function(tab) from(tab, within))
    out <- lapply(1:n_bands, function(j) t(sapply(1:T, function(i) temp[[i]][[j]])))
    dates <- do.call(c, lapply(x$list_of_tables, function(i) i$date))
    if (length(dates)==nrow(out[[1]])) {
        for (i in 1:length(out)) {
            out[[i]] <- zoo(out[[i]], order.by = dates)
        }
    }
    return(out)
}

#' @export
net.list_of_spills <- function(x, within = F) {
    T <- length(x$list_of_tables)
    n_bands <- (length((x$list_of_tables[[1]])$bounds)-1)
    if (check_that_it_is_not_fft(x[[1]][[1]]) & within) warning("You are setting within to FALSE. In DY case, the within and absolute spillovers are the same.")
    temp <- lapply(x$list_of_tables, function(tab) net(tab, within))
    out <- lapply(1:n_bands, function(j) t(sapply(1:T, function(i) temp[[i]][[j]])))
    dates <- do.call(c, lapply(x$list_of_tables, function(i) i$date))
    if (length(dates)==nrow(out[[1]])) {
        for (i in 1:length(out)) {
            out[[i]] <- zoo(out[[i]], order.by = dates)
        }
    }
    return(out)
}

#' @export
pairwise.list_of_spills <- function(x, within = F) {
    T <- length(x$list_of_tables)
    n_bands <- (length((x$list_of_tables[[1]])$bounds)-1)
    if (check_that_it_is_not_fft(x[[1]][[1]]) & within) warning("You are setting within to FALSE. In DY case, the within and absolute spillovers are the same.")
    temp <- lapply(x$list_of_tables, function(tab) pairwise(tab, within))
    out <- lapply(1:n_bands, function(j) t(sapply(1:T, function(i) temp[[i]][[j]])))
    dates <- do.call(c, lapply(x$list_of_tables, function(i) i$date))
    if (length(dates)==nrow(out[[1]])) {
        for (i in 1:length(out)) {
            out[[i]] <- zoo(out[[i]], order.by = dates)
        }
    }
    return(out)
}

#' @export
collapseBounds.list_of_spills <- function(x, which) {
    x$lists_of_tables <- lapply(x$lists_of_tables, function(i) collapseBounds(i, which))
    return(x)
}

#' @export
plotOverall.list_of_spills <- function(x, within = F) {
    spills <- overall(x, within)
    if (length(spills)==1) {
        plot.zoo(spills[[1]], main = "Overall spillovers", ylab = "")
    } else {
        for (i in 1:length(spills)) {
            plot.zoo(spills[[i]], main = sprintf("Overall spillovers on band: %.2f to %.2f.", x$list_of_tables[[1]]$bounds[i], x$list_of_tables[[1]]$bounds[i+1]), ylab = "")
            invisible(readline(prompt="Press [enter] to continue"))
        }
    }
}

#' @export
plotTo.list_of_spills <- function(x, within = F, which = 1:nrow(x$list_of_tables[[1]]$tables[[1]])) {
    spills <- to(x, within)
    if (length(spills)==1) {
        plot.zoo(spills[[1]][,which], main = "To spillovers")
    } else {
        for (i in 1:length(spills)) {
            plot.zoo(spills[[i]][,which], main = sprintf("To spillovers on band: %.2f to %.2f.", x$list_of_tables[[1]]$bounds[i], x$list_of_tables[[1]]$bounds[i+1]))
            invisible(readline(prompt="Press [enter] to continue"))
        }
    }
}

#' @export
plotFrom.list_of_spills <- function(x, within = F, which = 1:nrow(x$list_of_tables[[1]]$tables[[1]])) {
    spills <- from(x, within)
    if (length(spills)==1) {
        plot.zoo(spills[[1]][,which], main = "From spillovers")
    } else {
        for (i in 1:length(spills)) {
            plot.zoo(spills[[i]][,which], main = sprintf("From spillovers on band: %.2f to %.2f.", x$list_of_tables[[1]]$bounds[i], x$list_of_tables[[1]]$bounds[i+1]))
            invisible(readline(prompt="Press [enter] to continue"))
        }
    }
}

#' @export
plotNet.list_of_spills <- function(x, within = F, which = 1:nrow(x$list_of_tables[[1]]$tables[[1]])) {
    spills <- net(x, within)
    if (length(spills)==1) {
        plot.zoo(spills[[1]][,which], main = "Net spillovers")
    } else {
        for (i in 1:length(spills)) {
            plot.zoo(spills[[i]][,which], main = sprintf("Net spillovers on band: %.2f to %.2f.", x$list_of_tables[[1]]$bounds[i], x$list_of_tables[[1]]$bounds[i+1]))
            invisible(readline(prompt="Press [enter] to continue"))
        }
    }
}

#' @export
plotPairwise.list_of_spills <- function(x, within = F, which = 1:ncol(utils::combn(nrow(x$list_of_tables[[1]]$tables[[1]]), 2))) {
    spills <- pairwise(x, within)
    if (length(spills)==1) {
        plot.zoo(spills[[1]][,which], main = "Pairwise spillovers")
    } else {
        for (i in 1:length(spills)) {
            plot.zoo(spills[[i]][,which], main = sprintf("Pairwise spillovers on band: %.2f to %.2f.", x$list_of_tables[[1]]$bounds[i], x$list_of_tables[[1]]$bounds[i+1]))
            invisible(readline(prompt="Press [enter] to continue"))
        }
    }
}

#' @export
print.list_of_spills <- function(x) {
    cat("Surpressing printing of all the spillover tables, usually it is not a good\n
idea to print them all. (Too many of them.) If you want to do that\n
anyway use: lapply(\"..name..\", print).")
}