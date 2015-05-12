fftSpillover
==================

A package implementing frequency dependent spillovers due to [Barunik, Krehlik (2015)][BK2015] as well as the traditional definitions of [Diebold, Yilmaz (2009, 2012)][DY09]. See the papers for detailed description.

Installation
------------------

Be sure to have installed the `devtools` package that allows you to install packages from Github directly. In future, we plan to release the package through the standard CRAN repository, however, at the moment this way is the preferred one.

To install the current version

````{r}
# install.packages("devtools")
library(devtools)
install_github("tomaskrehlik/fftSpillover") 
````

Usage
--------------------
Currently the package works in close cooperation with the `vars` package. This is however not necessary and any estimate that gives you `fevd` will do. For the time being the following is available:

    - Traditional estimation of VAR
    - Fitting of the VECM model

For the illustration purposes we include some simulated data.

````{r}
library(vars)
library(fftSpillover)
data(exampleSim)
# Shorten the data, rolling estimation takes quite some time
exampleSim <- exampleSim[1:600,]
# Compute the VAR(2) estimate with constant and save results
est <- VAR(exampleSim, p = 2, type = "const")

# Compute traditional spillovers
spilloverDY09(est, n.ahead = 100)
spilloverDY12(est, n.ahead = 100)

# Get the connectedness tables
spilloverDY09(est, n.ahead = 100, table = T)
spilloverDY12(est, n.ahead = 100, table = T)

# Get the absolute FFT spillovers on partition (pi,pi/2), (pi/2, pi/4), (pi/4,0)
bounds <- c(1.0001, 0.5, 0.25, 0)*pi # The 1.001 has to be there because otherwise it is an open interval
spilloverfftDY09(est, n.ahead = 100, partition = bounds, absolute = T)
spilloverfftDY12(est, n.ahead = 100, partition = bounds, absolute = T)

# Check that they sum up to the original measures
sum(spilloverfftDY09(est, n.ahead = 100, partition = bounds, absolute = T))
sum(spilloverfftDY12(est, n.ahead = 100, partition = bounds, absolute = T))

# Get the within FFT spillovers on the same partition
spilloverfftDY09(est, n.ahead = 100, partition = bounds, absolute = F)
spilloverfftDY12(est, n.ahead = 100, partition = bounds, absolute = F)

# Both absolute and within spillovers can produce tables with parameter table = T

# Get rolling window estimates
spilloverRollingDY12(exampleSim, p = 2, type = "const", window = 200, n.ahead = 100)
spilloverRollingfftDY12(exampleSim, p = 2, type = "const", window = 200, n.ahead = 100, partition = bounds)
````

If you have more cores at your disposal as is usual in the computers nowadays, it is beneficial to use them through `parallel` package especially in case of rolling estimation. If you use two cores it usually almost doubles the speed. For example

````{r}
library(parallel)
cl <- makeCluster(4) # Assign R cores to the job
spilloverRollingfftDY12(exampleSim, p = 2, type = "const", window = 200, n.ahead = 100, partition = bounds, cluster = cl)
stopCluster()
````

License
--------------------
This package is free and open source software, licensed under GPL (>= 2).


[BK2015]: http:// "Some arxiv link"
[DY09]: http://www.sciencedirect.com/science/article/pii/S016920701100032X "Diebold, F. X., Yilmaz, K., Better to give than to receive: Predictive directional measurement of volatility spillovers"
