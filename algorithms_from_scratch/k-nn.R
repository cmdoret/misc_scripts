# Implementing k-nearest neighbours from scratch.
# Cyril Matthey-Doret

# To do: reduce number of dimensions before computing distance.
# Different distance metric for character features (hamming ?)

library(tidyverse)

knn <- function(df, k, obs, response){
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
  X <- prcomp(t(X))$rotation[,c(1,2)]; p <- 2
  Y <- as.matrix(df[,response]) # Response variable as matrix
  dimnames(Y)[[2]] <- list(response)
  O <- matrix(unlist(rep(unname(obs),N)),byrow=T,nrow=N)  # obs values as matrix
  dimnames(O)[[1]] = dimnames(Y)[[1]] <- dimnames(X)[[1]]  # Keeping same sample names
  dimnames(O)[[2]] <- dimnames(X)[[2]] # Keeping same feature names

  D <- (X-O)^2 %*% matrix(rep(1, p), ncol = 1)  # Euclidean distance calculation
  D <- D[order(D[,1]),][1:k]  # Filtering k-nearest neighbours
  if(is.numeric(df[,response])){  # regression mode
    obs[,response] <- mean(Y[names(D),])
    return(obs)
    
  } else{  # classification mode
    votes <- table(namesD)
    # picking randomly a choice if equal number of choices
    obs[,response] <- votes[votes==max(votes)]
    return(list(class=obs, confidence=prop_votes[names(out_vote)]))
  }
}

knn(df = swiss[-1,], k = 5, obs = swiss[1,], response = 'Infant.Mortality')
knn(df = iris[-1,], k = 10, obs = iris[100,], response = 'Petal.Width')


conf_mat <- function(){
  # confusion matrix to assess quality of model
  
}
