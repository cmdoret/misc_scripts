# Just writing a linear model from scratch for training.


lin_mod <- function(df, response){
  # Takes a dataframe and the name of the variable to predict as input.
  # Returns the input dataframe with the estimated age after minimizing RSS
  
  num_features <- colnames(df)[unname(sapply(df,is.numeric))]  # Numeric variables only
  num_features <- num_features[num_features != response]  # Excluding response variable
  
  N <- nrow(df)  # Number of observations
  p <- length(num_features)  # Number of input variables
  X <- as.matrix(df[,num_features])  # Transforming into matrix
  X <- cbind(rep(1,N),X)  # Adding intercept
  df[,response] <- as.numeric(df[,response])  # If response is factorial, encoded with integers
  Y <- as.matrix(df[,response])  # Response variable as matrix
  
  # Plotting input-response correlations
  par(mfrow=c(floor(sqrt(p)),p/floor(sqrt(p))))
  for(var in num_features){plot(df[,var],df[,response],main=var)}
  
  # Solution of the derivative by beta to minimize RSS
  B_hat <- solve(t(X)%*%X) %*% t(X) %*% Y
  Y_hat <- X %*% B_hat
  df_out <- cbind(df, Y_hat)
  return(list(table=df_out,weights=B_hat))
}


finish<-lin_mod(iris, 'Species')  # Trying to use linear regression to predict categorical variable
finish_table<- finish$table
finish_beta<- finish$weights

plot(finish_table$Species, finish_table$Y_hat)  # plotting actual species vs predicted species
abline(h=seq(1.5,3,1))  # Boundaries between species
1 - length(finish_table$Species[finish_table$Species != round(finish_table$Y_hat)])/nrow(finish_table)  # 97.3% accuracy
sd(finish_table$Species - finish_table$Y_hat)
