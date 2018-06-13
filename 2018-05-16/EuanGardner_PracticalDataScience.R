########################################
#Almost all code with many thanks from the following articles:

#http://topepo.github.io/caret/visualizations.html

#https://machinelearningmastery.com/machine-learning-in-r-step-by-step/

#######################################


#Install ALL the packages!
install.packages('mlbench')
install.packages('caret')
install.packages('AppliedPredictiveModeling')
install.packages('ellipse')
install.packages('psych')
install.packages('e1071')
install.packages('tidyverse')
install.packages('ggplot2')


#Loading libraries 
library(mlbench)
library(caret)
library(AppliedPredictiveModeling)
library(caret)
library(ellipse)
library(psych)
library(e1071)

######################################## Obtain 
#Import the data as if it were your own
#Set the working directory to the location of your file 
#setwd("<location of your dataset>")

#If larger dataset then SQL/tibble/small import should be used here: 
#df_iris <- read.table("Iris_data.txt", header = FALSE)

#Import the data as built in 
data(iris)

#Quick check of data/see if it loaded correctly
head(iris)
########################################

######################################## Explore 
#Brilliant visualisation matrix (see slides for link)
#5th column is Labels
featurePlot(x = iris[, 1:4], 
            y = iris$Species, 
            plot = "ellipse",
            ## Add a key at the top
            auto.key = list(columns = 3))

#As we can see it is possible to linearly sperate out the classes (though sepal length + width may not be useful
#as they are very close)
########################################

######################################## Model 1 - Feature Selection + Pre-processing + Splitting Data 

#Feature Selection 
# prepare training scheme
control <- trainControl(method="repeatedcv", number=10, repeats=3)
# train the model
model <- train(Species~., data=iris, method="lvq", preProcess="scale", trControl=control)
# estimate variable importance
importance <- varImp(model, scale=FALSE)
# summarize importance
print(importance)
# plot importance
plot(importance)

#Petal.Length, Petl.Width and Sepal.Length = best features. Can drop Sepal.width (see earlier graph)
updated_iris <- iris[c(-2)]

#Centering and Scaling
preprocessParams <- preProcess(updated_iris[,1:4], method=c("center", "scale"))
scaled_iris <- predict(preprocessParams, updated_iris[,1:4])

featurePlot(x = scaled_iris[, 1:3], 
            y = scaled_iris$Species, 
            plot = "ellipse",
            ## Add a key at the top
            auto.key = list(columns = 2))



########################################

######################################## Model 2 - SVM Time :D 
#Name sets
dataset = train
validation = test

# Run algorithms using 10-fold cross validation
control <- trainControl(method="cv", number=10)
metric <- "Accuracy"
# a) linear algorithms
set.seed(7)
fit.lda <- train(Species~., data=dataset, method="lda", metric=metric, trControl=control)
# b) nonlinear algorithms
# CART
set.seed(7)
fit.cart <- train(Species~., data=dataset, method="rpart", metric=metric, trControl=control)
# kNN
set.seed(7)
fit.knn <- train(Species~., data=dataset, method="knn", metric=metric, trControl=control)
# c) advanced algorithms
# SVM
set.seed(7)
fit.svm <- train(Species~., data=dataset, method="svmRadial", metric=metric, trControl=control)
# Random Forest
set.seed(7)
fit.rf <- train(Species~., data=dataset, method="rf", metric=metric, trControl=control)


######################################## Evaluate
# summarize accuracy of models
results <- resamples(list(lda=fit.lda, cart=fit.cart, knn=fit.knn, svm=fit.svm, rf=fit.rf))
summary(results)
# compare accuracy of models
dotplot(results)
########################################


######################################## Interpret
#As SVM + LDA super close, SVM scales for deployment 

#Testing Predictions of SVM
predictions <- predict(fit.svm, validation)
confusionMatrix(predictions, validation$Species)
########################################


