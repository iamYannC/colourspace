library(colorspace)

test_that("convert can return exact names", {
  expect_equal(convert("#c93f38", from = "hex", to = "name"), "100 Mph")
})

test_that("convert can fallback to nearest name when requested", {
  unknown_hex <- "#111114"
  expect_warning(res <- convert(unknown_hex, from = "hex", to = "name", fallback = "nearest"), "Fallback")
  expect_type(res, "character")
  expect_false(anyNA(res))
})

test_that("convert without fallback yields NA for unknown name mapping", {
  unknown_hex <- "#111114"
  res <- convert(unknown_hex, from = "hex", to = "name", fallback = "none")
  expect_true(is.na(res))
})

test_that("distance argument switches metric", {
  unknown_hex <- "#111114"
  expect_warning(res_lab <- convert(unknown_hex, from = "hex", to = "name", fallback = "nearest", distance = "lab"), "Fallback")
  expect_warning(res_oklch <- convert(unknown_hex, from = "hex", to = "name", fallback = "nearest", distance = "oklch"), "Fallback")
  expect_type(res_lab, "character")
  expect_type(res_oklch, "character")
})
