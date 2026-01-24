library(colorspace)

test_that("hex_to_hsl converts correctly", {
  expect_equal(hex_to_hsl("#336699"), c(h = 210, s = 50, l = 40))
  res <- hex_to_hsl(c("#ff0000", "#00ff00"))
  expect_equal(res[1, ], c(h = 0, s = 100, l = 50))
  expect_equal(res[2, ], c(h = 120, s = 100, l = 50))
})
