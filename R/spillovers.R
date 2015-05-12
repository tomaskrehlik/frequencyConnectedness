spillover <- function(func, est, n.ahead, table) {
	f <- get(func)
	if (table) {
		return(f(est, n.ahead))
	} else {
		return(1 - sum(diag(f(est, n.ahead)))/est$K)
	}
}

spilloverFft <- function(func, est, n.ahead, partition, table, absolute) {
	f <- get(func)
	if (table) {
		decomp <- f(est, n.ahead)
		return(lapply(getPartition(partition, n.ahead), function(j) Reduce('+', decomp[j])))
	} else {
		if (absolute) {
			decomp <- f(est, n.ahead)
			return(sapply(lapply(getPartition(partition, n.ahead), function(j) Reduce('+', decomp[j])), function(i) sum(i)/est$K  - sum(diag(i))/sum(Reduce('+', decomp)) ))
		} else {
			decomp <- f(est, n.ahead)
			return(sapply(lapply(getPartition(partition, n.ahead), function(j) Reduce('+', decomp[j])), function(i) 1  - sum(diag(i))/sum(i) ))
		}
		
	}
}

spilloverRolling <- function(func, data, p, type, window, n.ahead, table = F, cluster = NULL) {
	f <- get(func)
	if (table) {
		if (is.null(cluster)) {
			return(lapply(0:(nrow(data)-window), function(j) f(VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table)))
		} else {
			clusterExport(cluster, c("data", "p", "type", "window", "n.ahead", "table", "f", "VAR", "fevd", "irf"), envir=environment())
			return(parLapply(cl = cluster, 0:(nrow(data)-window), function(j) f(VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table)))
		}
	} else {
		if (is.null(cluster)) {
			return(sapply(0:(nrow(data)-window), function(j) f(VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table)))
		} else {
			clusterExport(cluster, c("data", "p", "type", "window", "n.ahead", "table", "f", "VAR", "fevd", "irf"), envir=environment())
			return(parSapply(cl = cluster, 0:(nrow(data)-window), function(j) f(VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table)))
		}
	}
}

spilloverRollingFft <- function(func, data, p, type, window, n.ahead, partition, absolute, table = F, cluster = NULL) {
	f <- get(func)
	if (table) {
		if (is.null(cluster)) {
			return(lapply(0:(nrow(data)-window), function(j) f(VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table, partition = partition, absolute = absolute)))
		} else {
			clusterExport(cluster, c("data", "p", "type", "window", "n.ahead", "table", "f", "VAR", "fevd", "irf", "absolute", "bounds"), envir=environment())
			return(parLapply(cl = cluster, 0:(nrow(data)-window), function(j) f(VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, partition = partition, table = table, absolute = absolute)))
		}	
	} else {
		if (is.null(cluster)) {
			return(sapply(0:(nrow(data)-window), function(j) f(VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, table = table, partition = partition, absolute = absolute)))
		} else {
			clusterExport(cluster, c("data", "p", "type", "window", "n.ahead", "table", "f", "VAR", "fevd", "irf", "absolute", "bounds"), envir=environment())
			return(parSapply(cl = cluster, 0:(nrow(data)-window), function(j) f(VAR(data[(1:window)+j,], p = p, type = type), n.ahead = n.ahead, partition = partition, table = table, absolute = absolute)))
		}
	}
	
}

spilloverDY09 <- function(est, n.ahead = 100, table = F) {
	return(spillover("fevd", est, n.ahead, table))
}

spilloverDY12 <- function(est, n.ahead = 100, table = F) {
	return(spillover("genFEVD", est, n.ahead, table))
}

spilloverBK09 <- function(est, n.ahead = 100, partition, table = F, absolute = T) {
	return(spilloverFft("fftFEVD", est = est, n.ahead = n.ahead, partition = partition, table = table, absolute = absolute))
}

spilloverBK12 <- function(est, n.ahead = 100, partition, table = F, absolute = T) {
	return(spilloverFft("fftGenFEVD", est, n.ahead, partition, table, absolute))
}

spilloverRollingDY09 <- function(data, p, type, window, n.ahead, table = F, cluster = NULL) {
	return(spilloverRolling("spilloverDY09", data, p, type, window, n.ahead, table = F, cluster = NULL))
}

spilloverRollingDY12 <- function(data, p, type, window, n.ahead, table = F, cluster = NULL) {
	return(spilloverRolling("spilloverDY12", data, p, type, window, n.ahead, table = F, cluster = NULL))
}

spilloverRollingBK09 <- function(data, p, type, window, n.ahead, partition, table = F, absolute, cluster = NULL) {
	return(spilloverRollingFft("spilloverBK09", data, p, type, window, n.ahead, partition, table = F, absolute = absolute, cluster = cluster))
}

spilloverRollingBK12 <- function(data, p, type, window, n.ahead, partition, table = F, absolute, cluster = NULL) {
	return(spilloverRollingFft("spilloverBK12", data, p, type, window, n.ahead, partition, table = F, absolute = absolute, cluster = cluster))
}