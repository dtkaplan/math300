#' Evaluate a model on inputs
#'
#'
#'
#' @param mod A model as from `lm()` or `glm()`
#' @param data A data frame of inputs. If missing, the inputs will be assembled from \ldots or
#' from the training data, or an skeleton will be constructed.
#' @param \ldots Optional vectors specifying the inputs. See examples.
#' @param skeleton Logical flag. If `TRUE`, a skeleton on inputs will be created. See [model_skeleton()].
#' @param ncont Only relevant to skeleton. The number of levels at which to evaluate continuous variables. See  [model_skeleton()].
#' @param interval One of "prediction" (default), "confidence", or "none".
#' @param level The level at which to construct the interval (default: 0.95)
#' @param type Either "response" (default) or "link". Relevant only to glm models. The format of the `.output`
#'
#' @returns A data frame. There is one row for each row of the input values (see `data` parameter). The
#' columns include
#' - the explanatory variables
#' - `.output` --- the output of the model that corresponds to the explanatory value
#' - the `.lwr` and `.upr` bounds of the prediction or confidence interval
#' - if training data is used as the input, the `.response` variable and the `.resid`. Note that
#' the generic name `.response` is used, not the actual name of the model's response variable.
#'
#' @family {Functions used in Lessons}
#' @examples
#' mod <- lm(mpg ~ hp + wt, data=mtcars)
#' model_eval(mod, hp=100, wt=c(2,3))
#' model_eval(mod) # training data
#' model_eval(mod, skeleton=TRUE)
#'
#' @export
model_eval <- function(mod, data=NULL, ..., skeleton=FALSE, ncont=3,
                       interval=c("prediction", "confidence", "none"), level=0.95,
                       type=c("response", "link")) {
  response_var_name <- as.character(deparse(response_var(mod)))

  # Figure out where the data is coming from
  if (is.null(data) || nrow(data) == 0) {
     data <- expand.grid(list(...)) # check \ldots First
  }

  if (is.null(data) || nrow(data) == 0) {
     if (skeleton) { # build a skeleton
       eval_data <- training_data <- model_skeleton(mod, ncont=ncont)
       response_in_data <- FALSE
     } else {
       # use the training data
       message("Using training data as input to model_eval().")
       eval_data <- training_data <- model.frame(mod)
       response_in_data <- TRUE
     }
  } else {
    eval_data <- training_data <- data
    names(training_data)[1] <- ".response"
    # the argument data might or might not have the response name
    response_in_data <- response_var_name %in% names(data)
  }

  explan_names <- explanatory_vars(mod)
  if (!all(explan_names %in% names(eval_data)))
    stop("Must provide values for all explanatory variables.")

  type <- match.arg(type)
  interval = match.arg(interval)
  if (level <= 0 || level >=1) stop("<level> must be > 0 and < 1.")

  # Evaluate the model at the selected data values
  interval_fun <- add_pi
  if (interval == "confidence") interval_fun = add_ci
  # Try to get a prediction interval
  Result <- try(
    interval_fun(eval_data, mod, yhatName=".output",
                 names=c(".lwr", ".upr"), alpha=1-level, response=TRUE),
    silent=TRUE
    )
  if (inherits(Result, "try-error")) {
    if (interval=="prediction")
      warning("Prediction intervals not available for this model type. Giving confidence intervals instead.")
    Result <- add_ci(eval_data, mod, alpha = 1 - level,
                     names=c(".lwr", ".upr"), yhatName=".output",
                     response=TRUE)
    }
  Fitted <- Result[".output"]
  if (".lwr" %in% names(Result)) Result <- Result[c(".lwr", ".upr")]

  if (response_in_data) {
    Residuals <- data.frame(.resid = eval_data[[1]] - Fitted$.output)
    names(training_data)[1] <- ".response" # give it a generic name
    return(bind_cols(training_data, Fitted, Residuals,  Result))
  } else {
    return(bind_cols(eval_data, Fitted, Result))
  }
}


