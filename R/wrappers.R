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
