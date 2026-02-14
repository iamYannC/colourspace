library(testthat)

# Note: Function handles rounding internally, always 3. opiniated, not for user to decide. 


test_that("to_css handles standard color names with 3-decimal precision", {
  # Values are powered by farver and rounded to 3 decimals in the emitted CSS.
  expect_equal(
    to_css("red", from = "name", to = "oklch", alpha = 1),
    "oklch(62.792% 0.258 29.221 / 1)"
  )
  
  expect_equal(
    to_css("blue", from = "name", to = "oklch", alpha = 1),
    "oklch(45.203% 0.313 264.068 / 1)"
  )
})

test_that("to_css handles hex inputs and case sensitivity", {
  # White: Max Lightness, Zero Chroma
  expect_equal(
    to_css("#FFFFFF", from = "hex", to = "oklch", alpha = 1),
    "oklch(100% 0 0 / 1)"
  )
  
  # A custom hex (e.g., #FF5A3C)
  expect_equal(
    to_css("#ff5a3c", from = "hex", to = "oklch", alpha = 0.8),
    "oklch(68.447% 0.206 32.514 / 0.8)"
  )
})

test_that("to_css handles alpha edge cases", {
  # Fully transparent
  expect_equal(
    to_css("black", alpha = 0),
    "oklch(0% 0 0 / 0)"
  )
  
  # Precise alpha decimals
  expect_equal(
    to_css("red", alpha = 0.1234),
    "oklch(62.792% 0.258 29.221 / 0.123)" # Alpha also rounds to 3
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
