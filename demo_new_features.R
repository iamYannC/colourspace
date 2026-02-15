library(colourspace)

# ============================================================
# TASK A: fallback = TRUE is now the default
# ============================================================

# Previously, you had to specify fallback = TRUE explicitly
# Now it's the default behavior

# When converting to "name", if exact match not found, 
# it returns the nearest named color
hex_to_name("#ff0001")  # Close to red, gets nearest name
hex_to_name("#111114")  # Close to black, gets nearest name

# To get NA for non-exact matches, set fallback = FALSE
hex_to_name("#ff0001", fallback = FALSE)  # Returns NA


# ============================================================
# TASK B: New from_css() function
# ============================================================

# Parse CSS color strings and convert to any color space
# The `from` argument is auto-detected!

# Example from your request:
css_color <- "oklch(62.792% 0.258 29.221 / 1)"
from_css(css_color, to = "hex")
# [1] "#ff0000"

# Works with different CSS formats:
from_css("rgb(255 0 0 / 1)", to = "hex")
from_css("hsl(0 100% 50% / 1)", to = "hex")  
from_css("oklab(0.628 0.225 0.126 / 1)", to = "hex")

# Also works with hex colors (for convenience):
from_css("#ff0000", to = "oklch")

# Convert to any color space:
from_css("oklch(62.792% 0.258 29.221 / 1)", to = "rgb")
from_css("oklch(62.792% 0.258 29.221 / 1)", to = "hsl")
from_css("oklch(62.792% 0.258 29.221 / 1)", to = "name")

# Vectorized:
colors <- c("oklch(62.792% 0.258 29.221 / 1)", 
            "rgb(0 255 0 / 1)",
            "hsl(240 100% 50% / 1)")
from_css(colors, to = "hex")
