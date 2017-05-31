# Just writing a linear model from scratch for training with cross validation.


train_mod <- function(df, response, exact=T,speed=0.6, plot=F){
  # Takes a dataframe and the name of the variable to predict as input.
  # Returns the input dataframe with the estimated age after minimizing RSS
  
  num_features <- colnames(df)[unname(sapply(df,is.numeric))]  # Numeric variables only
  num_features <- num_features[num_features != response]  # Excluding response variable
  
  N <- nrow(df)  # Number of observations
  p <- length(num_features)  # Number of input variables
  X <- as.matrix(df[,num_features])  # Transforming into matrix
  X <- cbind(rep(1,N),X)  # Adding intercept (bias)
  df[,response] <- as.numeric(df[,response])  # If response is factorial, encoded with integers
  Y <- as.matrix(df[,response])  # Response variable as matrix
  
  # Plotting input-response correlations
  if(plot==T){
    par(mfrow=c(floor(sqrt(p)),p/floor(sqrt(p))))
    for(var in num_features){plot(df[,var],df[,response],main=var)}
  }
  if(exact==T){
    # Solution of the derivative by beta to minimize RSS(B)
    B_hat <- solve(t(X)%*%X) %*% t(X) %*% Y
    Y_hat <- X %*% B_hat
    df_out <- cbind(df, Y_hat)
  } else{
    
  }
  return(list(table=df_out,weights=B_hat))
}

predict_mod <- function(obs, response, weights){
  # Predicting observations using pre-calculated weights

  num_features <- colnames(obs)[unname(sapply(obs,is.numeric))]  # Numeric variables only
  num_features <- num_features[num_features != response]  # Excluding response variable
  
  N <- nrow(obs)  # Number of observations
  p <- length(num_features)  # Number of input variables
  X <- as.matrix(obs[,num_features])  # Transforming into matrix
  X <- cbind(rep(1,N),X)  # Adding intercept (bias)
  predicted <- X %*% weights
  return(predicted)
}

cross_val <- function(data, response, exact=T, speed=0.6){
  # Cross validation: leave one out
  
  init <- rep(NA,nrow(data))  #  initializing df for cross-val. output
  accuracy <- data.frame(sq_err=init, pred=init)
  weight_list <- list()
  for(i in 1:nrow(data)){  # Leave one out (each obs once)
    trained <- train_mod(data[-i,], response, exact, speed)  # Training without obs i
    test_obs <- predict_mod(data[i,], response, trained$weights)  # Predicting val i
    sq_err <- (as.numeric(test_obs) - as.numeric(data[i,response]))^2
    # computing sqared error from real value
    weight_list[[i]] <- trained$weights
    accuracy[i,] <- c(sq_err, test_obs)
  }
  return(list(accuracy=accuracy, weights=weight_list))
}

out_var='Petal.Length'
results <-cross_val(iris,out_var)

plot(as.numeric(iris[,out_var]),results$accuracy$pred)
plot(density(results$accuracy$sq_err))

