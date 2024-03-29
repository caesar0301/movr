% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/seq.R
\name{seq_distinct}
\alias{seq_distinct}
\title{Sequencing by distinct values}
\usage{
seq_distinct(v)
}
\arguments{
\item{v}{A vector to generate integer sequence}
}
\description{
Generate a new (integer) sequence according to distinct value levels.
The same value takes a unique order number.
}
\examples{
seq_along(c(1,2,3,2))
seq_distinct(c(1,2,3,2))
}
\seealso{
\code{\link{seq_along}}, \code{\link{seq_collapsed}},
   \code{\link{vbin}}, \code{\link{vbin.range}}, \code{\link{vbin.grid}}
}
