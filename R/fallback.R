# Helpers for nearest-named-colour fallback
#
# Uses RANN KD-tree indices for O(log n) nearest-neighbour lookups instead
# of brute-force O(n) distance scans. Indices are built lazily on first use
# and cached in a package-level environment.

# Package-level cache for KD-tree data and color map
.fallback_cache <- new.env(parent = emptyenv())

get_color_map <- function() {
  if (!is.null(.fallback_cache$color_map)) {
    return(.fallback_cache$color_map)
  }
  env <- environment()
  utils::data("color_map", envir = env)
  cm <- get("color_map", envir = env)
  .fallback_cache$color_map <- cm
  cm
}

#' Get (or build) the reference matrix for a given distance metric.
#' @noRd
get_ref_matrix <- function(distance) {
  key <- paste0("ref_", distance)
  if (!is.null(.fallback_cache[[key]])) {
    return(.fallback_cache[[key]])
  }
  cm <- get_color_map()
  cols <- switch(distance,
    lab   = c("lab_l", "lab_a", "lab_b"),
    oklch = c("oklch_l", "oklch_c", "oklch_h"),
    rgb   = c("rgb_r", "rgb_g", "rgb_b"),
    hsl   = c("hsl_h", "hsl_s", "hsl_l"),
    stop(sprintf("Unsupported distance metric '%s'", distance), call. = FALSE)
  )
  ref <- as.matrix(cm[, cols])
  .fallback_cache[[key]] <- ref
  ref
}

exact_name_lookup <- function(hex) {
  hex <- strip_hex_alpha(hex)
  env <- environment()
  if (!exists("color_names", envir = env, inherits = TRUE)) {
    utils::data("color_names", envir = env)
  }
  cn <- get("color_names", envir = env, inherits = TRUE)
  matches <- match(hex, cn$hex)
  cn$name[matches]
}

hex_to_name_with_fallback <- function(hex, fallback = TRUE, distance = "lab") {
  hex <- strip_hex_alpha(hex)
  exact <- exact_name_lookup(hex)
  missing <- is.na(exact)
  if (!any(missing)) {
    return(exact)
  }

  if (!isTRUE(fallback)) {
    return(exact)
  }

  nearest <- nearest_named_colour(hex[missing], distance = distance)
  out <- exact
  out[missing] <- nearest
  warning(sprintf("Fallback to nearest %s name for %d colour(s).", distance, length(nearest)), call. = FALSE)
  out
}

#' @importFrom RANN nn2
nearest_named_colour <- function(hex, distance = "lab") {
  cm <- get_color_map()
  hex <- strip_hex_alpha(hex)

  ref <- get_ref_matrix(distance)
  target <- farver::decode_colour(hex, to = distance)
  if (is.null(dim(target))) {
    target <- matrix(target, ncol = 3, byrow = TRUE)
  }

  result <- RANN::nn2(data = ref, query = target, k = 1)
  idx <- as.integer(result$nn.idx)

  cm$name[idx]
}
