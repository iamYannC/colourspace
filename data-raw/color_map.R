# Build a lookup table with multiple colour spaces for nearest-name fallbacks

if (!requireNamespace("farver", quietly = TRUE)) {
  stop("Package 'farver' is required to build the color_map dataset.")
}

# Use existing color_names dataset
if (!exists("color_names")) {
  load("data/color_names.rda")
}

color_map <- color_names

lab <- farver::decode_colour(color_map$hex, to = "lab")
colnames(lab) <- c("lab_l", "lab_a", "lab_b")

oklch <- farver::decode_colour(color_map$hex, to = "oklch")
colnames(oklch) <- c("oklch_l", "oklch_c", "oklch_h")

rgb <- farver::decode_colour(color_map$hex, to = "rgb")
colnames(rgb) <- c("rgb_r", "rgb_g", "rgb_b")

hsl <- farver::decode_colour(color_map$hex, to = "hsl")
colnames(hsl) <- c("hsl_h", "hsl_s", "hsl_l")

color_map <- cbind(color_map, lab, oklch, rgb, hsl)

usethis::use_data(color_map, overwrite = TRUE)
