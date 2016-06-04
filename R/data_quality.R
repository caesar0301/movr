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
#' @return Q the unified quality indicator for each data point
#' @return H the entropic quality indicator for each user
#' 
#' @export
#' @references
#' [1] https://doi.org/10.1007/978-3-319-00615-4_14
#' 
#' @examples
#' user <- movement %>% dplyr::filter(id==1)
#' dq.iovan(user$lon, user$lat, user$time/3600)
dq.iovan <- function(x, y, t) {
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
  
  list(Q=c(1, Q), H=H)
}

#' Spatiotemporal data quality indicator of dynamics
#' @export
#' @examples
#' u1 <- movement %>% dplyr::filter(id==1)
#' head(dq.point.dynamic(u1$lon, u1$lat, u1$time))
dq.point.dynamic <- function(x, y, t) {
  stc <- stcoords(x, y, t)
  sessions <- gen.sessions(stc$sx, stc$sy, stc$t)
  sessions$x <- as.numeric(sessions$x)
  sessions$y <- as.numeric(sessions$y)
  t <- (sessions$etime + sessions$stime) / 2.0
  ddd <- dq.iovan(sessions$x, sessions$y, t)
  sessions$dq <- ddd$Q
  sessions
}

#' Calculate the coverage of each stay point according to Voronoi tesselation.
#' @export
#' @examples 
#' head(point.coverage(movement$lon, movement$lat))
point.coverage <- function(x, y) {
  dd <- deldir(x, y)
  summ <- dd$summary
  aaa <- data.frame(x=summ$x, y=summ$y, area=summ$dir.area)
  aaa$area.r <- standardize(aaa$area)
  aaa
}

#' Calculate the ocurrence of unique people at each stay point.
#' @export
#' @examples
#' people.occurrence(movement$id, movement$lon, movement$lat)
people.occurrence <- function(uid, x, y) {
  df <- data.frame(uid, x, y)
  oo <- df %>% group_by(x, y) %>% summarise(occur = length(unique(uid)))
  print(oo)
  oo$occur.r <- standardize(oo$occur)
  oo
}

#' Spatiotemporal data quality indicator of statics
#' @export
#' @examples
#' u1 <- movement %>% dplyr::filter(id==1)
#' pc <- point.coverage(u1$lon, u1$lat)
#' po <- people.occurrence(movement$id, movement$lon, movement$lat)
#' head(dq.point.static(u1$lon, u1$lat, u1$time, pc, po))
dq.point.static <- function(x, y, t, pc, po) {
  stopifnot(all(c('x', 'y') %in% colnames(pc)))
  stc <- stcoords(x, y, t)
  sessions <- gen.sessions(stc$sx, stc$sy, stc$t)
  sessions$x <- as.numeric(sessions$x)
  sessions$y <- as.numeric(sessions$y)
  sessions <- sessions %>%
    left_join(pc, by=c("x"="x", "y"="y")) %>%
    left_join(po, by=c("x"="x", "y"="y"))
  sessions$dur <- sessions$etime - sessions$stime

  ts <- sessions$stime
  te <- sessions$etime
  dur <- sessions$dur
  L <- nrow(sessions)
  rrr <- sapply(1:(L-1), function(i) {
    if(dur[i] == 0 || dur[i+1] == 0) {
      dd <- (ts[i+1] - te[i]) / 2
      c(dd, dd)
    } else {
      dd <- (ts[i+1] - te[i])
      p1 <- dur[i] / (dur[i] + dur[i+1])
      c(dd * p1, dd * (1 - p1))
    }
  })
  ttt <- t(as.data.frame(rrr))
  sss <- c(ttt[, 1], 0) + c(0, ttt[, 2])
  sessions$dur2 <- sss
  sessions
  
  D <- log(sessions$dur2 / 3600 / 24 + 1)
  S <- sessions$area.r
  rho <- sessions$occur.r
  Q <- 2 / pi * atan(D/S/sqrt(rho))
  sessions$dq <- Q
  sessions
}

#' Spatiotemporal data quality of stay points
#' @export
#' @examples
#' u1 <- movement %>% dplyr::filter(id==1)
#' pc <- point.coverage(u1$lon, u1$lat)
#' po <- people.occurrence(movement$id, movement$lon, movement$lat)
#' head(dq.point(u1$lon, u1$lat, u1$time, pc, po))
dq.point <- function(x, y, t, pc, po) {
  sss <- dq.point.static(x, y, t, pc, po)
  ddd <- dq.point.dynamic(x, y, t)
  ppp <- sss[, c('stime','etime','x','y')]
  ppp$dq.s <- sss$dq
  ppp$dq.d <- ddd$dq
  # ppp$dq <- (ppp$dq.s * ppp$dq.d)
  ppp$dq <- 2 * (ppp$dq.s * ppp$dq.d) / (ppp$dq.s + ppp$dq.d)
  ppp
}

#' Spatiotemporal data quality of user trajectories
#' 
#' TODO: add grid-based quality calculation.
#' @export
#' @examples
#' u1 <- movement %>% dplyr::filter(id==1)
#' pc <- point.coverage(u1$lon, u1$lat)
#' po <- people.occurrence(movement$id, movement$lon, movement$lat)
#' dq.traj(u1$lon, u1$lat, u1$time, pc, po)
dq.traj <- function(x, y, t, pc, po) {
  qq <- dq.point(x, y, t, pc, po)
  mean(qq$dq)
}