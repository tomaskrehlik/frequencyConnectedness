# frequencyConnectedness


A package implementing frequency dependent connectedness due to [Barunik, Krehlik (2015)][BK2015] as well as the traditional definitions of [Diebold, Yilmaz (2009, 2012)][DY09]. See the papers for detailed description.

## Installation


Be sure to have installed the `devtools` package that allows you to install packages from Github directly. In future, we plan to release the package through the standard CRAN repository, however, at the moment this way is the preferred one.

To install the current version

````{r}
# install.packages("devtools")
library(devtools)
install_github("tomaskrehlik/frequencyConnectedness") 
````

## Usage

Currently the package works in close cooperation with the `vars` and `urca` package. This is however not necessary and any estimate that gives you `fevd` will do. For the time being the following is available:

    - Traditional estimation of VAR
    - Fitting of the VECM model

For the illustration purposes we include some simulated data.

Let's walk through some basics. First load packages and get some data.

````{r}
library(vars)
library(urca)
library(frequencyConnectedness)
data(exampleSim)
# Shorten the data, rolling estimation takes quite some time
exampleSim <- exampleSim[1:600,]
````

Then compute a system estimate on which the computation of connectedness is based:
````{r}
# Compute the VAR(2) estimate with constant and save results
est <- VAR(exampleSim, p = 2, type = "const")
# Alternatively, you could use VECM
# est <- vec2var(ca.jo(exampleSim, ecdet = "trend", K = 2), r = 1)
````

Then use the estimate to compute the connectedness measures.
First, the traditional overall measures that are not frequency dependent as in Diebold and Yilmaz, also with the possibility to get the connectedness table.

````{r}
# Compute traditional spillovers
spilloverDY09(est, n.ahead = 100)
spilloverDY12(est, n.ahead = 100)

# Get the connectedness tables
spilloverDY09(est, n.ahead = 100, table = T)
spilloverDY12(est, n.ahead = 100, table = T)
````

Next, we can decompose the measure on desired frequencies and get the frequency dependent measures.

````{r}
# Get the frequency connectedness on partition (pi,pi/2), (pi/2, pi/4), (pi/4,0)
bounds <- c(1.0001, 0.5, 0.25, 0)*pi # The 1.001 has to be there because otherwise it is an open interval
spilloverBK09(est, n.ahead = 100, partition = bounds, absolute = T)
spilloverBK12(est, n.ahead = 100, partition = bounds, absolute = T)

# Check that they sum up to the original measures
sum(spilloverBK09(est, n.ahead = 100, partition = bounds, absolute = T))
sum(spilloverBK12(est, n.ahead = 100, partition = bounds, absolute = T))

# Get the within FFT connectedness on the same partition
spilloverBK09(est, n.ahead = 100, partition = bounds, absolute = F)
spilloverBK12(est, n.ahead = 100, partition = bounds, absolute = F)

# Both absolute and within connectedness can produce tables with parameter table = T
````
Note that the bounds should cover the range `(1.001, 0)*pi`, because the overall variance of the system is computed over these frequencies. (So if you wanted to remove the trend from computations, you could use `(1.001, 0.01)*pi` and the computation will ignore the variance created around the zero frequency.)

In many cases, one is interested in the dynamics of the connectedness. This can be achieved within the package by the following commands. (The parameters correspond to the `VAR` parameters from the `vars` package. Dynamic computation of connectedness with co-integration is not implemented in the package but is rather straightforward to do, see other examples.)

````{r}
# Get rolling window estimates
spilloverRollingDY12(exampleSim, p = 2, type = "const", window = 200, n.ahead = 100, no.corr = F)
spilloverRollingBK12(exampleSim, p = 2, type = "const", window = 200, n.ahead = 100, no.corr = F, partition = bounds, absolute = T)
````

If you have more cores at your disposal as is usual in the computers nowadays, it is beneficial to use them through `parallel` package especially in case of rolling estimation. If you use two cores it usually almost doubles the speed. For example

````{r}
library(parallel)
cl <- makeCluster(4) # Assign R cores to the job
spilloverRollingBK12(exampleSim, p = 2, type = "const", window = 200, n.ahead = 100, no.corr = F, partition = bounds, absolute = T, cluster = cl)
stopCluster()
````

## Other examples

### Rolling window estimation using co-integration
In the forecoming the `data` variable is T by k matrix and we are estimating with window 200, one co-integrating relationship, and two lags.
````{r}
sapply(0:(nrow(data)-window), function(i) spilloverDY12(vec2var(ca.jo(data[1:window + i, ], K=2, ecdet = "trend"), r = 1), n.ahead = 200, table = F))
````
### Rolling window estimation of element of connectedness table
Sometimes it is interesting to look at the development of the elements of the connectedness table itself. The function `spilloverRollingBK12` (or implementation of rolling estimation of other connectedness schemes) contains a parameter switch named `table` which is by default `FALSE`. If turned true, the rolling estimation returns a list which entry is the same as the value of `spilloverBK12` with the same parameter on the corresponding window of the data. For example, if we wanted to look at element 2,1 of the connectedness in the standard case

````{r}
connectedness <- spilloverRollingDY12(exampleSim, p = 2, type = "const", window = 200, n.ahead = 100, no.corr = F, table = TRUE)
plot(sapply(connectedness, function(i) i[2,1]), type="l")
````

In case we wanted the same information disaggregated over frequencies, we can use 

````{r}
connectedness <- spilloverRollingBK12(exampleSim, p = 2, type = "const", window = 200, n.ahead = 100, no.corr = F, table = T, partition = bounds, absolute = T)
plot.ts(t(sapply(connectedness, function(i) sapply(i, function(j) j[2,1]))), plot.type = "single", col = c("red","black","blue","green"))
````

## Replication of paper and tests

A release that reproduces the paper results with the original scripts will be tagged. The [original script](R/applications.R) can be found in the `R` folder and the header comment clearly indicates the tagged release (see the releases in the header of the file) with which it is supposed to work. Hence, the script might not work with the current version of the paper.

Because the package might change in the future, there is a set of test to always preserve the integrity of the original functions. You can read what is tested in the [testfile](tests/testthat/test-basic.r). Also provided that you have the `testthat` package installed, you can run the tests yourself.

````{r}
library(frequencyConnectedness)
library(testthat)
test_package("frequencyConnectedness")
````

## License

This package is free and open source software, licensed under GPL (>= 2).


[BK2015]: http://papers.ssrn.com/sol3/papers.cfm?abstract_id=2627599 "Barunik, J., Krehlk, T., Measuring the Frequency Dynamics of Financial and Macroeconomic Connectedness"
[DY09]: http://www.sciencedirect.com/science/article/pii/S016920701100032X "Diebold, F. X., Yilmaz, K., Better to give than to receive: Predictive directional measurement of volatility spillovers"
