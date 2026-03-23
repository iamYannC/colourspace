library(testthat)

# Note: Function handles rounding internally, always 4 decimals.
# Alpha = 1 is omitted. Achromatic hue uses "none".


test_that("to_css handles standard color names with 4-decimal precision", {
  expect_equal(
    to_css("red", from = "name", to = "oklch", alpha = 1),
    "oklch(62.7915% 0.2577 29.2211)"
  )

  expect_equal(
    to_css("blue", from = "name", to = "oklch", alpha = 1),
    "oklch(45.203% 0.3133 264.068)"
  )
})

test_that("to_css handles hex inputs and case sensitivity", {
  # White: achromatic — hue is "none"
  expect_equal(
    to_css("#FFFFFF", from = "hex", to = "oklch", alpha = 1),
    "oklch(100% 0 none)"
  )

  # A custom hex (e.g., #FF5A3C)
  expect_equal(
    to_css("#ff5a3c", from = "hex", to = "oklch", alpha = 0.8),
    "oklch(68.4473% 0.2058 32.5137 / 0.8)"
  )
})

test_that("to_css handles alpha edge cases", {
  # Fully transparent — achromatic hue is "none"
  expect_equal(
    to_css("black", alpha = 0),
    "oklch(0% 0 none / 0)"
  )

  # Precise alpha decimals (4 decimal places)
  expect_equal(
    to_css("red", alpha = 0.1234),
    "oklch(62.7915% 0.2577 29.2211 / 0.1234)"
  )
})

test_that("to_css throws meaningful errors", {
  # Out of bounds alpha
  expect_error(to_css("red", alpha = 1.1), "alpha must be between 0 and 1")

  # Invalid hex characters
  expect_error(to_css("#FF00ZZ", from = "hex"), "Invalid hex code")

  # Unsupported 'from' argument
  expect_error(to_css("red", from = "cmyk"), "Unsupported format")
})
