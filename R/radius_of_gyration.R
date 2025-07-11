#' Radius of gyration for human mobility
#'
#' Given a series of locations denoted by lat/lon coordinates,
#' the radius of gyration for individual is calculated.
#'
#' @param lat,lon The geographic coordinates of locations
#' @param w The weight value for each location
#' @return The radius of gyration (km)
#' @export
#' @references M. C. Gonzalez, C. A. Hidalgo, and A.-L. Barabasi,
#' "Understanding individual human mobility patterns,"
#' Nature, vol. 453, no. 7196, pp. 779-782, Jun. 2008.
#' @examples
#' lat <- c(30.2, 30, 30.5)
#' lon <- c(120, 120.4, 120.5)
#' radius.of.gyration(lat, lon)
#'
#' @seealso \code{\link{midpoint}}
radius.of.gyration <- function(lat, lon, w = rep(1, length(lat))) {
  # get the midpoint of given locations
  mp <- midpoint(lat, lon, w)

  # calculate distance from the midpoint
  diff <- apply(cbind(lat, lon), 1, function(x) gcd(mp, x))

  sqrt(1.0 * sum(diff^2) / length(diff))
}

#' Fast Radius of gyration for human mobility
#'
#' Given a series of locations denoted by lat/lon coordinates,
#' the radius of gyration for individual is calculated.
#'
#' @param lat,lon The geographic coordinates of locations
#' @param w The weight value for each location
#' @return The radius of gyration (km)
#' @export
#' @references M. C. Gonzalez, C. A. Hidalgo, and A.-L. Barabasi,
#' "Understanding individual human mobility patterns,"
#' Nature, vol. 453, no. 7196, pp. 779-782, Jun. 2008.
#' @examples
#' lat <- c(30.2, 30, 30.5)
#' lon <- c(120, 120.4, 120.5)
#' fast.radius.of.gyration(lat, lon)
#'
#' @seealso \code{\link{midpoint}}
fast.radius.of.gyration <- function(lat, lon, w = rep(1, length(lat))) {
  deg2rad <- pi / 180
  earth_radius_km <- 6371.0

  lat_rad <- lat * deg2rad
  lon_rad <- lon * deg2rad

  x_coord <- cos(lat_rad) * cos(lon_rad)
  y_coord <- cos(lat_rad) * sin(lon_rad)
  z_coord <- sin(lat_rad)

  total_weight <- sum(w)
  center_x <- sum(w * x_coord) / total_weight
  center_y <- sum(w * y_coord) / total_weight
  center_z <- sum(w * z_coord) / total_weight

  center_norm <- sqrt(center_x^2 + center_y^2 + center_z^2)
  center_x <- center_x / center_norm
  center_y <- center_y / center_norm
  center_z <- center_z / center_norm

  # great‐circle angular distances
  dot_vals <- pmin(
    pmax(x_coord * center_x + y_coord * center_y + z_coord * center_z, -1),
    1
  )
  angles_rad <- acos(dot_vals)

  # squared distances in km2 and final radius
  dist_sq <- (earth_radius_km * angles_rad)^2
  rg_km <- sqrt(sum(w * dist_sq) / total_weight)

  return(rg_km)
}

#' Turbo Radius of gyration for human mobility
#' @export
turbo.radius.of.gyration <- function(lat, lon, w = rep(1, length(lat))) {
  if (!is.double(lat)) {
    lat <- as.double(lat)
  }
  if (!is.double(lon)) {
    lon <- as.double(lon)
  }
  if (!is.double(w)) {
    w <- as.double(w)
  }
  .Call("_radius_of_gyration", lat, lon, w, PACKAGE = "movr")
}
