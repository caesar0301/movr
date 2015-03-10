#' Geographic midpoint calculation
#' 
#' Calculate the midpoint given a list of locations denoted by
#' latitude and longitude coordinates.
#' 
#' @param lat,lon The location points
#' @param w The weighted value for each point
#' @return The geographic midpoint in lat/lon
#' @export
#' @references \url{http://www.geomidpoint.com/calculation.html}
#' @examples
#' lat <- c(30.2, 30, 30.5)
#' lon <- c(120, 120.4, 120.5)
#' 
#' # equal weight
#' midpoint(lat, lon)
#' 
#' # custom weight
#' w <- c(1, 2, 1)
#' midpoint(lat, lon, w)
midpoint <- function(lat, lon, w=rep(1, length(lat))) {
  if (length(lat) != length(lon) || length(lat) != length(w)) {
    stop("The lat, lon and weight vectors should be the same length")
  }
  
  df <- data.frame(lat=deg2rad(lat), lon=deg2rad(lon), w=w)
  
  # convert geographic to cartesian points
  df$x <- cos(df$lat) * cos(df$lon)
  df$y <- cos(df$lat) * sin(df$lon)
  df$z <- sin(df$lat)
  total.weight <- sum(df$w)
  
  # calculate weighted midpoint
  m.x <- 1.0 * sum(df$x * df$w) / total.weight
  m.y <- 1.0 * sum(df$y * df$w) / total.weight
  m.z <- 1.0 * sum(df$z * df$w) / total.weight
  
  # convert cartesian to geographic point
  cart2geo(c(m.x, m.y, m.z))
}