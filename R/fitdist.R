#' Fit a truncated power-law.
#' 
#' Model: y ~ a * x^(-lambda) exp(-x/k)
#' 
#' @param x A vector of independent variable.
#' @param y A vector of dependent variable.
#' @param xmin The lower bound point of x.
#' @param xmax The higher truncated point of x.
#' @param plot Whether to plot the fitted curve.
#' @param add Whether to add the fitted curve to current plot.
#' @param ... Extra parameters to \code{\link{curve}}.
#' @return A list of values for a, lambda and k.
#' @seealso \code{\link{fit_power_law}}
#' @export
fit_truncated_power_law <- function(x, y, xmin=min(x), xmax=max(x), plot=TRUE, add=TRUE, ...) {
  xtrunc <- (x>=xmin & x<=xmax)
  x = x[xtrunc]
  y = y[xtrunc]
  y[y==0] <- 1e-32
  lm.out <- lm(log(y) ~ x + I(log(x)))
  p <- coef(lm.out)
  lambda = - as.numeric(p[3])
  k = -1 / as.numeric(p[2])
  a = exp(as.numeric(p[1]))
  
  if (plot) {
    curve(exp(-lambda * log(x) - x / k +  log(a)), add=add, ...)
  }
  
  list(model='y ~ a * x^(-lambda) exp(-x/k)', a=a, lambda=lambda, k=k)
}


#' Fit a power-law
#' 
#' Model: y ~ a * x^{-lambda}
#' 
#' @param x A vector of independent variable.
#' @param y A vector of dependent variable.
#' @param xmin The lower bound point of x.
#' @param xmax The higher truncated point of x.
#' @param plot Whether to plot the fitted curve.
#' @param add Whether to add the fitted curve to current plot.
#' @param ... Extra parameters to \code{\link{curve}}.
#' @return A list of values for a and lambda.
#' @seealso \code{\link[igraph]{fit_power_law}}, \code{\link{fit_truncated_power_law}}
#' @export
fit_power_law <- function(x, y, xmin=min(x), xmax=max(x), plot=TRUE, add=TRUE, ...) {
  xtrunc <- (x>=xmin & x<=xmax)
  x = x[xtrunc]
  y = y[xtrunc]
  y[y==0] <- 1e-32
  lm.out <- lm(log(y) ~ I(log(x)))
  p <- coef(lm.out)
  a <- exp(as.numeric(p[1]))
  lambda <- - as.numeric(p[2])
  
  if (plot) {
    curve(exp(log(a) - lambda * log(x)), add=add, ...)
  }
  
  list(model='y ~ a * x^(-lambda)', a=a, lambda=lambda)
}

#' Fit a poly-exponential distribution
#' 
#' Model: y ~ exp(a*x^2 + b*x + c) * x^d
#' 
#' @param x A vector of independent variable.
#' @param y A vector of dependent variable.
#' @param xmin The lower bound point of x.
#' @param xmax The higher truncated point of x.
#' @param plot Whether to plot the fitted curve.
#' @param add Whether to add the fitted curve to current plot.
#' @return A list of values for a, b, c, and d.
#' @param ... Extra parameters to \code{\link{curve}}.
#' @export
fit_polyexp <- function(x, y, xmin=min(x), xmax=max(x), plot=TRUE, add=TRUE, ...){
  xtrunc <- (x>=xmin & x<=xmax)
  x = x[xtrunc]
  y = y[xtrunc]
  y[y==0] <- 1e-32
  lm.out <- lm(log(y) ~ x + I(x ^ 2) + I(log(x)))
  p <- coef(lm.out)
  a=as.numeric(p[1])
  b=as.numeric(p[2])
  c=as.numeric(p[3])
  d=as.numeric(p[4])
  
  if (plot) {
    curve(exp(a + b * x + c * x^2) * x^d, add=add, ...)
  }
  
  list(model='y ~ exp(a*x^2 + b*x + c) * x^d', a=a, b=b, c=c, d=d)
}
