# colorspace

Enhances R's colour handling for designers and Shiny developers with CSS-ready conversions between HEX, RGB, HSL, and OKLCH, plus a 31k+ colour name lookup sourced from [meodai/color-names](https://github.com/meodai/color-names).

## Install (local dev)

```r
# from project root
remotes::install_local()
```

## Usage

```r
library(colorspace)

# General conversion
convert("#ff9900", from = "hex", to = "oklch")

# Named colour lookup + piping
name_to_hex("100 Mph") |>
  hex_to_hsl()

# Vectorised conversions
hex_to_rgb(c("#ff0000", "#00ff00", "#0000ff"))
```

## Data source

The `color_names` dataset is derived from the `colornames.csv` file in the
meodai/color-names repository (retrieved January 24, 2026). Names are matched
case-insensitively and mapped to lowercase hex codes.

## Development

- Roxygen2 docs (`devtools::document()`)
- Tests (`devtools::test()`)
- Pkgdown site (`pkgdown::build_site()`)

Feel free to open branches per feature before merging into `main` to mirror the
workflow used here.
