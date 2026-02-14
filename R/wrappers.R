#' Convert HEX to RGB
#'
#' @param hex Character vector of hex colour strings.
#' @param ... Additional options passed to [convert_colourspace()].
#' @return Numeric vector (length 3) or matrix with columns `r`, `g`, `b`.
#' @examples
#' hex_to_rgb("#336699")
#' @export
hex_to_rgb <- function(hex, ...) {
  convert_colourspace(hex, from = "hex", to = "rgb", ...)
}

#' Convert RGB to HEX
#'
#' @param rgb Numeric vector/matrix of RGB values (0-255).
#' @param ... Additional options passed to [convert_colourspace()].
#' @return Character vector of hex colours.
#' @examples
#' rgb_to_hex(c(51, 102, 153))
#' @export
rgb_to_hex <- function(rgb, ...) {
  convert_colourspace(rgb, from = "rgb", to = "hex", ...)
}

#' Convert HEX to HSL
#'
#' @param hex Character vector of hex colour strings.
#' @param ... Additional options passed to [convert_colourspace()].
#' @return Numeric vector (length 3) or matrix with columns `h`, `s`, `l`.
#' @examples
#' hex_to_hsl("#336699")
#' @export
hex_to_hsl <- function(hex, ...) {
  convert_colourspace(hex, from = "hex", to = "hsl", ...)
}

#' Convert HSL to HEX
#'
#' @param hsl Numeric vector/matrix of HSL values (h: 0-360, s/l: 0-100).
#' @param ... Additional options passed to [convert_colourspace()].
#' @return Character vector of hex colours.
#' @examples
#' hsl_to_hex(c(210, 50, 40))
#' @export
hsl_to_hex <- function(hsl, ...) {
  convert_colourspace(hsl, from = "hsl", to = "hex", ...)
}

#' Convert HEX to OKLCH
#'
#' @param hex Character vector of hex colour strings.
#' @param ... Additional options passed to [convert_colourspace()].
#' @return Numeric vector (length 3) or matrix with columns `l`, `c`, `h`.
#' @examples
#' hex_to_oklch("#ff0000")
#' @export
hex_to_oklch <- function(hex, ...) {
  convert_colourspace(hex, from = "hex", to = "oklch", ...)
}

#' Convert OKLCH to HEX
#'
#' @param oklch Numeric vector/matrix of OKLCH values (`l` in 0-1, `c` >= 0, `h` in degrees).
#' @param ... Additional options passed to [convert_colourspace()].
#' @return Character vector of hex colours.
#' @examples
#' oklch_to_hex(c(0.628, 0.258, 29.221))
#' @export
oklch_to_hex <- function(oklch, ...) {
  convert_colourspace(oklch, from = "oklch", to = "hex", ...)
}

#' Convert colour name to HEX
#'
#' Looks up CSS-style colour names from the bundled meodai list and returns hex
#' values.
#' @param name Character vector of colour names (case-insensitive).
#' @param ... Additional options passed to [convert_colourspace()].
#' @return Character vector of hex colours.
#' @examples
#' name_to_hex("100 Mph")
#' @export
name_to_hex <- function(name, ...) {
  convert_colourspace(name, from = "name", to = "hex", ...)
}

#' Convert HEX to OKLAB
#'
#' @param hex Character vector of hex colour strings.
#' @param ... Additional options passed to [convert_colourspace()].
#' @return Numeric vector (length 3) or matrix with columns `l`, `a`, `b`.
#' @examples
#' hex_to_oklab("#ff0000")
#' @export
hex_to_oklab <- function(hex, ...) {
  convert_colourspace(hex, from = "hex", to = "oklab", ...)
}

#' Convert OKLAB to HEX
#'
#' @param oklab Numeric vector/matrix of OKLAB values (`l` in 0-1).
#' @param ... Additional options passed to [convert_colourspace()].
#' @return Character vector of hex colours.
#' @examples
#' oklab_to_hex(c(0.628, 0.225, 0.126))
#' @export
oklab_to_hex <- function(oklab, ...) {
  convert_colourspace(oklab, from = "oklab", to = "hex", ...)
}

#' Convert HEX to colour name
#'
#' Reverse lookup using the bundled name database. When an exact match is not
#' found, you can return the nearest named colour (`fallback = TRUE`, the
#' default) or `NA` (`fallback = FALSE`).
#'
#' @param hex Character vector of hex colour strings.
#' @param fallback `TRUE` (default) to return the nearest named colour when
#'   no exact match exists, or `FALSE` to return `NA`.
#' @param distance Distance metric for nearest-colour fallback: one of `"lab"`
#'   (default), `"oklch"`, `"rgb"`, or `"hsl"`.
#' @param ... Additional options passed to [convert_colourspace()].
#' @return Character vector of colour names (or `NA`).
#' @examples
#' hex_to_name("#c93f38")
#' hex_to_name("#111114", fallback = TRUE)
#' @export
hex_to_name <- function(hex, fallback = TRUE,
                        distance = c("lab", "oklch", "rgb", "hsl"), ...) {
  convert_colourspace(hex, from = "hex", to = "name", fallback = fallback, distance = distance, ...)
}
