library(colourspace)

test_that("normalize_hex supports modern CSS hex lengths", {
  expect_equal(colourspace:::normalize_hex("#fff"), "#ffffff")
  expect_equal(colourspace:::normalize_hex("#ffff"), "#ffffffff")
  expect_equal(colourspace:::normalize_hex("FF00FF"), "#ff00ff")
  expect_error(colourspace:::normalize_hex("#ff00zz"), "Invalid hex code")
})

test_that("strip_hex_alpha drops alpha channel", {
  expect_equal(colourspace:::strip_hex_alpha("#ff00ff80"), "#ff00ff")
  expect_equal(colourspace:::strip_hex_alpha("#f0a8"), "#ff00aa")
})
