# Various tests
library(vars)

context("FEVD checks")
test_that("The FFT FEVD reconstructs on the original one", {
	data(exampleSim)
	exampleSim <- exampleSim[1:100,]
	est <- VAR(exampleSim, p = 4, type ="const")
	H <- 200
	expect_equivalent(fftSpillover::fevd(est, n.ahead = H, no.corr = F), Reduce('+', fftFEVD(est, n.ahead = H, no.corr = F)))
})

test_that("The FFT GenFEVD recunstructs on the original one", {
	data(exampleSim)
	exampleSim <- exampleSim[1:100,]
	est <- VAR(exampleSim, p = 4, type ="const")
	H <- 200
	expect_equivalent(genFEVD(est, n.ahead = H, no.corr = F), Reduce('+', fftGenFEVD(est, n.ahead = H, no.corr = F)))
})

test_that("The FEVD from our package is the same as from vars package", {
	data(exampleSim)
	exampleSim <- exampleSim[1:100,]
	est <- VAR(exampleSim, p = 4, type ="const")
	H <- 200
	expect_that(all(fftSpillover::fevd(est, n.ahead = H, no.corr = F)-t(sapply(vars::fevd(est, H), function(i) i[H,]))<1e-5), is_true())
})

context("Integrity of DY12")

# These estimates were done using trusted algorithm, so backchecking
test_that("The DY12 spillover gives the proofed result table", {
	data <- read.csv("simul_data.csv", header = F)
	output <- as.matrix(read.csv("DY12output.csv", header = F))

	expect_that(all(spilloverDY12(VAR(data, p = 2, type = "const"), 10, no.corr = F, table = T)/100-output < 1e-4), is_true())
})

context("Spillovers checks")

test_that("If bounds do not cover the whole partition, give warning", {	
	bounds <- c(pi + 0.001, sort(runif(5, min = 0, max = pi), decreasing = T), 0.000001)

	expect_warning(getPartition(bounds, 200), "The selected partition does not cover the whole range.")
})

test_that("If the partition is not decreasing, produce an error.", {
	bounds <- c(2,3,1,4,5)
	expect_error(getPartition(bounds, 300), "The bounds must be in decreasing order.")
})

test_that("The BK absolute spillovers tables reconstruct perfectly in both cases", {
	data(exampleSim)
	exampleSim <- exampleSim[1:100,]
	est <- VAR(exampleSim, p = 4, type ="const")

	# Create random bounds that cover the whole range
	bounds <- c(pi + 0.001, sort(runif(5, min = 0, max = pi), decreasing = T), 0)
	H <- 200
	expect_equivalent(spilloverDY09(est, n.ahead = H, table = T, no.corr=F), Reduce('+', spilloverBK09(est, n.ahead = H, partition = bounds, absolute = T, table = T, no.corr=F)))
	expect_equivalent(spilloverDY12(est, n.ahead = H, table = T, no.corr=F), Reduce('+', spilloverBK12(est, n.ahead = H, partition = bounds, absolute = T, table = T, no.corr=F)))
})

test_that("Test that spillovers are smaller than hundred", {
	data(exampleSim)
	exampleSim <- exampleSim[1:100,]
	est <- VAR(exampleSim, p = 4, type ="const")

	# Create random bounds that cover the whole range
	bounds <- c(pi + 0.001, sort(runif(5, min = 0, max = pi), decreasing = T), 0)
	H <- 200

	expect_that(spilloverDY09(est, n.ahead = H, table = F, no.corr=F) < 100, is_true())
	expect_that(spilloverDY12(est, n.ahead = H, table = F, no.corr=F) < 100, is_true())
})



