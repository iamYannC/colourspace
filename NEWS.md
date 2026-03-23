# colourspace 0.1.1

## CSS output accuracy

- Numeric precision increased from 3 to 4 decimal places.
- Achromatic colors (zero chroma) now use `none` for hue, per CSS Color Level 4 spec.
- Alpha omitted when equal to 1 (full opacity is the CSS default).
- `from_css()` now parses the `none` keyword.

## Fallback redesign

- `fallback` argument changed from `TRUE`/`FALSE` to `"all"`, `"r"`, or `"none"`.
- `fallback = "r"` returns the nearest R built-in colour name (from `grDevices::colors()`).
- `distance` argument removed from all functions. Lab distance is used internally.

# colourspace 0.0.1

- Initial CRAN release.
