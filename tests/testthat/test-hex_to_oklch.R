library(colourspace)

test_that("hex_to_oklch converts via farver", {
  red <- hex_to_oklch("#ff0000")
  expect_equal(round(red, 3), c(l = 0.628, c = 0.258, h = 29.221))

  combo <- hex_to_oklch(c("#ff0000", "#00ff00"))
  expect_equal(round(combo[2, ], 3), c(l = 0.866, c = 0.295, h = 142.511))
})
