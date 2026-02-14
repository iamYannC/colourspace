#' Format colours as modern CSS color functions
#'
#' Convert colours between supported spaces and return a character vector in
#' modern CSS Color 4 functional notation (space-separated components with an
#' optional alpha channel introduced by `/`).
#'
#' @param value Colour input. For `from = "hex"` or `from = "name"`, a
#'   character vector. For numeric spaces (`rgb`, `hsl`, `oklch`, `oklab`), a
#'   numeric vector of length 3, matrix/data frame with three columns, or a
#'   list of such vectors.
#' @param from Source colour space. One of `"hex"`, `"rgb"`, `"hsl"`, `"oklab"`,
#'   `"oklch"`, or `"name"`. If `NULL` (default), `to_css()` will infer `"hex"`
#'   vs `"name"` for character inputs.
#' @param to Target CSS function. One of `"oklch"` (default), `"oklab"`, `"rgb"`,
#'   `"hsl"`, or `"hex"`.
#' @param alpha Alpha channel as numbers in `[0, 1]`. Recycled to match the
#'   number of colours.
#' @param fallback Behaviour when `from = "name"` (via
#'   [convert_colourspace()]/[name_to_hex()]) or when generating names
#'   elsewhere. `TRUE` (default) returns the closest named colour;
#'   `FALSE` returns `NA`. Included for API consistency with
#'   [convert_colourspace()].
#' @param distance Distance metric used for nearest-name fallback when
#'   applicable. Included for API consistency with [convert_colourspace()].
#' @return A character vector of CSS colors.
#' @seealso
#'   [OKLCH in CSS: why we moved from RGB and HSL](https://evilmartians.com/chronicles/oklch-in-css-why-quit-rgb-hsl)
#'   for a detailed explanation of why OKLCH is the recommended colour space
#'   for modern CSS.
#' @examples
#' to_css("red")
#' to_css("#ff5a3c", from = "hex", to = "oklch", alpha = 0.8)
#' to_css(c("#ff0000", "#00ff00"), to = "rgb", alpha = c(1, 0.5))
#' @export
to_css <- function(value,
                   from = NULL,
                   to = c("oklch", "oklab", "rgb", "hsl", "hex"),
                   alpha = 1,
                   fallback = TRUE,
                   distance = c("lab", "oklch", "rgb", "hsl")) {
  to <- match.arg(to)
  if (!is.logical(fallback) || length(fallback) != 1L) {
    stop("`fallback` must be TRUE or FALSE.", call. = FALSE)
  }
  distance <- match.arg(distance)

  if (is.null(from)) {
    from <- infer_from(value)
  }
  from <- match_css_space(from, allow_name = TRUE)

  # Convert first (so we can recycle alpha against the actual output length).
  converted <- convert_colourspace(value, from = from, to = if (to == "hex") "hex" else to,
                       fallback = fallback, distance = distance)
  n <- css_ncolours(converted, to = to)
  alpha <- normalize_css_alpha(alpha, n = n)

  out <- switch(
    to,
    oklch = format_css_oklch(converted, alpha),
    oklab = format_css_oklab(converted, alpha),
    rgb = format_css_rgb(converted, alpha),
    hsl = format_css_hsl(converted, alpha),
    hex = format_css_hex(converted, alpha)
  )

  if (is.character(value) && !is.null(names(value)) && length(names(value)) == length(out)) {
    names(out) <- names(value)
  }
  out
}

match_css_space <- function(x, allow_name = FALSE) {
  valid <- c("hex", "rgb", "hsl", "oklab", "oklch")
  if (allow_name) {
    valid <- c("name", valid)
  }
  x <- tolower(x)
  if (!x %in% valid) {
    stop(sprintf("Unsupported format '%s' (supported: %s)", x, paste(valid, collapse = ", ")), call. = FALSE)
  }
  x
}

infer_from <- function(value) {
  if (is.character(value)) {
    ok <- !is.na(value)
    if (!any(ok)) {
      return("hex")
    }
    is_hex <- is_hex_like(value[ok])
    if (all(is_hex)) {
      return("hex")
    }
    if (!any(is_hex)) {
      return("name")
    }
    stop("Cannot infer `from` for mixed hex/name input; please set `from=` explicitly.", call. = FALSE)
  }

  stop("Cannot infer `from` for non-character input; please set `from=`.", call. = FALSE)
}

is_hex_like <- function(x) {
  if (!is.character(x)) return(FALSE)
  x <- trimws(x)
  x <- ifelse(startsWith(x, "#"), substring(x, 2), x)
  grepl("^([0-9a-fA-F]{3}|[0-9a-fA-F]{4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$", x)
}

css_ncolours <- function(converted, to) {
  if (to == "hex") {
    return(length(converted))
  }
  if (is.matrix(converted)) {
    return(nrow(converted))
  }
  # Scalar conversion to numeric spaces returns a length-3 vector.
  if (is.numeric(converted) && length(converted) == 3) {
    return(1L)
  }
  length(converted)
}

normalize_css_alpha <- function(alpha, n) {
  alpha <- as.numeric(alpha)
  if (anyNA(alpha) || any(!is.finite(alpha))) {
    stop("alpha must be a finite numeric value in [0, 1].", call. = FALSE)
  }
  if (!(length(alpha) %in% c(1L, n))) {
    stop(sprintf("alpha must have length 1 or %d (got %d).", n, length(alpha)), call. = FALSE)
  }
  if (any(alpha < 0 | alpha > 1)) {
    stop("alpha must be between 0 and 1", call. = FALSE)
  }
  if (length(alpha) == 1L) {
    alpha <- rep(alpha, n)
  }
  alpha
}

fmt_css_number <- function(x, digits = 3) {
  # Round to a fixed number of decimal places, then trim trailing zeros.
  x <- round(x, digits = digits)
  out <- format(x, trim = TRUE, scientific = FALSE)
  out
}

fmt_css_percent <- function(x, digits = 3) {
  paste0(fmt_css_number(x, digits = digits), "%")
}

format_css_oklch <- function(oklch, alpha) {
  mat <- if (is.matrix(oklch)) oklch else matrix(oklch, nrow = 1)
  l <- mat[, 1]
  c <- mat[, 2]
  h <- mat[, 3]

  # Keep output stable for common edge cases (e.g. white/black).
  l <- pmax(0, pmin(1, l))
  c <- pmax(0, c)
  eps <- 1e-4
  l[abs(l) < eps] <- 0
  l[abs(l - 1) < eps] <- 1

  # Hue is undefined at C == 0; canonicalise to 0 when chroma rounds to 0.
  h[round(c, 3) == 0] <- 0

  paste0(
    "oklch(",
    fmt_css_percent(l * 100, 3), " ",
    fmt_css_number(c, 3), " ",
    fmt_css_number(h, 3),
    " / ", fmt_css_number(alpha, 3),
    ")"
  )
}

format_css_oklab <- function(oklab, alpha) {
  mat <- if (is.matrix(oklab)) oklab else matrix(oklab, nrow = 1)
  l <- mat[, 1]
  a <- mat[, 2]
  b <- mat[, 3]
  l <- pmax(0, pmin(1, l))
  eps <- 1e-4
  l[abs(l) < eps] <- 0
  l[abs(l - 1) < eps] <- 1
  paste0("oklab(", fmt_css_number(l, 3), " ", fmt_css_number(a, 3), " ", fmt_css_number(b, 3), " / ", fmt_css_number(alpha, 3), ")")
}

format_css_rgb <- function(rgb, alpha) {
  mat <- if (is.matrix(rgb)) rgb else matrix(rgb, nrow = 1)
  r <- round(mat[, 1])
  g <- round(mat[, 2])
  b <- round(mat[, 3])
  paste0("rgb(", r, " ", g, " ", b, " / ", fmt_css_number(alpha, 3), ")")
}

format_css_hsl <- function(hsl, alpha) {
  mat <- if (is.matrix(hsl)) hsl else matrix(hsl, nrow = 1)
  h <- mat[, 1]
  s <- mat[, 2]
  l <- mat[, 3]
  paste0("hsl(", fmt_css_number(h, 3), " ", fmt_css_percent(s, 3), " ", fmt_css_percent(l, 3), " / ", fmt_css_number(alpha, 3), ")")
}

format_css_hex <- function(hex, alpha) {
  hex <- normalize_hex(hex)
  if (all(alpha == 1)) {
    return(hex)
  }

  a <- sprintf("%02x", as.integer(round(alpha * 255)))
  if (length(a) == 1L && length(hex) > 1L) {
    a <- rep(a, length(hex))
  }
  paste0(substr(hex, 1, 7), a)
}
