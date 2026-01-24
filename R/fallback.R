# Helpers for nearest-named-colour fallback

get_color_map <- function() {
  env <- environment()
  if (!exists("color_map", envir = env, inherits = TRUE)) {
    data("color_map", envir = env)
  }
  get("color_map", envir = env, inherits = TRUE)
}

exact_name_lookup <- function(hex) {
  if (!exists("color_names", envir = environment(), inherits = TRUE)) {
    data("color_names", envir = environment())
  }
  matches <- match(hex, color_names$hex)
  color_names$name[matches]
}

hex_to_name_with_fallback <- function(hex, fallback = "none", distance = "lab") {
  hex <- normalize_hex(hex)
  exact <- exact_name_lookup(hex)
  missing <- is.na(exact)
  if (!any(missing)) {
    return(exact)
  }

  if (fallback != "nearest") {
    return(exact)
  }

  nearest <- nearest_named_colour(hex[missing], distance = distance)
  out <- exact
  out[missing] <- nearest
  warning(sprintf("Fallback to nearest %s name for %d colour(s).", distance, length(nearest)), call. = FALSE)
  out
}

nearest_named_colour <- function(hex, distance = "lab") {
  cm <- get_color_map()
  cols <- switch(distance,
                 lab = c("lab_l", "lab_a", "lab_b"),
                 oklch = c("oklch_l", "oklch_c", "oklch_h"),
                 rgb = c("rgb_r", "rgb_g", "rgb_b"),
                 hsl = c("hsl_h", "hsl_s", "hsl_l"),
                 stop(sprintf("Unsupported distance metric '%s'", distance), call. = FALSE))

  ref <- as.matrix(cm[, cols])
  target <- farver::decode_colour(hex, to = distance)
  if (is.null(dim(target))) {
    target <- matrix(target, ncol = 3, byrow = TRUE)
  }

  idx <- apply(target, 1, function(row) {
    diff <- sweep(ref, 2, row, FUN = "-")
    dist_sq <- rowSums(diff * diff)
    which.min(dist_sq)
  })

  cm$name[idx]
}
