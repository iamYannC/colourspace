library(colourspace)

test_that("hex_to_oklab wraps convert_colourspace", {
  expect_equal(hex_to_oklab("#ff0000"), convert_colourspace("#ff0000", from = "hex", to = "oklab"))
  res <- hex_to_oklab(c("#ff0000", "#00ff00"))
  expect_true(is.matrix(res))
  expect_equal(ncol(res), 3)
})

test_that("oklab_to_hex wraps convert_colourspace and round-trips", {
  red_oklab <- hex_to_oklab("#ff0000")
  expect_equal(oklab_to_hex(red_oklab), "#ff0000")

  mat <- rbind(red_oklab, hex_to_oklab("#00ff00"))
  expect_equal(unname(oklab_to_hex(mat)), c("#ff0000", "#00ff00"))
})
