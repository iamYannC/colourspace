library(colourspace)

test_that("convert_colourspace can return exact names", {
  expect_equal(convert_colourspace("#c93f38", from = "hex", to = "name"), "100 Mph")
})

test_that("convert_colourspace can fallback to nearest name when requested", {
  unknown_hex <- "#111114"
  expect_warning(res <- convert_colourspace(unknown_hex, from = "hex", to = "name", fallback = TRUE), "Fallback")
  expect_type(res, "character")
  expect_false(anyNA(res))
})

test_that("convert_colourspace without fallback yields NA for unknown name mapping", {
  unknown_hex <- "#111114"
  res <- convert_colourspace(unknown_hex, from = "hex", to = "name", fallback = FALSE)
  expect_true(is.na(res))
})

test_that("distance argument switches metric", {
  unknown_hex <- "#111114"
  expect_warning(res_lab <- convert_colourspace(unknown_hex, from = "hex", to = "name", fallback = TRUE, distance = "lab"), "Fallback")
  expect_warning(res_oklch <- convert_colourspace(unknown_hex, from = "hex", to = "name", fallback = TRUE, distance = "oklch"), "Fallback")
  expect_type(res_lab, "character")
  expect_type(res_oklch, "character")
})
