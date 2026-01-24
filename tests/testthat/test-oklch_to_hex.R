library(colorspace)

test_that("oklch_to_hex converts back to hex", {
  red_oklch <- c(0.6279152, 0.2576972, 29.2211)
  expect_equal(oklch_to_hex(red_oklch), "#ff0000")

  combo <- rbind(red_oklch, c(0.8664397, 0.2948076, 142.5107))
  expect_equal(unname(oklch_to_hex(combo)), c("#ff0000", "#00ff00"))
})
