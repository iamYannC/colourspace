library(colourspace)

test_that("hex_to_name wraps convert_colourspace for exact matches", {
  expect_equal(hex_to_name("#c93f38"), "100 Mph")
})

test_that("hex_to_name supports nearest-name fallback", {
  unknown_hex <- "#111114"
  expect_warning(res <- hex_to_name(unknown_hex, fallback = TRUE), "Fallback")
  expect_type(res, "character")
  expect_false(anyNA(res))
})
