#' Compress movement history
#' 
#' Remove duplicate location records in user's movement history.
#' Continuous records at the same location is merged into a single session
#' recording the starting and ending times.
#' 
#' @param x,y,t see params of \code{\link{stcoords}}
#' @export
#' @seealso \code{\link{seq_collapsed}}
#' @examples
#' data(movement)
#' user_move <- subset(movement, id==1)
#' ## 1D location
#' compress_mov(user_move[,c("loc", "time")])
#' ## 2D location
#' compress_mov(user_move[,c("lat", "lon", "time")])
compress_mov <- function(x, y=NULL, t=NULL) {
  st = stcoords_1d(x, y, t)
  
  compressed <- data.frame(loc=st$sx, time=st$t) %>%
    dplyr::arrange(time) %>%
    dplyr::mutate(segment = seq_collapsed(loc)) %>%
    group_by(segment) %>%
    dplyr::summarise(
      loc = unique(loc),
      stime = min(time),
      etime = max(time)
    ) %>%
    dplyr::select(-segment)
  
  compressed
}

# calculate edge stat of flowmap
# TODO: this can be optimized with C implementation
.edge.stat <- function(loc, stime, etime, gap) {
  stopifnot(length(loc) == length(stime) &&
              length(loc) == length(etime))
  df <- data.frame(loc=loc, stime=stime, etime=etime)
  edge <- c()
  
  i = 2
  rlen = nrow(df)
  last_record = df[i-1, ]
  while ( i <= rlen) {
    current_record = df[i, ]
    # add a new edge when temporal contraint is met
    if (current_record[2] - last_record[3] <= gap) {
      edge = c(edge, sprintf("%s->%s", last_record[1], current_record[1]))
    }
    last_record = current_record
    i = i + 1
  }
  
  as.data.frame(table(edge))
}

#' Generate flowmap from movement data
#' 
#' Use historical movement data to generate flowmap, which records mobility
#' statistics between two locations 'from' and 'to'.
#' 
#' @param uid a vector to record user identities
#' @param loc 1D vector to record locations of movement history
#' @param time the timestamp (SECONDS) vector of movement history
#' @param gap the maximum dwelling time to consider a valid move between locations.
#' @return a data frame with four columns: from, to, total, unique (users)
#' @export
#' @examples
#' data(movement)
#' 
#' with(movement[1:2000, ], flowmap(id, loc, time))
flowmap <- function(uid, loc, time, gap=8*3600) {
  
  # remove duplicated info in user movement hisotry
  compressed <- data.frame(uid=uid, loc=loc, time=time) %>%
    group_by(uid) %>%
    dplyr::do(compress_mov(x=.$loc, t=.$time))
  
  # calculate the edge stat
  fmap <- compressed %>%
    group_by(uid) %>%
    dplyr::do( .edge.stat(.$loc, .$stime, .$etime, gap)) %>%
    group_by(edge) %>%
    dplyr::summarise(
      total = sum(Freq),
      unique = length(unique(uid))) %>%
    separate(edge, c("from", "to"), sep="->")
  
  fmap
}