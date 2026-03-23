library(colourspace)

test_that("convert_colourspace can return exact names", {
  expect_equal(convert_colourspace("#c93f38", from = "hex", to = "name"), "100 Mph")
})

test_that("convert_colourspace can fallback to nearest name when requested", {
  unknown_hex <- "#111114"
  expect_warning(
    res <- convert_colourspace(unknown_hex, from = "hex", to = "name", fallback = "all"),
    "Fallback"
  )
  expect_type(res, "character")
  expect_false(anyNA(res))
})

test_that("convert_colourspace without fallback yields NA for unknown name mapping", {
  unknown_hex <- "#111114"
  res <- convert_colourspace(unknown_hex, from = "hex", to = "name", fallback = "none")
  expect_true(is.na(res))
})

test_that("fallback = 'r' returns an R built-in colour name", {
  unknown_hex <- "#111114"
  res <- hex_to_name(unknown_hex, fallback = "r")
  expect_type(res, "character")
  expect_false(is.na(res))
  expect_true(tolower(res) %in% grDevices::colors())
})

test_that("fallback = 'r' returns R colour even when exact extended match exists", {
  # "#c93f38" has an exact match ("100 Mph") in the extended database,

  # but fallback = "r" should return the nearest R built-in colour instead.
  res <- hex_to_name("#c93f38", fallback = "r")
  expect_type(res, "character")
  expect_true(tolower(res) %in% grDevices::colors())
})

test_that("fallback = 'r' is vectorised and all results are R colours", {
  hexes <- c("#a1b2c3", "#ff5733", "#111114", "#c93f38")
  res <- hex_to_name(hexes, fallback = "r")
  expect_length(res, 4)
  expect_false(anyNA(res))
  expect_true(all(tolower(res) %in% grDevices::colors()))
})
