if (packageVersion("testthat") >= "0.7.1.99") {
	library(testthat)
	library(frequencyConnectedness)
	test_check("frequencyConnectedness")
}