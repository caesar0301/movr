# Utility funcitons used by movr package
# By Xiaming Chen <chenxm35@gmail.com>

# Rotate a matrix by 90 degree
#' @export
rot90 <- function(m) t(m)[,nrow(m):1]


#' Root Mean Squared Error (RMSE)
#' 
#' calculate the root mean squared error (RMSE) of two vectors.
#' 
#' @param x A given vector to calculate RMSE.
#' @param y The target vector
#' @export
#' @examples
#' RMSE(c(1,2,3,4), c(2,3,2,3))
RMSE <- function(x, y){
  if( !(class(x) == class(y)
        & class(x) %in% c("matrix", "numeric")) ) {
    stop("The input should be matrix or vector")
  }
  
  x = c(x); y = c(y)
  sqrt(mean((x-y)^2))
}


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


#' Melt time into parts
#' 
#' @param epoch the UNIX epoch timestamp in seconds
#' @param tz the time zone string
#' @return several fields (indexed by order) of given timestamp:
#'  year, month, day, hour, minute, second,
#'  day of week (dow),
#'  day of year (doy),
#'  week of month (wom),
#'  week of year (woy),
#'  quarter of year (qoy)
#' @export
melt_time <- function(epoch, tz='Asia/Shanghai') {
  pt <- as.POSIXct(epoch, origin="1970-01-01", tz=tz)
  year = format(pt, "%Y")
  month = format(pt, "%m")
  day = format(pt, "%d")
  hour = format(pt, "%H")
  minute = format(pt, "%m")
  second = format(pt, "%S")
  dow = format(pt, "%a")
  doy = format(pt, "%j")
  wom = ceiling(as.numeric(day) / 7)
  woy = format(pt, "%V")
  qoy = quarters(pt, abbr=T)
  list(year=year, month=month, day=day, hour=hour, minute=minute, second=second,
       dow=dow, doy=doy, wom=wom, woy=woy, qoy=qoy)
}