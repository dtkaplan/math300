#' Extract the training data from a model object
#'
#' @param model A model fitted by `lm()` or `glm()` or similar.
#' @export
extract_training_data <- function(model, ...) {
UseMethod("extract_training_data")
}

#' @export
extract_training_data.default <- function(model, ...) {
  error_string <- paste0("Model architecture '",
                         paste(class(model), collapse = "', "),
                         "' not recognized by math300 package.")
  if (inherits(model, "model_train")) return(attr(model, "training_data"))

  if ( ! "call" %in% names(model) || !"data" %in% names(model$call))
    stop(error_string)
  if ("data" %in% names(model$call)) {
    if (model$call$data == ".") {
      stop("Cannot extract training data when it was piped into model-building function.")
    }
    the_data <- eval(model$call$data, envir = parent.frame(3))
    if (is.data.frame(the_data)) return(the_data)
  }
  stop(error_string)
}

#' @export
extract_training_data.bootstrap_ensemble <- function(model, ...) extract_training_data(model$original_model, ...)


#' @export
extract_training_data.knn3 <- function(model, ...) {
  res <- data.frame(model$learn$y, model$learn$X)
  names(res)[1] <- as.character(response_var(model))

  res
}
