library(colorspace)

test_that("rgb_to_hex wraps convert", {
  expect_equal(rgb_to_hex(c(51, 102, 153)), "#336699")
  mat <- matrix(c(255, 0, 0,
                  0, 255, 0,
                  0, 0, 255), ncol = 3, byrow = TRUE)
  expect_equal(rgb_to_hex(mat), c("#ff0000", "#00ff00", "#0000ff"))
})
