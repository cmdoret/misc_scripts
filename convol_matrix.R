# Primitive script attempting to perform matrix convolution and display it.
# Cyril Matthey-Doret
# Wed Dec 14 00:53:41 2016 ------------------------------


get_neigh<- function(mat,md=F,I,J,n.row,n.col){
  ind_neigh <- c()
  for(i in -1:1){
    for(j in -1:1){
      if((I+i)>0 & (I+i)<=n.row ){
        if((J+j)>0 & (J+j)<=n.col){
          ind_neigh <- append(ind_neigh,mat[I+i,J+j])
        }
      }
    }
  }
  if(any(md)){out <-median(ind_neigh)}else{out <- mean(ind_neigh)}
  #print(out)
  return(out)
}

mat.convolution <- function(M,med=F){
  mat.row <-nrow(M)
  mat.col <- ncol(M)
  ConvMat <- sapply(1:mat.col,function(j){
    sapply(1:mat.row,function(i){get_neigh(mat=M,md=med,I=i,J=j,n.row=mat.row,n.col=mat.col)})})
  return(ConvMat)
}

#M <- matrix(c(1,1,1,1,10,1,1,1,1),nrow=3)
M <- matrix(nrow=100,ncol=100,rpois(10000,lambda = 1))
Mc <- M
Md <- M
par(mfrow=c(1,2))
for(i in 1:100){
  Mc <- mat.convolution(Mc,med=F)
  Md <- mat.convolution(Md,med=T)
  #Mc <- sqrt(Mc)
  #par(mfrow=c(1,2))
  image(t(Mc))
  image(t(Md))
  Sys.sleep(0.01)
}

M <- matrix(rep(0,10000),nrow=100)
M[45:50,45:50] <- 10
