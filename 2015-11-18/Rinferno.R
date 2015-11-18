# space matters -------------
x<-3
x <- 3
x< -3
x <- -3

# <- or = ? ---------------
list(a = 1:5, b = letters[1:4])
list(a <- 1:5, b <- letters[1:4])
system.time(result <- runif(1000))
system.time(result2 = runif(1000))

# Floating point trap -----------------
myVect <- c(0.1/1, 0.2/2, 0.3/3, 0.4/4, 0.5/5, 0.6/6, 0.7/7)
myVect == 0.1
seq(0, 1, by = 0.1) == 0.3

print(myVect, digits = 20)
all.equal(myVect[1], 0.1)
all.equal(myVect[3], 0.1)
all.equal(0.11, 0.1)
isTRUE(all.equal(myVect[1], 0.1))
isTRUE(all.equal(0.11, 0.1))


# Failing to vectorize --------------
# the mean pitfall
max(-1, 5, 118, 0, -4)
min(-1, 5, 118, 0, -4)
mean(-1, 5, 118, 0, -4)
median(-1, 5, 118, 0, -4)

max(c(-1, 5, 118, 0, -4))
min(c(-1, 5, 118, 0, -4))
median(c(-1, 5, 118, 0, -4))
mean(c(-1, 5, 118, 0, -4))

# if else or ifelse
x <- 0
if(x < 1) y <- -1 else y <- 1
y
x <- seq(-1, 2, by = 1)
if(x < 1) y <- -1 else y <- 1
y
y <- ifelse(x < 1, -1, 1)

# unexpected else in else
x <- 5
if(x < 0) abs(x)
else sqrt(x)

if(x < 0) {
    abs(x)
}
else {
    sqrt(x)
}

if(x < 0) abs(x) else sqrt(x)
if(x < 0) {
    abs(x)
} else {
    sqrt(x)
}

# believing it doeas as intended -------------------
# precedence ----------------
1:5-1
1:5 - 1
10^2:5
10^(2:5)
-2.3^2.5
(-2.3)^2.5
(-2.3 + 0i)^2.5

# equality of missing value ----------------
myVect <- c(1:3, 2, NA)
myVect
myVect == NA
myVect == 3
is.na(myVect)
max(myVect)
max(myVect, na.rm = TRUE)

NULL == NULL
is.null(NULL)
1 + NULL
sum(NULL)
prod(NULL)
max(NULL)

myVect[myVect == 2]
myVect[myVect == 2 & !is.na(myVect)]
myVect[which(myVect == 2)]
which(myVect == 2)

# multiple testing --------------------
myVect <- 1:7
myVect == 4|6
myVect == (4|6)
myVect == 4 | myVect == 6
myVect %in% c(4,6)

0 < myVect < 3
0 < myVect & myVect < 3

# Numeric to factor, accidentally -------------
is.numeric(1:4)
is.numeric(factor(1:4))
mf <- factor(c(100:105, 101))
as.numeric(mf)
cat(mf)

as.numeric(as.character(mf))
as.numeric(levels(mf))[mf]

c(mf, factor(5:3))
factor(c(as.numeric(as.character(mf)), as.numeric(as.character(factor(5:3)))))
unlist(list(mf, factor(5:3)))

mdf <- data.frame(a = 2:3, b = c("x", "y"))
mdf[1,]
as.character(mdf[1,])
as.character(as.matrix(mdf[1,]))
mdf <- data.frame(a = 2:3, b = c("x", "y"), stringsAsFactors = FALSE)
mdf[1,]


# list subseting -------------------
ml <- list(one2five = 1:5, alphabet = letters)
myVar <- "alphabet"

ml$myVar
ml[[alphabet]]

ml$"alphabet"
ml$alphabet
ml[["alphabet"]]
ml[[myVar]]

ml["alphabet"]

# combining lists -----------------------
ml1 <- list(one2five = 1:5, alphabet = letters)
ml2 <- list(A = "a", BC = c("b", "c"))
c(ml1, ml2)
c(ml1, DE = c("d", "e"))
c(ml1, list(DE = c("d", "e")))
list(ml1, ml2)

# coercicion ------------------------
50 < "7"
50 < as.numeric("7")

# seq() and sample() ------------
seq(0:10)
0:10
seq(0, 10)

# sample -------------------
sample(c(5.2, 1), 9, replace = TRUE)
sample(c(5.2), 9, replace = TRUE)
sample(5.2, 9, replace = TRUE)

as.numeric(sample(as.character(5.2), 9, replace = TRUE))

# matrix in dataframe ---------------
myMat <- array(1:6, c(3,2))
myDF1 <- data.frame(X = 101:103, Y = myMat)
myDF2 <- data.frame(X = 101:103)
myDF2$Y <- myMat
myDF1
myDF2
dim(myDF1)
dim(myDF2)
myDF1$Y
myDF2$Y


# failing to use drop = FALSE is a major source of bugs ---------------------
myMatrix <- matrix(1:9, ncol = 3)
myMatrix
colSums(myMatrix)
colSums(myMatrix[c(1,2),])
colSums(myMatrix[c(2),])
colSums(myMatrix[c(2), , drop = FALSE])

# not reserved
T == TRUE
F <- TRUE
T <- FALSE
T == TRUE

c("a", "b")
c <- function(x) x*100 # also, t
c("a", "b")

plus4 <- function(x) return(x + 4)
plus4(1)
plus4(1:5)
# don't try this at home
return <- function(x) 2*x
plus4(1:5)
rm(retrun)

# quotes " ' `
# "" and '' are mostly synonimous
# backquotes allows using "reserved" words
`2` <- 2.5
`2` + `2`

# negative nothing is something
myVect <- 1:4
myVect[-which(myVect == 2)]
myVect[-which(myVect == 5)]
myVect[-5]
myVect[]
myVect[numeric(0)]

myVect[c(0, 4)] <- c(0, 1)

# subseting when names are not unique
myVect <- c(a = 1, b = 2, a = 3)
myVect
myVect["a"]
myVect[names(myVect) == "a"]
