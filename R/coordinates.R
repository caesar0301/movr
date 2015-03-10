# Funcitons about coordinates' conversion used by movr package
# By Xiaming Chen <chenxm35@gmail.com>

#' @export
deg2rad <- function(deg) { deg * pi / 180 }

#' @export
rad2deg <- function(rad) { rad * 180 / pi }

#' Geopoint and Cartesian conversion
#' 
#' Converting geo-points in lat/long into Cartesian coordinates.
#' 
#' @param x A 2D vector (lat, long) representing the geo-point in degree.
#' @return A unit-length 3D vector (x, y, z) in Cartesian system.
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
#' @export
#' @examples
#' cart2geo(c(-0.4330127, 0.7500000, 0.5000000))
cart2geo <- function(x) {
  p <- cart2geo.radian(x)
  c(rad2deg(p[1]), rad2deg(p[2]))
}

#' @export
cart2geo.radian <- function(x) {
  lon = atan2(x[2], x[1])
  hyp = sqrt(x[1]^2 + x[2]^2)
  lat = atan2(x[3], hyp)
  c(lat, lon)
}