#' Spatiotemporal data quality indicators of Iovan
#' 
#' In the paper, Iovan et al.[1] addressed user sampling issues from local and global
#' aspects, respectively. The local measures quantify the quality of each observation
#' point for each individual, which include speed index (theta), uncertainty (U),
#' and a unified quality indicator (Q) based of previous two metrics. The global measure (H)
#' quantifies the data quality for a whole trajectory, by considering the information entropy
#' of a vector of quality indicators (Q).
#' 
#' @param x,y,t input for \code{\link{stcoords}}. If x and y represent longitude and
#' latitude respectively, please make sure that longitude is located as the first param.
#' @return theta the speed index
#' @return U the uncertainty
#' @return Q the unified quality indicator for each data point
#' @return H the entropic quality indicator for each user
#' @export
#' @references
#' [1] https://doi.org/10.1007/978-3-319-00615-4_14
#' @examples
#' user <- movement %>% dplyr::filter(id==1)
#' dq.point.dynamic(user$lon, user$lat, user$time/3600)
dq.point.dynamic <- function(x, y, t) {
  dat <- stcoords(x, y, t)
  torder <- order(dat$t)
  x <- dat$sx[torder]
  y <- dat$sy[torder]
  t <- dat$t[torder]
  L <- length(t)
  d <- sapply(1:(L-1), function(i) {
    gcd(c(y[i], x[i]), c(y[i+1], x[i+1]))
  })
  delta.t <- t[2:L] - t[1:L-1]
  
  # Speed index
  theta <- atan(d / delta.t)
  
  # Uncertainty
  U <- delta.t / cos(theta)
  
  # Quanlity indicator for each point
  Q <- exp(-theta * 2 / pi * U)
  
  # Entropic quality indicator for a user
  H <- -sum(Q * log2(Q)) / L
  
  invisible(list(theta=theta, U=U, Q=Q, H=H))
}

dq.point.static <- function(x, y, t, area.map) {
  
}

dq.point <- function(x, y, t) {
  
}

dq.traj <- function(x, y, t) {
  
}