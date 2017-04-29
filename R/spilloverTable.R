#' Create a latex spillover table like in Barunik, Krehlik (2015)
#'
#' @param tot a matrix usually from spilloverDY12 or spilloverDY09
#' @param decomposition_a a list of matrices containing absolute decomposition typically from spilloverBK12
#' @param decomposition_r a list of matrices containing within decomposition typically from spilloverBK12
#' @param nams names of the variables
#' @param format a format of the output numbers
#' @param sep a separator in the decomposition
#'
#' @export
#' @author Tomas Krehlik <tomas.krehlik@@gmail.com>

createSpilloverTable <- function(tot, decomposition_a, decomposition_r, nams, format = "%1.1f", sep = "-") {

	zip <- function(i,j) {
		output <- c()
		for (k in 1:length(i)) {
			output <- c(output, i[k], j[k])
		}
		return(output)
	}
	zip2 <- function(i,j,l) {
		output <- c()
		for (k in 1:length(i)) {
			output <- c(output, i[k], j[k], l[k])
		}
		return(output)
	}

	addeol <- function(j) {
		return(paste(j, " \\\\", sep = ""))
	}

	decomposition_a <- lapply(decomposition_a, function(i) i)
	decomposition_r <- lapply(decomposition_r, function(i) i)
	tot <- tot

	k <- nrow(decomposition_a[[1]])
	decomp_a <- matrix(apply(expand.grid(1:k,1:k), 1, function(j) paste(sapply(decomposition_a, function(i) sprintf(format,i[j[1],j[2]])), collapse=sep)), nrow = k, byrow = F)
	decomp_r <- matrix(apply(expand.grid(1:k,1:k), 1, function(j) paste(sapply(decomposition_r, function(i) sprintf(format,i[j[1],j[2]])), collapse=sep)), nrow = k, byrow = F)


	from_a <- Map(function(j) apply(j-diag(diag(j)), 1, function(i) sprintf(format, sum(i))), decomposition_a)
	from_a <- apply(do.call(cbind, from_a), 1, function(j) paste(j, collapse = sep))
	from_r <- Map(function(j) apply(j-diag(diag(j)), 1, function(i) sprintf(format, sum(i))), decomposition_r)
	from_r <- apply(do.call(cbind, from_r), 1, function(j) paste(j, collapse = sep))
	from_t <- apply(tot-diag(diag(tot)), 1, function(i)  sum(i))

	to_a <- Map(function(j) apply(j-diag(diag(j)), 2, function(i) sprintf(format, sum(i))), decomposition_a)
	to_a <- apply(do.call(cbind, to_a), 1, function(j) paste(j, collapse = sep))
	to_r <- Map(function(j) apply(j-diag(diag(j)), 2, function(i) sprintf(format, sum(i))), decomposition_r)
	to_r <- apply(do.call(cbind, to_r), 1, function(j) paste(j, collapse = sep))
	to_t <- apply(tot-diag(diag(tot)), 2, function(i) sum(i))

	decomp_a <- cbind(decomp_a, from_a)
	decomp_r <- cbind(decomp_r, from_r)
	total <- cbind(tot, from_t)

	decomp_a <- matrix(paste("\\textbf{\\tiny{",rbind(decomp_a, c(to_a, paste(sprintf(format, sapply(decomposition_a, function(i) sum(i-diag(diag(i)))/sum(tot))), collapse = sep))),"}}", sep = ""), ncol = k+1, byrow = F)
	decomp_r <- matrix(paste("\\tiny{",rbind(decomp_r, c(to_r, paste(sprintf(format, sapply(decomposition_r, function(i) sum(i-diag(diag(i)))/sum(tot))), collapse = sep))),"}", sep = ""), ncol = k+1, byrow = F)
	total <- rbind(total, c(to_t, sum(tot-diag(diag(tot)))/sum(tot)))

	relative <- apply(decomp_r, 1, function(i) paste(i, collapse = " & "))
	absolute <- apply(decomp_a, 1, function(i) paste(i, collapse = " & "))
	t <- apply(matrix(do.call(c, Map(function(j) sprintf(format, j), total)), nrow = k+1, byrow = F), 1, function(i) paste(i, collapse = " & "))

	tab <- zip2(t, absolute, relative)
	row_names <- zip2(paste(c("\\multirow{3}{*}{"), c(nams, "To Others"), "}", sep = ""), rep(" ", length(nams)+1), rep(" ", length(nams)+1))
	tab <- paste(row_names, tab, collapse = " \\\\ \n ", sep = " & ")
	tab <- stringr::str_replace_all(tab, "\n \\\\multirow\\{3\\}\\{\\*\\}", "[10pt]\n \\\\multirow\\{3\\}\\{\\*\\}")
	tab <- stringr::str_replace_all(tab, "\\[10pt\\]\n \\\\multirow\\{3\\}\\{\\*\\}\\{To Others\\}", "\n \\\\midrule \n \\\\multirow\\{3\\}\\{\\*\\}\\{To\\}")

	return(paste(c("\\toprule", addeol(paste(c(" ",nams, "From Others"), collapse = " & ")), "\\midrule", addeol(tab), "\\bottomrule"), collapse = " \n"))

}