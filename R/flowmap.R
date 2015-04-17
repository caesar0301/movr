#' Calculate flow stat between locations
#' 
#' @export
flowmap_stat <- function(loc, stime, etime, gap=8*3600) {
  stopifnot(length(loc) == length(stime) && length(loc) == length(etime))
  stopifnot(is.numeric(stime))
  stopifnot(is.numeric(etime))
  
  loc = as.character(loc)
  fstat = .Call("_flow_stat", loc, stime, etime, gap)
  df = as.data.frame(fstat)
  colnames(df) = c("edge", "freq")
  df
}

#' Generate flowmap from movement data
#' 
#' Use historical movement data to generate flowmap, which records mobility
#' statistics between two locations 'from' and 'to'.
#' 
#' @param uid a vector to record user identities
#' @param loc a 1D vector to record locations of movement history
#' @param time the timestamp (SECONDS) vector of movement history
#' @param gap the maximum dwelling time to consider a valid move between locations.
#' @return a data frame with four columns: from, to, total, unique (users)
#' @export
#' @seealso \code{\link{flowmap2}}
#' @examples
#' data(movement)
#' \dontrun{}
#'  with(movement, flowmap(id, loc, time))
#' }
flowmap <- function(uid, loc, time, gap=8*3600) {
  
  # remove duplicated info in user movement hisotry
  compressed <- data.frame(uid=uid, loc=loc, time=time) %>%
    dplyr::group_by(uid) %>%
    dplyr::do(compress_mov(x=.$loc, t=.$time))
  
  fmap <- compressed %>%
    group_by(uid) %>%
    dplyr::do( flowmap_stat(.$loc, .$stime, .$etime, gap)) %>%
    group_by(edge) %>%
    dplyr::summarise(
      total = sum(freq),
      unique = length(unique(uid))) %>%
    separate(edge, c("from", "to"), sep="->")
  
  fmap
}