#' Function to print the spillover table object
#' 
#' The function takes as an argument the spillover_table object and prints it
#' nicely to the console. While doing that it also computes all the neccessary
#' measures.
#' 
#' @param x a spillover_table object, ideally from the provided estimation 
#'      functions
#' @param ... for the sake of CRAN not to complain
#' 
#' @import knitr
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
print.spillover_table <- function(x, ...) {
    options(knitr.kable.NA = '')
    tables <- x$tables
    cat(sprintf("Spillover table for day: %s \n\n", as.character(x$date)))
    if (length(x$bounds)==2) {
        cat(sprintf("The spillover table has no frequency bands, standard Diebold & Yilmaz.\n"))
    } else {
        cat(sprintf("The spillover table has %d frequency bands.\n", length(x$bounds) - 1))
    }
    
    if (length(x$bounds)==2) {        
        output <- rbind(
            cbind(
                100 * x$tables[[1]], 
                FROM = from(x, within = F)[[1]]), 
            TO = c(
                to(x, within = F)[[1]], 
                overall(x, within = F)[[1]]
                )
            )
        print(knitr::kable(output, format = "markdown", digits = 2))    
    } else {
        for (i in 1:length(tables)) {
            cat(sprintf("\n\nThe spillover table for band: %.2f to %.2f\n", x$bounds[i], x$bounds[i+1]))
            cat(sprintf("Roughly corresponds to %.0f days to %.0f days.\n", round(pi/x$bounds[i]), round(pi/x$bounds[i+1])))
            output <- rbind(
                cbind(
                    100 * x$tables[[i]], 
                    FROM_ABS = from(x, within = F)[[i]], 
                    FROM_WTH = from(x, within = T)[[i]]), 
                TO_ABS = c(
                    to(x, within = F)[[i]], 
                    overall(x, within = F)[[i]],
                    NA
                    ),
                TO_WTH = c(
                    to(x, within = T)[[i]], 
                    NA,
                    overall(x, within = T)[[i]]
                    )
                )
            print(knitr::kable(output, format = "markdown", digits = 2))    
        }
    }
}

#' Function to compute overall spillovers
#' 
#' Taking in spillover_table, the function computes the overall spillover.
#' 
#' @param spillover_table a spillover_table object, ideally from the provided estimation 
#'      functions
#' @param within whether to compute the within spillovers if the spillover
#'      tables are frequency based.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return a list containing the overall spillover
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
overall.spillover_table <- function(spillover_table, within = F, ...) {
    tables <- spillover_table$tables
    assets <- colnames(tables[[1]])
    if (within) {
        if (check_that_it_is_not_fft(spillover_table)) warning("You are setting within to FALSE. In DY case, the within and absolute spillovers are the same.")
        return(
            lapply(
                tables, 
                function(i) 
                    100 * ( sum( i ) - sum( diag( i ) ) ) / sum(i)
                )
            )
    } else {
        return(
            lapply(
                tables, 
                function(i) 
                    100 * sum( sum( i ) - sum( diag( i ) ) ) / length(assets)
                )
            )
    }
}


#' Function to compute to spillovers
#' 
#' Taking in spillover_table, the function computes the to spillover.
#' 
#' @param spillover_table a spillover_table object, ideally from the provided estimation 
#'      functions
#' @param within whether to compute the within spillovers if the spillover
#'      tables are frequency based.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return a list containing the to spillover
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
to.spillover_table <- function(spillover_table, within = F, ...) {
    tables <- spillover_table$tables
    assets <- colnames(tables[[1]])
    if (within) {
        if (check_that_it_is_not_fft(spillover_table)) warning("You are setting within to FALSE. In DY case, the within and absolute spillovers are the same.")
        return(
            lapply(
                tables, 
                function(i) sapply(
                    assets, 
                    function(j) 
                    100 * sum( i[-which(assets==j), j] ) / sum(i)
                    )
                )
            )
    } else {
        return(
            lapply(
                tables, 
                function(i) sapply(
                    assets, 
                    function(j) 
                    100 * sum( i[-which(assets==j), j] ) / length(assets)
                    )
                )
            )
    }
}


#' Function to compute from spillovers
#' 
#' Taking in spillover_table, the function computes the from spillover.
#' 
#' @param spillover_table a spillover_table object, ideally from the provided estimation 
#'      functions
#' @param within whether to compute the within spillovers if the spillover
#'      tables are frequency based.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return a list containing the from spillover
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
from.spillover_table <- function(spillover_table, within = F, ...) {
    tables <- spillover_table$tables
    assets <- colnames(tables[[1]])
    if (within) {
        if (check_that_it_is_not_fft(spillover_table)) warning("You are setting within to FALSE. In DY case, the within and absolute spillovers are the same.")
        return(
            lapply(
                tables, 
                function(i) sapply(
                    assets, 
                    function(j) 
                    100 * sum( i[j, -which(assets==j)] ) / sum(i)
                    )
                )
            )
    } else {
        return(
            lapply(
                tables, 
                function(i) sapply(
                    assets, 
                    function(j) 
                    100 * sum( i[j, -which(assets==j)]) / length(assets)
                    )
                )
            )
    }
}


#' Function to compute pairwise spillovers
#' 
#' Taking in spillover_table, the function computes the pairwise spillover.
#' 
#' @param spillover_table a spillover_table object, ideally from the provided estimation 
#'      functions
#' @param within whether to compute the within spillovers if the spillover
#'      tables are frequency based.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return a list containing the pairwise spillover
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
pairwise.spillover_table <- function(spillover_table, within = F, ...) {
    tables <- spillover_table$tables
    assets <- colnames(tables[[1]])
    combinations <- utils::combn(assets, 2)

    if (within) {
        if (check_that_it_is_not_fft(spillover_table)) warning("You are setting within to FALSE. In DY case, the within and absolute spillovers are the same.")
        out <- lapply(
            tables, 
            function(tab) apply(
                combinations, 2, 
                function(i) 
                100 * ( tab[i[1], i[2]] - tab[i[2], i[1]] ) / sum(tab) 
                )
            )    
    } else {
        out <- lapply(
            tables, 
            function(tab) apply(
                combinations, 2, 
                function(i) 
                100 * ( tab[i[1], i[2]] - tab[i[2], i[1]] ) / length(assets) 
                )
            )   
    }
    
    for (i in 1:length(out)) {
        names(out[[i]]) <- apply(combinations, 2, function(i) paste(i, collapse = "-"))
    }
    return(out)
}


#' Function to compute net spillovers
#' 
#' Taking in spillover_table, the function computes the net spillover.
#' 
#' @param spillover_table a spillover_table object, ideally from the provided estimation 
#'      functions
#' @param within whether to compute the within spillovers if the spillover
#'      tables are frequency based.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return a list containing the net spillover
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
net.spillover_table <- function(spillover_table, within = F, ...) {
    if (check_that_it_is_not_fft(spillover_table) & within) warning("You are setting within to FALSE. In DY case, the within and absolute spillovers are the same.")
    t <- to(spillover_table, within)
    f <- from(spillover_table, within)
    out <- lapply(1:length(t), function(i) t[[i]] - f[[i]])
    names(out) <- names(t)
    return(out)    
}


#' Function to collapse bounds
#' 
#' Taking in spillover_table, if the spillover_table is frequency based, it 
#' allows you to collapse several frequency bands into one.
#' 
#' @param spillover_table a spillover_table object, ideally from the provided estimation 
#'      functions
#' @param which which frequency bands to collapse. Should be a sequence like 1:2
#'      or 1:5, etc.
#' @param ... for the sake of CRAN not to complain
#' 
#' @return spillover_table with less frequency bands.
#' 
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>
#' @export
collapseBounds.spillover_table <- function(spillover_table, which) {
    orig <- 1:length(spillover_table$tables)
    di <- setdiff(orig, which)

    spillover_table$tables <- c(spillover_table$tables[di[di<max(which)]], list(Reduce(`+`, spillover_table$tables[which])), spillover_table$tables[di[di>max(which)]])
    spillover_table$bounds <- spillover_table$bounds[-which[2:length(which)]]

    return(spillover_table)
}
