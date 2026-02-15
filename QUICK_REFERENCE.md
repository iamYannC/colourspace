# Quick Reference: New Features

## Task A: `fallback = TRUE` is now the default ✓

Good news! This was **already implemented** in your package.

```r
# These all use fallback = TRUE by default:
hex_to_name("#ff0001")              # Returns nearest color name
convert_colourspace(x, to = "name") # Returns nearest color name
to_css("red")                       # Uses fallback when needed

# To get NA for non-exact matches:
hex_to_name("#ff0001", fallback = FALSE)
```

## Task B: New `from_css()` function ✓

Parse CSS color strings and convert to any color space. The `from` argument is auto-detected!

### Basic Usage

```r
# Your example - it works exactly as requested!
css_color <- "oklch(62.792% 0.258 29.221 / 1)"
from_css(css_color, to = "hex")
# [1] "#ff0000"
```

### Supported Input Formats

```r
# OKLCH (recommended modern format)
from_css("oklch(62.792% 0.258 29.221 / 1)", to = "hex")

# RGB
from_css("rgb(255 0 0 / 1)", to = "hex")

# HSL
from_css("hsl(0 100% 50% / 1)", to = "hex")

# OKLAB
from_css("oklab(0.628 0.225 0.126 / 1)", to = "hex")

# Hex colors also work
from_css("#ff0000", to = "oklch")
```

### Output Options

```r
css <- "oklch(62.792% 0.258 29.221 / 1)"

from_css(css, to = "hex")    # "#ff0000"
from_css(css, to = "rgb")    # c(r=255, g=0, b=0)
from_css(css, to = "hsl")    # c(h=0, s=100, l=50)
from_css(css, to = "oklch")  # c(l=0.628, c=0.258, h=29.221)
from_css(css, to = "oklab")  # c(l=0.628, a=0.225, b=0.126)
from_css(css, to = "name")   # Color name (with fallback)
```

### Vectorized

```r
colors <- c(
  "oklch(62.792% 0.258 29.221 / 1)",
  "rgb(0 255 0 / 1)",
  "hsl(240 100% 50% / 1)"
)

from_css(colors, to = "hex")
# [1] "#ff0000" "#00ff00" "#0000ff"
```

### Function Signature

```r
from_css(
  css,                                    # CSS color string(s)
  to = "hex",                             # Output format
  fallback = TRUE,                        # Use fallback for name lookup
  distance = c("lab", "oklch", "rgb", "hsl")  # Distance metric
)
```

## See Also

- `to_css()` - Convert colors TO CSS format
- `convert_colourspace()` - General color space conversion
- `hex_to_*()`, `*_to_hex()` - Specific conversion helpers
