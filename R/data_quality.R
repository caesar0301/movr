#' Spatiotemporal data quality of Iovan's
#' 
#' In this data quality measure, Iovan et al.[1] addressed mobility data quality from both
#' local and global aspects. The local measure quantifies the quality of each data point,
#' which encodes the reasonableness of data mainly with regards to SPEED (or time and distance).
#' The global measure based on informational entropy quantifies the data quality within
#' a whole trajectory. This function implements these measures, which are also referred
#' to as the DYNAMIC quality for mobility data.
#' 
#' @param stcoords The spatiotemporal coordinates, see \code{\link{stcoords}}
#' @param type the selection of distance calculation function: 'lonlat' -> great circle distance
#'  of long/lat pair, 'xy' -> euclidean distance.
#' @return a list of data quality indicators:
#' @return theta the speed index
#' @return Q the unified quality indicator for each data point
#' @return H the entropic quality indicator for each mobility trajectory
#' @references
#' [1] https://doi.org/10.1007/978-3-319-00615-4_14
#' @export
#' @examples
#' u1 <- dplyr::filter(movement, id==1)
#' stc <- stcoords(u1[, c('lon','lat','time')])
#' dq.iovan(stc, type='lonlat')
dq.iovan <- function(stcoords, type='lonlat') {
  ## distance functions
  stopifnot(type %in% c('lonlat', 'xy'))
  fun.g <- gcd
  fun.e <- euc.dist
  FUN <- if(type=='lonlat') fun.g else fun.e
  ## transform
  dat <- stcoords
  torder <- order(dat$t)
  x <- dat$x[torder]
  y <- dat$y[torder]
  t <- dat$t[torder]
  L <- length(t)
  ## calculate distances
  d <- sapply(1:(L-1), function(i) {
    p1 <- c(y[i], x[i])
    p2 <- c(y[i+1], x[i+1])
    FUN(p1, p2)
  })
  ## calculate time period
  delta.t <- t[2:L] - t[1:L-1]
  ## Speed index
  theta <- atan(d/delta.t)
  ## Uncertainty
  U <- delta.t / cos(theta)
  ## Quanlity indicator for each point
  Q <- exp(-theta * 2 / pi * U)
  ## Entropic quality indicator for a user
  H <- -sum(Q * log2(Q)) / L
  list(theta=c(0, theta), Q=c(1, Q), H=H)
}


#' Spatial coverages of stay points.
#' 
#' Calculate the spatial coverage of each data point by employing the Voronoi tesselation
#' (with \code{\link[deldir]{deldir}}). The spatial area is calculated in a Euclidean
#' space. Thus the user should convert long/lat data into Euclidean coordinates before
#' passing into the function.
#' 
#' @param x,y the coordinates of all (unique) stay points in Euclidean space
#' @param type the type of coordinate system: c('lonlat', 'xy')
#' @return a data.frame with four columns:
#' @return x,y input stay points
#' @return area the vector of spatial area (km^2) of each mosaic in Voronoi diagram
#' @return area.r the normalized ratio of log(area).
#' @export 
#' @examples
#' ## Long/lat points
#' head(point.coverage(movement$lon, movement$lat, type='lonlat'))
#' 
#' ## Euclidean points
#' ii <- lonlat2xy(movement$lon, movement$lat)
#' head(point.coverage(ii$x, ii$y, type='xy'))
point.coverage <- function(x, y, type='lonlat') {
  stopifnot(type %in% c('lonlat', 'xy'))
  ori <- data.frame(x=x, y=y)
  ori <- ori[!duplicated(ori), ]
  xy <- if (type=='lonlat') lonlat2xy(ori$x, ori$y) else ori
  dd <- deldir::deldir(xy$x, xy$y)
  summ <- dd$summary
  ori$area <- summ$dir.area
  ori$area.r <- standardize(log(ori$area*1e6))
  ori
}


#' People occurrence at each stay point.
#' 
#' Calculate the identifiability of a person within a stay point's coverage.
#' The identifiability is given via the average number of unique people present
#' in the data. The more occurrence of people, the lower of identifiability to
#' detect a specific person in the coverage.
#' 
#' @param uid a vector of user id
#' @param x,y vectors of user's locations
#' @return a data.frame with columns: uid, x, y, occur, occur.r
#' @return occur the number of unique people detected at a stay point
#' @return occur.r the normalized ratio of occur.
#' @export
#' @examples
#' people.occurrence(movement$id, movement$lon, movement$lat)
people.occurrence <- function(uid, x, y) {
  df <- data.frame(uid, x, y)
  oo <- df %>% dplyr::group_by(x, y) %>% dplyr::summarise(occur = length(unique(uid)))
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
    dplyr::left_join(pc, by=c("x"="x", "y"="y")) %>%
    dplyr::left_join(po, by=c("x"="x", "y"="y"))
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
  D <- standardize(sessions$dur2)
  S <- sapply(sessions$area.r, function(i) max(i, 0.001))
  rho <- sessions$occur / sessions$area * 1.0
  Q <- 2 / pi * atan(D/S/sqrt(rho))
  Q <- exp(-Q)
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
#' 
#' This function gives the local quality metric of spatiotemporal data points.
#' The metric contains two parts of quality information, ie STATIC and DYNAMIC.
#' The STATIC part comes from the spatial and temporal coverage of each point,
#' which quantifies the uncertainty of user whereabouts caused by the intrinsic
#' limitation of measurement method (eg location coverage). The DYNAMIC part
#' gives the quality from dynamic information like speed, which uses the
#' Iovan's algorithm as addressed in \code{\link{dq.iovan}}.
#' 
#' @param stcoords the spatiotemporal coordinates, see \code{\link{stcoords}}
#' @param pc the point coverage, see \code{\link{point.coverage}}
#' @param po the occurrence of people, see \code{\link{people.occurrence}}
#' @param dq.min the lower bound of data quality. Values less than this bound
#'  will be set by force to this quality (default 1e-5)
#' @param na the replacement of NA (default dq.min)
#' @return the original sessions with extra fields: c('dq.s', 'dq.d', 'dq'). `dq.s`
#'  and `dq.d` give the STATIC and DYNAMIC quality measures respectively, while
#'  `dq` is the Harmonic mean of previous two.
#' @export
#' @seealso \code{\link{dq.point2}}
#' @examples
#' u1 <- dplyr::filter(movement, id==1)
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
#' 
#' This is the inner implementation of \code{\link{dq.point}}. Differently,
#' this function accepts the session data generated by \code{\link{gen.sessions}},
#' or external utilities.
#' 
#' @param sessions a data.frame of session data generated by \code{\link{gen.sessions}}
#'  or external tools. Four columns are required: c('stime', 'etime', 'x', 'y')
#' @param pc the point coverage, see \code{\link{point.coverage}}
#' @param po the occurrence of people, see \code{\link{people.occurrence}}
#' @param dq.min the lower bound of data quality. Values less than this bound
#'  will be set by force to this quality (default 1e-5)
#' @param na the replacement of NA (default dq.min)
#' @return as the return of \code{\link{dq.point}}
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
  sss$dq[sss$dq < dq.min] <- dq.min
  ddd$dq[is.na(ddd$dq)] <- na
  ddd$dq[ddd$dq < dq.min] <- dq.min
  ppp$dq.s <- sss$dq
  ppp$dq.d <- ddd$dq
  ppp$dq <- 2 * (ppp$dq.s * ppp$dq.d) / (ppp$dq.s + ppp$dq.d)
  ppp
}


#' Spatiotemporal data quality of user trajectory
#' 
#' This function calculates the data quality of a user's trajectory. The measure
#' is quantifies with heterogeneity of spatiotemporal data points, as obtained
#' via a grid-based optimal searching algorithm.
#' @param stcoords the spatiotemporal coordinates, see \code{\link{stcoords}}
#' @param pc the point coverage, see \code{\link{point.coverage}}
#' @param po the occurrence of people, see \code{\link{people.occurrence}}
#' @return a data.frame of data qualities for each user.
#' @return N the number of data points in a trajectory
#' @return dq the data quality of a given trajectory
#' @return mean the average data quality of stay points
#' @return entropy the informative entropy of point data qualities
#' @seealso \code{\link{dq.traj2}}
#' @export
#' @examples
#' u1 <- dplyr::filter(movement, id==4)
#' pc <- point.coverage(movement$lon, movement$lat)
#' po <- people.occurrence(movement$id, movement$lon, movement$lat)
#' stc <- stcoords(u1[,c('lon','lat','time')])
#' 
#' dq.traj(stc, pc, po)
#' dq.traj2(dq.point(stc, pc, po))
dq.traj <- function(stcoords, pc, po) {
  qq <- dq.point(stcoords, pc, po)
  dq.traj2(qq)
}


#' Spatiotemporal data quality of user trajectory
#' 
#' The inner implementation of algorithm in \code{\link{dq.traj}}.
#' 
#' @param dqPoints the data quality returned by \code{\link{dq.point}}
#' @return as the return of \code{\link{dq.traj}}
#' @seealso \code{\link{dq.traj}}
#' @export
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