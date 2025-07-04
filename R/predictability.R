#' Major concepts, tools and visualization in the predictability paper.
#'  Song, C. et al., Limits of predictability in human mobility.
#'  Science 2010, 1018. (doi:10.1126/science.1177170)

#' Mobility entropy
#' 
#' In Song's paper, three kinds of entropy are involved to investigate
#' the predictability of human mobility, i.e., random entropy \eqn{S^{rand}},
#' spatial entropy \eqn{S^{unc}} and spatio-temproal entropy \eqn{S_i}.
#' 
#' @param N The number of unique locations.
#' @return The entropy value in bits.
#' @seealso \code{\link{entropy.space}}, \code{\link{entropy.spacetime}}
#' @references
#'  Song, C. et al., Limits of predictability in human mobility.
#'  Science 2010, 1018. (doi:10.1126/science.1177170)
#' @export
entropy.rand <- function(N) {
  log2(N)
}

#' Mobility entropy
#' 
#' In Song's paper, three kinds of entropy are involved to investigate
#' the predictability of human mobility, i.e., random entropy \eqn{S^{rand}},
#' spatial entropy \eqn{S^{unc}} and spatio-temproal entropy \eqn{S_i}.
#' 
#' @param probs A vector of probability to find the person in unique locations.
#' @return The entropy value in bits.
#' @seealso \code{\link{entropy.rand}}, \code{\link{entropy.spacetime}}
#' @references
#'  Song, C. et al., Limits of predictability in human mobility.
#'  Science 2010, 1018. (doi:10.1126/science.1177170)
#' @export
#' @examples
#' p <- c(0.1, 0.3, 0.5, 0.1)
#' entropy.space(p)
entropy.space <- function(probs) {
  -sum(probs * log2(probs))
}

#' Mobility entropy
#' 
#' In Song's paper, three kinds of entropy are involved to investigate
#' the predictability of human mobility, i.e., random entropy \eqn{S^{rand}},
#' spatial entropy \eqn{S^{unc}} and spatio-temproal entropy \eqn{S_i}.
#' 
#' @param x,y A chronologically ordered sequence of visited locations. The sequence
#'  is given by a vector (e.g. location names) or two vectors of location coordinates
#'  (e.g., latitude and longitude values).
#' @return The entropy value in bits.
#' @seealso \code{\link{entropy.rand}}, \code{\link{entropy.space}}
#' @references
#'  Song, C. et al., Limits of predictability in human mobility.
#'  Science 2010, 1018. (doi:10.1126/science.1177170)
#' @export
entropy.spacetime <- function(x, y=NULL) {
  stop('Unsupported right now.')
}

# entropy_estimated <- function(x, y=NULL) {
#   
# }
# 
# lempel_ziv <- function(S) {
#   
# }
# 
# predictability <- function() {
#   
# }
# 
# regularity <- function() {
#   
# }