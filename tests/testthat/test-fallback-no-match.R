library(colourspace)

# Tests for hex values that have no exact name match,
# exercising the nearest-neighbour fallback path.

test_that("fallback returns a non-NA name for a single unmatched hex", {
  # #a1b2c3 has no exact entry in color_names
  expect_warning(
    res <- hex_to_name("#a1b2c3", fallback = "all"),
    "Fallback"
  )
  expect_type(res, "character")
  expect_length(res, 1)
  expect_false(is.na(res))
})

test_that("fallback returns non-NA names for a vector of unmatched hexes", {
  unmatched <- c("#a1b2c3", "#070301", "#f0f0f1", "#abcabc")
  expect_warning(
    res <- hex_to_name(unmatched, fallback = "all"),
    "Fallback"
  )
  expect_type(res, "character")
  expect_length(res, length(unmatched))
  expect_false(anyNA(res))
})

test_that("mixed matched and unmatched hexes return correct results", {
  # #c93f38 has exact match "100 Mph"; #070301 does not
  mixed <- c("#c93f38", "#070301")
  expect_warning(
    res <- hex_to_name(mixed, fallback = "all"),
    "Fallback"
  )
  expect_length(res, 2)
  expect_equal(res[1], "100 Mph")
  expect_false(is.na(res[2]))
  expect_type(res[2], "character")
})

test_that("fallback = 'none' returns NA for unmatched hexes", {
  res <- hex_to_name("#a1b2c3", fallback = "none")
  expect_true(is.na(res))
})

test_that("fallback = 'r' returns R colour for unmatched hexes", {
  expect_length(
    res <- hex_to_name(c("#a1b2c3", "#070301"), fallback = "r"),
    2
  )
  expect_false(anyNA(res))
  expect_true(all(tolower(res) %in% grDevices::colors()))
})
