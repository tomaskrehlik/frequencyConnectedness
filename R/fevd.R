irf <- function(est, n.ahead, ...) {
	if (class(est) %in% c("varest", "vec2var")) {
		# cat("The model is from the vars package, using irf function from there.")
		return(vars::irf(est, n.ahead = n.ahead, boot = F, ortho = F))
	} else if (class(est)=="BigVAR.results") {
		# cat("The model is from BigVAR package, using own irf function.")
		return(irf.bigvar(est, n.ahead = n.ahead))
	} else {
		stop("Unsupported class of estimate")
	}
}

#' @import methods
methods::setMethod("residuals", signature(object = "BigVAR.results"), function(object) {
	object@resids
})

irf.bigvar <- function(est, n.ahead) {
	B <- est@betaPred

	H <- n.ahead
	p <- est@lagmax
	k <- nrow(B)
	# Remove the constants
	B <- B[,-1]
	betas <- lapply(1:p, function(i) B[,1:k + (i-1)*k])

	lags_obs <- c( 	lapply(1:(p-1), function(i) matrix(0, nrow = k, ncol = k)), 
					list(diag(k)), 
					lapply(1:H, function(i) matrix(0, nrow = k, ncol = k)))

	for (i in 1:H) {
    	for (j in 1:p) {
        	lags_obs[[p+i]] <- t(betas[[j]])%*%lags_obs[[p+i-j]] + lags_obs[[p+i]]
    	}
	}

	lags_obs <- lags_obs[p:length(lags_obs)]

	return(list(irf = lapply(1:k, function(j) t(sapply(lags_obs, function(i) i[j,])))))
}


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
	# Get the unorthogonalized impulse responses (essentially Wold decomposition
	# coefficients thats why the name Phi.)
	Phi <- irf(est, n.ahead = n.ahead, boot = F, ortho = F)
	# Extract them from standard format
	Phi <- lapply(1:(n.ahead + 1), function(j) sapply(Phi$irf, function(i) i[j,]))
	# Estimate the covariance matrix of the residuals
	Sigma <- t(residuals(est)) %*% residuals(est)/nrow(residuals(est))
	# Eliminate the off-diagonal elements of the covariance matrix to only
	# see the effects of the coefficients
	# This is primarily useful for Lasso.
	if (no.corr) {
		Sigma <- diag(diag(Sigma))
	}
	# Estimate the denominator of the ration of FEVD.
	denom <- diag(Reduce('+', lapply(Phi, function(i) i%*%Sigma%*%t(i))))
	

	# This computes the enumerator, essentially compute all the elements of the
	# sum and then reduce them using the sum operator.
	enum <- Reduce('+', lapply(Phi, function(i) 
		( chol(Sigma) %*% t(i) )^2 
		)
	)
	
	# Compute the ration and return the matrix.
	return(
		t(
			sapply(1:ncol(enum), function(i)  enum[,i]/denom[i] )
			)
		)
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
	# Warn if the n.ahead is too low.
	if (n.ahead < 100) {
		warning("The frequency decomposition works with unconditional IRF. You have opted for 
			IRF with horizon lower than 100 periods. This might cause trouble, some frequencies
			might not be estimable depending on the bounds settings.")
	}
	# Get the unorthogonalized impulse responses (essentially Wold decomposition
	# coefficients thats why the name Phi.)
	Phi <- irf(est, n.ahead = n.ahead, boot = F, ortho = F)
	# Get the Fourier transform of the impulse responses
	fftir <- lapply(Phi$irf, function(i) apply(i, 2, fft))
	# Transform them into shape we work with
	fftir <- lapply(1:(n.ahead+1), function(j) sapply(fftir, function(i) i[j,]))
	# Estimate the covariance matrix of the residuals
	Sigma <- t(residuals(est))%*%residuals(est) / nrow(residuals(est))
	# Eliminate the off-diagonal elements of the covariance matrix to only
	# see the effects of the coefficients
	# This is primarily useful for Lasso.
	if (no.corr) {
		Sigma <- diag(diag(Sigma))
	}
	# Here I compute the variance, and only include the frequencies mentioned
	# in range. This is because of the co-integration setting, where I want to
	# only standardize by variance from some frequency to 2*pi.
	denom <- diag(
		Re(
			Reduce('+', lapply(fftir, function(i) 
				i %*% Sigma %*% t(Conj(i)) / (n.ahead + 1)
				)[range])
			)
		)
	# Compute the enumerator of the ration for every given frequency
	enum <- lapply(fftir, function(i) 
			( abs( i %*% t(chol(Sigma)) ) )^2 / (n.ahead+1) 
		)
	# Compute the whole table by division of the individual elements.
	tab <- lapply(enum, function(i) t(sapply(1:nrow(i), function(j) i[j,]/(denom[j]))))

	return(tab)
}


#' Compute a forecast error vector decomposition in generalised VAR scheme.
#'
#' This function computes the standard forecast error vector decomposition given the 
#' estimate of the VAR.
#' There are common complaints and requests whether the computation is ok and why
#' it does not follow the original Pesaran Shin (1998) article. So let me clear two things
#' out. First, the \eqn{\sigma} in the equation on page 20 refers to elements of \eqn{\Sigma}, not standard
#' deviation. Second, the indexing is wrong, it should be \eqn{\sigma_jj} not \eqn{\sigma_ii}. Look, for example,
#' to Diebold and Yilmaz (2012) or ECB WP by Dees, Holly, Pesaran, and Smith (2007)
#' for the correct version.
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
	# Get the unorthogonalized impulse responses (essentially Wold decomposition
	# coefficients thats why the name Phi.)
	Phi <- irf(est, n.ahead = n.ahead, boot = F, ortho = F)
	# Extract them from standard format
	Phi <- lapply(1:(n.ahead + 1), function(j) sapply(Phi$irf, function(i) i[j,]))
	# Estimate the covariance matrix
	Sigma <- t(residuals(est))%*%residuals(est) / nrow(residuals(est))
	# Remove the individual elements, if needed.
	if (no.corr) {
		Sigma <- diag(diag(Sigma))
	}
	# Compute the variance for standardization
	# One wants to do this before nullifying the elements, because otherwise
	# the ratios could get weird in principle.
	denom <- diag(
		Reduce('+', lapply(Phi, function(i) 
			i %*% Sigma %*% t(i) 
			)
		)
		)
	
	# Compute the enumerator of the ration, see for example D&Y 2012
	enum <- Reduce('+', lapply(Phi, function(i) (i%*%Sigma)^2))
	# Compute the elements of the FEVD
	tab <- sapply(1:nrow(enum), function(j) 
		enum[j,] / ( denom[j] * diag(Sigma) )
		)
	# Standardize rows as they don't have to add up to one.
	tab <- t(apply(tab, 2, function(i) i / sum(i) ))
	return(tab)
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
	# Warn if the n.ahead is too low.
	if (n.ahead < 100) {
		warning("The frequency decomposition works with unconditional IRF. You have opted for 
			IRF with horizon lower than 100 periods. This might cause trouble, some frequencies
			might not be estimable depending on the bounds settings.")
	}
	# Get the unorthogonalized impulse responses (essentially Wold decomposition
	# coefficients thats why the name Phi.)
	Phi <- irf(est, n.ahead = n.ahead, boot = F, ortho = F)
	# Get the Fourier transform of the impulse responses
	fftir <- lapply(Phi$irf, function(i) apply(i, 2, fft))
	# Transform them into shape we work with
	fftir <- lapply(1:(n.ahead+1), function(j) sapply(fftir, function(i) i[j,]))
	# Estimate the covariance matrix
	Sigma <- t(residuals(est))%*%residuals(est) / nrow(residuals(est))
	# Remove the individual elements, if needed.
	if (no.corr) {
		Sigma <- diag(diag(Sigma))
	}
	# Compute the variance for standardization
	# One wants to do this before nullifying the elements, because otherwise
	# the ratios could get weird in principle.
	# Here I compute the variance, and only include the frequencies mentioned
	# in range. This is because of the co-integration setting, where I want to
	# only standardize by variance from some frequency to 2*pi.
	denom <- diag(
		Re(
			Reduce('+', lapply(fftir, function(i) 
				i %*% Sigma %*% t( Conj(i) ) / (n.ahead + 1)
				)[range]
			)
		)
		)
	# Compute the enumerator of the equation
	enum <- lapply(fftir, function(i) 
		( abs( i %*% Sigma ) )^2 / (n.ahead+1)
		)
	# Compute the fevd table be dividing the individual elements
	tab <- lapply(enum, function(i) 
			sapply(1:nrow(i), function(j) 
					i[j, ] / ( denom[j] * diag(Sigma) ) 
				) 
		)
	# Compute the totals over the range for standardization
	tot <- apply(Reduce('+', tab[range]), 2, sum)	
	# Standardize so that it sums up to one row-wise
	tab <- lapply(tab, function(i) t(i)/tot)
	return(tab)
}
