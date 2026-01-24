library(colorspace)

test_that("hsl_to_hex converts to CSS hex", {
  expect_equal(hsl_to_hex(c(210, 50, 40)), "#336699")
  hsl_mat <- matrix(c(0, 100, 50,
                      120, 100, 50), ncol = 3, byrow = TRUE)
  expect_equal(hsl_to_hex(hsl_mat), c("#ff0000", "#00ff00"))
})
