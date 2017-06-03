# Implementing k-nearest neighbours from scratch.
# Cyril Matthey-Doret

# To do: reduce number of dimensions before computing distance.
# Different distance metric for character features (hamming ?)

library(tidyverse)

knn <- function(df, k, softmax=F, obs, response){
  # implementing k-nearest neighbours. This function can work with
  # categorical or numeric response. It can only predict one observation
  # at a time. Possibility to chose between softmax weighted votes or simple
  # cut-off at k-nearest neighbours. 
  obs <- select(obs,-matches(response))
  isNum <- sapply(obs,is.numeric)
  obs <- select(obs, which(isNum))
  num_features <- colnames(df)[unname(sapply(df,is.numeric))]  # Numeric variables only
  num_features <- num_features[num_features != response]
  
  N <- nrow(df)  # Number of observations
  p <- length(num_features)  # Number of input variables
  X <- as.matrix(df[,num_features])  # Transforming into matrix
  Y <- as.matrix(df[,response]) # Response variable as matrix
  dimnames(Y)[[2]] <- list(response)
  O <- matrix(unlist(rep(unname(obs),N)),byrow=T,nrow=N)  # obs values as matrix
  dimnames(O)[[1]] = dimnames(Y)[[1]] <- dimnames(X)[[1]]  # Keeping same sample names
  dimnames(O)[[2]] <- dimnames(X)[[2]] # Keeping same feature names

  D <- (X-O)^2 %*% matrix(rep(1, p), ncol = 1)  # Euclidean distance calculation
  D <- D[order(D[,1]),][1:k]  # Filtering k-nearest neighbours
  if(softmax){D <- 1/(1+exp(-(D-mean(D))/sd(D)))} # Normalize distance to reduce impact of outliers
  if(is.numeric(df[,response])){  # regression mode
    weight <- ifelse(softmax,yes = list(round(exp(-D)/sum(exp(-D)),3)),
                     no = list(rep(x = 1/k,times=k)))[[1]]
    # weights are either all the same or defined by softmax function
    obs[,response] <- weight %*% as.matrix(Y[names(D),])
    return(obs)
  } else{  # classification mode
    votes <- table(namesD)
    if(softmax){
    out_vote <- votes[votes==max(votes)]
    out_vote <- out_vote[sample(x = 1:length(out_vote),size = 1)]
    prop_votes <- sapply(votes,function(x) x/sum(votes))
    }
    # picking randomly a choice if equal number of choices
    obs[,response] <- out_vote
    return(list(class=obs, confidence=prop_votes[names(out_vote)]))
  }
}

knn(df = swiss[-1,], k = 5, obs = swiss[1,], softmax = F, response = 'Infant.Mortality')
knn(df = iris[-1,], k = 10, obs = iris[1,], softmax = F, response = 'Petal.Width')

conf_mat <- function(){
  # confusion matrix to assess quality of model
  
}