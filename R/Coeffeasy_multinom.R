#' Easily interpret the coefficients of a multinomial model.
#'
#' This function takes a multinomial model and returns a simplified interpretation
#' of the coefficients, focusing especially on the change in log-odds
#' associated with a unit change in the predictor variable for each category of the dependent variable.
#'
#' @param modelo A multinom object (multinomial model).
#' @param x Name of the predictor variable of interest (character). If NULL, the function will try to identify it automatically.
#' @param alfa Significance level for hypothesis testing. The default value is 0.05.
#'
#' @return A text string with the interpretation of the multinomial model's coefficients.
#'
#' @export
Coeffeasy_multinom <- function(modelo, x = NULL, alfa = 0.05) {
  # Get the names of the model variables if x is not specified
  if (is.null(x)) {
    variables <- as.character(attr(terms(modelo), "variables"))
    x <- tail(variables, n=1)
  }

  # Loop over each level of the dependent variable (excluding reference category)
  interpretations <- list()
  for (level in rownames(coef(modelo))) {
    coef_value <- stats::coef(modelo)[level, x]
    coef_p_value <- summary(modelo)$coefficients[level, pmatch(x, colnames(stats::coef(modelo)))]

    if (coef_value > 0) {
      direction <- "increases"
    } else {
      direction <- "decreases"
    }

    p_value_text <- ifelse(coef_p_value < 0.001, paste("<", 0.001), sprintf("%.3f", coef_p_value))
    significance_impact <- ifelse(coef_p_value < alfa, "significant", "not significant")
    hypothesis_decision <- ifelse(coef_p_value < alfa, "is rejected", "is not rejected")

    change <- paste("For the level", level, "of the response variable: If", x, "increases by one unit, the log-odds of being in this level relative to the reference level", direction, "by", round(coef_value, 2), "units.")
    accessible_reading <- paste("For the level", level, ": if", x, "increases, it is more likely that this level occurs relative to the reference level.")

    interpretation_message <- paste(change, "This means that", accessible_reading,
                                    "This effect has a p-value of", p_value_text, "and, using a significance level of", alfa, ",",
                                    "the null hypothesis", hypothesis_decision, ". This suggests that", x,
                                    "significantly impacts the chances of being in this level relative to the reference level.",
                                    "Remember that this function interprets the model's result as it has been presented.")
    interpretations[[level]] <- interpretation_message
  }

  return(interpretations)
}