% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/snell_fresnel.R
\name{snell_decomp}
\alias{snell_decomp}
\title{Decompose a complex refracted angle}
\usage{
snell_decomp(thetar, nr)
}
\arguments{
\item{thetar}{Complex refracted angle (radians).}

\item{nr}{Refractive index of the medium of refraction (unitless).}
}
\value{
A matrix with the constant-phase (theta_kp) and constant-amplitude
(theta_ka) angles.
}
\description{
The function calculates the angle of constant phase and the angle of constant
amplitude for complex refracted angles of eletromagnetic radiation 
transmitted to a medium.
}
\details{
Refractive index of the medium of refraction may be real or complex.
The refracted angle is the angle at constant phase.
}
\examples{
# Refraction from average seawater to standard dry air at 550 nm:
refr <- snell(c(0, pi/4, pi/2), ni = complex(real = 1.342033, 
              imaginary = 2.442E-09), nr = 1.000278)
snell_decomp(thetar = refr, nr = 1)

}
\references{
Liu, Y.; Qian, J.; Tian, Y. 2003. Succinct formulas for decomposition of 
complex refraction angle. IEEE Antennas and Propagation Society International 
Symposium. Digest. Held in conjunction with: USNC/CNC/URSI North American 
Radio Sci. Meeting (Cat. No.03CH37450), Columbus, OH, pp. 487-490, vol. 3. 
DOI: 10.1109/APS.2003.1219892
}
\seealso{
\code{\link{snell}}, \code{\link{fresnel}}
}
