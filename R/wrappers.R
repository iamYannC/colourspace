#' Convert HEX to RGB
#'
#' @param hex Character vector of hex colour strings.
#' @return Numeric vector (length 3) or matrix with columns `r`, `g`, `b`.
#' @examples
#' hex_to_rgb("#336699")
#' @export
hex_to_rgb <- function(hex) {
  convert(hex, from = "hex", to = "rgb")
}

#' Convert RGB to HEX
#'
#' @param rgb Numeric vector/matrix of RGB values (0-255).
#' @return Character vector of hex colours.
#' @examples
#' rgb_to_hex(c(51, 102, 153))
#' @export
rgb_to_hex <- function(rgb) {
  convert(rgb, from = "rgb", to = "hex")
}

#' Convert HEX to HSL
#'
#' @param hex Character vector of hex colour strings.
#' @return Numeric vector (length 3) or matrix with columns `h`, `s`, `l`.
#' @examples
#' hex_to_hsl("#336699")
#' @export
hex_to_hsl <- function(hex) {
  convert(hex, from = "hex", to = "hsl")
}

#' Convert HSL to HEX
#'
#' @param hsl Numeric vector/matrix of HSL values (h: 0-360, s/l: 0-100).
#' @return Character vector of hex colours.
#' @examples
#' hsl_to_hex(c(210, 50, 40))
#' @export
hsl_to_hex <- function(hsl) {
  convert(hsl, from = "hsl", to = "hex")
}

#' Convert HEX to OKLCH
#'
#' @param hex Character vector of hex colour strings.
#' @return Numeric vector (length 3) or matrix with columns `l`, `c`, `h`.
#' @examples
#' hex_to_oklch("#ff0000")
#' @export
hex_to_oklch <- function(hex) {
  convert(hex, from = "hex", to = "oklch")
}

#' Convert OKLCH to HEX
#'
#' @param oklch Numeric vector/matrix of OKLCH values (`l` in 0-1, `c` >= 0, `h` in degrees).
#' @return Character vector of hex colours.
#' @examples
#' oklch_to_hex(c(0.628, 0.258, 29.221))
#' @export
oklch_to_hex <- function(oklch) {
  convert(oklch, from = "oklch", to = "hex")
}

#' Convert colour name to HEX
#'
#' Looks up CSS-style colour names from the bundled meodai list and returns hex
#' values.
#' @param name Character vector of colour names (case-insensitive).
#' @return Character vector of hex colours.
#' @examples
#' name_to_hex(\"100 Mph\")
#' @export
name_to_hex <- function(name) {
  convert(name, from = "name", to = "hex")
}
