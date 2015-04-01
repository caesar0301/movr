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