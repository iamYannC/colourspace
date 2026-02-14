library(colourspace)

test_that("match_css_space validates supported spaces", {
  expect_equal(colourspace:::match_css_space("HEX"), "hex")
  expect_equal(colourspace:::match_css_space("name", allow_name = TRUE), "name")
  expect_error(colourspace:::match_css_space("cmyk"), "Unsupported format")
})

test_that("is_hex_like detects modern CSS hex forms", {
  expect_true(all(colourspace:::is_hex_like(c("#fff", "fff", "#ffff", "#ff00ff", "ff00ff", "#ff00ff00"))))
  expect_false(colourspace:::is_hex_like("red"))
  expect_false(colourspace:::is_hex_like("#ff00zz"))
})

test_that("infer_from infers hex vs name and rejects mixed input", {
  expect_equal(colourspace:::infer_from(c("#fff", "#000")), "hex")
  expect_equal(colourspace:::infer_from(c("red", "blue")), "name")
  expect_error(colourspace:::infer_from(c("#fff", "red")), "mixed")
})

test_that("css_ncolours detects scalar vs vectorised conversions", {
  expect_equal(colourspace:::css_ncolours(matrix(1:6, ncol = 3, byrow = TRUE), to = "oklch"), 2L)
  expect_equal(colourspace:::css_ncolours(c(l = 0.1, c = 0.2, h = 30), to = "oklch"), 1L)
  expect_equal(colourspace:::css_ncolours(c("#ff0000", "#00ff00"), to = "hex"), 2L)
})

test_that("normalize_css_alpha validates and recycles", {
  expect_equal(colourspace:::normalize_css_alpha(0.5, n = 3), rep(0.5, 3))
  expect_equal(colourspace:::normalize_css_alpha(c(0, 1), n = 2), c(0, 1))
  expect_error(colourspace:::normalize_css_alpha(c(0.1, 0.2), n = 3), "length 1 or 3")
  expect_error(colourspace:::normalize_css_alpha(1.1, n = 1), "between 0 and 1")
})

test_that("fmt_css_number and fmt_css_percent are stable", {
  expect_equal(colourspace:::fmt_css_number(1.23456, 3), "1.235")
  expect_equal(colourspace:::fmt_css_number(1, 3), "1")
  expect_equal(colourspace:::fmt_css_percent(12.3, 3), "12.3%")
})

test_that("format_css_* helpers emit modern functional syntax", {
  expect_equal(colourspace:::format_css_rgb(c(255, 0, 0), alpha = 1), "rgb(255 0 0 / 1)")
  expect_equal(colourspace:::format_css_hsl(c(0, 100, 50), alpha = 1), "hsl(0 100% 50% / 1)")
  expect_equal(colourspace:::format_css_hex("#ff0000", alpha = 0.5), "#ff000080")
  expect_equal(colourspace:::format_css_oklab(c(1, 0, 0), alpha = 1), "oklab(1 0 0 / 1)")

  # Hue is canonicalised when chroma rounds to 0.
  expect_equal(
    colourspace:::format_css_oklch(c(0.99999, 0, 274.031), alpha = 1),
    "oklch(100% 0 0 / 1)"
  )
})
