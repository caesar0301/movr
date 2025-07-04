% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/seq.R
\name{vbin}
\alias{vbin}
\title{Vector binning}
\usage{
vbin(x, n, center = FALSE)
}
\arguments{
\item{x}{a numeric vector}

\item{n}{the number of bins}

\item{center}{indication of representing intervals as index (FALSE, default) or
center points (TRUE).}
}
\value{
Sequence with interval index or center points.
}
\description{
Bin a vector into `n` intervals in regard with its value range.
The vector x is split into n bins within [min(x), max(x)],
and bin index is given by checking the bin [bin_min, bin_max)
into which data points in x fall.
}
\examples{
vbin(1:10, 3)
vbin(1:10, 3, TRUE)
}
\seealso{
\code{\link{seq_approximate}}, \code{\link{vbin.range}}, \code{\link{vbin.grid}}
}
