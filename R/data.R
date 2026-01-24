#' CSS color names to HEX mapping
#'
#' A dataset containing 31k+ color names compiled by the
#' [meodai/color-names](https://github.com/meodai/color-names) project.
#'
#' @format A data frame with two columns:
#' \describe{
#'   \item{name}{Color name as provided by the source (character).}
#'   \item{hex}{Lowercase hex triplet starting with '#'.}
#' }
#' @source <https://github.com/meodai/color-names>
"color_names"

#' Precomputed colour map for nearest-name lookup
#'
#' A data frame containing each colour name, hex code, and coordinates in
#' multiple colour spaces for fast nearest-neighbour search.
#'
#' @format A data frame with the following columns:
#' \describe{
#'   \item{name}{Colour name (character).}
#'   \item{hex}{Lowercase hex code starting with '#'.}
#'   \item{lab_l, lab_a, lab_b}{CIELAB components.}
#'   \item{oklch_l, oklch_c, oklch_h}{OKLCH components.}
#'   \item{rgb_r, rgb_g, rgb_b}{sRGB components (0-255).}
#'   \item{hsl_h, hsl_s, hsl_l}{HSL components.}
#' }
#' @source Derived from \code{color_names} using farver decoders.
"color_map"
