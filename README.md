[![Build
Status](https://travis-ci.org/tomaskrehlik/frequencyConnectedness.svg?branch=master)](https://travis-ci.org/tomaskrehlik/frequencyConnectedness.svg?branch=master)

A package implementing frequency dependent connectedness due to
[Barunik, Krehlik (2018) (forthcoming in
JFE)](http://papers.ssrn.com/sol3/papers.cfm?abstract_id=2627599 "Barunik, J., Krehlk, T., Measuring the Frequency Dynamics of Financial and Macroeconomic Connectedness")
as well as the traditional definitions of [Diebold, Yilmaz (2009,
2012)](http://www.sciencedirect.com/science/article/pii/S016920701100032X "Diebold, F. X., Yilmaz, K., Better to give than to receive: Predictive directional measurement of volatility spillovers").
See the papers for detailed description.

NOTICE
------

There is a new version of the interface coming with the version `0.2.0`.
If you implemented anything prior to this version, you can install the
older stable version using

    # install.packages("devtools")
    library(devtools)
    install_github("tomaskrehlik/frequencyConnectedness", tag = "0.1.6") 

Installation
------------

The stable version can be installed from `CRAN` by the standard means of
using `install.packages("frequencyConnectedness")`. If there is any
other development version, you can install it using the following
instructions.

Be sure to have installed the `devtools` package that allows you to
install packages from Github directly. To install the version from
branch `dev` do

    # install.packages("devtools")
    library(devtools)
    install_github("tomaskrehlik/frequencyConnectedness", tag = "dev") 

Usage
-----

Currently the package works in close cooperation with the `vars`,
`urca`, and `BigVAR` packages. In general, if you have any model that
can produce the forecast error variance decomposition, it can be
relatively easily made to work with this package. Let me know by filing
an issue, if that is the case and I will try to incorporate it.

For the time being the following is available:

-   Traditional estimation of VAR
-   Fitting of the VECM model
-   Using `BigVAR` to fit VAR models with various penalization schemes

For the illustration purposes we include some simulated data and
volatilities data from the [Ox-Man
institute](http://realized.oxford-man.ox.ac.uk/).

Let’s walk through some basics. First load packages and get some data.

    library(frequencyConnectedness)

    ## Loading required package: vars

    ## Loading required package: MASS

    ## Loading required package: strucchange

    ## Loading required package: zoo

    ## 
    ## Attaching package: 'zoo'

    ## The following objects are masked from 'package:base':
    ## 
    ##     as.Date, as.Date.numeric

    ## Loading required package: sandwich

    ## Loading required package: urca

    ## Loading required package: methods

    ## Loading required package: lmtest

    ## Loading required package: knitr

    ## Loading required package: pbapply

    ## **********
    ## The syntax has changed since the version 0.1.6. check out the README at the github.com/tomaskrehlik/frequencyConnectedness .
    ## **********

    ## 
    ## Attaching package: 'frequencyConnectedness'

    ## The following object is masked from 'package:vars':
    ## 
    ##     fevd

    data(exampleSim)
    # Shorten the data, rolling estimation takes quite some time
    exampleSim <- exampleSim[1:600,]

Then compute a system estimate on which the computation of connectedness
is based:

    # Compute the VAR(2) estimate with constant and save results
    est <- VAR(exampleSim, p = 2, type = "const")
    # Alternatively, you could use VECM
    # est <- vec2var(ca.jo(exampleSim, ecdet = "trend", K = 2), r = 1)

Then use the estimate to compute the connectedness measures. First, the
traditional overall measures that are not frequency dependent as in
Diebold and Yilmaz, also with the possibility of nullifying the cross
correlation elements. These commands print out the table and all the
relevant measures.

    # Compute traditional spillovers
    spilloverDY09(est, n.ahead = 100, no.corr = F)

    ## The spillover table has no frequency bands, standard Diebold & Yilmaz.
    ## 
    ## 
    ## |   |   V1|    V2|    V3|  FROM|
    ## |:--|----:|-----:|-----:|-----:|
    ## |V1 | 8.84|  7.13| 84.03| 30.39|
    ## |V2 | 2.65| 10.09| 87.26| 29.97|
    ## |V3 | 0.31|  0.20| 99.50|  0.17|
    ## |TO | 0.99|  2.44| 57.10| 60.53|

    spilloverDY12(est, n.ahead = 100, no.corr = F)

    ## The spillover table has no frequency bands, standard Diebold & Yilmaz.
    ## 
    ## 
    ## |   |   V1|    V2|    V3|  FROM|
    ## |:--|----:|-----:|-----:|-----:|
    ## |V1 | 8.56| 10.34| 81.09| 30.48|
    ## |V2 | 2.62| 11.50| 85.88| 29.50|
    ## |V3 | 0.31|  0.26| 99.43|  0.19|
    ## |TO | 0.97|  3.53| 55.66| 60.17|

    spilloverDY09(est, n.ahead = 100, no.corr = T)

    ## The spillover table has no frequency bands, standard Diebold & Yilmaz.
    ## 
    ## 
    ## |   |   V1|    V2|    V3|  FROM|
    ## |:--|----:|-----:|-----:|-----:|
    ## |V1 | 5.61|  8.15| 86.24| 31.46|
    ## |V2 | 1.10| 11.09| 87.81| 29.64|
    ## |V3 | 0.24|  0.22| 99.54|  0.15|
    ## |TO | 0.44|  2.79| 58.02| 61.25|

    spilloverDY12(est, n.ahead = 100, no.corr = T)

    ## The spillover table has no frequency bands, standard Diebold & Yilmaz.
    ## 
    ## 
    ## |   |   V1|    V2|    V3|  FROM|
    ## |:--|----:|-----:|-----:|-----:|
    ## |V1 | 5.61|  8.15| 86.24| 31.46|
    ## |V2 | 1.10| 11.09| 87.81| 29.64|
    ## |V3 | 0.24|  0.22| 99.54|  0.15|
    ## |TO | 0.44|  2.79| 58.02| 61.25|

If you save them, you can use the functions
`overall, to, from, net, pairwise` to extract the spillovers in numeric
form

    sp <- spilloverDY12(est, n.ahead = 100, no.corr = T)
    overall(sp)

    ## [[1]]
    ## [1] 61.25391

    to(sp)

    ## [[1]]
    ##         V1         V2         V3 
    ##  0.4445176  2.7906399 58.0187552

    from(sp)

    ## [[1]]
    ##         V1         V2         V3 
    ## 31.4636556 29.6365456  0.1537115

    net(sp)

    ## [[1]]
    ##        V1        V2        V3 
    ## -31.01914 -26.84591  57.86504

    pairwise(sp)

    ## [[1]]
    ##     V1-V2     V1-V3     V2-V3 
    ##  2.350667 28.668472 29.196572

Next, we can decompose the measure on desired frequencies and get the
frequency dependent measures.

    # Get the frequency connectedness on partition (pi,pi/4), (pi/4,0), roughly
    # corresponding to movements of 1 to 4 days and 4 to longer.
    bounds <- c(pi+0.00001, pi/4, 0)
    spilloverBK09(est, n.ahead = 100, no.corr = F, partition = bounds)

    ## The spillover table has 2 frequency bands.
    ## 
    ## 
    ## The spillover table for band: 3.14 to 0.79
    ## Roughly corresponds to 1 days to 4 days.
    ## 
    ## 
    ## |       |   V1|   V2|    V3| FROM_ABS| FROM_WTH|
    ## |:------|----:|----:|-----:|--------:|--------:|
    ## |V1     | 0.15| 0.26|  0.55|     0.27|     2.11|
    ## |V2     | 0.09| 2.27|  4.85|     1.65|    12.97|
    ## |V3     | 0.04| 0.02| 29.87|     0.02|     0.17|
    ## |TO_ABS | 0.04| 0.09|  1.80|     1.94|         |
    ## |TO_WTH | 0.35| 0.73| 14.17|         |    15.25|
    ## 
    ## 
    ## The spillover table for band: 0.79 to 0.00
    ## Roughly corresponds to 4 days to Inf days.
    ## 
    ## 
    ## |       |   V1|   V2|    V3| FROM_ABS| FROM_WTH|
    ## |:------|----:|----:|-----:|--------:|--------:|
    ## |V1     | 8.69| 6.87| 83.49|    30.12|    34.50|
    ## |V2     | 2.56| 7.82| 82.41|    28.32|    32.44|
    ## |V3     | 0.27| 0.17| 69.62|     0.15|     0.17|
    ## |TO_ABS | 0.94| 2.35| 55.30|    58.59|         |
    ## |TO_WTH | 1.08| 2.69| 63.34|         |    67.11|

    spilloverBK12(est, n.ahead = 100, no.corr = F, partition = bounds)

    ## The spillover table has 2 frequency bands.
    ## 
    ## 
    ## The spillover table for band: 3.14 to 0.79
    ## Roughly corresponds to 1 days to 4 days.
    ## 
    ## 
    ## |       |   V1|   V2|    V3| FROM_ABS| FROM_WTH|
    ## |:------|----:|----:|-----:|--------:|--------:|
    ## |V1     | 0.14| 0.28|  0.53|     0.27|     2.11|
    ## |V2     | 0.09| 2.30|  4.81|     1.63|    12.87|
    ## |V3     | 0.04| 0.04| 29.86|     0.03|     0.21|
    ## |TO_ABS | 0.04| 0.10|  1.78|     1.93|         |
    ## |TO_WTH | 0.35| 0.82| 14.02|         |    15.19|
    ## 
    ## 
    ## The spillover table for band: 0.79 to 0.00
    ## Roughly corresponds to 4 days to Inf days.
    ## 
    ## 
    ## |       |   V1|    V2|    V3| FROM_ABS| FROM_WTH|
    ## |:------|----:|-----:|-----:|--------:|--------:|
    ## |V1     | 8.42| 10.07| 80.57|    30.21|    34.60|
    ## |V2     | 2.52|  9.20| 81.07|    27.86|    31.92|
    ## |V3     | 0.27|  0.22| 69.57|     0.16|     0.19|
    ## |TO_ABS | 0.93|  3.43| 53.88|    58.24|         |
    ## |TO_WTH | 1.07|  3.93| 61.71|         |    66.71|

    spilloverBK09(est, n.ahead = 100, no.corr = T, partition = bounds)

    ## The spillover table has 2 frequency bands.
    ## 
    ## 
    ## The spillover table for band: 3.14 to 0.79
    ## Roughly corresponds to 1 days to 4 days.
    ## 
    ## 
    ## |       |   V1|   V2|    V3| FROM_ABS| FROM_WTH|
    ## |:------|----:|----:|-----:|--------:|--------:|
    ## |V1     | 0.13| 0.28|  0.56|     0.28|     2.20|
    ## |V2     | 0.03| 2.39|  4.88|     1.64|    12.86|
    ## |V3     | 0.03| 0.02| 29.89|     0.02|     0.14|
    ## |TO_ABS | 0.02| 0.10|  1.81|     1.94|         |
    ## |TO_WTH | 0.17| 0.79| 14.24|         |    15.20|
    ## 
    ## 
    ## The spillover table for band: 0.79 to 0.00
    ## Roughly corresponds to 4 days to Inf days.
    ## 
    ## 
    ## |       |   V1|   V2|    V3| FROM_ABS| FROM_WTH|
    ## |:------|----:|----:|-----:|--------:|--------:|
    ## |V1     | 5.48| 7.87| 85.68|    31.18|    35.74|
    ## |V2     | 1.06| 8.70| 82.93|    28.00|    32.09|
    ## |V3     | 0.21| 0.20| 69.65|     0.14|     0.16|
    ## |TO_ABS | 0.42| 2.69| 56.20|    59.32|         |
    ## |TO_WTH | 0.49| 3.08| 64.41|         |    67.98|

    spilloverBK12(est, n.ahead = 100, no.corr = T, partition = bounds)

    ## The spillover table has 2 frequency bands.
    ## 
    ## 
    ## The spillover table for band: 3.14 to 0.79
    ## Roughly corresponds to 1 days to 4 days.
    ## 
    ## 
    ## |       |   V1|   V2|    V3| FROM_ABS| FROM_WTH|
    ## |:------|----:|----:|-----:|--------:|--------:|
    ## |V1     | 0.13| 0.28|  0.56|     0.28|     2.20|
    ## |V2     | 0.03| 2.39|  4.88|     1.64|    12.86|
    ## |V3     | 0.03| 0.02| 29.89|     0.02|     0.14|
    ## |TO_ABS | 0.02| 0.10|  1.81|     1.94|         |
    ## |TO_WTH | 0.17| 0.79| 14.24|         |    15.20|
    ## 
    ## 
    ## The spillover table for band: 0.79 to 0.00
    ## Roughly corresponds to 4 days to Inf days.
    ## 
    ## 
    ## |       |   V1|   V2|    V3| FROM_ABS| FROM_WTH|
    ## |:------|----:|----:|-----:|--------:|--------:|
    ## |V1     | 5.48| 7.87| 85.68|    31.18|    35.74|
    ## |V2     | 1.06| 8.70| 82.93|    28.00|    32.09|
    ## |V3     | 0.21| 0.20| 69.65|     0.14|     0.16|
    ## |TO_ABS | 0.42| 2.69| 56.20|    59.32|         |
    ## |TO_WTH | 0.49| 3.08| 64.41|         |    67.98|

Note that the bounds should cover the range `(1.001, 0)*pi`, because the
overall variance of the system is computed over these frequencies. (So
if you wanted to remove the trend from computations, you could use
`(1.001, 0.01)*pi` and the computation will ignore the variance created
around the zero frequency.) Again, if you save the outputs from the
`spillover....` function, you can evaluate the
`overall, to, from, net, pairwise` to get the relevant tables.

Moreover, if you want to aggregate the behaviour of some of the bands,
you can do:

    # Get the frequency connectedness on partition (pi,pi/4), (pi/4,0), roughly
    # corresponding to movements of 1 to 4 days and 4 to longer.
    bounds <- c(pi+0.00001, pi/4, pi/10, 0)

    spilloverBK12(est, n.ahead = 100, no.corr = F, partition = bounds)

    ## The spillover table has 3 frequency bands.
    ## 
    ## 
    ## The spillover table for band: 3.14 to 0.79
    ## Roughly corresponds to 1 days to 4 days.
    ## 
    ## 
    ## |       |   V1|   V2|    V3| FROM_ABS| FROM_WTH|
    ## |:------|----:|----:|-----:|--------:|--------:|
    ## |V1     | 0.14| 0.28|  0.53|     0.27|     2.11|
    ## |V2     | 0.09| 2.30|  4.81|     1.63|    12.87|
    ## |V3     | 0.04| 0.04| 29.86|     0.03|     0.21|
    ## |TO_ABS | 0.04| 0.10|  1.78|     1.93|         |
    ## |TO_WTH | 0.35| 0.82| 14.02|         |    15.19|
    ## 
    ## 
    ## The spillover table for band: 0.79 to 0.31
    ## Roughly corresponds to 4 days to 10 days.
    ## 
    ## 
    ## |       |   V1|   V2|    V3| FROM_ABS| FROM_WTH|
    ## |:------|----:|----:|-----:|--------:|--------:|
    ## |V1     | 1.74| 3.00| 19.54|     7.51|    22.61|
    ## |V2     | 0.94| 4.25| 31.71|    10.88|    32.75|
    ## |V3     | 0.18| 0.10| 38.24|     0.09|     0.29|
    ## |TO_ABS | 0.38| 1.03| 17.08|    18.49|         |
    ## |TO_WTH | 1.13| 3.11| 51.40|         |    55.64|
    ## 
    ## 
    ## The spillover table for band: 0.31 to 0.00
    ## Roughly corresponds to 10 days to Inf days.
    ## 
    ## 
    ## |       |   V1|   V2|    V3| FROM_ABS| FROM_WTH|
    ## |:------|----:|----:|-----:|--------:|--------:|
    ## |V1     | 6.68| 7.07| 61.02|    22.70|    41.98|
    ## |V2     | 1.58| 4.95| 49.36|    16.98|    31.41|
    ## |V3     | 0.08| 0.12| 31.34|     0.07|     0.13|
    ## |TO_ABS | 0.55| 2.40| 36.79|    39.75|         |
    ## |TO_WTH | 1.03| 4.43| 68.05|         |    73.51|

    collapseBounds(spilloverBK12(est, n.ahead = 100, no.corr = F, partition = bounds), 1:2)

    ## The spillover table has 2 frequency bands.
    ## 
    ## 
    ## The spillover table for band: 3.14 to 0.31
    ## Roughly corresponds to 1 days to 10 days.
    ## 
    ## 
    ## |       |   V1|   V2|    V3| FROM_ABS| FROM_WTH|
    ## |:------|----:|----:|-----:|--------:|--------:|
    ## |V1     | 1.88| 3.27| 20.07|     7.78|    16.94|
    ## |V2     | 1.04| 6.55| 36.52|    12.52|    27.25|
    ## |V3     | 0.22| 0.14| 68.10|     0.12|     0.26|
    ## |TO_ABS | 0.42| 1.14| 18.86|    20.42|         |
    ## |TO_WTH | 0.91| 2.48| 41.07|         |    44.46|
    ## 
    ## 
    ## The spillover table for band: 0.31 to 0.00
    ## Roughly corresponds to 10 days to Inf days.
    ## 
    ## 
    ## |       |   V1|   V2|    V3| FROM_ABS| FROM_WTH|
    ## |:------|----:|----:|-----:|--------:|--------:|
    ## |V1     | 6.68| 7.07| 61.02|    22.70|    41.98|
    ## |V2     | 1.58| 4.95| 49.36|    16.98|    31.41|
    ## |V3     | 0.08| 0.12| 31.34|     0.07|     0.13|
    ## |TO_ABS | 0.55| 2.40| 36.79|    39.75|         |
    ## |TO_WTH | 1.03| 4.43| 68.05|         |    73.51|

In many cases, one is interested in the dynamics of the connectedness.
This can be achieved within the package by the following commands.

    # Get the rolling window estimates
    params_est = list(p = 2, type = "const")
    sp <- spilloverRollingDY09(exampleSim, n.ahead = 100, no.corr = F, "VAR", params_est = params_est, window = 100)
    # alternatively for co-integration you could do
    # coint_est <- function(data, r) {
    #     return(vec2var(ca.jo(data, ecdet = "trend", K = 2), r = r))
    # }
    # params_est = list(r = 1)
    # sp <- spilloverRollingDY09(exampleSim, n.ahead = 100, no.corr = F, "coint_est", params_est = params_est, window = 100)

In general, the `spilloverRolling....` function takes the following
arguments:

-   data, as `exampleSim`
-   the arguments for relevant spillover function, as
    `n.ahead, no.corr`, and alternatively `partition` in case of the
    `BK` variant.
-   window, what window you should roll
-   name of function used for estimates, in this case `"VAR"`, and list
    of parameters for this function called `params_est`

Using this, one can plot the resulting spillover measures.

    plotOverall(sp)

![](README_files/figure-markdown_strict/unnamed-chunk-10-1.png)

    plotTo(sp)

![](README_files/figure-markdown_strict/unnamed-chunk-10-2.png)

    plotFrom(sp)

![](README_files/figure-markdown_strict/unnamed-chunk-10-3.png)

    plotNet(sp)

![](README_files/figure-markdown_strict/unnamed-chunk-10-4.png)

    plotPairwise(sp)

![](README_files/figure-markdown_strict/unnamed-chunk-10-5.png)

It is generally not a good idea to print all the spillover tables as
they are not informative.

To make your own rolling estimate, let’s follow this example. First, we
start with construction of unconditional estimate and then use the same
function for the rolling estimate. We perform VAR-LASSO estimation on a
big system of log-volatilities of financial indices with automatic
selection of the LASSO penalty using cross-validation.

    # Example of usage of BigVAR package on the volatilities data that are included
    library(BigVAR)
    data(volatilities)

    big_var_est <- function(data) {
        Model1 = constructModel(as.matrix(data), p = 4, struct = "Basic", gran = c(50, 50), VARX = list(), verbose = F)
        Model1Results = cv.BigVAR(Model1)
    }

    # Perform the estimation
    oo <- big_var_est(log(volatilities[apply(volatilities>0, 1, all),]))

    spilloverDY12(oo, n.ahead = 100, no.corr = F)

    ## The spillover table has no frequency bands, standard Diebold & Yilmaz.
    ## 
    ## 
    ## |                        | S.P.500| FTSE.100| Nikkei.225|   DAX| Russel.2000| All.Ordinaries|  DJIA| Nasdaq.100| CAC.40| Hang.Seng| KOSPI.Composite.Index| AEX.Index| Swiss.Market.Index| IBEX.35| S.P.CNX.Nifty| IPC.Mexico| Bovespa.Index| S.P.TSX.Composite.Index| Euro.STOXX.50| FT.Straits.Times.Index| FTSE.MIB|  FROM|
    ## |:-----------------------|-------:|--------:|----------:|-----:|-----------:|--------------:|-----:|----------:|------:|---------:|---------------------:|---------:|------------------:|-------:|-------------:|----------:|-------------:|-----------------------:|-------------:|----------------------:|--------:|-----:|
    ## |S.P.500                 |   12.83|     6.32|       0.28|  5.00|       10.03|           0.88| 11.73|      11.38|   5.06|      0.22|                  0.77|      5.49|               4.26|    4.02|          0.04|       3.06|          2.43|                    7.12|          5.10|                   0.16|     3.81|  4.15|
    ## |FTSE.100                |    7.05|    10.38|       0.21|  7.64|        5.68|           1.35|  6.73|       6.22|   7.99|      0.22|                  0.76|      8.63|               6.26|    6.44|          0.27|       2.30|          1.79|                    5.90|          7.97|                   0.13|     6.06|  4.27|
    ## |Nikkei.225              |    5.87|     3.03|      40.48|  3.12|        3.23|           3.32|  6.04|       5.00|   2.71|      2.43|                  1.90|      2.92|               3.25|    2.77|          0.29|       3.39|          1.76|                    2.97|          3.09|                   0.78|     1.66|  2.83|
    ## |DAX                     |    5.67|     8.44|       0.25| 11.23|        4.41|           0.95|  5.50|       5.01|   9.24|      0.32|                  0.64|      9.36|               6.31|    7.28|          0.15|       1.68|          1.76|                    4.82|          9.66|                   0.19|     7.14|  4.23|
    ## |Russel.2000             |   12.14|     5.65|       0.14|  4.40|       16.17|           0.58| 10.84|      12.36|   4.38|      0.14|                  0.62|      4.90|               3.94|    3.54|          0.07|       3.04|          2.22|                    6.96|          4.38|                   0.11|     3.40|  3.99|
    ## |All.Ordinaries          |    6.66|     5.94|       1.85|  5.35|        4.66|          20.01|  6.65|       5.73|   4.91|      1.89|                  1.23|      5.51|               4.91|    4.24|          0.22|       2.24|          1.80|                    7.05|          5.20|                   0.71|     3.24|  3.81|
    ## |DJIA                    |   12.36|     6.45|       0.35|  5.14|        9.28|           1.17| 12.53|      10.71|   5.16|      0.27|                  0.74|      5.62|               4.40|    4.13|          0.04|       3.06|          2.49|                    6.92|          5.21|                   0.21|     3.75|  4.17|
    ## |Nasdaq.100              |   12.58|     5.65|       0.21|  4.59|       11.40|           0.66| 11.24|      14.50|   4.59|      0.18|                  0.51|      5.09|               3.75|    3.60|          0.04|       3.14|          2.66|                    7.28|          4.60|                   0.19|     3.55|  4.07|
    ## |CAC.40                  |    5.79|     8.69|       0.20|  8.90|        4.36|           1.01|  5.57|       5.06|  10.11|      0.19|                  0.57|      9.71|               6.41|    7.75|          0.16|       1.72|          1.54|                    4.66|          9.71|                   0.12|     7.81|  4.28|
    ## |Hang.Seng               |    4.62|     3.27|       2.78|  3.79|        2.83|           4.12|  4.71|       3.79|   2.85|     40.53|                  2.61|      3.39|               2.90|    2.41|          0.60|       1.25|          1.69|                    4.60|          3.32|                   2.34|     1.60|  2.83|
    ## |KOSPI.Composite.Index   |    7.26|     5.35|       0.92|  4.54|        6.91|           1.22|  6.87|       6.40|   4.20|      1.16|                 26.59|      4.58|               4.39|    3.46|          0.65|       2.16|          1.07|                    4.36|          4.27|                   0.44|     3.18|  3.50|
    ## |AEX.Index               |    6.20|     8.71|       0.21|  8.57|        4.84|           1.27|  5.99|       5.59|   9.01|      0.31|                  0.60|     10.15|               6.32|    7.01|          0.17|       2.01|          1.78|                    5.54|          8.85|                   0.17|     6.68|  4.28|
    ## |Swiss.Market.Index      |    6.56|     8.44|       0.50|  7.56|        4.95|           1.78|  6.37|       5.75|   7.91|      0.32|                  0.84|      8.31|              11.88|    6.53|          0.28|       2.18|          1.53|                    4.56|          7.80|                   0.22|     5.74|  4.20|
    ## |IBEX.35                 |    5.03|     8.40|       0.29|  8.56|        4.01|           0.46|  4.86|       4.34|   9.65|      0.08|                  0.49|      9.25|               6.45|   12.03|          0.20|       1.76|          1.65|                    3.07|         10.14|                   0.05|     9.23|  4.19|
    ## |S.P.CNX.Nifty           |    2.32|     4.04|       0.49|  2.98|        2.87|           0.85|  2.05|       2.12|   2.60|      1.54|                  1.41|      2.94|               3.29|    2.39|         57.49|       2.29|          1.42|                    1.91|          2.72|                   0.48|     1.81|  2.02|
    ## |IPC.Mexico              |    7.98|     5.38|       1.24|  4.33|        6.18|           0.88|  7.61|       7.11|   4.31|      0.18|                  0.79|      4.94|               3.94|    3.75|          0.48|      23.13|          5.04|                    5.28|          4.13|                   0.27|     3.07|  3.66|
    ## |Bovespa.Index           |    7.25|     4.85|       0.87|  4.43|        4.75|           0.36|  7.00|       6.51|   4.37|      0.38|                  0.41|      4.56|               2.91|    3.86|          0.26|       5.09|         27.94|                    6.13|          4.57|                   0.20|     3.29|  3.43|
    ## |S.P.TSX.Composite.Index |    9.90|     5.92|       0.15|  4.86|        8.26|           1.50|  9.21|       9.27|   4.70|      0.30|                  0.54|      5.48|               3.47|    3.55|          0.09|       2.92|          3.10|                   18.17|          4.69|                   0.19|     3.73|  3.90|
    ## |Euro.STOXX.50           |    5.68|     8.61|       0.24|  9.18|        4.34|           1.02|  5.47|       4.94|   9.64|      0.21|                  0.57|      9.47|               6.30|    8.01|          0.15|       1.63|          1.54|                    4.57|         10.14|                   0.13|     8.15|  4.28|
    ## |FT.Straits.Times.Index  |    4.37|     3.63|       2.35|  4.33|        2.72|           3.89|  4.55|       4.01|   3.37|      3.81|                  1.28|      3.86|               3.21|    2.57|          0.52|       2.16|          1.68|                    4.43|          3.65|                  37.47|     2.15|  2.98|
    ## |FTSE.MIB                |    5.05|     8.36|       0.21|  8.54|        3.86|           0.33|  4.77|       4.55|   9.61|      0.04|                  0.42|      9.33|               6.01|    8.97|          0.15|       1.42|          1.50|                    3.83|          9.99|                   0.06|    13.00|  4.14|
    ## |TO                      |    6.68|     5.96|       0.65|  5.51|        5.22|           1.31|  6.37|       5.99|   5.54|      0.68|                  0.84|      5.87|               4.41|    4.59|          0.23|       2.31|          1.93|                    4.86|          5.67|                   0.34|     4.24| 79.20|

    spilloverBK12(oo, n.ahead = 100, no.corr = F, partition = bounds)

    ## The spillover table has 3 frequency bands.
    ## 
    ## 
    ## The spillover table for band: 3.14 to 0.79
    ## Roughly corresponds to 1 days to 4 days.
    ## 
    ## 
    ## |                        | S.P.500| FTSE.100| Nikkei.225|  DAX| Russel.2000| All.Ordinaries| DJIA| Nasdaq.100| CAC.40| Hang.Seng| KOSPI.Composite.Index| AEX.Index| Swiss.Market.Index| IBEX.35| S.P.CNX.Nifty| IPC.Mexico| Bovespa.Index| S.P.TSX.Composite.Index| Euro.STOXX.50| FT.Straits.Times.Index| FTSE.MIB| FROM_ABS| FROM_WTH|
    ## |:-----------------------|-------:|--------:|----------:|----:|-----------:|--------------:|----:|----------:|------:|---------:|---------------------:|---------:|------------------:|-------:|-------------:|----------:|-------------:|-----------------------:|-------------:|----------------------:|--------:|--------:|--------:|
    ## |S.P.500                 |    3.02|     1.12|       0.06| 0.89|        2.05|           0.06| 2.75|       2.43|   0.90|      0.04|                  0.11|      0.96|               0.65|    0.72|          0.01|       0.70|          0.71|                    1.44|          0.92|                   0.03|     0.70|     0.82|     4.11|
    ## |FTSE.100                |    0.84|     2.46|       0.03| 1.61|        0.55|           0.08| 0.82|       0.68|   1.76|      0.01|                  0.08|      1.82|               1.32|    1.43|          0.06|       0.32|          0.31|                    0.49|          1.74|                   0.01|     1.35|     0.73|     3.64|
    ## |Nikkei.225              |    0.52|     0.26|      10.80| 0.29|        0.41|           0.55| 0.52|       0.47|   0.24|      0.55|                  0.32|      0.26|               0.31|    0.27|          0.06|       0.25|          0.16|                    0.34|          0.29|                   0.13|     0.17|     0.30|     1.51|
    ## |DAX                     |    0.75|     1.77|       0.06| 2.72|        0.48|           0.06| 0.75|       0.63|   2.14|      0.03|                  0.11|      2.08|               1.38|    1.70|          0.04|       0.26|          0.31|                    0.43|          2.25|                   0.03|     1.60|     0.80|     4.01|
    ## |Russel.2000             |    2.69|     0.98|       0.04| 0.74|        3.92|           0.07| 2.38|       2.73|   0.72|      0.03|                  0.06|      0.82|               0.58|    0.60|          0.01|       0.72|          0.70|                    1.47|          0.73|                   0.02|     0.56|     0.79|     3.96|
    ## |All.Ordinaries          |    0.30|     0.27|       0.34| 0.22|        0.23|           7.04| 0.30|       0.25|   0.20|      0.21|                  0.13|      0.23|               0.29|    0.21|          0.03|       0.11|          0.09|                    0.26|          0.22|                   0.11|     0.12|     0.20|     0.98|
    ## |DJIA                    |    2.86|     1.14|       0.07| 0.93|        1.89|           0.06| 3.19|       2.23|   0.93|      0.04|                  0.12|      0.99|               0.66|    0.76|          0.01|       0.69|          0.70|                    1.39|          0.95|                   0.04|     0.71|     0.82|     4.09|
    ## |Nasdaq.100              |    3.08|     1.17|       0.04| 0.95|        2.63|           0.06| 2.72|       3.79|   0.95|      0.03|                  0.09|      1.06|               0.69|    0.74|          0.01|       0.76|          0.79|                    1.70|          0.95|                   0.04|     0.75|     0.92|     4.58|
    ## |CAC.40                  |    0.68|     1.74|       0.04| 1.93|        0.41|           0.05| 0.68|       0.56|   2.50|      0.01|                  0.07|      2.14|               1.35|    1.77|          0.03|       0.24|          0.27|                    0.38|          2.27|                   0.01|     1.65|     0.78|     3.88|
    ## |Hang.Seng               |    0.23|     0.10|       0.85| 0.16|        0.17|           0.45| 0.24|       0.19|   0.09|     17.60|                  0.57|      0.12|               0.13|    0.09|          0.16|       0.06|          0.13|                    0.15|          0.13|                   0.78|     0.07|     0.23|     1.16|
    ## |KOSPI.Composite.Index   |    0.41|     0.37|       0.36| 0.39|        0.28|           0.20| 0.42|       0.30|   0.31|      0.39|                 10.65|      0.32|               0.39|    0.28|          0.10|       0.20|          0.13|                    0.21|          0.33|                   0.12|     0.23|     0.27|     1.36|
    ## |AEX.Index               |    0.65|     1.65|       0.04| 1.71|        0.42|           0.05| 0.65|       0.56|   1.95|      0.01|                  0.07|      2.23|               1.25|    1.50|          0.03|       0.26|          0.25|                    0.41|          1.87|                   0.02|     1.44|     0.70|     3.52|
    ## |Swiss.Market.Index      |    0.51|     1.38|       0.07| 1.31|        0.35|           0.11| 0.51|       0.42|   1.42|      0.02|                  0.11|      1.45|               2.63|    1.20|          0.06|       0.24|          0.19|                    0.27|          1.38|                   0.02|     1.05|     0.57|     2.87|
    ## |IBEX.35                 |    0.70|     1.78|       0.07| 1.92|        0.44|           0.09| 0.70|       0.56|   2.21|      0.02|                  0.09|      2.05|               1.42|    3.13|          0.05|       0.27|          0.29|                    0.37|          2.35|                   0.01|     2.00|     0.83|     4.14|
    ## |S.P.CNX.Nifty           |    0.45|     0.61|       0.11| 0.45|        0.46|           0.08| 0.41|       0.46|   0.43|      0.18|                  0.18|      0.46|               0.50|    0.42|         20.08|       0.32|          0.22|                    0.27|          0.45|                   0.09|     0.35|     0.33|     1.64|
    ## |IPC.Mexico              |    1.84|     1.13|       0.17| 0.79|        1.44|           0.10| 1.75|       1.58|   0.83|      0.00|                  0.17|      1.00|               0.78|    0.73|          0.11|       8.82|          1.19|                    1.18|          0.74|                   0.05|     0.57|     0.77|     3.84|
    ## |Bovespa.Index           |    1.57|     0.93|       0.05| 0.81|        1.21|           0.02| 1.50|       1.40|   0.79|      0.06|                  0.07|      0.83|               0.53|    0.68|          0.05|       1.00|          7.34|                    1.11|          0.83|                   0.03|     0.55|     0.67|     3.34|
    ## |S.P.TSX.Composite.Index |    1.96|     0.93|       0.04| 0.74|        1.52|           0.05| 1.81|       1.84|   0.73|      0.02|                  0.08|      0.87|               0.49|    0.54|          0.01|       0.61|          0.68|                    4.24|          0.72|                   0.02|     0.61|     0.68|     3.40|
    ## |Euro.STOXX.50           |    0.72|     1.75|       0.06| 2.06|        0.44|           0.06| 0.72|       0.59|   2.29|      0.02|                  0.08|      2.07|               1.32|    1.91|          0.04|       0.22|          0.29|                    0.39|          2.52|                   0.01|     1.76|     0.80|     4.00|
    ## |FT.Straits.Times.Index  |    0.24|     0.16|       0.21| 0.26|        0.19|           0.29| 0.29|       0.28|   0.17|      0.83|                  0.19|      0.21|               0.17|    0.14|          0.09|       0.16|          0.10|                    0.18|          0.19|                  23.50|     0.13|     0.21|     1.06|
    ## |FTSE.MIB                |    0.74|     1.85|       0.04| 2.00|        0.45|           0.03| 0.72|       0.62|   2.30|      0.00|                  0.08|      2.16|               1.37|    2.24|          0.04|       0.23|          0.26|                    0.45|          2.42|                   0.01|     3.43|     0.86|     4.28|
    ## |TO_ABS                  |    1.04|     1.00|       0.13| 0.96|        0.76|           0.12| 0.98|       0.89|   1.02|      0.12|                  0.13|      1.04|               0.74|    0.85|          0.05|       0.36|          0.37|                    0.61|          1.04|                   0.08|     0.78|    13.08|         |
    ## |TO_WTH                  |    5.17|     5.02|       0.65| 4.79|        3.81|           0.59| 4.91|       4.47|   5.09|      0.59|                  0.67|      5.21|               3.71|    4.27|          0.24|       1.81|          1.85|                    3.07|          5.17|                   0.38|     3.89|         |    65.35|
    ## 
    ## 
    ## The spillover table for band: 0.79 to 0.31
    ## Roughly corresponds to 4 days to 10 days.
    ## 
    ## 
    ## |                        | S.P.500| FTSE.100| Nikkei.225|  DAX| Russel.2000| All.Ordinaries| DJIA| Nasdaq.100| CAC.40| Hang.Seng| KOSPI.Composite.Index| AEX.Index| Swiss.Market.Index| IBEX.35| S.P.CNX.Nifty| IPC.Mexico| Bovespa.Index| S.P.TSX.Composite.Index| Euro.STOXX.50| FT.Straits.Times.Index| FTSE.MIB| FROM_ABS| FROM_WTH|
    ## |:-----------------------|-------:|--------:|----------:|----:|-----------:|--------------:|----:|----------:|------:|---------:|---------------------:|---------:|------------------:|-------:|-------------:|----------:|-------------:|-----------------------:|-------------:|----------------------:|--------:|--------:|--------:|
    ## |S.P.500                 |    2.24|     0.88|       0.06| 0.70|        1.65|           0.08| 2.03|       1.97|   0.72|      0.03|                  0.09|      0.77|               0.57|    0.58|          0.01|       0.53|          0.49|                    1.06|          0.73|                   0.02|     0.56|     0.64|     4.28|
    ## |FTSE.100                |    0.83|     1.38|       0.05| 0.97|        0.66|           0.11| 0.79|       0.72|   1.04|      0.01|                  0.08|      1.12|               0.79|    0.85|          0.04|       0.30|          0.26|                    0.56|          1.04|                   0.01|     0.80|     0.52|     3.48|
    ## |Nikkei.225              |    1.28|     0.62|       7.06| 0.65|        0.86|           0.50| 1.30|       1.11|   0.58|      0.44|                  0.36|      0.62|               0.64|    0.59|          0.07|       0.60|          0.36|                    0.72|          0.66|                   0.14|     0.41|     0.60|     3.95|
    ## |DAX                     |    0.81|     1.26|       0.07| 1.75|        0.64|           0.08| 0.78|       0.71|   1.42|      0.03|                  0.09|      1.42|               0.96|    1.15|          0.03|       0.26|          0.28|                    0.51|          1.50|                   0.03|     1.09|     0.63|     4.15|
    ## |Russel.2000             |    2.03|     0.77|       0.04| 0.60|        2.87|           0.05| 1.80|       2.11|   0.59|      0.02|                  0.07|      0.66|               0.51|    0.49|          0.01|       0.54|          0.46|                    1.09|          0.60|                   0.02|     0.46|     0.62|     4.09|
    ## |All.Ordinaries          |    0.76|     0.59|       0.35| 0.51|        0.59|           3.45| 0.77|       0.65|   0.48|      0.27|                  0.16|      0.54|               0.54|    0.45|          0.04|       0.27|          0.20|                    0.60|          0.52|                   0.10|     0.30|     0.41|     2.74|
    ## |DJIA                    |    2.16|     0.91|       0.07| 0.73|        1.52|           0.12| 2.20|       1.84|   0.74|      0.03|                  0.09|      0.79|               0.60|    0.61|          0.01|       0.52|          0.49|                    1.02|          0.76|                   0.03|     0.57|     0.65|     4.30|
    ## |Nasdaq.100              |    2.34|     0.90|       0.05| 0.73|        2.12|           0.07| 2.07|       2.83|   0.73|      0.03|                  0.07|      0.81|               0.56|    0.57|          0.01|       0.60|          0.57|                    1.27|          0.73|                   0.04|     0.57|     0.71|     4.69|
    ## |CAC.40                  |    0.77|     1.23|       0.05| 1.27|        0.55|           0.10| 0.75|       0.67|   1.53|      0.02|                  0.07|      1.44|               0.92|    1.18|          0.03|       0.25|          0.23|                    0.47|          1.46|                   0.01|     1.18|     0.60|     4.00|
    ## |Hang.Seng               |    0.56|     0.28|       0.49| 0.36|        0.38|           0.43| 0.57|       0.46|   0.26|      7.50|                  0.42|      0.31|               0.29|    0.25|          0.10|       0.13|          0.22|                    0.35|          0.33|                   0.40|     0.15|     0.32|     2.13|
    ## |KOSPI.Composite.Index   |    0.85|     0.58|       0.25| 0.53|        0.69|           0.14| 0.83|       0.71|   0.47|      0.22|                  5.13|      0.50|               0.49|    0.41|          0.09|       0.33|          0.26|                    0.44|          0.49|                   0.08|     0.36|     0.41|     2.75|
    ## |AEX.Index               |    0.77|     1.21|       0.05| 1.20|        0.61|           0.10| 0.75|       0.70|   1.34|      0.03|                  0.07|      1.53|               0.90|    1.04|          0.03|       0.27|          0.25|                    0.54|          1.29|                   0.02|     0.98|     0.58|     3.84|
    ## |Swiss.Market.Index      |    0.69|     1.09|       0.07| 1.01|        0.49|           0.16| 0.68|       0.59|   1.08|      0.03|                  0.09|      1.11|               1.81|    0.91|          0.05|       0.26|          0.21|                    0.39|          1.06|                   0.02|     0.80|     0.51|     3.41|
    ## |IBEX.35                 |    0.83|     1.41|       0.08| 1.46|        0.61|           0.09| 0.81|       0.70|   1.65|      0.02|                  0.08|      1.57|               1.09|    2.14|          0.04|       0.30|          0.30|                    0.45|          1.74|                   0.01|     1.54|     0.70|     4.67|
    ## |S.P.CNX.Nifty           |    0.53|     0.91|       0.11| 0.68|        0.60|           0.10| 0.46|       0.52|   0.65|      0.15|                  0.19|      0.70|               0.72|    0.62|          9.74|       0.48|          0.33|                    0.35|          0.68|                   0.08|     0.55|     0.45|     2.97|
    ## |IPC.Mexico              |    1.30|     0.81|       0.17| 0.62|        1.06|           0.09| 1.23|       1.19|   0.63|      0.01|                  0.12|      0.73|               0.58|    0.55|          0.08|       4.37|          0.73|                    0.79|          0.59|                   0.04|     0.45|     0.56|     3.72|
    ## |Bovespa.Index           |    1.36|     0.73|       0.07| 0.62|        1.14|           0.03| 1.27|       1.27|   0.61|      0.04|                  0.07|      0.65|               0.43|    0.52|          0.03|       0.76|          4.07|                    0.96|          0.63|                   0.03|     0.43|     0.55|     3.68|
    ## |S.P.TSX.Composite.Index |    1.24|     0.53|       0.03| 0.41|        1.08|           0.09| 1.14|       1.19|   0.40|      0.02|                  0.05|      0.48|               0.30|    0.31|          0.01|       0.38|          0.40|                    2.22|          0.40|                   0.02|     0.33|     0.42|     2.79|
    ## |Euro.STOXX.50           |    0.78|     1.27|       0.07| 1.38|        0.57|           0.11| 0.76|       0.66|   1.50|      0.02|                  0.07|      1.45|               0.95|    1.27|          0.03|       0.24|          0.24|                    0.48|          1.58|                   0.02|     1.29|     0.63|     4.16|
    ## |FT.Straits.Times.Index  |    0.47|     0.39|       0.38| 0.51|        0.31|           0.47| 0.50|       0.45|   0.39|      0.65|                  0.18|      0.44|               0.38|    0.31|          0.10|       0.28|          0.18|                    0.36|          0.43|                   7.42|     0.26|     0.36|     2.36|
    ## |FTSE.MIB                |    0.71|     1.27|       0.05| 1.32|        0.49|           0.05| 0.68|       0.63|   1.50|      0.01|                  0.07|      1.44|               0.93|    1.44|          0.03|       0.22|          0.23|                    0.46|          1.58|                   0.01|     2.13|     0.62|     4.14|
    ## |TO_ABS                  |    1.00|     0.84|       0.12| 0.77|        0.79|           0.14| 0.95|       0.90|   0.80|      0.10|                  0.12|      0.84|               0.63|    0.67|          0.04|       0.36|          0.32|                    0.61|          0.82|                   0.05|     0.62|    11.49|         |
    ## |TO_WTH                  |    6.66|     5.57|       0.81| 5.14|        5.25|           0.94| 6.31|       5.96|   5.30|      0.66|                  0.78|      5.55|               4.15|    4.46|          0.26|       2.38|          2.12|                    4.06|          5.43|                   0.35|     4.14|         |    76.30|
    ## 
    ## 
    ## The spillover table for band: 0.31 to 0.00
    ## Roughly corresponds to 10 days to Inf days.
    ## 
    ## 
    ## |                        | S.P.500| FTSE.100| Nikkei.225|  DAX| Russel.2000| All.Ordinaries| DJIA| Nasdaq.100| CAC.40| Hang.Seng| KOSPI.Composite.Index| AEX.Index| Swiss.Market.Index| IBEX.35| S.P.CNX.Nifty| IPC.Mexico| Bovespa.Index| S.P.TSX.Composite.Index| Euro.STOXX.50| FT.Straits.Times.Index| FTSE.MIB| FROM_ABS| FROM_WTH|
    ## |:-----------------------|-------:|--------:|----------:|----:|-----------:|--------------:|----:|----------:|------:|---------:|---------------------:|---------:|------------------:|-------:|-------------:|----------:|-------------:|-----------------------:|-------------:|----------------------:|--------:|--------:|--------:|
    ## |S.P.500                 |    7.57|     4.32|       0.15| 3.41|        6.33|           0.75| 6.95|       6.98|   3.44|      0.16|                  0.56|      3.77|               3.04|    2.72|          0.03|       1.84|          1.24|                    4.62|          3.45|                   0.11|     2.54|     2.69|     4.14|
    ## |FTSE.100                |    5.39|     6.54|       0.14| 5.06|        4.48|           1.17| 5.12|       4.82|   5.19|      0.20|                  0.60|      5.69|               4.15|    4.15|          0.17|       1.69|          1.21|                    4.85|          5.19|                   0.11|     3.92|     3.01|     4.64|
    ## |Nikkei.225              |    4.07|     2.15|      22.61| 2.18|        1.96|           2.28| 4.22|       3.42|   1.90|      1.43|                  1.22|      2.05|               2.30|    1.91|          0.17|       2.54|          1.24|                    1.90|          2.14|                   0.52|     1.09|     1.94|     2.98|
    ## |DAX                     |    4.11|     5.42|       0.12| 6.76|        3.29|           0.81| 3.96|       3.66|   5.68|      0.26|                  0.45|      5.85|               3.98|    4.43|          0.07|       1.16|          1.17|                    3.87|          5.91|                   0.14|     4.45|     2.80|     4.31|
    ## |Russel.2000             |    7.42|     3.91|       0.07| 3.06|        9.38|           0.46| 6.66|       7.53|   3.06|      0.09|                  0.49|      3.41|               2.85|    2.46|          0.05|       1.79|          1.06|                    4.40|          3.05|                   0.08|     2.38|     2.58|     3.98|
    ## |All.Ordinaries          |    5.61|     5.07|       1.16| 4.62|        3.84|           9.52| 5.58|       4.83|   4.23|      1.41|                  0.95|      4.74|               4.08|    3.58|          0.15|       1.86|          1.52|                    6.19|          4.46|                   0.49|     2.81|     3.20|     4.93|
    ## |DJIA                    |    7.35|     4.40|       0.21| 3.48|        5.87|           0.99| 7.15|       6.63|   3.49|      0.20|                  0.53|      3.83|               3.14|    2.77|          0.03|       1.85|          1.29|                    4.52|          3.50|                   0.13|     2.47|     2.70|     4.16|
    ## |Nasdaq.100              |    7.16|     3.57|       0.11| 2.90|        6.66|           0.53| 6.44|       7.88|   2.91|      0.12|                  0.35|      3.22|               2.50|    2.29|          0.02|       1.78|          1.30|                    4.31|          2.91|                   0.11|     2.23|     2.45|     3.77|
    ## |CAC.40                  |    4.33|     5.72|       0.10| 5.69|        3.40|           0.86| 4.15|       3.84|   6.08|      0.16|                  0.42|      6.13|               4.13|    4.80|          0.10|       1.23|          1.03|                    3.81|          5.99|                   0.10|     4.97|     2.90|     4.47|
    ## |Hang.Seng               |    3.83|     2.89|       1.44| 3.27|        2.27|           3.24| 3.89|       3.15|   2.51|     15.43|                  1.63|      2.96|               2.47|    2.07|          0.34|       1.07|          1.35|                    4.10|          2.86|                   1.16|     1.38|     2.28|     3.51|
    ## |KOSPI.Composite.Index   |    5.99|     4.40|       0.31| 3.62|        5.93|           0.88| 5.62|       5.40|   3.43|      0.55|                 10.82|      3.77|               3.51|    2.78|          0.46|       1.63|          0.67|                    3.71|          3.46|                   0.24|     2.59|     2.81|     4.33|
    ## |AEX.Index               |    4.78|     5.84|       0.13| 5.66|        3.81|           1.11| 4.59|       4.32|   5.72|      0.27|                  0.47|      6.39|               4.18|    4.47|          0.11|       1.47|          1.28|                    4.59|          5.69|                   0.14|     4.26|     3.00|     4.61|
    ## |Swiss.Market.Index      |    5.35|     5.97|       0.35| 5.24|        4.11|           1.52| 5.18|       4.75|   5.40|      0.27|                  0.63|      5.75|               7.44|    4.42|          0.17|       1.69|          1.13|                    3.91|          5.36|                   0.18|     3.90|     3.11|     4.79|
    ## |IBEX.35                 |    3.51|     5.21|       0.14| 5.19|        2.96|           0.29| 3.35|       3.08|   5.79|      0.05|                  0.32|      5.63|               3.94|    6.76|          0.12|       1.19|          1.05|                    2.25|          6.04|                   0.03|     5.68|     2.66|     4.09|
    ## |S.P.CNX.Nifty           |    1.34|     2.53|       0.27| 1.85|        1.81|           0.67| 1.18|       1.14|   1.52|      1.22|                  1.03|      1.77|               2.07|    1.35|         27.68|       1.49|          0.88|                    1.29|          1.60|                   0.32|     0.91|     1.25|     1.92|
    ## |IPC.Mexico              |    4.85|     3.44|       0.90| 2.92|        3.68|           0.68| 4.63|       4.34|   2.85|      0.16|                  0.50|      3.21|               2.58|    2.47|          0.29|       9.93|          3.11|                    3.31|          2.80|                   0.18|     2.05|     2.33|     3.59|
    ## |Bovespa.Index           |    4.33|     3.20|       0.76| 3.00|        2.40|           0.31| 4.22|       3.83|   2.96|      0.27|                  0.27|      3.09|               1.95|    2.66|          0.17|       3.33|         16.53|                    4.07|          3.11|                   0.15|     2.30|     2.21|     3.40|
    ## |S.P.TSX.Composite.Index |    6.69|     4.45|       0.08| 3.71|        5.67|           1.36| 6.25|       6.25|   3.57|      0.26|                  0.41|      4.13|               2.68|    2.70|          0.07|       1.94|          2.02|                   11.70|          3.57|                   0.15|     2.79|     2.80|     4.31|
    ## |Euro.STOXX.50           |    4.18|     5.60|       0.12| 5.74|        3.33|           0.85| 4.00|       3.68|   5.84|      0.17|                  0.41|      5.95|               4.03|    4.83|          0.09|       1.16|          1.01|                    3.70|          6.04|                   0.10|     5.10|     2.85|     4.39|
    ## |FT.Straits.Times.Index  |    3.66|     3.08|       1.76| 3.56|        2.22|           3.13| 3.77|       3.27|   2.81|      2.34|                  0.90|      3.21|               2.65|    2.12|          0.34|       1.71|          1.39|                    3.89|          3.03|                   6.54|     1.77|     2.41|     3.71|
    ## |FTSE.MIB                |    3.60|     5.25|       0.12| 5.22|        2.93|           0.26| 3.37|       3.31|   5.81|      0.03|                  0.27|      5.73|               3.71|    5.29|          0.09|       0.97|          1.00|                    2.92|          6.00|                   0.04|     7.44|     2.66|     4.10|
    ## |TO_ABS                  |    4.64|     4.11|       0.40| 3.78|        3.66|           1.05| 4.44|       4.20|   3.72|      0.46|                  0.59|      3.99|               3.04|    3.06|          0.14|       1.59|          1.24|                    3.63|          3.82|                   0.21|     2.84|    54.63|         |
    ## |TO_WTH                  |    7.15|     6.34|       0.62| 5.82|        5.64|           1.62| 6.83|       6.47|   5.73|      0.71|                  0.91|      6.15|               4.69|    4.71|          0.22|       2.45|          1.90|                    5.59|          5.88|                   0.33|     4.37|         |    84.14|

    # Now use the same function to perform the rolling estimation.
    # The original estimation call was:
    # big_var_est(log(volatilities[apply(volatilities>0, 1, all),]))
    # so our data are:
    # log(volatilities[apply(volatilities>0, 1, all),]) (we only use 1:150) because it takes a lot of time to fit
    # n.ahead, no.corr, and window are self explanatory.
    # name of the function to use for estimation is the big_var_est.
    sp <- spilloverRollingBK12(log(volatilities[apply(volatilities>0, 1, all),])[1:150, ], n.ahead = 100, no.corr = F, func_est = "big_var_est", params_est = list(), window = 100, partition = bounds)

    plotOverall(sp)

![](README_files/figure-markdown_strict/unnamed-chunk-11-1.png)

    ## Press [enter] to continue

![](README_files/figure-markdown_strict/unnamed-chunk-11-2.png)

    ## Press [enter] to continue

![](README_files/figure-markdown_strict/unnamed-chunk-11-3.png)

    ## Press [enter] to continue

    # I only plot 5 of the To indicators as plotting all of them is not nice
    plotTo(sp, which = 1:5)

![](README_files/figure-markdown_strict/unnamed-chunk-11-4.png)

    ## Press [enter] to continue

![](README_files/figure-markdown_strict/unnamed-chunk-11-5.png)

    ## Press [enter] to continue

![](README_files/figure-markdown_strict/unnamed-chunk-11-6.png)

    ## Press [enter] to continue

    # You can extract the to spillovers
    head(to(sp)[[1]])

    ##             S.P.500 FTSE.100 Nikkei.225      DAX Russel.2000
    ## 2010-08-16 1.097873 1.066749  0.3277611 1.051465   0.8119981
    ## 2010-08-17 1.138643 1.095658  0.3843875 1.100250   0.8499665
    ## 2010-08-18 1.124862 1.074633  0.3659280 1.071091   0.8149918
    ## 2010-08-19 1.042511 1.041785  0.2487570 1.024492   0.7812996
    ## 2010-08-20 1.055531 1.057180  0.2462113 1.028099   0.8102106
    ## 2010-08-23 1.068766 1.079574  0.2885744 1.060441   0.8341170
    ##            All.Ordinaries      DJIA Nasdaq.100   CAC.40 Hang.Seng
    ## 2010-08-16      0.2642978 1.0401521  1.0387876 1.129556 0.2610661
    ## 2010-08-17      0.2563549 1.0770887  1.0818338 1.161023 0.2860525
    ## 2010-08-18      0.2469859 1.0420231  1.0529600 1.139471 0.2829924
    ## 2010-08-19      0.1398142 0.9608208  0.9685661 1.093604 0.1960783
    ## 2010-08-20      0.1277975 0.9693819  0.9851356 1.102920 0.1987971
    ## 2010-08-23      0.1448988 0.9761075  0.9934412 1.141174 0.2241355
    ##            KOSPI.Composite.Index AEX.Index Swiss.Market.Index   IBEX.35
    ## 2010-08-16             0.3133652  1.091412          0.8925674 0.9657302
    ## 2010-08-17             0.3523387  1.151879          0.9258074 0.9938947
    ## 2010-08-18             0.3373574  1.125805          0.8962469 0.9775621
    ## 2010-08-19             0.2103448  1.062353          0.8483595 0.9726057
    ## 2010-08-20             0.2234559  1.070852          0.8476664 0.9847690
    ## 2010-08-23             0.2210809  1.121240          0.8888475 1.0296039
    ##            S.P.CNX.Nifty IPC.Mexico Bovespa.Index S.P.TSX.Composite.Index
    ## 2010-08-16     0.2473780  0.4063709     0.5743914               0.7280036
    ## 2010-08-17     0.2644057  0.4464628     0.5918717               0.7393336
    ## 2010-08-18     0.2721730  0.4332499     0.5753806               0.7636962
    ## 2010-08-19     0.2064011  0.3341194     0.5190265               0.6591463
    ## 2010-08-20     0.2114888  0.3328275     0.5210253               0.6614011
    ## 2010-08-23     0.2347120  0.3392785     0.5414425               0.6672760
    ##            Euro.STOXX.50 FT.Straits.Times.Index  FTSE.MIB
    ## 2010-08-16      1.116497              0.1924190 0.9479682
    ## 2010-08-17      1.142271              0.2093392 0.9886458
    ## 2010-08-18      1.114937              0.2018900 0.9730582
    ## 2010-08-19      1.081791              0.1316680 0.9744135
    ## 2010-08-20      1.098281              0.1448527 0.9891224
    ## 2010-08-23      1.135820              0.1426263 1.0239369

If you have more cores at your disposal as is usual in the computers
nowadays, it is beneficial to use them through `parallel` package
especially in case of rolling estimation. If you use two cores it
usually almost doubles the speed. For example

    library(parallel)
    cl <- makeCluster(4) # Assign R cores to the job

    ...
    code from previous box
    ...

    stopCluster()

Replication of paper and tests
------------------------------

I will release later some codes that replicat papers that we wrote using
this package and the methodology.

If you would be interested in having your script included, write me an
e-mail, or create an issue.

Because the package might change in the future, there is a set of test
to always preserve the integrity of the original functions. You can read
what is tested in the [testfile](tests/testthat/test-basic.r). Also
provided that you have the `testthat` package installed, you can run the
tests yourself.

    library(frequencyConnectedness)
    library(testthat)
    test_package("frequencyConnectedness")

License
-------

This package is free and open source software, licensed under GPL (&gt;=
2).
