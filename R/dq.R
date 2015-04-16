## Preprocessing and data quality control utilities

#' Compress movement history
#' 
#' Remove duplicate location records in user's movement history.
#' Continuous records at the same location is merged into a single session
#' (with interval less than `gap`) recording the starting and ending times.
#' 
#' @param x,y,t see params of \code{\link{stcoords}}
#' @param gap the time tolerance (sec) to conbime two continuous observations
#' @export
#' @seealso \code{\link{seq_collapsed}}
#' @examples
#' data(movement)
#' 
#' user_move <- subset(movement, id==1)
#' compress_mov(user_move[,c("loc", "time")])
#' 
#' ## With dplyr
#' data(u10)
#' u10 %>% group_by(usr) %>% do(compress_mov(x=.$site, t=.$time)) %>% filter(usr==10)
compress_mov <- function(x, y=NULL, t=NULL, gap=0.5 * 3600) {
  st = stcoords_1d(x, y, t)
  sx = as.integer(st$sx)
  tt = as.numeric(st$t)
  
  compressed <- as.data.frame(.Call("_compress_mov", sx, tt, gap))
  colnames(compressed) <- c("loc", "stime", "etime")
  
  compressed
}