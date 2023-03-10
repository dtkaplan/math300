#' Plot model output for representative levels of explanatory variables
#'
#' @examples
#' mod <- lm(time ~ distance*sex*climb, data=Hill_racing)
#' model_plot(mod, x=climb, color=sex, facet=distance, nlevels=4, show_data=TRUE)

#' @export
model_plot <- function(mod, x, color=NULL, facet=NULL, facet2=NULL,
                       ..., data = NULL, nlevels=3, show_data=TRUE,
                       interval=c("none", "prediction", "confidence"), data_alpha=0.25) {
  # Allow unquoted names as arguments
  if (missing(x)) { # when the plotting variables aren't explicitly identified.
    evars <- explanatory_vars(mod)
    x <- evars[1]
    if (length(evars) >= 4) facet2 <- evars[4]
    if (length(evars) >= 3) facet <- evars[3]
    if( length(evars) >= 2) color <- evars[2]
  }

  x <- as.character(substitute(x))

  if (x[1] == "aes") { # handle the mistaken use of aes() gracefully.
    if (length(x) >= 5) facet2 <- x[5]
    if (length(x) >= 4) facet <- x[4]
    if (length(x) >= 3) color <- x[3]
    x <- x[2]
  } else {
    if (length(x) == 0) stop("Must provide mapping to `x` variable.")
    color <- as.character(substitute(color))
    if (length(color) == 0) color <- NULL
    facet <- as.character(substitute(facet))
    if (length(facet) == 0) facet <- NULL
    facet2 <- as.character(substitute(facet2))
    if (length(facet2) == 0) facet2 <- NULL
  }

  interval=match.arg(interval)

  response_name <- as.character(deparse(response_var(mod)))

  if (is.null(data)) data <- extract_training_data(mod)
  plotting_names <- c(x, color)
  facet_names <- c(facet, facet2)
  spread_names <- c(plotting_names, facet_names)
  other_explan_names <- all.vars(formula_from_mod(mod)[[3]])
  all_names <- union(spread_names, other_explan_names)
  all_names_formula <- as.formula(paste("~", paste(all_names, collapse="+")))
  # data_skeleton() never returns the response variable
  Skeleton <- data_skeleton(data, all_names_formula,
                            spreadn=length(spread_names),
                            ...,
                            ncont=100, nlevels=nlevels)

  # If there is faceting going on based on a quantitative variable,
  # redo the Skeleton so the levels are in the middle
  # of the data for each facet
  for (var in facet_names) {
    if (continuous_or_discrete(data[[var]])=="continuous") {
      temp_data <- data.frame(raw = data[[var]])
      breaks <- compromise_breaks(data[[var]], n=nlevels + 1)
      temp_data$groups <- cut(temp_data$raw, breaks, include.lowest=TRUE, dig.lab=3)
      center_of_groups <- df_stats(raw ~ groups, data = temp_data, middle=median())
      Skeleton[[var]] <- center_of_groups$middle
    }
  }
  # If a continuous variable is mapped to color, space the skeleton
  # levels evenly
  if (!is.null(color) && continuous_or_discrete(data[[color]])=="continuous") {
    vals <- data[[color]]
    breaks <- seq(quantile(vals, 0.01, na.rm=TRUE),
                  quantile(vals, 0.99, na.rm=TRUE),
                  length = nlevels)
    Skeleton[[color]] <- breaks
  }

  alpha_val <- 0.75
  For_plotting <-
    model_eval(mod, data=expand.grid(Skeleton), interval=interval)

  # determine the plot geoms and formulas
  data_formula <- as.formula(glue::glue("{response_name} ~ {x}"))
  if (continuous_or_discrete(data[[x]]) == "continuous") {

    data_plot_fun <- gf_point
    if (interval != "none" && ".lwr" %in% names(For_plotting)) {
      space_formula <- as.formula(glue::glue(".lwr + .upr ~ {x}"))
      mod_plot_fun <- gf_ribbon
      alpha_val <- .3
    } else {
      space_formula <- as.formula(glue::glue(".output ~ {x}"))
      mod_plot_fun <- gf_line
    }

  } else {
    mod_plot_fun <- gf_errorbar
    data_plot_fun <- gf_jitter
    if (interval != "none" && ".lwr" %in% names(For_plotting)) {
      space_formula <- as.formula(glue::glue(".lwr + .upr ~ {x}"))
    }
    space_formula <- as.formula(glue::glue(".output + .output ~ {x}"))
  }

  if(length(plotting_names) > 1) {
    color_formula <- as.formula(glue::glue("~ {color}"))
    fill_formula <- color_formula
  } else fill_formula <- color_formula <- "blue"


  # Add columns for the facets, if any
  for (var in facet_names) {
    # even number of points in each cut level
    fname <- paste0("..", var, "..") # name of column for this facet axis
    if (continuous_or_discrete(data[[var]])=="discrete") {
      data[[fname]] <- data[[var]]
      For_plotting[[fname]] <- For_plotting[[var]]
    } else {
      breaks <- compromise_breaks(data[[var]], n=nlevels + 1) %>% signif(3)
      data[[fname]] <- cut(data[[var]], breaks, include.lowest=TRUE, dig.lab=3)
      For_plotting[[fname]] <- cut(For_plotting[[var]], breaks, include.lowest=TRUE, dig.lab=5)
    }
  }


  if (show_data) {
    P <- data_plot_fun(data_formula, color=color_formula, data = data, alpha=data_alpha)
  } else {
    P <- NULL
  }

  P <- P %>%
    mod_plot_fun(space_formula, color=color_formula, fill=fill_formula,
                 group=color_formula, data = For_plotting, alpha=alpha_val,
                 linewidth=0.75, inherit=FALSE) +
    ylab(response_name)

  # Facet the plot
  if (length(facet_names) == 1) {
    P <- P + facet_wrap(paste0("..", facet, ".."),labeller = "label_both")
  } else if (length(facet_names)==2) {
    dotted_names <- paste0("..", facet_names, "..")
     P <- P + facet_grid(rows=dotted_names[1],
                         cols=dotted_names[2],
                         labeller = "label_both")
  }

  # Set the color scale
  if (is.null(color)) return(P)
  else if (continuous_or_discrete(data[[color]]) == "discrete")
    return(P)
  else return(P + scale_color_stepsn(colors=heat.colors(5)) +
                scale_fill_stepsn(colors=heat.colors(5)))

}


