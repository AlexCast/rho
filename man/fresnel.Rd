% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/snell_fresnel.R
\name{fresnel}
\alias{fresnel}
\title{Calculate the reflectance at a flat interface}
\usage{
fresnel(thetai, thetar, ni, nr, fp = 0.5, ave = FALSE)
}
\arguments{
\item{thetai}{Incidence angle relative to the normal of the interface between
the two mediums (radians).}

\item{thetar}{Refracted angle relative to the normal of the interface between
the two mediums (radians). If missing, function \code{snell} 
will be called internally.}

\item{ni}{Refractive index of the medium of incidence (unitless).}

\item{nr}{Refractive index of the medium of refraction (unitless).}

\item{fp}{Fraction of parallel polarization (unitless).}

\item{ave}{Logical. Should the reflections for S and P polarizations be 
returned separately?}
}
\value{
A numeric vector if average reflectance is desired or a matrix with
the reflectance for parallel (R_p) and perpendicular polarizations (R_s).
}
\description{
The function calculates the reflectance, i.e., the squared modulus of the 
(complex) amplitude reflection coefficient, of (polarized) electromagnetic 
radiation incident at a flat interface.
}
\details{
Uses Fresnel's formulations to calculate the reflectance based on 
the incident and (complex) refracted angles and the (complex) indexes of 
refraction. \code{NA}s allowed in all arguments.

If \code{ave} is set to TRUE, the weighted average reflectance will be 
calculated, with the weights of each polarization given by \code{fp}.
}
\examples{
# Reflection from standard dry air to average seawater at 550 nm:
fresnel(thetai = c(0, pi/4, pi/2), ni = 1.000278, nr = 
complex(real = 1.342033, imaginary = 2.442E-09), ave = TRUE)

}
\references{
Bohren, C. F.; Huffman, D. R. 1983. Absorption and Scattering of Light by 
Small Particles. Wiley, New York.
}
\seealso{
\code{\link{snell}}, \code{\link{snell_decomp}}
}
