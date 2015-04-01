#' Geographic area checking
#' 
#' Check if the given lon-lat pair falls into specific area.
#' The area is a 4-length vector with lon-lat pairs of two points that
#' confine the area boundaries.
#' @param lon,lat The point to be checked.
#' @param area The area defined by two points c(lon1, lat1, lon2, lat2).
#' @export
#' @examples
#' in_area(120.1, 30.1, c(120.0,30.0,120.5,30.5))
in_area <- function(lon, lat, area){
  lon1 <- area[1]; lat1 <- area[2]
  lon2 <- area[3]; lat2 <- area[4]
  lons <- sort(c(lon1, lon2))
  lats <- sort(c(lat1, lat2))
  (lon >= lons[1] & lon <= lons[2] & lat >= lats[1] & lat <= lats[2])
}

#' @export
euc_dist <- function(x1, x2) sqrt(sum((x1 - x2) ^ 2))

# pseudo spatiotemporal data generator
.pseudo_movement <- function() {
  data.frame(x=rep(1:10, 5), y=rep_each(1:10, 5), t=1:50)
}