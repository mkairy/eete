% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cpiee.R
\name{cpiee}
\alias{cpiee}
\title{Calculate values of Constant Protected Income Elasticity Evaluations (CPIEE)}
\usage{
cpiee(x, eta, c)
}
\arguments{
\item{x}{A numeric value or list.}

\item{eta}{The value of eta.}

\item{c}{The value of c.}
}
\value{
A numeric or list of return values from the CPIEE utility function.
}
\description{
This function calculates the value of \eqn{g(x) = \frac{(\ln\frac{x}{c})^{1-\eta}}{1-\eta}} given a value for \eqn{\eta \geq 0} and \eqn{\eta \neq 1} or will calculate the value of \eqn{\ln\frac{x}{c}} given a value \eqn{\eta = 1}.
}
