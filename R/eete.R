#' Find the Inverse Function Value
#'
#' This function returns the inverse function value of a given function `f` for a specific value `y`,
#' searching within the interval specified by `lower` and `upper`.
#'
#' @param f A function for which the inverse value needs to be found.
#' @param lower The lower bound of the search interval.
#' @param upper The upper bound of the search interval.
#' @return A function that takes a single value `y` and returns the inverse function value of `f` at `y`.
#' @examples
#' inv_sqrt <- inverse_fun(function(x) x^2, 0, 100)
#' inv_sqrt(4) # Should find a value close to 2


inverse_fun = function(f, lower, upper) {
  function(y) uniroot((function(x) f(x) - y), lower = lower, upper = upper)$root
}



#' Estimate the Egalitarian Equivalent Treatment Effect (eete)
#'
#' This function estimates the eete, which optional arguments to include an IV or bootstrapped SE.
#' It applies an input function to data, conditioning on treatment (and instrument variables, if applicable).
#'
#' @param inputFunction A function that will be applied to the data.
#' @param ... Additional arguments to be passed to `inputFunction`.
#' @param y The name of the outcome variable column in `data`.
#' @param d The name of the treatment variable column in `data`.
#' @param z Optional argument to include the name of the instrument variable column in `data`.
#' @param data The data frame containing the variables.
#' @param lower The lower bound for finding the inverse function value.
#' @param upper The upper bound for finding the inverse function value.
#' @param se Optional argument to calculate the standard error of the estimate with bootstrapping.
#' @param B The number of iterations to be used in the standard error bootstrap.
#' @return The estimated egalitarian equivalent treatment effect.
#' @import dplyr
#' @importFrom boot boot
#' @export
#' @examples
#' # Example using the mtcars dataset
#' # Let's assume `mpg` is the outcome, `vs` is the treatment indicator, and `am` is used as an instrument.
#' eete_sqrt = eete(sqrt, y = "mpg", d = "vs", z = "am", data = mtcars)
#' print(eete_sqrt)

eete = function(f, ..., y, d, z = NULL, data, lower = 0.1, upper = 100, se = NULL, B = 1000, f_inv = NULL) {



  data_test = data %>%
    dplyr::select(!!sym(y))

  if (is.character(f(data_test, ...))) {
    eete = f(data_test, ...)


  } else {

    se_function = NULL

    if (any(identical(f, eete::crpie), identical(f, eete::cdpie), identical(f, eete::cpiee))) {

      if (!is.null(f_inv)) {
        f_inv = NULL
      }
      if (lower != 0.1 | upper != 100 | B != 1000){
        message("B, lower, and upper parameters are options for custom functions, which require bootstrapped standard errors and uniroot inverses. These parameters will not affect eete::crpie, eete::cdpie, or eete::cpiee functions.")
      }
}
    if (is.null(f_inv)) {

      if (identical(f, eete::crpie)) {
        f_inv = function(x) eete::crpie_inv(x, ...)
        # INSERT SE CODE HERE
        # se_function =

      } else if (identical(f, eete::cdpie)) {
        f_inv = function(x) eete::cdpie_inv(x, ...)
        # INSERT SE CODE HERE
        # se_function =

      } else if (identical(f, eete::cpiee)) {
        f_inv = function(x) eete::cpiee_inv(x, ...)
        # INSERT SE CODE HERE
        # se_function =

      } else {
        f_inv = inverse_fun(function(x) f(x, ...), lower, upper)
      }
    }

  if (!is.null(z)) {

  ee = function(data, indices){

    bdata = data[indices,]

    data1 = bdata %>%
      dplyr::filter(!!sym(z) == 1)

    data0 = bdata %>%
      dplyr::filter(!!sym(z) == 0)

    yz1 = data1[[y]]
    yz0 = data0[[y]]
    p1 = mean(data1[[d]], na.rm = TRUE)
    p0 = mean(data0[[d]], na.rm = TRUE)

    fee_p1 = mean(f(yz1, ...), na.rm = TRUE)
    fee_p0 = mean(f(yz0, ...), na.rm = TRUE)
    fee1 = (((1 - p0) * fee_p1 - (1 - p1) * fee_p0) / (p1 - p0))
    fee0 = ((p1 * fee_p0 - p0 * fee_p1) / (p1 - p0))

    eete = (f_inv(fee1) - f_inv(fee0))

    return(eete)
  }



  } else {

    ee = function(data, indices){

      bdata = data[indices,]

      data1 = bdata %>%
        dplyr::filter(!!sym(d) == 1)

      data0 = bdata %>%
        dplyr::filter(!!sym(d) == 0)

      yz1 = data1[[y]]
      yz0 = data0[[y]]

      fee1 = mean(f(yz1, ...), na.rm = TRUE)
      fee0 = mean(f(yz0, ...), na.rm = TRUE)

      eete = (f_inv(fee1) - f_inv(fee0))

      return(eete)
    }

  }

  eete = ee(data, 1:nrow(data))

  if (is.null(se)) {

    eete = list(estimate = eete)

  } else if (se == TRUE) {


    if (is.null(se_function)){
      boot_results = boot::boot(data, ee, R = B)
      se = sd(boot_results$t)

      eete = list(estimate = eete, se = se)
    } else {
      # INSERT SE CODE HERE
      #se = se_function()
      eete = list(estimate = eete, se = se)
    }

  }
}
  return(eete)
}
