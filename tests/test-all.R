if (packageVersion("testthat") >= "0.7.1.99") {
	library(testthat)
	library(fftSpillover)
	test_check("fftSpillover")
}