% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Bus_delays.R
\docType{data}
\name{Bus_delays}
\alias{Bus_delays}
\title{School bus delays in New York City}
\format{
A data.frame object with one row for each of 238,266 bus-delay
incidents in New York City.
\itemize{
\item \code{breakdown_id}: A unique (almost) id number for each incident
\item \code{year} the school year of the incident
\item \code{route_name} the name of the bus route
\item \code{delay_duration} how long (minutes) the delay lasted
\item \code{pre_k} whether the bus was for Pre-kindergarden students. If not, it was for elementary
school students. (Older students ride the city bus in NYC.)
\item \code{reason} an explanation of the cause of the delay
\item \code{boro} which of the jurisdictions of the NYC area the delay occurred in.
\item \code{n_students} how many student passengers were on the bus when the delay occurred.
\item \code{company} the name of the company operating the bus
\item \code{date} the date of the incident
}
}
\source{
The data themselves were scraped from the New York City OpenData site,
\url{https://data.cityofnewyork.us/Transportation/Bus-Breakdown-and-Delays/ez4e-fazm} on Dec. 13, 2018.
The data was brought to the author's attention on a blog written by Nils Ross \url{https://datascienceplus.com/nyc-bus-delays/}. Much
of the code used to clean the data was copied from that blog post.
}
\usage{
data(Bus_delays)
}
\description{
School bus delays in New York City
}
\details{
The data have been lightly cleaned from their original form as a CSV file. 305 rows from the original
data were removed: those with a number of passengers greater than 48. (These were presumably
data-entry errors since a common legal limit for bus passengers is 48.)
}
\keyword{datasets}
