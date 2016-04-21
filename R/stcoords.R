#' Spatiotemporal data formatting
#' 
#' Format spatiotemporal series in a unified manner for both 1D and 2D locations.
#' If \code{x} is a data frame or matrix, \code{y} and \code{t} are omitted.
#' 
#' If \code{x} is a data frame (3 columns), this function automatically identify spatial
#' and temporal values by column names, i.e., (x,y,t) and (lat,lon,time).
#' Otherwise, the column indexes are employed as [, 1] and [, 2] being the space
#' coordinates and [, 3] being the timestamps.
#' 
#' If \code{x} is a data frame (2 columns), similar policies are involved, but
#' alternatively column names (x, t) and (loc, time) are used.
#' 
#' If \code{x} is a matrix, column indexes are used merely.
#' 
#' If \code{x} is a vector, dimensions of space coordinates are determined
#' by both \code{x} and \code{y}, and the time dimension by \code{t}.
#' 
#' @param x A vector, data frame or matrix.
#' @param y A vector.
#' @param t A vector.
#' @seealso \code{\link{stcoords_1d}}
#' @export
#' @examples
#' ## One data frame with columes x, y, t
#' x <- data.frame(x=rep(1:10, 2), y=rep_each(1:10, 2), t=1:20)
#' stcoords(x)
#' 
#' ## One data frame without demanded colume names
#' x <- data.frame(rep(1:10, 2), rep_each(1:10, 2), 1:20)
#' 
#' ## One data frame with two columes loc, time
#' x <- data.frame(loc=rep(1:10, 2), time=1:20)
#' 
#' ## With vectors
#' stcoords(x=rep(1:10, 2), t=1:20)
stcoords <- function(x, y=NULL, t=NULL) {
  coords <- list()
  coords[['is_1d']] = FALSE
  
  if ( is.matrix(x) ){
    x = as.data.frame(x)
  }
  
  if ( is.data.frame(x) ) {
    if (ncol(x) == 2) { # 1D location index
      coords[['is_1d']] = TRUE
      if ( all(c('x', 't') %in% colnames(x)) ){
        coords[['sx']] = x[, 'x']
        coords[['t']] = x[, 't']
      } else if (all(c('loc', 'time') %in% colnames(x))) {
        coords[['sx']] = x[, 'loc']
        coords[['t']] = x[, 'time']
      } else {
        coords[['sx']] = x[, 1]
        coords[['t']] = x[, 2]
      }
    } else if ( ncol(x) == 3 ) { # 2D space coordincates
      if ( all(c('x', 'y', 't') %in% colnames(x)) ) {
        coords[['sx']] = x[, 'x']
        coords[['sy']] = x[, 'y']
        coords[['t']] = x[, 't']
      } else if (all(c('lon', 'lat', 'time') %in% colnames(x))) {
        coords[['sx']] = x[, 'lon']
        coords[['sy']] = x[, 'lat']
        coords[['t']] = x[, 'time']
      } else {
        coords[['sx']] = x[, 1]
        coords[['sy']] = x[, 2]
        coords[['t']] = x[, 3]
      }
    }
  } else if (is.vector(x)) {
    stopifnot( !is.null(t) || length(t)!=length(x))
    coords[['sx']] = x
    coords[['t']] = t
    coords[['is_1d']] = TRUE
    
    if ( !is.null(y) ) {
      stopifnot( length(y) == length(x) )
      coords[['sy']] = y
      coords[['is_1d']] = FALSE
    }
  } else {
    stop("Invalid spatiotemporal data to format.")
  }
  
  # return formated coordinates
  coords
}


#' Spatiotemporal data formatting (1D)
#' 
#' Similar to \code{\link{stcoords}}, return location instead of x, y coordinates.
#' 
#' @param x,y,t params of \code{stcoords}
#' 
#' @seealso \code{\link{stcoords}}
#' @export
#' @examples
#' x <- data.frame(rep(1:10, 2), rep_each(1:10, 2), 1:20)
#' stcoords_1d(x)
stcoords_1d <- function(x, y=NULL, t=NULL) {
  st <- stcoords(x, y, t)
  if ( ! st$is_1d ) {
    df <- data.frame(st$sx, st$sy) %>%
      tidyr::unite(loc, c(1, 2))
    st$sx <- df$loc
    st$sy <- NULL
    st$is_1d <- TRUE
  }
  st
}


#' Convert degrees to radians.
#' @param deg A number or vector of degrees.
#' @seealso \code{\link{rad2deg}}
#' @export
deg2rad <- function(deg) { deg * pi / 180 }


#' Convert radians to degrees.
#' @param rad A number or vector of radians
#' @seealso \code{\link{deg2rad}}
#' @export
rad2deg <- function(rad) { rad * 180 / pi }


#' Geopoint and Cartesian conversion
#' 
#' Converting geo-points in lat/long into Cartesian coordinates.
#' 
#' @param x A 2D vector (lat, long) representing the geo-point in degrees.
#' @return A unit-length 3D vector (x, y, z) in Cartesian system.
#' @seealso \code{\link{geo2cart.radian}}, \code{\link{cart2geo}}
#' @export
#' @examples
#' geo2cart(c(30, 120))
geo2cart <- function(x) {
  if ( x[1] < -90 || x[1] > 90 || x[2] < -180 || x[2] > 180) {
    stop("Invalid lat/long coordinates.")
  }
  lat <- deg2rad(x[1])
  lon <- deg2rad(x[2])
  geo2cart.radian(c(lat, lon))
}


#' Convert geopoints in radians to Cartesian coordinates.
#' @param x A 2D vector (lat, long) representing the geo-point in radians.
#' @seealso \code{\link{cart2geo.radian}}
#' @export
geo2cart.radian <- function(x) {
  p.x <- cos(x[1]) * cos(x[2])
  p.y <- cos(x[1]) * sin(x[2])
  p.z <- sin(x[1])
  c(p.x, p.y, p.z)
}


#' Cartesian and geopoint conversion
#' 
#' Converting Cartesian coordinates into long/lat geo-points.
#' 
#' @param x A unit-length 3D vector (x, y, z) in Cartesian system.
#' @return A 2D vector (lat, long) representing the geo-point in degree.
#' @seealso \code{\link{geo2cart}}, \code{\link{cart2geo.radian}}
#' @export
#' @examples
#' cart2geo(c(-0.4330127, 0.7500000, 0.5000000))
cart2geo <- function(x) {
  p <- cart2geo.radian(x)
  c(rad2deg(p[1]), rad2deg(p[2]))
}


#' Convert Cartesian coordinates to geopoints in radians.
#' @param x A 2D vector (lat, long) representing the geo-point in radians.
#' @seealso \code{\link{geo2cart.radian}}
#' @export
cart2geo.radian <- function(x) {
  lon = atan2(x[2], x[1])
  hyp = sqrt(x[1]^2 + x[2]^2)
  lat = atan2(x[3], hyp)
  c(lat, lon)
}