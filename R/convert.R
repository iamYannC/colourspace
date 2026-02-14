#' Convert between colour spaces
#'
#' @param value Colour input. For `from = "hex"` or `from = "name"`, a
#'   character vector. For numeric spaces (`rgb`, `hsl`, `oklch`), a
#'   numeric vector of length 3, matrix/data frame with three columns, or a
#'   list of such vectors.
#' @param from Source colour space. One of `"hex"`, `"rgb"`, `"hsl"`,
#'   `"oklab"`, `"oklch"`, or `"name"`.
#' @param to Target colour space. One of `"hex"`, `"rgb"`, `"hsl"`,
#'   `"oklab"`, `"oklch"`, or `"name"` (reverse lookup).
#' @param fallback Behaviour when mapping `to = "name"` and no exact
#'   hex/name match is found. `TRUE` (default) returns the closest named
#'   colour using `distance` (a warning is issued). `FALSE` returns `NA`
#'   for unknown colours.
#' @param distance Distance metric for nearest-colour fallback: one of
#'   `"lab"` (default), `"oklch"`, `"rgb"`, or `"hsl"`.
#' @param ... Additional arguments passed through by wrapper helpers.
#' @return For scalar inputs, a named numeric vector (or hex string or colour
#'   name). For vectorised inputs, a matrix with one row per input colour or a
#'   character vector for `to = "name"`.
#' @details All conversions and nearest-colour calculations are powered by the
#'   \pkg{farver} package. Hex inputs may include an alpha channel
#'   (`#rgba`/`#rrggbbaa`), but alpha is currently ignored (stripped before
#'   decoding).
#' @importFrom farver decode_colour encode_colour convert_colour
#' @examples
#' convert_colourspace("#ff0000", from = "hex", to = "rgb")
#' convert_colourspace(c(255, 255, 0), from = "rgb", to = "hex")
#' convert_colourspace(c("#ff0000", "#00ff00"), from = "hex", to = "oklch")
#' @export
convert_colourspace <- function(value, from, to, fallback = TRUE,
                    distance = c("lab", "oklch", "rgb", "hsl"), ...) {
  from <- match_space(from, allow_name = TRUE)
  to <- match_space(to, allow_name = TRUE)
  if (!is.logical(fallback) || length(fallback) != 1L) {
    stop("`fallback` must be TRUE or FALSE.", call. = FALSE)
  }
  distance <- match.arg(distance)

  if (identical(from, to)) {
    return(value)
  }

  if (from == "name") {
    hex <- lookup_name(value)
    if (to == "hex") {
      return(hex)
    }
    return(convert_colourspace(hex, from = "hex", to = to, fallback = fallback, distance = distance))
  }

  if (to == "name") {
    # Convert anything to hex first, then map to names (with optional fallback)
    hex <- if (from == "hex") normalize_hex(value) else convert_colourspace(value, from = from, to = "hex", fallback = FALSE, distance = distance)
    return(hex_to_name_with_fallback(hex, fallback = fallback, distance = distance))
  }

  if (from == "hex") {
    hex <- strip_hex_alpha(value)
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
  valid <- c("hex", "rgb", "hsl", "oklab", "oklch")
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
  invalid <- !grepl("^#([0-9a-f]{3}|[0-9a-f]{4}|[0-9a-f]{6}|[0-9a-f]{8})$", x)
  if (any(invalid)) {
    bad <- unique(x[invalid])
    stop(sprintf("Invalid hex code(s): %s", paste(bad, collapse = ", ")), call. = FALSE)
  }

  # Expand #rgb/#rgba to full length for downstream tools.
  short3 <- grepl("^#[0-9a-f]{3}$", x)
  if (any(short3)) {
    s <- substring(x[short3], 2)
    x[short3] <- paste0(
      "#",
      substring(s, 1, 1), substring(s, 1, 1),
      substring(s, 2, 2), substring(s, 2, 2),
      substring(s, 3, 3), substring(s, 3, 3)
    )
  }
  short4 <- grepl("^#[0-9a-f]{4}$", x)
  if (any(short4)) {
    s <- substring(x[short4], 2)
    x[short4] <- paste0(
      "#",
      substring(s, 1, 1), substring(s, 1, 1),
      substring(s, 2, 2), substring(s, 2, 2),
      substring(s, 3, 3), substring(s, 3, 3),
      substring(s, 4, 4), substring(s, 4, 4)
    )
  }
  x
}

strip_hex_alpha <- function(x) {
  # farver decoders operate on opaque colours; drop alpha if provided.
  x <- normalize_hex(x)
  x[grepl("^#[0-9a-f]{8}$", x)] <- substr(x[grepl("^#[0-9a-f]{8}$", x)], 1, 7)
  x
}

lookup_name <- function(name) {
  env <- environment()
  if (!exists("color_names", envir = env, inherits = TRUE)) {
    utils::data("color_names", envir = env)
  }
  cn <- get("color_names", envir = env, inherits = TRUE)
  idx <- match(tolower(name), tolower(cn$name))
  missing <- is.na(idx)
  if (any(missing)) {
    stop(sprintf("Unknown colour name(s): %s", paste(unique(name[missing]), collapse = ", ")), call. = FALSE)
  }
  cn$hex[idx]
}

as_colour_matrix <- function(value, space) {
  cols <- switch(space,
                 rgb = c("r", "g", "b"),
                 hsl = c("h", "s", "l"),
                 oklab = c("l", "a", "b"),
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
                         oklab = c("l", "a", "b"),
                         oklch = c("l", "c", "h"))
  if (nrow(mat) == 1) {
    return(drop(mat[1, ]))
  }
  mat
}
