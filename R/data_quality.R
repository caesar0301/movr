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
#' u1 <- movement %>% dplyr::filter(id==1)
#' dq.iovan(stcoords(u1[, c('lon','lat','time')]))
dq.iovan <- function(stcoords) {
  dat <- stcoords
  torder <- order(dat$t)
  x <- dat$x[torder]
  y <- dat$y[torder]
  t <- dat$t[torder]
  L <- length(t)
  d <- sapply(1:(L-1), function(i) {
    gcd(c(y[i], x[i]), c(y[i+1], x[i+1]))
  })
  delta.t <- t[2:L] - t[1:L-1]
  # Speed index
  theta <- atan(d/delta.t)
  # Uncertainty
  U <- delta.t / cos(theta)
  # Quanlity indicator for each point
  Q <- exp(-theta * 2 / pi * U)
  # Entropic quality indicator for a user
  H <- -sum(Q * log2(Q)) / L
  list(theta=c(0, theta), U = c(1, U), Q=c(1, Q), H=H)
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
  oo$occur.r <- standardize(oo$occur)
  oo
}


# Spatiotemporal data quality indicator of statics
dq.point.static <- function(sessions, pc, po) {
  stopifnot(all(c('x', 'y', 'stime', 'etime') %in% colnames(sessions)))
  stopifnot(all(c('x', 'y') %in% colnames(pc)))
  ## Add coverage and people occurrence statistics
  sessions$x <- as.numeric(sessions$x)
  sessions$y <- as.numeric(sessions$y)
  sessions <- sessions %>%
    left_join(pc, by=c("x"="x", "y"="y")) %>%
    left_join(po, by=c("x"="x", "y"="y"))
  sessions$dur <- sessions$etime - sessions$stime
  sessions$area.r <- standardize(sessions$area.r)
  ## Recalculate duration at each stay point
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
  ## Calculate dynamics data quality
  D <- log(sessions$dur2 / 3600 / 24 + 1)
  S <- sessions$area.r
  rho <- sessions$occur.r
  Q <- 2 / pi * atan(D/S/sqrt(rho))
  sessions$dq <- Q
  sessions
}

# Spatiotemporal data quality indicator of dynamics
dq.point.dynamic <- function(sessions) {
  stopifnot(all(c('x', 'y', 'stime', 'etime') %in% colnames(sessions)))
  # Use Iovan's algorithm to calculate the dynamic indicator
  sessions$x <- as.numeric(sessions$x)
  sessions$y <- as.numeric(sessions$y)
  t <- (sessions$etime + sessions$stime) / 2.0
  ddd <- dq.iovan(stcoords(sessions$x, sessions$y, t))
  sessions$dq <- ddd$Q
  sessions
}


#' Spatiotemporal data quality of stay points
#' @export
#' @seealso \code{\link{dq.point2}}
#' @examples
#' u1 <- movement %>% dplyr::filter(id==1)
#' pc <- point.coverage(movement$lon, movement$lat)
#' po <- people.occurrence(movement$id, movement$lon, movement$lat)
#' 
#' stc <- stcoords(u1[,c('lon','lat','time')])
#' head(dq.point(stc, pc, po))
#' 
#' sessions <- gen.sessions(stc$x, stc$y, stc$t)
#' head(dq.point2(sessions, pc, po))
dq.point <- function(stcoords, pc, po, dq.min=1e-5, na=dq.min) {
  if(stcoords$is_1d)
    stop("Currently only support numeric x,y coordinates")
  sessions <- gen.sessions(stcoords$x, stcoords$y, stcoords$t)
  dq.point2(sessions, pc, po, dq.min, na)
}


#' Spatiotemporal data quality of stay points
#' @export
#' @seealso \code{\link{dq.point}}
dq.point2 <- function(sessions, pc, po, dq.min=1e-5, na=dq.min) {
  stopifnot(all(c('x', 'y', 'stime', 'etime') %in% colnames(sessions)))
  ## Calculate quality indicators of the statics, dynamics
  sss <- dq.point.static(sessions, pc, po)
  ddd <- dq.point.dynamic(sessions)
  ppp <- sss[, c('stime','etime','x','y')]
  ## Calculate combined quality indicator
  sss$dq[is.na(sss$dq)] <- na
  ppp$dq.s <- sss$dq
  ddd$dq[is.na(ddd$dq)] <- na
  ppp$dq.d <- ddd$dq
  ppp$dq <- 2 * (ppp$dq.s * ppp$dq.d) / (ppp$dq.s + ppp$dq.d)
  ppp
}


#' Spatiotemporal data quality of user trajectories
#' @export
#' @seealso \code{\link{dq.traj2}}
#' @examples
#' u1 <- movement %>% dplyr::filter(id==4)
#' pc <- point.coverage(movement$lon, movement$lat)
#' po <- people.occurrence(movement$id, movement$lon, movement$lat)
#' stc <- stcoords(u1[,c('lon','lat','time')])
#' dq.traj(stc, pc, po)
#' dq.traj2(dq.point(stc, pc, po))
dq.traj <- function(stcoords, pc, po) {
  qq <- dq.point(stcoords, pc, po)
  dq.traj2(qq)
}


#' Spatiotemporal data quality of user trajectories
#' @export
#' @seealso \code{\link{dq.traj}}
dq.traj2 <- function(dqPoints) {
  stopifnot(is.data.frame(dqPoints))
  stopifnot('dq' %in% colnames(dqPoints))
  qq <- dqPoints
  N <- length(qq$dq)
  mm <- mean(qq$dq)
  entropy <- function(.v) {
    v <- .v[.v>0]
    -sum(v * log2(v)) / length(v)
  }
  H <- entropy(qq$dq)
  ## TODO: add grid-based quality calculation.
  data.frame(N=N, dq=mm, mean=mm, entropy=H)
}