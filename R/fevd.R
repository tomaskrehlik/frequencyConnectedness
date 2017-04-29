#' Compute a forecast error vector decomposition in recursive identification scheme
#'
#' This function computes the standard forecast error vector decomposition given the 
#' estimate of the VAR.
#'
#' @param est the VAR estimate from the vars package
#' @param n.ahead how many periods ahead should be taken into account
#' @param no.corr boolean if the off-diagonal elements should be set to 0.
#' @return a matrix that corresponds to contribution of ith variable to jth variance of forecast
#' @export
#' @author Tomas Krehlik \email{tomas.krehlik@@gmail.com}
#' @import vars
#' @import urca
#' @import stats
fevd <- function(est, n.ahead = 100, no.corr = F) {
	ir <- irf(est, n.ahead = n.ahead, boot = F, ortho = F)

	ir <- lapply(1:(n.ahead + 1), function(j) sapply(ir$irf, function(i) i[j,]))
	sig <- t(residuals(est)) %*% residuals(est)/nrow(residuals(est))
	if (no.corr) {
		sig <- diag(diag(sig))
	}

	denom <- diag(Reduce('+', lapply(ir, function(i) i%*%sig%*%t(i))))

	K <- chol(sig)

	enum <- Reduce('+', lapply(ir, function(i) (K%*%t(i))^2))
	
	return(t(sapply(1:est$K, function(i) enum[,i]/(denom[i]))))
}


#' Compute a FFT transform of forecast error vector decomposition in recursive identification scheme
#'
#' This function computes the decomposition of standard forecast error vector decomposition given the 
#' estimate of the VAR. The decomposition is done according to the Stiassny (1996)
#'
#' @param est the VAR estimate from the vars package
#' @param n.ahead how many periods ahead should be taken into account
#' @param no.corr boolean if the off-diagonal elements should be set to 0.
#' @param range defines the frequency partitions to which the spillover should be decomposed
#' @return a list of matrices that corresponds to contribution of ith variable to jth variance of forecast
#'	 
#' @export
#' @author Tomas Krehlik \email{tomas.krehlik@@gmail.com}
#' @import vars
#' @import urca
#' @import stats
fftFEVD <- function(est, n.ahead = 100, no.corr = F, range) {
	if (n.ahead < 100) {
		warning("The frequency decomposition works with unconditional IRF. You have opted for 
			IRF with horizon lower than 100 periods. This might cause trouble, some frequencies
			might not be estimable depending on the bounds settings.")
	}
	Phi <- irf(est, n.ahead = n.ahead, boot = F, ortho = F)

	fftir <- lapply(Phi$irf, function(i) apply(i, 2, fft))
	fftir <- lapply(1:(n.ahead+1), function(j) sapply(fftir, function(i) i[j,]))

	Phi <- lapply(1:(n.ahead + 1), function(j) sapply(Phi$irf, function(i) i[j,]))
	Sigma <- t(residuals(est))%*%residuals(est) / nrow(residuals(est))
	if (no.corr) {
		Sigma <- diag(diag(Sigma))
	}
	
	denom <- diag(Re(Reduce('+', lapply(fftir, function(i) i %*% Sigma %*% t(Conj(i) )/(n.ahead + 1))[range])))
	
	enum <- lapply(fftir, function(i) (abs(i%*%t(chol(Sigma))))^2/(n.ahead+1))
	a <- lapply(enum, function(i) t(sapply(1:est$K, function(j) i[j,]/(denom[j]))))

	return(a)
}


#' Compute a forecast error vector decomposition in generalised VAR scheme.
#'
#' This function computes the standard forecast error vector decomposition given the 
#' estimate of the VAR.
#'
#' @param est the VAR estimate from the vars package
#' @param n.ahead how many periods ahead should be taken into account
#' @param no.corr boolean if the off-diagonal elements should be set to 0.
#' @return a matrix that corresponds to contribution of ith variable to jth variance of forecast
#'
#' @export
#' @author Tomas Krehlik \email{tomas.krehlik@@gmail.com}
#' @import vars
#' @import urca
#' @import stats
genFEVD <- function(est, n.ahead = 100, no.corr = F) {
	Phi <- irf(est, n.ahead = n.ahead+1, boot = F, ortho = F)
	Phi <- lapply(1:(n.ahead + 1), function(j) sapply(Phi$irf, function(i) i[j,]))
	Sigma <- t(residuals(est))%*%residuals(est) / nrow(residuals(est))

	denom <- diag(Reduce('+', lapply(Phi, function(i) i %*% Sigma %*% t(i) )))

	if (no.corr) {
		Sigma <- diag(diag(Sigma))
	}

	enum <- Reduce('+', lapply(Phi, function(i) (i%*%Sigma)^2))
	# print(enum)
	# print(denom)
	a <- sapply(1:est$K, function(j) enum[j,]/(denom[j]*diag(Sigma)))
	# print(a)
	a <- t(apply(a, 2, function(i) i / sum(i) ))
	return(a)
}

#' Compute a FFT transform of forecast error vector decomposition in generalised VAR scheme.
#'
#' This function computes the decomposition of standard forecast error vector decomposition given the 
#' estimate of the VAR. The decomposition is done according to the Stiassny (1996)
#'
#' @param est the VAR estimate from the vars package
#' @param n.ahead how many periods ahead should be taken into account
#' @param no.corr boolean if the off-diagonal elements should be set to 0.
#' @param range defines the frequency partitions to which the spillover should be decomposed
#' @return a list of matrices that corresponds to contribution of ith variable to jth variance of forecast
#'	 
#' @export
#' @author Tomas Krehlik \email{tomas.krehlik@@gmail.com}
#' @import vars
#' @import urca
#' @import stats
fftGenFEVD <- function(est, n.ahead = 100, no.corr = F, range) {
	if (n.ahead < 100) {
		warning("The frequency decomposition works with unconditional IRF. You have opted for 
			IRF with horizon lower than 100 periods. This might cause trouble, some frequencies
			might not be estimable depending on the bounds settings.")
	}
	Phi <- irf(est, n.ahead = n.ahead, boot = F, ortho = F)

	fftir <- lapply(Phi$irf, function(i) apply(i, 2, fft))
	fftir <- lapply(1:(n.ahead+1), function(j) sapply(fftir, function(i) i[j,]))

	Phi <- lapply(1:(n.ahead + 1), function(j) sapply(Phi$irf, function(i) i[j,]))
	Sigma <- t(residuals(est))%*%residuals(est) / nrow(residuals(est))

	# print(diag(Reduce('+', lapply(Phi, function(i) i %*% Sigma %*% t(i) ))))
	denom <- diag(Re(Reduce('+', lapply(fftir, function(i) i %*% Sigma %*% t(Conj(i) )/(n.ahead + 1))[range])))

	# cat("The weights are: ")
	# cat(denom)
	# cat("\n")
	if (no.corr) {
		Sigma <- diag(diag(Sigma))
	}

	# print(Sigma)

	enum <- lapply(fftir, function(i) (abs(i%*%Sigma))^2/(n.ahead+1))
	a <- lapply(enum, function(i) sapply(1:est$K, function(j) i[j,]/(denom[j]*diag(Sigma)) ) )
	tot <- apply(Reduce('+', a[range]), 2, sum)	
	

	a <- lapply(a, function(i) t(i)/tot)

	return(a)
}
