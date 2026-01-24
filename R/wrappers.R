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
