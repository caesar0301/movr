% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/flowmap.R
\name{flowmap}
\alias{flowmap}
\title{Generate flowmap from movement data}
\usage{
flowmap(uid, loc, time, gap = 8 * 3600)
}
\arguments{
\item{uid}{a vector to record user identities}

\item{loc}{a 1D vector to record locations of movement history}

\item{time}{the timestamp (SECONDS) vector of movement history}

\item{gap}{the maximum dwelling time to consider a valid move between locations.}
}
\value{
a data frame with four columns: from, to, total, unique (users)
}
\description{
Use historical movement data to generate flowmap, which records mobility
statistics between two locations 'from' and 'to'.
}
\examples{
data(movement)

res <- with(movement, flowmap(id, loc, time))
head(res)
}
\seealso{
\code{\link{gen.sessions}}, \code{\link{flowmap2}}, \code{\link{flow.stat}},
   \code{\link{plot_flowmap}}
}
