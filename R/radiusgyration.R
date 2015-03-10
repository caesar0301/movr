#' Radius of gyration for human mobility
#' 
#' Given a series of locations denoted by lat/lon coordinates,
#' the radius of gyration for individual is calculated.
#' 
#' @param lat,lon The geographic coordinates of locations
#' @param w The weight value for each location
#' @return The radius of gyration (km)
#' @export
#' @references M. C. González, C. A. Hidalgo, and A.-L. Barabási,
#' "Understanding individual human mobility patterns,"
#' Nature, vol. 453, no. 7196, pp. 779–782, Jun. 2008.
#' @examples
#' lat <- c(30.2, 30, 30.5)
#' lon <- c(120, 120.4, 120.5)
#' radius.gyration(lat, lon)
#' 
radius.gyration <- function(lat, lon, w=rep(1, length(lat))) {
  # get the midpoint of given locations
  mp <- midpoint(lat, lon, w)
  
  # calculate distance from the midpoint
  diff <- apply(cbind(lat, lon), 1, function(x) gcd(mp, x))
  
  sqrt(1.0 * sum(diff^2) / length(diff))
}