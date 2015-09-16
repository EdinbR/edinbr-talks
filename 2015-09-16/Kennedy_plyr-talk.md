---
title: "The plyr package"
author: |
  | Nick Kennedy
  | Clinical Research Fellow
  | GI Unit, IGMM
  | University of Edinburgh
date: "16/09/2015"
output: slidy_presentation
---

Loops in R
========================================================



> - `for`
> - Vectorised functions
> - `lapply`
> - The `plyr` package

`lapply`
========


```r
set.seed(123)
my_list <- list(a = rnorm(100), b = rnorm(50), c = runif(20))
lapply(my_list, mean)
```

```
## $a
## [1] 0.09040591
## 
## $b
## [1] -0.2539004
## 
## $c
## [1] 0.4793934
```

Split-Apply-Combine
===================

> - **Split** a large dataset
> - **Apply** a function to each piece
> - **Combine** the results back together

> - ![Split-Apply-Combine](images/split-apply-combine-small.png)

The plyr package
================

- Authored by [Hadley Wickham](http://had.co.nz/)
- Provides a consistent interface for perfoming split-apply-combine tasks


| &nbsp;  |    l    |    a    |    d    |    _    |
|:-------:|:-------:|:-------:|:-------:|:-------:|
|  **l**  | `llply` | `laply` | `ldply` | `l_ply` |
|  **a**  | `alply` | `aaply` | `adply` | `a_ply` |
|  **d**  | `dlply` | `daply` | `ddply` | `d_ply` |
|  **r**  | `rlply` | `raply` | `rdply` | `r_ply` |
|  **m**  | `mlply` | `maply` | `mdply` | `m_ply` |

Meaning of the first two characters of the -ply functions
=========================================================

- **Input and output**
    - **l**ist
    - **a**rray
    - **d**ata.frame
- **Input only**
    - **r**eplicate
    - **m**ultiple arguments from columns of data.frame or array
- **Output only**
    - _ no output

List input examples: `llply`
==========================

- Mostly equivalent to base R `lapply`


```r
llply(my_list, mean)
```

```
## $a
## [1] 0.09040591
## 
## $b
## [1] -0.2539004
## 
## $c
## [1] 0.4793934
```

List input examples: `laply`
==========================

- Mostly equivalent to base R `sapply`, but will **always** return an array (whereas `sapply` will return a list if the output is ragged)


```r
llply(my_list, mean)
```

```
## $a
## [1] 0.09040591
## 
## $b
## [1] -0.2539004
## 
## $c
## [1] 0.4793934
```

```r
#laply(my_list, I)
#Will return an error
```

List input examples: `ldply`
==========================

- Used for returning a data.frame as output
- The output from the function can either be a 1 row data.frame, or
  will become the column of a data.frame


```r
ldply(my_list, mean)
```

```
##   .id          V1
## 1   a  0.09040591
## 2   b -0.25390043
## 3   c  0.47939338
```

```r
ldply(my_list, function(x) data.frame(mean = mean(x), sd = sd(x)))
```

```
##   .id        mean        sd
## 1   a  0.09040591 0.9128159
## 2   b -0.25390043 0.9893339
## 3   c  0.47939338 0.2830888
```

List input examples: `l_ply`
==========================

- Handy when no return value is needed
- Examples include
    - Plots
    - Writing files


```r
layout(1:3)
l_ply(my_list, hist)
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7-1.png) 

```r
layout(1)
```

Array input examples: `aaply`
===========================

- Mostly equivalent to `apply` in base R
- Always returns an array (whereas `base::apply` may return a list if the result cannot be
  simplified)
- Order of dimensions in the ouptut is different to `apply` in base R
    - `aaply(.data, .margins, .fun = identity)` will return the same as
      `aperm(.data, c(.margins, (1:length(dim(.data)))[-.margins]))`


```r
x <- array(1:24, c(2, 3, 4))
all(aaply(x, 2, .fun = identity) == aperm(x, c(2, 1, 3)))
```

```
## [1] TRUE
```

Array input examples: `aaply`
===========================

- Useful for computing row and column statistics (although vectorised functions in base R and the `matrixStats` package should be preferred)


```r
set.seed(913)
x <- matrix(rnorm(100), 10, 10)
aaply(x, 1, sd)
```

```
##         1         2         3         4         5         6         7 
## 0.9194631 0.8210030 0.5969373 0.8796405 0.9995688 1.2863265 0.8085736 
##         8         9        10 
## 0.8429865 0.9946271 1.1209652
```

Using `aaply` on a `data.frame`
===============================

- The input to `aaply` can be a `data.frame` instead of an array or matrix.
- Using `aaply` on margin 2 will apply the function to each column and return a vector or array as one might expect.
- For rows, by default `.expand=TRUE`. If the `data.frame` has 4 columns and the function result is a scalar, the final result will have 4 dimensions (one for each column) and each will have **every** possible value of that variable.


```r
my_fun <- function(r) r$Sepal.Length + r$Petal.Length
iris_data <- iris[, c("Sepal.Length", "Petal.Length")]
aaply(iris_data, 1, my_fun)[1:10, 1:10]
```

```
##             Petal.Length
## Sepal.Length   1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.9   3
##          4.3  NA 5.4  NA  NA  NA  NA  NA  NA  NA  NA
##          4.4  NA  NA  NA 5.7 5.8  NA  NA  NA  NA  NA
##          4.5  NA  NA  NA 5.8  NA  NA  NA  NA  NA  NA
##          4.6 5.6  NA  NA  NA 6.0 6.1  NA  NA  NA  NA
##          4.7  NA  NA  NA 6.0  NA  NA 6.3  NA  NA  NA
##          4.8  NA  NA  NA  NA 6.2  NA 6.4  NA 6.7  NA
##          4.9  NA  NA  NA  NA 6.3 6.4  NA  NA  NA  NA
##          5    NA  NA 6.2 6.3 6.4 6.5 6.6  NA  NA  NA
##          5.1  NA  NA  NA  NA 6.5 6.6 6.7 6.8 7.0 8.1
##          5.2  NA  NA  NA  NA 6.6 6.7  NA  NA  NA  NA
```

Using `aaply` on a `data.frame`
===============================

- If instead, you want a vector with one value for each row, you can supply `.expand = FALSE`:

```r
aaply(iris_data, 1, my_fun, .expand = FALSE)[1:20]
```

```
##   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18 
## 6.5 6.3 6.0 6.1 6.4 7.1 6.0 6.5 5.8 6.4 6.9 6.4 6.2 5.4 7.0 7.2 6.7 6.5 
##  19  20 
## 7.4 6.6
```

Array input examples: `adply`
=============================

- `adply` works similarly to `aaply` but as expected returns a data.frame.
- A scalar result will become a column in the data.frame.


```r
x <- array(1:24, c(2, 3, 4))
sum(x[1, , ])
```

```
## [1] 144
```

```r
adply(x, 1, sum)
```

```
##   X1  V1
## 1  1 144
## 2  2 156
```

Array input examples: `adply`
=============================

- A vector will become a row.

```r
add_one <- function(a) a + 1
add_one(x[1, 1, ])
```

```
## [1]  2  8 14 20
```

```r
adply(x, 1:2, add_one)
```

```
##   X1 X2 V1 V2 V3 V4
## 1  1  1  2  8 14 20
## 2  2  1  3  9 15 21
## 3  1  2  4 10 16 22
## 4  2  2  5 11 17 23
## 5  1  3  6 12 18 24
## 6  2  3  7 13 19 25
```

Array input examples: `adply`
=============================

- A matrix will be coerced to a `data.frame` and the results `rbind`ed

```r
add_one(x[1, , ])
```

```
##      [,1] [,2] [,3] [,4]
## [1,]    2    8   14   20
## [2,]    4   10   16   22
## [3,]    6   12   18   24
```

```r
adply(x, 1, add_one)
```

```
##   X1 1  2  3  4
## 1  1 2  8 14 20
## 2  1 4 10 16 22
## 3  1 6 12 18 24
## 4  2 3  9 15 21
## 5  2 5 11 17 23
## 6  2 7 13 19 25
```
- Higher dimensional arrays are collapsed to a vector and become rows of the `data.frame`

`adply` on a `data.frame` with `.expand`
======================

- Here, `.expand` indicates whether to add a new column to the existing `data.frame`

```r
adply(iris_data, 1, my_fun, .expand = TRUE)[1:10, ]
```

```
##    Sepal.Length Petal.Length  V1
## 1           5.1          1.4 6.5
## 2           4.9          1.4 6.3
## 3           4.7          1.3 6.0
## 4           4.6          1.5 6.1
## 5           5.0          1.4 6.4
## 6           5.4          1.7 7.1
## 7           4.6          1.4 6.0
## 8           5.0          1.5 6.5
## 9           4.4          1.4 5.8
## 10          4.9          1.5 6.4
```

- or to just use row numbers:

```r
adply(iris_data, 1, my_fun, .expand = FALSE)[1:10, ]
```

```
##    X1  V1
## 1   1 6.5
## 2   2 6.3
## 3   3 6.0
## 4   4 6.1
## 5   5 6.4
## 6   6 7.1
## 7   7 6.0
## 8   8 6.5
## 9   9 5.8
## 10 10 6.4
```

Other `a*ply` functions
=======================

- `alply` and `a_ply` work analogously to the `l*ply` functions described previously.

Data.frame input examples
=========================

- One option for `data.frame`s is to use the `a*ply` functions in a row-wise manner.
- `plyr` offers the `d*ply` functions as an alternative where the intention is to split by every unique combination of values of the desired columns.
- The second parameter here is the grouping columns to be used.
- These can be supplied as a character vector or as `quote`d names. `.()` is useful shorthard for the latter.


```r
daply(iris, .(Species), function(r) mean(r$Petal.Length))
```

```
##     setosa versicolor  virginica 
##      1.462      4.260      5.552
```

```r
ddply(iris, .(Species), function(r) mean(r$Petal.Length))
```

```
##      Species    V1
## 1     setosa 1.462
## 2 versicolor 4.260
## 3  virginica 5.552
```

`sumarise` with `ddply` functions
=================================================

- One common task is to want to provide summary statistics by group.
- `plyr` provides a `summarise` function to make this easier.


```r
ddply(iris, .(Species, round(Sepal.Length, 0)), summarise,
      Mean.Petal.Length = mean(Petal.Length),
      SD.Petal.Length = sd(Petal.Length))
```

```
##       Species round(Sepal.Length, 0) Mean.Petal.Length SD.Petal.Length
## 1      setosa                      4          1.280000       0.1095445
## 2      setosa                      5          1.490000       0.1661016
## 3      setosa                      6          1.420000       0.1923538
## 4  versicolor                      5          3.583333       0.5382069
## 5  versicolor                      6          4.277778       0.3711843
## 6  versicolor                      7          4.687500       0.2167124
## 7   virginica                      5          4.500000              NA
## 8   virginica                      6          5.255556       0.3238391
## 9   virginica                      7          5.737500       0.3263434
## 10  virginica                      8          6.566667       0.2804758
```

Replication using `r*ply` functions
===================================

- Sometimes you don't want to use data as an input, you just want to run a piece of code 1000 times.
- An example would be permutation testing.
- In `plyr` this can easily be done using the `r*ply` functions.
- In common with `replicate`, and unlike the other `ply` functions, this takes an expression not a function

Replication using `r*ply` functions example
===================================


```r
result <- raply(100, mean(runif(1000)))
sum(result)
```

```
## [1] 49.96337
```

```r
hist(result)
```

![plot of chunk unnamed-chunk-19](figure/unnamed-chunk-19-1.png) 

Progress bars with `plyr`
=========================

- One really neat option in `plyr` is progres bars.
- These can be used with any of the `**ply` functions.


```r
file_list <- list.files("data", "\\.csv$")
process_file <- function(file_name) {
  # Do something rather slow on a file and return a one row data.frame
}
processed_data <- ldply(file_list, process_file, .progress = "text")
```

```
  |================                                    |  21%
```

- Other progress bars included with `plyr` are `.progress = "tk"` and `.progress = "win"`.
- Alternatively, a custom progress bar function can be written.

Parallelisation with `plyr`
===========================

- Progress bars are handy, but what's even better is faster results!
- `plyr` offers an easy route into parallelisation when used in conjunction with one of a few backends:
    - `SNOW`/`parallel` (`doSNOW` or `doParallel`)
    - `multicore` (`doMC`)
    - `MPI` (`doMPI`)
- On UNIX-like OSes, multicore tends to be the easiest, fastest and least memory intensive option.
- On Windows, SNOW (or parallel which uses SNOW) have to be used. SNOW also supports distribution of
  work across multiple machines.
- Parallelisation and progress bars are mutually exclusive (unless nesting)

Parallelisation with `plyr` (doMC)
==================================

- `multicore` works on UNIX-like OSes by forking the main process.
- All of the available data and packages are available to the child processes.


```r
library("doMC")
registerDoMC(4)
system.time(llply(1:4, sleepy_time, .parallel = TRUE))
```

Parallelisation with `plyr` (doParallel)
========================================


```r
library("doParallel")
```

```
## Loading required package: foreach
## foreach: simple, scalable parallel programming from Revolution Analytics
## Use Revolution R for scalability, fault tolerance and more.
## http://www.revolutionanalytics.com
## Loading required package: iterators
## Loading required package: parallel
```

```r
cl <- makeCluster(4)
registerDoParallel(cl)
sleepy_time <- function(x) Sys.sleep(2)
system.time(llply(1:4, sleepy_time, .parallel = FALSE))
```

```
##    user  system elapsed 
##    0.00    0.00    8.01
```

```r
system.time(llply(1:4, sleepy_time, .parallel = TRUE))
```

```
##    user  system elapsed 
##    0.05    0.02    3.02
```

```r
stopCluster(cl)
```

Parallelisation with `plyr` (doParallel 2)
========================================

- With `doParallel`, packages and the required variables need to be explicitly exported using
  the `.paropts` parameter.


```r
library("pROC")
```

```
## Type 'citation("pROC")' for a citation.
## 
## Attaching package: 'pROC'
## 
## The following objects are masked from 'package:stats':
## 
##     cov, smooth, var
```

```r
my_data <- data.frame(resp = sample(1:2, 1000, TRUE), V1 = rnorm(1000), V2 = rnorm(1000))
library("doParallel")
cl <- makeCluster(4)
registerDoParallel(cl)
llply(c("V1", "V2"), function(var) auc(my_data$resp, my_data[, var]),
  .parallel = TRUE, .paropts = list(.packages = "pROC", .export = "my_data"))
```

```
## [[1]]
## Area under the curve: 0.4919
## 
## [[2]]
## Area under the curve: 0.5129
```

```r
stopCluster(cl)
```


```r
llply(c("V1", "V2"), function(var) auc(my_data$resp, my_data[, var]), .parallel = TRUE)
```

```
## Error in do.ply(i) : task 1 failed - "could not find function "auc""
```

Parallelisation with `plyr` (doParallel 3)
========================================

- Alternatively, packages can be loaded using `clusterEvalQ` and data exported using `clusterExport`.


```r
library("pROC")
my_data <- data.frame(resp = sample(1:2, 1000, TRUE), V1 = rnorm(1000), V2 = rnorm(1000))
library("doParallel")
cl <- makeCluster(4)
registerDoParallel(cl)
clusterExport(cl, "my_data")
invisible(clusterEvalQ(cl, library("pROC")))
llply(c("V1", "V2"), function(var) auc(my_data$resp, my_data[, var]), .parallel = TRUE)
```

```
## [[1]]
## Area under the curve: 0.538
## 
## [[2]]
## Area under the curve: 0.5007
```

```r
stopCluster(cl)
```

Limitations of `plyr`
====================

- Just like the base R `lapply`, each iteration cannot access data from a previous iteration.
    - Modification of the parent/global environment using the `<<-` operator is possible, but not recommended.
    - In general, it may be better to use a `for` loop (ideally with pre-assignment of the output variable)
- The `d*ply` functions are quite a bit slower than the equivalents in `dplyr` and `data.table`.
- If you are using `dplyr` and `plyr` in the same session, they have multiple functions with the same name.
  It is recommended to load the packages in the order:

```r
library("plyr")
library("dplyr")
```

- If the specific version of a function is needed it can be called using the `::` operator.


```r
plyr::summarise(x, mean = mean(y))
```

Conclusions
===========

- `plyr` is an excellent way of taking some data, splitting it up, doing something to each bit and joining it all together.
- It has a consistent interface across its many functions that make coding more straightforward.
- It also offers an easy route to adding parallelisation and progress bars to running code.
