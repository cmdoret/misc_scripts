# Just writing a linear model with k-fold cross validation from scratch for training.
# Model supports two fitting methods: normal equation (exact=T), and gradient
# descent (exact=F). 


train_mod <- function(df, response, exact=T,speed=0.6, iter=200, plot=F){
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
  } else{
    # Using gradient descent method. Approximate solution, but
    # faster in very high dimensional space with many observations
    B_hat <- matrix(rep(1,p+1),ncol=1)  # Initiating weights
    for(i in 1:iter){
      Y_hat <- X %*% B_hat  # Computing estimated response from weights
      gradients <- (2/N) * (t((Y_hat - Y)) %*% X)
      # Using partial derivative of each weight to compute gradient
      B_hat <- B_hat - t(gradients) * speed  # Updating weights using gradients
    }
  }
  Y_hat <- X %*% B_hat
  df_out <- cbind(df, Y_hat)
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
  
  predicted <- X %*% weights  # Estimating response variable
  return(predicted)
}

cross_val <- function(data, response, folds, exact=T, speed=0.001, iter=200){
  # Cross validation: leave one out
  
  init <- rep(NA,nrow(data))  #  initializing df for cross-val. output
  accuracy <- data.frame(pred=init, folds=init)
  #accuracy <- data.frame(pred = numeric(0), folds = numeric(0))
  weight_list <- list(); MSE=rep(NA, folds)
  pool <- 1:nrow(data)  # pool of rows from which to sample folds
  fold_size <- floor(nrow(data)/folds)  # Number of samples per fold
  fold_list <- matrix(ncol = folds, nrow = fold_size)  # initializing data structure for folds
  
  for(i in 1:folds){  # Leave one out (each obs once)
    fold_list[,i] <- sample(pool[!is.na(pool)], size = fold_size, replace = F)  # randomly sampling fold
    pool[fold_list[,i]] <- NA #  removing samples in fold from sample pool
    trained <- train_mod(data[-fold_list[,i],], response, exact, speed, iter)  # Training without fold i
    test_obs <- predict_mod(data[fold_list[,i],], response, trained$weights)  # Predicting fold i
    SE <- (as.numeric(test_obs) - as.numeric(data[fold_list[,i],response]))^2 # Squared error
    MSE[i] <- mean(SE)
    # computing mean squared error from real value
    weight_list[[i]] <- trained$weights
    test_obs <- data.frame(pred=test_obs,folds=rep(i,fold_size))
    accuracy[fold_list[,i],] <- test_obs
    #accuracy <- rbind(accuracy, test_obs)
    Sys.sleep(0.5)
  }
  return(list(accuracy=accuracy, weights=weight_list, MSE=MSE))
}

#============================
# Playing around with model =
#============================

# Predicting quantitative variable
out_var='Petal.Length'
cross_val(iris, out_var, folds=150, exact=T)
cross_val(iris,out_var, folds=5,exact=F,speed=0.005, iter=100)

if(FALSE){

assess_perf <- data.frame(iterations=numeric(0),
                          fold=numeric(0), cost=numeric(0))
  
for(it in seq(1,100,1)){
  for(f in seq(2,nrow(iris),1)){
    results <-cross_val(iris,out_var, folds=f,exact=F,speed=0.05, iter=it)
    tmp_row <- c(iterations=it, fold=f, 
                cost=mean((iris[,out_var] - results$accuracy$pred)^2))
    assess_perf <- rbind(assess_perf, tmp_row)
  }
}
colnames(assess_perf) <- c('iterations', 'k_fold', 'mean_squared_error')
assess_plot <- assess_perf[!is.na(assess_perf$mean_squared_error),]
scatter3D(assess_plot$iterations, assess_plot$k_fold, -log(assess_plot$mean_squared_error),clab=colnames(assess_plot))

for(it in seq(1,3000,10)){
results <-cross_val(iris,out_var, folds=3, exact=F, speed=0.0005, iter = it)
plot(as.numeric(iris[,out_var]),results$accuracy$pred,col=results$accuracy$folds,
     xlim=c(0,10),ylim=c(0,10))
abline(a=0,b=1)
Sys.sleep(0.2)
}

plot(density((iris[,out_var] - results$accuracy$pred)^2))

boxplot(t(do.call(cbind,results$weights)),pch="x")
# Plotting variation of weights and intercept

# ----------
# Predicting categorical variable
out_var<- 'Species'
classified <- c()
for(f in 2:150){
  results <- cross_val(iris, out_var, folds=f, exact=F, speed=0.006, iter=100)
  classified <- append(classified, length(iris$Species[round(results$accuracy$pred)==as.numeric(iris[,out_var])])/nrow(iris))
}
abline(h=c(1.5,2.5),col="red")
plot(as.numeric(iris[,out_var]),results$accuracy$pred)

# Plotting variation of weights and intercept
fitted_lines <- t(do.call(cbind,results$weights))
boxplot(fitted_lines)
par(mfrow=c(2,2))
for(b in 2:5){  
  # Fitted curves produced by cross-val. on every axis
  plot(seq(1,200,4),seq(1,50),type='n')
  for(r in 1:nrow(fitted_lines)){
    abline(a = fitted_lines[r,1],b=fitted_lines[r,b])
  }
}

plot(2:150, classified, type='l')
}
