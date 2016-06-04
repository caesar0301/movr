#' Vector Normalization
#' 
#' Normalize a given vector.
#' 
#' @param x A vector to be normalized.
#' @seealso \code{\link{standardize_st}}
#' @export
#' @examples
#' standardize(c(1,2,3,4,5,6))
standardize <- function(x) {
  standardize_v(x)
}

#' @export
standardize_v <- function(x){
  if(length(x) == 1){
    warning('standardize_v takes lenght-1 vector')
    return(1)
  }
  x.min = min(x);
  x.max = max(x)
  (x - x.min) / (x.max - x.min)
}

#' Normalization over spatial and temporal scale
#' 
#' Scale the value along spatial and temporal coordinates simultaneously.
#' 
#' @param scoord a 1D vector of spatial coordinate
#' @param tcoord a 1D vector of temporal coordinate
#' @param value a value vector for each (scoord, tcoord)
#' @param alpha a tuning parameter controling the weight of space and time
#' @export
#' @examples
#' scoord <- rep(seq(6), 2)
#' tcoord <- rep(c(1,2), each=6)
#' value <- runif(6 * 2)
#' standardize_st(scoord, tcoord, log10(1+value))
standardize_st <- function(scoord, tcoord, value, alpha=0.5){
  df <- data.frame(s=scoord, t=tcoord, v=value)
  df2 <- df %>%
    # scaled over time
    group_by(s) %>%
    dplyr::mutate(
      z.t = standardize_v(v) ) %>%
    # scaled over space
    group_by(t) %>%
    dplyr::mutate(
      z.s = standardize_v(v),
      z = alpha * z.s + (1-alpha) * z.t ) %>%
    dplyr::select(-z.t, -z.s)
  df2$z
}

#' Approximately matching sequence
#' 
#' Match x to y approximately, and return the index of y,
#' which is mostly near to each value in x.
#' A variate of match() or %in%
#' 
#' @param x A given vector to be matched
#' @param y A target vector to calculate absolute approximation
#' @seealso \code{\link{seq_along}}, \code{\link{rep_each}}
#' @export
#' @examples
#' a <- c(1,2,3)
#' b <- c(0.1, 0.2, 0.5)
#' seq_approximate(a, b)
seq_approximate <- function(x, y){
  sapply(x, function(i) which.min(abs(y-i)))
}

#' Sequencing by distinct values
#' 
#' Generate a new (integer) sequence according to distinct value levels.
#' The same value takes a unique order number.
#' 
#' @param v A vector to generate integer sequence
#' @export
#' @seealso \code{\link{seq_along}}, \code{\link{seq_collapsed}},
#'    \code{\link{vbin}}, \code{\link{vbin.range}}, \code{\link{vbin.grid}}
#' @examples
#' seq_along(c(1,2,3,2))
#' seq_distinct(c(1,2,3,2))
seq_distinct <- function(v) {
  v.u <- unique(v)
  sapply(v, match, v.u)
}

#' Sequencing by collapsing adjacent same values
#' 
#' Generate integer sequence by assigning the same adjacent values to the same
#' level.
#' 
#' @param v The input vector.
#' @seealso \code{\link{seq_along}}, \code{\link{seq_distinct}},
#'    \code{\link{vbin}}, \code{\link{vbin.range}}, \code{\link{vbin.grid}}
#' @export
#' @examples
#' seq_collapsed(c(1,2,2,3,2,2))
seq_collapsed <- function(v) {
  len = length(v)
  stopifnot(len > 0)
  last_index = 1
  res = c(last_index)
  if ( len >= 2) {
    last_value = v[1]
    for (p in v[2:len]) {
      if ( last_value != p) {
        last_index = last_index + 1
      }
      res = c(res, last_index)
      last_value = p
    }
  }
  res
}

#' Replicate elements of vector
#' 
#' This is a slight modification of \code{rep} in basic package. It replicates
#' each element of a vector one by one to construct a new vector.
#' 
#' @param x a vector
#' @param times the number of replication times of each element.
#' @seealso \code{\link{seq_approximate}}, 
#' @export
#' @examples
#' rep(1:10, 2)
#' rep_each(1:10, 2)
rep_each <- function(x, times=2) {
  if (!is.vector(x))
    stop("Param x should be a vector.")
  as.vector(sapply(x, rep, times))
}

#' Vector binning
#' 
#' Bin a vector into `n` intervals in regard with its value range.
#' The vector x is split into n bins within [min(x), max(x)],
#' and bin index is given by checking the bin [bin_min, bin_max)
#' into which data points in x fall.
#' 
#' @usage
#'     vbin(x, n, center=c(TRUE, FALSE))
#' @param x a numeric vector
#' @param n the number of bins
#' @param center indication of representing intervals as index (default) or
#' center points.
#' @return Sequence with interval index or center points.
#' @seealso \code{\link{seq_approximate}}, \code{\link{vbin.range}}, \code{\link{vbin.grid}}
#' @export
#' @examples
#' vbin(1:10, 3)
#' vbin(1:10, 3, TRUE)
vbin <- function(x, n, center=FALSE){
  x.bin <- seq(floor(min(x)), ceiling(max(x)), length.out=n+1)
  x.int <- findInterval(x, x.bin, all.inside = TRUE)
  if(center)
    return(0.5 * (x.bin[x.int] + x.bin[x.int+1]))
  else
    return(x.int)
}

#' Vector range binning
#' 
#' Bin the range of given vector into n itervals.
#' 
#' @param x a numeric vector
#' @param n the number of bins
#' @return the center of each interval
#' @export
#' @seealso \code{\link{seq_approximate}}, \code{\link{vbin}}, \code{\link{vbin.grid}}
#' @examples
#' vbin.range(10:20, 3)
vbin.range <- function(x, n){
  x.bin <- seq(floor(min(x)), ceiling(max(x)), length.out=n+1)
  vbin(x.bin, n, TRUE)[1:n]
}

#' 2D random field binning
#' 
#' Generate a bined matrix given a 2D random field.
#' 
#' @param x,y,z a random field with location vectors (x, y) and value vector z.
#' They must have the same length.
#' @param nx,ny the number of bins in x and y dimension.
#' @param FUN a function to calculate statistics in each 2D bin.
#' @param na Replacemnet for NA value in matrix bins.
#' @return a matrix with row (column) names being the center points of x (y) dim,
#' and with cell value being the aggregate statistics calculated by FUN.
#' @seealso \code{\link{seq_approximate}}, \code{\link{vbin}}, \code{\link{vbin.range}}
#' @export
#' @examples
#' vbin.grid(1:20, 20:1, runif(20), nx=5, ny=5)
vbin.grid <- function(x, y, z, nx, ny, FUN=mean, na=NA){
  if( length(x) != length(y) || length(x) != length(z))
    stop("Input x, y, z should be the same legnth.")
  
  # generate binning sequence of x and y
  x.int <- vbin(x, nx)
  y.int <- vbin(y, ny)
  
  # binning matrix statistics
  df <- data.frame(x.int=x.int, y.int=y.int, z=z)
  dfg <- df %>%
    group_by(x.int, y.int) %>%
    dplyr::summarise(z = FUN(z))
  
  mat <- matrix(data=na, nrow=nx, ncol=ny)
  mat[cbind(dfg$x.int, dfg$y.int)] <- dfg$z
  rownames(mat) <- vbin.range(x, nx)
  colnames(mat) <- vbin.range(y, ny)
  mat
}