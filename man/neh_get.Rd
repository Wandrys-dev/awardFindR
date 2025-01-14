% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/neh.R
\name{neh_get}
\alias{neh_get}
\title{Get relevant awards from NEH}
\usage{
neh_get(keywords, from_year, to_year)
}
\arguments{
\item{keywords}{Vector of strings to search for in the project description}

\item{from_year}{Beginning year to search}

\item{to_year}{Ending year to search}
}
\value{
A raw data.frame with the relevant results from NEH
}
\description{
Get relevant awards from NEH
}
\examples{
neh <- neh_get(c("focus groups", "ethnography"), 2018, 2020)
}
