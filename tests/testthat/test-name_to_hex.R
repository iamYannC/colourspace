library(colourspace)

test_that("name_to_hex maps names via dataset", {
  expect_equal(name_to_hex("100 Mph"), "#c93f38")
  expect_equal(name_to_hex(c("100 Mph", "1989 Miami Hotline")), c("#c93f38", "#dd3366"))
})
