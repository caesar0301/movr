# Utility funcitons used by movr package
# By Xiaming Chen <chenxm35@gmail.com>

# Rotate a matrix by 90 degree
#' @export
rot90 <- function(m) t(m)[,nrow(m):1]