library(colourspace)

test_that("hex_to_rgb wraps convert_colourspace", {
  expect_equal(hex_to_rgb("#0000ff"), c(r = 0, g = 0, b = 255))
  res <- hex_to_rgb(c("#0000ff", "#00ff00"))
  expect_equal(res[1, ], c(r = 0, g = 0, b = 255))
  expect_equal(res[2, ], c(r = 0, g = 255, b = 0))
})
