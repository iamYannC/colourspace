#' Convert between colour spaces
#'
#' @param value Colour input. For `from = "hex"` or `from = "name"`, a
#'   character vector. For numeric spaces (`rgb`, `hsl`, `oklch`), a
#'   numeric vector of length 3, matrix/data frame with three columns, or a
#'   list of such vectors.
#' @param from Source colour space. One of `"hex"`, `"rgb"`, `"hsl"`,
#'   `"oklch"`, or `"name"`.
#' @param to Target colour space. One of `"hex"`, `"rgb"`, `"hsl"`,
#'   `"oklch"`, or `"name"` (reverse lookup).
#' @param fallback Optional behaviour when mapping `to = "name"` and no exact
#'   hex/name match is found. Use `"none"` (default) to return `NA` for unknown
#'   colours or `"nearest"` to return the closest named colour using
#'   `distance`. A warning is issued when fallback is used.
#' @param distance Distance metric for nearest-colour fallback: one of
#'   `"lab"` (default), `"oklch"`, `"rgb"`, or `"hsl"`.
#' @param ... Additional arguments passed through by wrapper helpers.
#' @return For scalar inputs, a named numeric vector (or hex string or colour
#'   name). For vectorised inputs, a matrix with one row per input colour or a
#'   character vector for `to = "name"`.
#' @details All conversions and nearest-colour calculations are powered by the
#'   \pkg{farver} package.
#' @importFrom farver decode_colour encode_colour convert_colour
#' @examples
#' convert("#ff0000", from = "hex", to = "rgb")
#' convert(c(255, 255, 0), from = "rgb", to = "hex")
#' convert(c("#ff0000", "#00ff00"), from = "hex", to = "oklch")
#' @export
convert <- function(value, from, to, fallback = c("none", "nearest"),
                    distance = c("lab", "oklch", "rgb", "hsl"), ...) {
  from <- match_space(from, allow_name = TRUE)
  to <- match_space(to, allow_name = TRUE)
  fallback <- match_fallback(fallback)
  distance <- match.arg(distance)

  if (identical(from, to)) {
    return(value)
  }

  if (from == "name") {
    hex <- lookup_name(value)
    if (to == "hex") {
      return(hex)
    }
    return(convert(hex, from = "hex", to = to, fallback = fallback, distance = distance))
  }

  if (to == "name") {
    # Convert anything to hex first, then map to names (with optional fallback)
    hex <- if (from == "hex") normalize_hex(value) else convert(value, from = from, to = "hex", fallback = "none", distance = distance)
    return(hex_to_name_with_fallback(hex, fallback = fallback, distance = distance))
  }

  if (from == "hex") {
    hex <- normalize_hex(value)
    out <- farver::decode_colour(hex, to = to)
    return(format_colour_result(out, to))
  }

  input <- as_colour_matrix(value, from)

  if (to == "hex") {
    hex <- farver::encode_colour(input, from = from)
    return(normalize_hex(hex))
  }

  out <- farver::convert_colour(input, from = from, to = to)
  format_colour_result(out, to)
}

match_space <- function(x, allow_name = FALSE) {
  valid <- c("hex", "rgb", "hsl", "oklch")
  if (allow_name) {
    valid <- c("name", valid)
  }
  x <- tolower(x)
  if (!x %in% valid) {
    stop(sprintf("`%s` is not a supported colour space (%s)", x, paste(valid, collapse = ", ")), call. = FALSE)
  }
  x
}

normalize_hex <- function(x) {
  if (!is.character(x)) {
    stop("Hex values must be character vectors", call. = FALSE)
  }
  x <- tolower(trimws(x))
  needs_hash <- !grepl("^#", x)
  x[needs_hash] <- paste0("#", x[needs_hash])
  invalid <- !grepl("^#([0-9a-f]{6}|[0-9a-f]{3})$", x)
  if (any(invalid)) {
    bad <- unique(x[invalid])
    stop(sprintf("Invalid hex value(s): %s", paste(bad, collapse = ", ")), call. = FALSE)
  }
  x
}

lookup_name <- function(name) {
  if (!exists("color_names", envir = environment(), inherits = TRUE)) {
    data("color_names", envir = environment())
  }
  idx <- match(tolower(name), tolower(color_names$name))
  missing <- is.na(idx)
  if (any(missing)) {
    stop(sprintf("Unknown colour name(s): %s", paste(unique(name[missing]), collapse = ", ")), call. = FALSE)
  }
  color_names$hex[idx]
}

as_colour_matrix <- function(value, space) {
  cols <- switch(space,
                 rgb = c("r", "g", "b"),
                 hsl = c("h", "s", "l"),
                 oklch = c("l", "c", "h"))

  if (is.matrix(value)) {
    mat <- value
  } else if (is.data.frame(value)) {
    mat <- as.matrix(value)
  } else if (is.list(value) && !is.null(value[[1]]) && length(value[[1]]) == 3) {
    mat <- do.call(rbind, lapply(value, unlist))
  } else {
    mat <- matrix(value, ncol = 3, byrow = TRUE)
  }

  if (ncol(mat) != 3) {
    stop(sprintf("`%s` values must have three components", space), call. = FALSE)
  }
  storage.mode(mat) <- "double"
  colnames(mat) <- cols
  mat
}

format_colour_result <- function(mat, space) {
  if (is.null(dim(mat))) {
    return(mat)
  }
  colnames(mat) <- switch(space,
                         rgb = c("r", "g", "b"),
                         hsl = c("h", "s", "l"),
                         oklch = c("l", "c", "h"))
  if (nrow(mat) == 1) {
    return(drop(mat[1, ]))
  }
  mat
}

match_fallback <- function(x) {
  if (is.logical(x)) {
    x <- if (isTRUE(x)) "nearest" else "none"
  }
  x <- match.arg(tolower(x), c("none", "nearest"))
  x
}
