#' Major concepts, tools and visualization in the predictability paper.
#'  Song, C. et al., Limits of predictability in human mobility.
#'  Science 2010, 1018. (doi:10.1126/science.1177170)

#' Mobility entropies
#' 
#' In Song's paper, three kinds of entorpies are involved to investigate
#' the predictability of human mobility, i.e., random entropy $S^{rand}$,
#' spatial entropy $S^{unc}$ and spatio-temproal entropy $S_i$.
#' 
#' @param N The number of unique locations.
#' @return The entropy value in bits.
#' @seealso \code{\link{entropy_space}}, \code{\link{entropy_spacetime}}
#' @references
#'  Song, C. et al., Limits of predictability in human mobility.
#'  Science 2010, 1018. (doi:10.1126/science.1177170)
#' @export
entropy_rand <- function(N) {
  log2(N)
}

#' Mobility entropies
#' 
#' In Song's paper, three kinds of entorpies are involved to investigate
#' the predictability of human mobility, i.e., random entropy $S^{rand}$,
#' spatial entropy $S^{unc}$ and spatio-temproal entropy $S_i$.
#' 
#' @param probs A vector of probability to find the person in unique locations.
#' @return The entropy value in bits.
#' @seealso \code{\link{entropy_rand}}, \code{\link{entropy_spacetime}}
#' @references
#'  Song, C. et al., Limits of predictability in human mobility.
#'  Science 2010, 1018. (doi:10.1126/science.1177170)
#' @export
#' @examples
#' p <- c(0.1, 0.3, 0.5, 0.1)
#' entropy_space(p)
entropy_space <- function(probs) {
  -sum(probs * log2(probs))
}

#' Mobility entropies
#' 
#' In Song's paper, three kinds of entorpies are involved to investigate
#' the predictability of human mobility, i.e., random entropy $S^{rand}$,
#' spatial entropy $S^{unc}$ and spatio-temproal entropy $S_i$.
#' 
#' @param x,y A chronologically ordered sequence of visited locations. The sequence
#'  is given by a vector (e.g. location names) or two vectors of location coordinates
#'  (e.g., latitude and longitude values).
#' @return The entropy value in bits.
#' @seealso \code{\link{entropy_rand}}, \code{\link{entropy_space}}
#' @references
#'  Song, C. et al., Limits of predictability in human mobility.
#'  Science 2010, 1018. (doi:10.1126/science.1177170)
#' @export
# entropy_spacetime <- function(x, y=NULL) {
#   coord = stcoords(x, y, t=seq_along(x))
# }

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