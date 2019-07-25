
#' Radiative transfer semi-analytical approximations
#'
#' This function calculates the subsurface bi-hemispherical and 
#' hemispherical-directional water-leaving reflectance over optically deep 
#' or optically shallow waters.
#'
#' @param a       Total absorption coefficient (1/m).
#' @param bb      Total back-scattering coefficient (1/m).
#' @param rho_b   Bottom bi-hemispherical reflectance (unitless).
#' @param depth   Bottom depth, positive downwards (m).
#' @param theta_s Sun zenith angle refracted underwater (radians).
#' @param theta_v Observation nadir angle refracted underwater (radians).
#' @param wsp     Wind speed (m/s). Only for model "Albert-Mobley03".
#' @param bbp     Particle back-scattering (1/m). See details.
#' @param aop     Desired reflectance. One of: 'rho' or 'rrs'. See details.
#' @param model   Semi-analytical parametrization to use. Possible values are:
#'                "Albert-Mobley03" and "Lee98". See details.
#'
#' @details In Hydrology Optics, the bi-hemispherical and hemispherical-
#' -directional reflectances are commonly named irradiance refelctance ("R" or 
#' "Rho") and remote sensing reflectance ("Rrs"), respectively. Those are two 
#' apparent optical properties of the medium. This function uses semi-analytical 
#' parametrizations to calculate their subsurface values, i.e., at depth 0 just 
#' below the water surface. The lower case names are used to indicate the 
#' subsurface quantities. Those quantities can be propagated into air, just 
#' above the water surface, with the function \code{propagate_r}.
#'
#' An optically deep medium is equivalent of a semi-infinite medium, i.e., the 
#' bottom depth is infinite and has no contribution to the water-leaving 
#' reflectance. Optically shallow water are defined as the complement, when 
#' there is "measurable" influence of bottom albedo (bi-hemispherical 
#' reflectance).
#'
#' Model "Albert-Mobley03" is used as default. It implements the equations and 
#' coefficients provided in Albert & Mobley (2003). The model includes an 
#' extended range of water medium properties, the effect of wind speed and 
#' include specific coefficients for "rho" and "rrs".
#'
#' Model "Lee98" is also available. It implements the equations and coefficients
#' provided in Lee et al. (1998), with the corrections of Lee et al. (1999). The 
#' model is specifically parametrized for "rrs", and "rho" is calculated (with a 
#' warning) by assuming that the diffuse subsurface hemispherical-directional 
#' water-leaving reflectance is Lambertian.
#'
#' Both models can be used to calculate 'rrs' at off-nadir observation. The 
#' model "Lee98" requires that the backscattering of particles (bbp) be provided 
#' separately in case of off-nadir observation. The "Albert-Mobley03" also 
#' allows to calculate off-zenith illumination, while the model of "Lee98" is an
#' average fit to three Sun zenith angles (0, 30 and 60 degrees, in air).
#'
#' If the arguments passed to the function are outside the range used for 
#' parametrization of the specific model, values will be return with a warning 
#' of extrapolation beyond model domain.
#'
#' Note that although the base data for the parametrization of both models 
#' includes the inelastic scattering (vibrational Raman from water and 
#' fluorescence from pigments and dissolved organic carbon), the semi-analytical
#' approximations do not model those processes. Simulations therefore should 
#' present higher errors when those processes are important contributors, 
#' particularly pigment fluorescence will produce a spectrally localized error.
#'
#' @return A numeric vector with the subsurface bi-hemispherical ('r', 
#' unitless) or hemispherical-directional ('rrs', 1/sr) water-leaving 
#' reflectance.
#'
#' @references
#' Albert, A.; Mobley, C. D. 2003. An analytical model for subsurface irradiance 
#' and remote sensing reflectance in deep and shallow case-2 waters. Optics 
#' Express 11, 22, 2873-2890. DOI: 10.1364/oe.11.002873
#' 
#' Lee, Z.-P.; Carder, K. L.; Mobley, C. D.; Steward, R. G.; Patch, J. S. 1998. 
#' Hyperspectral remote sensing for shallow waters. I. A semianalytical model. 
#' Applied Optics 37, 27, 6329-6338. DOI: 10.1364/AO.37.006329
#'
#' Lee, Z.-P.; Carder, K. L.; Mobley, C. D.; Steward, R. G.; Patch, J. S. 1999. 
#' Hyperspectral remote sensing for shallow waters: 2. Deriving bottom depths 
#' and water properties by optimization. Applied Optics 38, 18, 3831-3843. DOI:
#' 10.1364/AO.38.003831
#'
#' @seealso \code{\link{propagate_r}}
#'
#' @examples
#' theta_s  <- rad(seq(0, 90, 0.5))
#' tehta_sw <- snell(theta_s, 1, 1.33)
#' r_am     <- rta_sa(a = 1, bb = 0.5, theta_s = theta_sw, model = "Albert-Mobley03")
#' r_lee    <- rta_sa(a = 1, bb = 0.5, theta_s = theta_sw, model = "Lee98")
#' plot(deg(theta_s), r_am)
#' lines(deg(theta_s), r_lee)


rta_sa <- function(a, bb, theta_s = 0, depth = Inf, rho_b, theta_v = 0, wsp = 0, 
                   aop = c('rrs', 'rho'), model = c("Albert-Mobley03", "Lee98"), 
                   bbp) {

  if(missing(a) || missing(bb))
    stop("At least a and bb must be specified", call. = FALSE)

  if(any(!is.infinite(depth)) && missing(rho_b))
      stop("For finite bottom depth, rho_b must be specified")
  
  if(!missing(rho_b))
    if(any(rho_b < 0) || any(rho_b > 1))
      stop("rho_b must be between 0 and 1")

  if(aop == 'rho' && any(theta_v > 0)) {
    warning("Irradiance reflectance is fixed to theta_v = 0")
  }

  if(any(theta_v != 0) && model == "Lee98" && missing(bbp))
    stop("For non-nadir view angles over non infinite bottom depths, bbp must ", 
         "be provided for model Lee98")

  if(any(wsp > 0) && model == "Lee98")
    warning("Wind speed effect not parametrized in model Lee98")

  .args <- as.list(match.call()[-1])
  .args$depth <- abs(depth)

  if(model == 'Albert-Mobley03') {
    if(any((bb / (a + bb)) > 0.8))
      warning("Back-scattering albedo is beyond model domain (max = 0.8)")

    if(any(theta_s > 0.8028515))
      warning("Refracted Sun zenith angle is beyond model domain (max = 46 ",
              "degrees in water, 80 degree in air)")

    if(any(theta_v > 0.8028515))
      warning("Refracted observation angle is beyond model domain (max = 46 ",
              "degrees in water, 80 degrees in air)")

    R     <- do.call(.rta_AM03, .args) 
  } else if(model == 'Lee98') {
    if(aop == 'rho')
      warning("The Lee98 model is parametrized only for 'rrs', so 'rho' ", 
              "calculation assumes diffuse reflectance is Lambertian (i.e., ", 
              "rho = rrs * pi)")

    if(any((bb / (a + bb)) > 0.6))
      warning("Back-scattering albedo is beyond model domain (max = 0.6)")

    if(any(theta_s > 0.7090946))
      warning("Refracted Sun zenith angle is beyond model domain (max = 40 ",
              "degrees in water, 60 degrees in air)")

    if(any(theta_v > 0.6137942))
      warning("Refracted observation angle is beyond model domain (max = 35 ",
              "degrees in water, 50 degrees in air)")

    R     <- do.call(.rta_L98, .args) 
  } else {
    stop("model must be one of 'Albert-Mobley03' or 'Lee98'")
  }

  return(R)

}

.rta_L98 <- function(a, bb, theta_s = 0, depth = Inf, rho_b, theta_v = 0, bbp, aop = c('rrs', 'rho'), ...) {

  aop <- match.arg(aop)
  if(aop == "rho")
    theta_v[theta_v > 0] <- 0

  if(theta_v != 0) {
    e  <- 1 + (0.1 + 0.8 * bbp / bb) * sin(theta_s) * sin(theta_v)
    bb <- (bb - bbp) + e * bbp
  }

  p1  <- 0.084
  p2  <- 0.17
  k1w <- 1.03
  k2w <- 2.04
  k1b <- 1.04
  k2b <- 5.04

  if(aop == 'rrs') {
    q1   <- 1
    if(!missing(rho_b)) .rho_b <- rho_b / pi
  } else if(aop == 'rho'){
    q1   <- pi
    if(!missing(rho_b)) .rho_b <- rho_b / pi
  }

  k <- a + bb
  u <- bb / k

  R <- q1 * (p1 + p2 * u) * u
  R <- rep(R, length(theta_s))

  if(!is.infinite(depth)) {
    mu_s <- cos(theta_s)
    mu_v <- cos(theta_v)
    du_w <- k1w * sqrt(1 + k2w * u)
    du_b <- k1b * sqrt(1 + k2b * u)
    R    <- R * (1 - exp(-(1 / mu_s + du_w / mu_v) * k * depth)) + 
            .rho_b * exp(-(1 / mu_w + du_b / mu_v) * k * depth)
  }

  return(R)

}


.rta_AM03 <- function(a, bb, theta_s = 0, theta_v = 0, wsp = 0, depth = Inf, rho_b, aop = c('rrs', 'rho'), ...) {

  aop <- match.arg(aop)
  if(aop == 'rrs') {
    p1  <-  0.0512  # (+- 0.0001)
    p2  <-  4.6659  # (+- 0.0174)
    p3  <- -7.8387  # (+- 0.0434)
    p4  <-  5.4571  # (+- 0.0345)
    p5  <-  0.1098  # (+- 0.0018)
    p6  <- -0.0044  # (+- 0.0000)
    p7  <-  0.4021  # (+- 0.0020)
    A1  <-  1.1576  # (+- 0.0014)
    k0  <-  1.0546  # (+- 0.0001)
    k1w <-  3.5421  # (+- 0.0152)
    k2w <- -0.2786  # (+- 0.0030)
    A2  <-  1.0389  # (+- 0.0013)
    k1b <-  2.2658  # (+- 0.0076)
    k2b <-  0.0577  # (+- 0.0009)
  } else if(aop == 'rho'){
    p1  <-  0.1034  # (+- 0.0014)
    p2  <-  3.3586  # (+- 0.0305)
    p3  <- -6.5358  # (+- 0.0808)
    p4  <-  4.6638  # (+- 0.0649)
    p5  <-  2.4121  # (+- 0.0443)
    p6  <- -0.0005  # (+- 0.0001)
    p7  <-  0.0000  # (NA)
    A1  <-  1.0546  # (+- 0.0038)
    k0  <-  1.0546  # (+- 0.0001)
    k1w <-  1.9991  # (+- 0.0305)
    k2w <-  0.2995  # (+- 0.0122)
    A2  <-  0.9755  # (+- 0.0013)
    k1b <-  1.2441  # (+- 0.0209)
    k2b <-  0.5182  # (+- 0.0036)
  } 

  k <- a + bb
  u <- bb / k
  mu_s <- cos(theta_s)
  mu_v <- cos(theta_v)

  R <- p1 * (1 + p2 * u + p3 * u^2 + p4 * u^3) * (1 + p5 / mu_s) * 
       (1 + p6 * wsp) * (1 + p7 / mu_v) * u

  if(!is.infinite(depth)) {
    kd  <- k0 * k / mu_s
    kuw <- k * (1 + u)^k1w * (1 + k2w / mu_s)
    kub <- k * (1 + u)^k1b * (1 + k2b / mu_s)
    R <- R * (1 - A1 * exp(-(kd + kuw) * depth)) + A2 * rho_b * exp(-(kd +kub) * depth)
  }

  return(R)

}

#' Propagates reflectance across a boundary:
#' HOW TO GENERALIZE THIS FUNCTION??? MAKE BOTH WAYS, for Rrs and R

propagate_r <- function(rrs) {
  Rrs    <- 0.518 * rrs / (1 - 1.562 * rrs)
  return(Rrs)
}