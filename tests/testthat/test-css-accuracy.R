library(testthat)

# Tests for CSS Color Level 4 accuracy improvements:
#   - 4 decimal places (not 3)
#   - Achromatic hue → "none" (not 0)
#   - Alpha = 1 omitted (not "/ 1")

# ── Precision: 4 decimals ────────────────────────────────────────────────────

test_that("to_css emits 4-decimal precision for oklch", {
  expect_equal(
    to_css("red", from = "name", to = "oklch", alpha = 1),
    "oklch(62.7915% 0.2577 29.2211)"
  )
  expect_equal(
    to_css("blue", from = "name", to = "oklch", alpha = 1),
    "oklch(45.203% 0.3133 264.068)"
  )
  expect_equal(
    to_css("#ff5a3c", from = "hex", to = "oklch", alpha = 0.8),
    "oklch(68.4473% 0.2058 32.5137 / 0.8)"
  )
})

test_that("fmt_css_number defaults to 4 decimals", {
  expect_equal(colourspace:::fmt_css_number(1.23456), "1.2346")
  expect_equal(colourspace:::fmt_css_number(1), "1")
  expect_equal(colourspace:::fmt_css_percent(12.3), "12.3%")
  expect_equal(colourspace:::fmt_css_percent(12.34567), "12.3457%")
})

# ── Achromatic hue: "none" ───────────────────────────────────────────────────

test_that("achromatic colors use 'none' for hue in oklch", {
  expect_equal(
    to_css("#FFFFFF", from = "hex", to = "oklch", alpha = 1),
    "oklch(100% 0 none)"
  )
  expect_equal(
    to_css("black", alpha = 0),
    "oklch(0% 0 none / 0)"
  )
  expect_equal(
    colourspace:::format_css_oklch(c(0.99999, 0, 274.031), alpha = 1),
    "oklch(100% 0 none)"
  )
})

test_that("from_css parses 'none' keyword as 0", {
  expect_equal(from_css("oklch(100% 0 none)"), "#ffffff")
  expect_equal(from_css("oklch(0% 0 none)"), "#000000")
  expect_equal(
    from_css("oklch(100% 0 none)", to = "oklch"),
    c(1, 0, 0)
  )
})

# ── Alpha omission ───────────────────────────────────────────────────────────

test_that("alpha = 1 is omitted from CSS output", {
  expect_no_match(to_css("red", alpha = 1), "/ 1")
  expect_no_match(
    colourspace:::format_css_rgb(c(255, 0, 0), alpha = 1),
    "/"
  )
  expect_no_match(
    colourspace:::format_css_hsl(c(0, 100, 50), alpha = 1),
    "/"
  )
  expect_no_match(
    colourspace:::format_css_oklab(c(1, 0, 0), alpha = 1),
    "/"
  )
})

test_that("non-unit alpha is still emitted", {
  expect_match(to_css("red", alpha = 0.5), "/ 0.5\\)$")
  expect_match(to_css("black", alpha = 0), "/ 0\\)$")
  expect_equal(
    to_css("red", alpha = 0.1234),
    "oklch(62.7915% 0.2577 29.2211 / 0.1234)"
  )
})

test_that("format helpers emit clean output without / 1", {
  expect_equal(
    colourspace:::format_css_rgb(c(255, 0, 0), alpha = 1),
    "rgb(255 0 0)"
  )
  expect_equal(
    colourspace:::format_css_hsl(c(0, 100, 50), alpha = 1),
    "hsl(0 100% 50%)"
  )
  expect_equal(
    colourspace:::format_css_oklab(c(1, 0, 0), alpha = 1),
    "oklab(1 0 0)"
  )
  expect_equal(
    colourspace:::format_css_rgb(c(255, 0, 0), alpha = 0.5),
    "rgb(255 0 0 / 0.5)"
  )
})

# ── Round-trip stability ─────────────────────────────────────────────────────

test_that("round-trip hex -> oklch -> hex is stable", {
  hex <- "#e63946"
  oklch <- hex_to_oklch(hex)
  back <- oklch_to_hex(oklch)
  expect_equal(back, hex)
})

test_that("round-trip name -> hex -> rgb -> hex -> oklch is stable", {
  h1 <- name_to_hex("coral")
  r <- hex_to_rgb(h1)
  h2 <- rgb_to_hex(r)
  oklch1 <- hex_to_oklch(h1)
  oklch2 <- hex_to_oklch(h2)
  expect_equal(oklch1, oklch2)
})
