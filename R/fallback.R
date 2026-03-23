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

#' Get (or build) the Lab reference matrix, optionally filtered by source.
#' @param source `"all"` for the full color map, `"r"` for R built-in colors only.
#' @noRd
get_ref_matrix <- function(source = "all") {
  key <- paste0("ref_", source)
  if (!is.null(.fallback_cache[[key]])) {
    return(.fallback_cache[[key]])
  }
  cm <- get_color_map()
  if (source == "r") {
    cm <- cm[cm$source == "r", ]
  }
  cols <- c("lab_l", "lab_a", "lab_b")
  ref <- as.matrix(cm[, cols])
  .fallback_cache[[key]] <- ref
  .fallback_cache[[paste0("cm_", source)]] <- cm
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

hex_to_name_with_fallback <- function(hex, fallback = "all") {
  hex <- strip_hex_alpha(hex)

  # "r" mode: always return nearest R color, skip exact lookup.
  if (fallback == "r") {
    return(nearest_named_colour(hex, source = "r"))
  }

  exact <- exact_name_lookup(hex)
  missing <- is.na(exact)
  if (!any(missing) || fallback == "none") {
    return(exact)
  }

  nearest <- nearest_named_colour(hex[missing], source = "all")
  out <- exact
  out[missing] <- nearest
  warning(sprintf("Fallback to nearest named colour for %d colour(s).", length(nearest)), call. = FALSE)
  out
}

#' @importFrom RANN nn2
nearest_named_colour <- function(hex, source = "all") {
  ref <- get_ref_matrix(source)
  cm <- .fallback_cache[[paste0("cm_", source)]]
  hex <- strip_hex_alpha(hex)

  target <- farver::decode_colour(hex, to = "lab")
  if (is.null(dim(target))) {
    target <- matrix(target, ncol = 3, byrow = TRUE)
  }

  result <- RANN::nn2(data = ref, query = target, k = 1)
  idx <- as.integer(result$nn.idx)

  cm$name[idx]
}
