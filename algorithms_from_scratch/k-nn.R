# Implementing k-nearest neighbours from scratch.
# Cyril Matthey-Doret

# To do: reduce number of dimensions before computing distance.
# Different distance metric for character features (hamming ?)

library(tidyverse)

knn <- function(df, k, PCA=T, obs, response){
  # implementing k-nearest neighbours. This function can work with
  # categorical or numeric response. It can only predict one observation
  # at a time. 
  obs <- select(obs,-matches(response))
  isNum <- sapply(obs,is.numeric)
  obs <- select(obs, which(isNum))
  num_features <- colnames(df)[unname(sapply(df,is.numeric))]  # Numeric variables only
  num_features <- num_features[num_features != response]
  
  N <- nrow(df)  # Number of observations
  p <- length(num_features)  # Number of input variables
  X <- as.matrix(df[,num_features])  # Transforming into matrix
  obs <- t(apply(obs, MARGIN=1, function(x) x-colMeans(X)))
  obs <- t(apply(obs, MARGIN=1, function(x) x/apply(X , MARGIN=2, FUN=sd)))
  O <- matrix(unlist(rep(unname(obs),N)),byrow=T,nrow=N)  # obs values as matrix
  Y <- as.matrix(df[,response]) # Response variable as matrix
  dimnames(Y)[[2]] <- list(response)
  if(PCA){
    red_dim <- prcomp(X, scale = T, rank=2); p <- 2
    rot_var <- red_dim$rotation[,c(1,2)]
    X <- red_dim$x[,c(1,2)]
    O <- O %*% rot_var
  }
  dimnames(O)[[1]] = dimnames(Y)[[1]] <- dimnames(X)[[1]]  # Keeping same sample names
  dimnames(O)[[2]] <- dimnames(X)[[2]] # Keeping same feature names
  D <- matrix((X-O)^2 %*% matrix(rep(1, p), ncol = 1))  # Euclidean distance calculation
  D <- order(D,decreasing = F)[1:k]  # Filtering k-nearest neighbours
  if(is.numeric(df[,response])){  # regression mode
    pred_val <- mean(Y[D,])
    return(pred_val)
  } else{  # classification mode
    votes <- table(Y[D])
    # picking randomly a choice if equal number of choices
    pred_val <- names(votes[votes==max(votes)])
    prop_votes <- votes[pred_val]/sum(votes)
    return(list(prediction=pred_val, confidence=prop_votes))
  }
}

knn(df = swiss[-1,], k = 5, obs = swiss[1,], response = 'Infant.Mortality')
knn(df = iris[-1,], k = 10, obs = iris[100,], response = 'Petal.Width')

pred_class <- list(class=rep(NA,nrow(iris)), conf=rep(NA,nrow(iris)))
for(i in 1:nrow(iris)){
  pred_class$class[i] <- knn(df = iris[-i,], k = 7, obs = iris[i,], response = 'Species')$prediction
  pred_class$conf[i] <- knn(df = iris[-i,], k = 7, obs = iris[i,], response = 'Species')$confidence
}

conf_mat <- function(){
  # confusion matrix to assess quality of model
  
}
