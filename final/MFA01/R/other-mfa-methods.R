#' @title summary method
#' @description Summarizes information about the obtained eigenvalues
#' @param x an R object
#' @param digit number of decimal digit in print output
#' @export
ev.summary <- function(x,digit=3, ...) UseMethod("ev.summary")

#' @export
ev.summary.mfa <- function(x,digit=3, ...) {
  options(digits=digit)
  Eigenvalue <- round(x$eigen,2)
  Component <- 1:length(Eigenvalue)
  SingularValue <- round(sqrt(Eigenvalue),2)
  CumulativeEigenvalue <- cumsum(Eigenvalue)
  Inertia <- round(Eigenvalue/sum(Eigenvalue) * 100)
  CumulativeInertia <-round(cumsum(Inertia))
  x <- data.frame(SingularValue,Eigenvalue,CumulativeEigenvalue,Inertia,CumulativeInertia)
  print(x)
}


#' @title contribution method
#' @description Summarizes contribution of an observation to a dimension
#' @param x an R object
#' @param obs which observation to analyze
#' @param comp which component to analyze
#' @export
ctr.obs <- function(x,obs=NULL,comp=NULL,...) UseMethod("ctr.obs")

#' @export
ctr.obs.mfa <- function(x,obs=NULL,comp=NULL,  ...) {
  t <- x$cfs^2/nrow(x$cfs)
  ctr <- sweep(t,2,colSums(t),'/')
  if (is.null(obs) & is.null(comp)){
    return(ctr)
  } else if (!is.null(obs) & is.null(comp) ){
      return(ctr[obs,])
  } else if (is.null(obs) & !is.null(comp) ){
      return(ctr[,comp])
  }
    else{
      return(ctr[obs,comp])
  }
}

#' @title contribution method
#' @description Summarizes contribution of a variable to a dimension
#' @param x an R object
#' @param var which variable to analyze
#' @param comp which component to analyze
#' @export
ctr.var <- function(x, var=NULL,comp=NULL,  ...) UseMethod("ctr.var")

#' @export
ctr.var.mfa <- function(x, var=NULL,comp=NULL,  ...) {
  t <- x$fl^2
  ctr <- sweep(t,1,x$weights,'*')
  if (is.null(var) & is.null(comp)){
      return(ctr)
  } else if(!is.null(var) & is.null(comp) ){
      return(ctr[var,])
  }
    else if(is.null(var) & !is.null(comp)){
      return(ctr[,comp])
  }
    else{
      return(ctr[var,comp])
  }
}

#' @title contribution method
#' @description Summarizes contribution of a table/block to a dimension
#' @param x an R object
#' @param var which table/block to analyze
#' @param comp which component to analyze
#' @export
ctr.table <- function(x, table = NULL,comp=NULL,...) UseMethod("ctr.table")

#' @export
ctr.table.mfa <- function(x, table = NULL,comp=NULL,...) {
  t <- ctr.var(x)
  idx <- x$index_lists
  ctr.slt <- split(data.frame(t),idx)
  ctr.table <- list()
  for (i in 1:length(ctr.slt)){
    ctr.table[[i]]  <- apply(ctr.slt[[i]], 2,sum)}

  if (is.null(table) & is.null(comp)){
      return(ctr.table)
  } else if(!is.null(table) & is.null(comp) ){
      return(ctr[[table]])
  }
    else if(!is.null(table) & !is.null(comp)){
      return(ctr.table[[table]][comp])
    }
}
#' @title RV table
#' @description private function to evaluate the similarity between two tables
#' @param table1 the first table to analyze
#' @param table2 the second table to analyze
#' @export
RV <- function(table1, table2) UseMethod("RV")
#' @export

RV <- function(table1, table2){
  m1 <- as.matrix(table1)
  m2 <- as.matrix(table2)
  m1m <- m1 %*% t(m1)
  m2m <- m2 %*% t(m2)
  res1 <- sum(diag( m1m %*% m2m))
  res2 <- sqrt( sum(diag( m1m %*% m1m)) * sum(diag( m2m %*% m2m)) )
  res1 / res2
}

#' @title RV table
#' @description Coefficients to study the Between-Table Structure
#' @param dataset the dataset to study 
#' @param sets list with sets of variables
#' @export
RV_table <- function(dataset, sets = list(1:3, 4:5, 6:10)) UseMethod("RV_table")
#' @export
RV_table <- function(dataset, sets = list(1:3, 4:5, 6:10)){
  K <- length(sets)
  res <- matrix(1, K, K)
  for(i in 1:K){
    for(j in i:K){
      res[i,j] <- RV(dataset[, sets[[i]]], dataset[, sets[[j]]])
      res[j,i] <- res[i,j]
    }
  }
  res
}

#' @title Lg coefficient
#' @description Lg Coefficient between two tables
#' @param table1 the first table to analyze
#' @param table2 the second table to analyze
#' @export
Lg <- function(table1, table2) UseMethod("Lg")

#' @export
Lg <- function(table1, table2){
  m1 <- as.matrix(table1)
  m2 <- as.matrix(table2)
  m1m <- m1 %*% t(m1)
  m2m <- m2 %*% t(m2)
  svd1 <- svd(m1)
  svd2 <- svd(m2)
  alpha1 <- 1 / max(svd1$d)^2
  alpha2 <- 1 / max(svd2$d)^2
  res <- sum(diag( m1m %*% m2m)) * alpha1 * alpha2
  res
}

#' @title Lg table
#' @description table of Lg coefficients
#' @param dataset the dataset to study 
#' @param sets list with sets of variables
#' @export
Lg_table <- function(dataset, sets = list(1:3, 4:5, 6:10)) UseMethod("Lg_table")
#' @export
Lg_table <- function(dataset, sets = list(1:3, 4:5, 6:10)){
  K <- length(sets)
  res <- matrix(1, K, K)
  for(i in 1:K){
    for(j in i:K){
      res[i,j] <- Lg(dataset[, sets[[i]]], dataset[, sets[[j]]])
      res[j,i] <- res[i,j]
    }
  }
  res
}

#' @title bootstrap
#' @description Bootstrap to estimate the stability of the compromise factor scores
#' @param x an object of class \code{"mfa"}
#' @param K bootstrap sample size
#' @param L number of bootstrap samples
#' @export
bootStrap <- function(x, K = 10, L = 1000,...) UseMethod("bootStrap")
#' @examples
#'  \dontrun{
#'  # create a \code{"mfa"} and plot its common factor scores
#'  a <- MFA()
#'
#'  bootstrap(a)
#'  }
#' @export
bootStrap <- function(x, K = 10, L = 1000,...){
  n <- nrow(x$cfs)      # num of observations
  R <- ncol(x$cfs)       # rank
  KK <- max(x$index_lists)      # maximum num of components
  pfs <- x$pfs         # partial factor scores
  Fstar <- array(0, dim = c(n, R, L))
  for(i in 1:L){
    B <- sample(KK, K, replace = TRUE)
    for(j in 1:K){
      Fstar[, , i] <- Fstar[, , i] + pfs[[B[j]]] / K
    }
  }
  meanFstar <- apply(Fstar, c(1,2), mean)
  varFstar <- apply(Fstar, c(1,2), var) * (L-1) / L
  res <- list(meanFstar, sqrt(varFstar))
  names(res) <- c('mean', 'sd')
  res
}



############### Below is testing code
# x <- matrix(1:100, nrow=10, ncol=10)
# RV_table(x,list(1:3,5:6,7:10))
# Lg_table(x)

