spillover <- function(func, est, n.ahead, table, no.corr = F) {
	f <- get(func)
	if (table) {
		return(f(est, n.ahead, no.corr = no.corr))
	} else {
		return(1 - sum(diag(f(est, n.ahead, no.corr = no.corr)))/est$K)
	}
}

spilloverFft <- function(func, est, n.ahead, partition, table, absolute, no.corr = F) {
	f <- get(func)
	if (table) {
		decomp <- f(est, n.ahead, no.corr = no.corr)
		return(lapply(getPartition(partition, n.ahead), function(j) Reduce('+', decomp[j])))
	} else {
		if (absolute) {
			decomp <- f(est, n.ahead, no.corr = no.corr)
			return(sapply(lapply(getPartition(partition, n.ahead), function(j) Reduce('+', decomp[j])), function(i) sum(i)/est$K  - sum(diag(i))/sum(Reduce('+', decomp)) ))
		} else {
			decomp <- f(est, n.ahead, no.corr = no.corr)
			return(sapply(lapply(getPartition(partition, n.ahead), function(j) Reduce('+', decomp[j])), function(i) 1  - sum(diag(i))/sum(i) ))
		}
		
	}
}

spilloverRolling <- function(func, data, p, type, window, n.ahead, no.corr, table = F, cluster = NULL) {
	f <- get(func)
	if (table) {
		if (is.null(cluster)) {
			return(lapply(0:(nrow(data)-window), function(j) f(VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table, no.corr = no.corr)))
		} else {
			clusterExport(cluster, c("data", "p", "type", "window", "n.ahead", "table", "f", "VAR", "fevd", "irf", "no.corr"), envir=environment())
			return(parLapply(cl = cluster, 0:(nrow(data)-window), function(j) f(VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table, no.corr = no.corr)))
		}
	} else {
		if (is.null(cluster)) {
			return(sapply(0:(nrow(data)-window), function(j) f(VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table, no.corr = no.corr)))
		} else {
			clusterExport(cluster, c("data", "p", "type", "window", "n.ahead", "table", "f", "VAR", "fevd", "irf", "no.corr"), envir=environment())
			return(parSapply(cl = cluster, 0:(nrow(data)-window), function(j) f(VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table, no.corr = no.corr)))
		}
	}
}

spilloverRollingFft <- function(func, data, p, type, window, n.ahead, partition, absolute, no.corr, table = F, cluster = NULL) {
	f <- get(func)
	if (table) {
		if (is.null(cluster)) {
			return(lapply(0:(nrow(data)-window), function(j) f(VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table, partition = partition, absolute = absolute, no.corr = no.corr)))
		} else {
			clusterExport(cluster, c("data", "p", "type", "window", "n.ahead", "table", "f", "VAR", "fevd", "irf", "absolute", "bounds", "no.corr"), envir=environment())
			return(parLapply(cl = cluster, 0:(nrow(data)-window), function(j) f(VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, partition = partition, table = table, absolute = absolute, no.corr = no.corr)))
		}	
	} else {
		if (is.null(cluster)) {
			return(sapply(0:(nrow(data)-window), function(j) f(VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table, partition = partition, absolute = absolute, no.corr = no.corr)))
		} else {
			clusterExport(cluster, c("data", "p", "type", "window", "n.ahead", "table", "f", "VAR", "fevd", "irf", "absolute", "bounds", "no.corr"), envir=environment())
			return(parSapply(cl = cluster, 0:(nrow(data)-window), function(j) f(VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, partition = partition, table = table, absolute = absolute, no.corr = no.corr)))
		}
	}
	
}

spilloverDY09 <- function(est, n.ahead = 100, no.corr, table = F) {
	return(spillover("fevd", est, n.ahead, table, no.corr = no.corr))
}

spilloverDY12 <- function(est, n.ahead = 100, no.corr, table = F) {
	return(spillover("genFEVD", est, n.ahead, table, no.corr = no.corr))
}

spilloverBK09 <- function(est, n.ahead = 100, no.corr, partition, table = F, absolute = T) {
	return(spilloverFft("fftFEVD", est = est, n.ahead = n.ahead, partition = partition, table = table, absolute = absolute, no.corr = no.corr))
}

spilloverBK12 <- function(est, n.ahead = 100, no.corr, partition, table = F, absolute = T) {
	return(spilloverFft("fftGenFEVD", est, n.ahead, partition, table, absolute, no.corr = no.corr))
}

spilloverRollingDY09 <- function(data, p, type, window, n.ahead, table = F, no.corr, cluster = NULL) {
	return(spilloverRolling("spilloverDY09", data, p, type, window, n.ahead, table = table, cluster = cluster, no.corr = no.corr))
}

spilloverRollingDY12 <- function(data, p, type, window, n.ahead, table = F, no.corr, cluster = NULL) {
	return(spilloverRolling("spilloverDY12", data, p, type, window, n.ahead, table = table, cluster = cluster, no.corr = no.corr))
}

spilloverRollingBK09 <- function(data, p, type, window, n.ahead, partition, table = F, no.corr, absolute, cluster = NULL) {
	return(spilloverRollingFft("spilloverBK09", data, p, type, window, n.ahead, partition, table = table, absolute = absolute, cluster = cluster, no.corr = no.corr))
}

spilloverRollingBK12 <- function(data, p, type, window, n.ahead, partition, table = F, no.corr, absolute, cluster = NULL) {
	return(spilloverRollingFft("spilloverBK12", data, p, type, window, n.ahead, partition, table = table, absolute = absolute, cluster = cluster, no.corr = no.corr))
}