#' Human mobility dataset
#' 
#' A sample dataset containing human mobility data with spatiotemporal coordinates.
#' 
#' @format A data frame with 7509 rows and 4 variables:
#' \describe{
#'   \item{id}{User identifier}
#'   \item{lon}{Longitude coordinate}
#'   \item{lat}{Latitude coordinate}
#'   \item{time}{Timestamp in seconds since UNIX epoch}
#'   \item{loc}{Location identifier}
#' }
#' 
#' @source Sample mobility data for demonstration purposes
#' @docType data
#' @examples
#' data(movement)
#' head(movement)
#' summary(movement)
"movement" 