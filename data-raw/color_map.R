# Build a lookup table with multiple colour spaces for nearest-name fallbacks

if (!requireNamespace("farver", quietly = TRUE)) {
  stop("Package 'farver' is required to build the color_map dataset.")
}

# ============================================================================
# Load color_names dataset
# ============================================================================

# In data-raw context, load the .rda file directly
load("data/color_names.rda")

# ============================================================================
# Build color_map with multiple color spaces
# ============================================================================

color_map <- color_names

# Decode to LAB color space
lab <- farver::decode_colour(color_map$hex, to = "lab")
colnames(lab) <- c("lab_l", "lab_a", "lab_b")

# Decode to OKLCH color space
oklch <- farver::decode_colour(color_map$hex, to = "oklch")
colnames(oklch) <- c("oklch_l", "oklch_c", "oklch_h")

# Decode to RGB color space
rgb <- farver::decode_colour(color_map$hex, to = "rgb")
colnames(rgb) <- c("rgb_r", "rgb_g", "rgb_b")

# Decode to HSL color space
hsl <- farver::decode_colour(color_map$hex, to = "hsl")
colnames(hsl) <- c("hsl_h", "hsl_s", "hsl_l")

# Combine all color spaces into color_map
color_map <- cbind(color_map, lab, oklch, rgb, hsl)

# ============================================================================
# Save dataset
# ============================================================================

usethis::use_data(color_map, overwrite = TRUE)
