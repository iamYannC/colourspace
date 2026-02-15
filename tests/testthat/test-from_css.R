test_that("from_css parses OKLCH strings", {
  css <- "oklch(62.792% 0.258 29.221 / 1)"
  hex <- from_css(css, to = "hex")
  expect_type(hex, "character")
  expect_match(hex, "^#[0-9a-f]{6}$")
})

test_that("from_css parses RGB strings", {
  css <- "rgb(255 0 0 / 1)"
  hex <- from_css(css, to = "hex")
  expect_equal(hex, "#ff0000")
})

test_that("from_css parses HSL strings", {
  css <- "hsl(0 100% 50% / 1)"
  hex <- from_css(css, to = "hex")
  expect_equal(hex, "#ff0000")
})

test_that("from_css parses OKLAB strings", {
  css <- "oklab(0.628 0.225 0.126 / 1)"
  hex <- from_css(css, to = "hex")
  expect_type(hex, "character")
  expect_match(hex, "^#[0-9a-f]{6}$")
})

test_that("from_css handles hex colors", {
  hex <- from_css("#ff0000", to = "hex")
  expect_equal(hex, "#ff0000")
})

test_that("from_css converts to different color spaces", {
  css <- "oklch(62.792% 0.258 29.221 / 1)"

  rgb <- from_css(css, to = "rgb")
  expect_type(rgb, "double")
  expect_length(rgb, 3)
  expect_named(rgb, c("r", "g", "b"))

  hsl <- from_css(css, to = "hsl")
  expect_type(hsl, "double")
  expect_length(hsl, 3)
  expect_named(hsl, c("h", "s", "l"))

  oklch <- from_css(css, to = "oklch")
  expect_type(oklch, "double")
  expect_length(oklch, 3)
})

test_that("from_css works with vectorized input", {
  css <- c("oklch(62.792% 0.258 29.221 / 1)", "rgb(0 255 0 / 1)")
  hex <- from_css(css, to = "hex")
  expect_length(hex, 2)
  expect_type(hex, "character")
})

test_that("from_css handles colors without alpha", {
  css <- "oklch(62.792% 0.258 29.221)"
  hex <- from_css(css, to = "hex")
  expect_type(hex, "character")
  expect_match(hex, "^#[0-9a-f]{6}$")
})

test_that("from_css handles various whitespace", {
  css1 <- "oklch( 62.792%  0.258  29.221  /  1 )"
  css2 <- "oklch(62.792% 0.258 29.221 / 1)"
  expect_equal(from_css(css1), from_css(css2))
})

test_that("from_css errors on invalid input", {
  expect_error(from_css("not-a-color"), "Could not parse")
  expect_error(from_css("rgb(255 0)"), "Expected 3 colour components")
  expect_error(from_css("rgb(abc def ghi)"), "Could not parse component")
  expect_error(from_css(123), "must be a character vector")
})

test_that("from_css handles mixed case function names", {
  css1 <- "OKLCH(62.792% 0.258 29.221 / 1)"
  css2 <- "Oklch(62.792% 0.258 29.221 / 1)"
  css3 <- "oklch(62.792% 0.258 29.221 / 1)"
  expect_equal(from_css(css1), from_css(css2))
  expect_equal(from_css(css2), from_css(css3))
})

test_that("from_css returns matrix for multiple colors to numeric spaces", {
  css <- c("rgb(255 0 0 / 1)", "rgb(0 255 0 / 1)")
  rgb <- from_css(css, to = "rgb")
  expect_true(is.matrix(rgb))
  expect_equal(nrow(rgb), 2)
  expect_equal(ncol(rgb), 3)
})

# ---- Legacy comma syntax ----

test_that("from_css handles legacy rgb comma syntax", {
  hex <- from_css("rgb(255, 0, 0)", to = "hex")
  expect_equal(hex, "#ff0000")
})

test_that("from_css handles legacy rgb comma syntax with alpha (ignored)", {
  hex <- from_css("rgb(255, 0, 0, 0.5)", to = "hex")
  expect_equal(hex, "#ff0000")
})

test_that("from_css handles rgba() alias", {
  hex <- from_css("rgba(255, 0, 0, 0.5)", to = "hex")
  expect_equal(hex, "#ff0000")
})

test_that("from_css handles legacy hsl comma syntax", {
  hex <- from_css("hsl(0, 100%, 50%)", to = "hex")
  expect_equal(hex, "#ff0000")
})

test_that("from_css handles hsla() alias", {
  hex <- from_css("hsla(0, 100%, 50%, 0.8)", to = "hex")
  expect_equal(hex, "#ff0000")
})

test_that("from_css strips alpha from 8-digit hex", {
  hex <- from_css("#ff000080", to = "hex")
  expect_equal(hex, "#ff0000")
})

test_that("from_css ignores alpha in modern syntax", {
  expect_equal(from_css("rgb(255 0 0 / 0.2)"), "#ff0000")
  expect_equal(from_css("rgb(255 0 0)"), "#ff0000")
})

test_that("from_css trims leading/trailing whitespace", {
  expect_equal(from_css("  rgb(255 0 0 / 0.2)  "), "#ff0000")
})

# ---- Round-trip ----

test_that("to_css |> from_css round-trip to name works", {
  css <- to_css(c(255, 0, 0), "rgb", "rgb", alpha = 0.5)
  result <- from_css(css, to = "name")
  expect_type(result, "character")
  expect_true(nchar(result) > 0)
})

test_that("from_css user example matches expectation", {
  css_color <- "oklch(62.792% 0.258 29.221 / 1)"
  hex <- from_css(css_color, to = "hex")
  expect_equal(hex, "#ff0000")
})
