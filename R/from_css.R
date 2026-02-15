#' Parse CSS color strings
#'
#' Parse CSS color function strings (e.g., `oklch(...)`, `rgb(...)`, `hsl(...)`)
#' or hex colors and convert them to a target color space. Automatically detects
#' the input format from the CSS syntax.
#'
#' Both modern (space-separated) and legacy (comma-separated) CSS notations are
#' supported:
#'
#' \itemize{
#'   \item Modern: `rgb(255 0 0)`, `rgb(255 0 0 / 0.5)`
#'   \item Legacy: `rgb(255, 0, 0)`, `rgb(255, 0, 0, 0.5)`
#'   \item Legacy with explicit alpha: `rgba(255, 0, 0, 0.5)`
#' }
#'
#' Alpha channels are currently parsed but **ignored** during conversion.
#'
#' @param css Character vector of CSS color strings. Supported formats:
#'   \itemize{
#'     \item `oklch(L C H)`, `oklch(L C H / A)`
#'     \item `oklab(L A B)`, `oklab(L A B / A)`
#'     \item `rgb(R G B)`, `rgb(R G B / A)`, `rgb(R, G, B)`, `rgb(R, G, B, A)`
#'     \item `rgba(R, G, B, A)`
#'     \item `hsl(H S L)`, `hsl(H S L / A)`, `hsl(H, S, L)`, `hsl(H, S, L, A)`
#'     \item `hsla(H, S, L, A)`
#'     \item Hex colors: `#rgb`, `#rrggbb`, `#rrggbbaa`
#'   }
#' @param to Target colour space. One of `"hex"` (default), `"rgb"`, `"hsl"`,
#'   `"oklab"`, `"oklch"`, or `"name"`.
#' @param fallback Behaviour when mapping `to = "name"` and no exact
#'   hex/name match is found. `TRUE` (default) returns the closest named
#'   colour using `distance` (a warning is issued). `FALSE` returns `NA`
#'   for unknown colours.
#' @param distance Distance metric for nearest-colour fallback: one of
#'   `"lab"` (default), `"oklch"`, `"rgb"`, or `"hsl"`.
#' @return For scalar inputs, a named numeric vector (or hex string or colour
#'   name). For vectorised inputs, a matrix with one row per input colour or a
#'   character vector for `to = "name"` or `to = "hex"`.
#' @examples
#' # Parse OKLCH CSS string to hex
#' from_css("oklch(62.792% 0.258 29.221 / 1)")
#'
#' # Parse RGB CSS string (modern & legacy)
#' from_css("rgb(255 0 0 / 1)", to = "oklch")
#' from_css("rgb(255, 0, 0)", to = "hex")
#'
#' # Parse HSL CSS string
#' from_css("hsl(210 50% 40% / 1)", to = "rgb")
#'
#' # Also works with hex colors
#' from_css("#ff0000", to = "oklch")
#'
#' # Vectorized
#' from_css(c("oklch(62.792% 0.258 29.221 / 1)", "rgb(0 255 0 / 1)"))
#' @export
from_css <- function(css, to = "hex", fallback = TRUE,
                     distance = c("lab", "oklch", "rgb", "hsl")) {
  if (!is.character(css)) {
    stop("`css` must be a character vector", call. = FALSE)
  }
  distance <- match.arg(distance)
  to <- match_space(to, allow_name = TRUE)

  # Process each color string
  results <- lapply(css, function(x) {
    parsed <- parse_single_css(x)
    convert_colourspace(
      parsed$value,
      from = parsed$space,
      to = to,
      fallback = fallback,
      distance = distance
    )
  })

  # Format output
  if (to %in% c("hex", "name")) {
    unlist(results)
  } else if (length(results) == 1) {
    results[[1]]
  } else {
    do.call(rbind, results)
  }
}

#' Parse a single CSS color string into space and value.
#'
#' @return A list with elements:
#'   - `space`: character, the colour space
#'   - `value`: colour value suitable for `convert_colourspace()`
#' @noRd
parse_single_css <- function(css) {
  css <- trimws(css)

  # --- Hex colours ---
  if (grepl("^#", css)) {
    hex <- normalize_hex(css)
    # Strip alpha from 8-digit hex (ignored for now)
    if (nchar(hex) == 9) {
      hex <- substr(hex, 1, 7)
    }
    return(list(space = "hex", value = hex))
  }

  # --- Functional notation: fname(...) ---
  # Accept rgba/hsla as aliases for rgb/hsl
  pattern <- "^(oklch|oklab|rgba?|hsla?)\\s*\\((.+)\\)\\s*$"
  if (!grepl(pattern, css, ignore.case = TRUE)) {
    stop(sprintf("Could not parse CSS color string: '%s'", css), call. = FALSE)
  }

  matches <- regmatches(css, regexec(pattern, css, ignore.case = TRUE))[[1]]
  fname <- tolower(matches[2])
  content <- trimws(matches[3])

  # Normalize function name: rgba -> rgb, hsla -> hsl
  space <- sub("a$", "", fname)

  # Detect syntax style: comma-separated (legacy) vs space-separated (modern)
  has_commas <- grepl(",", content)

  if (has_commas) {
    parse_legacy_css(content, space, css)
  } else {
    parse_modern_css(content, space, css)
  }
}

#' Parse modern CSS syntax (space-separated, alpha after `/`).
#' e.g. "255 0 0 / 0.5", "62.792% 0.258 29.221 / 1"
#' @noRd
parse_modern_css <- function(content, space, original) {
  # Split by / to separate colour components from alpha (alpha is ignored)
  slash_parts <- strsplit(content, "/")[[1]]
  components_str <- trimws(slash_parts[1])

  comp_parts <- strsplit(components_str, "\\s+")[[1]]

  if (length(comp_parts) != 3) {
    stop(sprintf("Expected 3 colour components in '%s', got %d", original, length(comp_parts)),
         call. = FALSE)
  }

  values <- parse_css_components(comp_parts, space, original)
  list(space = space, value = values)
}

#' Parse legacy CSS syntax (comma-separated, alpha as 4th value).
#' e.g. "255, 0, 0, 0.5", "0, 100%, 50%, 0.5"
#' @noRd
parse_legacy_css <- function(content, space, original) {
  parts <- strsplit(content, ",")[[1]]
  parts <- trimws(parts)

  if (length(parts) == 3) {
    # No alpha
  } else if (length(parts) == 4) {
    # Alpha present but ignored for now
    parts <- parts[1:3]
  } else {
    stop(sprintf("Expected 3 or 4 comma-separated values in '%s', got %d",
                 original, length(parts)), call. = FALSE)
  }

  values <- parse_css_components(parts, space, original)
  list(space = space, value = values)
}

#' Parse 3 CSS colour components into numeric values, handling percentages.
#' @noRd
parse_css_components <- function(parts, space, original) {
  values <- numeric(3)

  for (i in 1:3) {
    val_str <- parts[i]
    is_pct <- grepl("%$", val_str)

    if (is_pct) {
      val_str <- sub("%$", "", val_str)
    }

    val <- suppressWarnings(as.numeric(val_str))
    if (is.na(val)) {
      stop(sprintf("Could not parse component '%s' in '%s'", parts[i], original),
           call. = FALSE)
    }

    if (is_pct) {
      if (space == "oklch" && i == 1) {
        val <- val / 100
      } else if (space == "oklab" && i == 1) {
        val <- val / 100
      } else if (space == "rgb") {
        val <- val * 255 / 100
      }
      # hsl S and L percentages: keep as-is (farver expects 0-100)
    }

    values[i] <- val
  }

  values
}
