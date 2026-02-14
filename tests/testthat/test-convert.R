library(colourspace)

skip_if_not_installed("farver")

test_that("convert_colourspace handles hex to rgb", {
  rgb <- convert_colourspace("#ff0000", from = "hex", to = "rgb")
  expect_equal(rgb, c(r = 255, g = 0, b = 0))
})

test_that("convert_colourspace vectorises between numeric and hex", {
  rgb_mat <- matrix(c(255, 0, 0,
                      0, 255, 0), ncol = 3, byrow = TRUE)
  hex <- convert_colourspace(rgb_mat, from = "rgb", to = "hex")
  expect_equal(hex, c("#ff0000", "#00ff00"))
})

test_that("convert_colourspace supports names via dataset", {
  expect_equal(convert_colourspace("100 Mph", from = "name", to = "hex"), "#c93f38")
})

test_that("convert_colourspace handles HSL and OKLCH", {
  hsl <- convert_colourspace("#ff0000", from = "hex", to = "hsl")
  expect_equal(hsl, c(h = 0, s = 100, l = 50))

  oklch <- convert_colourspace(c("#ff0000", "#00ff00"), from = "hex", to = "oklch")
  expect_equal(round(oklch[1, ], 3), c(l = 0.628, c = 0.258, h = 29.221))
  expect_equal(round(oklch[2, ], 3), c(l = 0.866, c = 0.295, h = 142.511))
})
