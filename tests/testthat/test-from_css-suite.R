# from_css comprehensive test suite
# Converted from tests-from_css.R examples

# ==========================================
# 1. OKLCH Space Tests
# ==========================================

oklch_examples <- c(
  "oklch(62.792% 0.258 29.221 / 0.2)",
  "oklch(55% 0.22 144)",
  "oklch(70% 0.18 330)",
  "oklch(35% 0.11 260)",
  "oklch(0.85 0.12 95)",
  "oklch(0.40 0.15 20)",
  "oklch(0.95, 0.05, 210)"
)

test_that("oklch -> oklch parses correctly (single values)", {
  result <- from_css("oklch(62.792% 0.258 29.221 / 0.2)", to = "oklch")
  expect_equal(result, c(0.62792, 0.258, 29.221))
})

test_that("oklch -> oklch parses correctly (multiple values)", {
  result <- sapply(oklch_examples, \(syn) from_css(syn, to = "oklch"))
  expect_true(is.matrix(result))
  expect_equal(nrow(result), 3)
  expect_equal(ncol(result), length(oklch_examples))
  # Check specific parsed values

  expect_equal(result[, 1], c(0.62792, 0.258, 29.221))
  expect_equal(result[, 2], c(0.55, 0.22, 144))
  expect_equal(result[, 7], c(0.95, 0.05, 210))
})

test_that("oklch -> name with fallback=FALSE returns NA for non-exact matches", {
  result <- sapply(oklch_examples, \(syn) from_css(syn, to = "name", fallback = FALSE))
  expect_equal(unname(result[1]), "Red")
  expect_true(all(is.na(result[-1])))
})

test_that("oklch -> hex -> name matches oklch -> name (fallback=FALSE)", {
  hex_result <- sapply(oklch_examples, \(syn) from_css(syn, to = "hex"))
  roundtrip_names <- hex_to_name(unname(hex_result), fallback = FALSE)
  direct_names <- sapply(oklch_examples, \(syn) from_css(syn, to = "name", fallback = FALSE))
  expect_equal(unname(roundtrip_names), unname(direct_names))
})

test_that("oklch -> name with fallback=TRUE returns closest names", {
  result <- suppressWarnings(
    sapply(oklch_examples, \(syn) from_css(syn, to = "name"))
  )
  expect_equal(unname(result), c(
    "Red", "Clover", "Pink Orchid", "Azure Dragon",
    "Le Bon Dijon", "Oxblood", "Vaporised"
  ))
})

test_that("oklch major round-trip: name -> hex -> oklch -> hex -> name", {
  fallback_names <- suppressWarnings(
    sapply(oklch_examples, \(syn) from_css(syn, to = "name"))
  )
  # Skip first (exact match "Red"), test the fallback names
  roundtrip <- name_to_hex(unname(fallback_names[-1])) |>
    hex_to_oklch() |>
    round(4) |>
    oklch_to_hex() |>
    hex_to_name()
  expect_equal(unname(roundtrip), unname(fallback_names[-1]))
})


# ==========================================
# 2. HEX Space Tests
# ==========================================

hex_examples <- c(
  "#FF5733",
  "#0F0",
  "#FF573380",

  "#123456"
)

test_that("hex -> hex normalizes correctly", {
  result <- sapply(hex_examples, \(syn) from_css(syn, to = "hex"))
  expect_equal(unname(result), c("#ff5733", "#00ff00", "#ff5733", "#123456"))
})

test_that("hex -> hex: 3-digit shorthand expands to 6-digit", {
  expect_equal(from_css("#0F0", to = "hex"), "#00ff00")
})

test_that("hex -> hex: 8-digit hex drops alpha", {
  expect_equal(from_css("#FF573380", to = "hex"), "#ff5733")
})

test_that("hex -> name with fallback=FALSE", {
  result <- sapply(hex_examples, \(syn) from_css(syn, to = "name", fallback = FALSE))
  expect_true(is.na(result[["#FF5733"]]))
  expect_equal(unname(result[["#0F0"]]), "Green")
  expect_true(is.na(result[["#FF573380"]]))
  expect_equal(unname(result[["#123456"]]), "Incremental Blue")
})

test_that("hex -> name with fallback=TRUE", {
  result <- suppressWarnings(
    sapply(hex_examples, \(syn) from_css(syn, to = "name"))
  )
  expect_equal(unname(result), c(
    "Poppy Surprise", "Green", "Poppy Surprise", "Incremental Blue"
  ))
})

test_that("hex major round-trip: name -> hex -> name", {
  fallback_names <- suppressWarnings(
    sapply(hex_examples, \(syn) from_css(syn, to = "name"))
  )
  roundtrip <- name_to_hex(unname(fallback_names)) |> hex_to_name()
  expect_equal(unname(roundtrip), unname(fallback_names))
})


# ==========================================
# 3. sRGB Space Tests
# ==========================================

rgb_examples <- c(
  "rgb(255 87 51)",
  "rgba(0, 255, 0, 0.5)",
  "rgb(100% 34% 20%)",
  "rgb(18 52 86 / 80%)"
)

test_that("rgb -> rgb parses modern space-separated syntax", {
  result <- from_css("rgb(255 87 51)", to = "rgb")
  expect_equal(result, c(255, 87, 51))
})

test_that("rgb -> rgb parses legacy comma-separated with alpha", {
  result <- from_css("rgba(0, 255, 0, 0.5)", to = "rgb")
  expect_equal(result, c(0, 255, 0))
})

test_that("rgb -> rgb parses percentage syntax", {
  result <- from_css("rgb(100% 34% 20%)", to = "rgb")
  expect_equal(result, c(255, 86.7, 51))
})

test_that("rgb -> rgb parses modern with slash alpha", {
  result <- from_css("rgb(18 52 86 / 80%)", to = "rgb")
  expect_equal(result, c(18, 52, 86))
})

test_that("rgb -> rgb returns matrix for multiple inputs", {
  result <- sapply(rgb_examples, \(syn) from_css(syn, to = "rgb"))
  expect_true(is.matrix(result))
  expect_equal(nrow(result), 3)
  expect_equal(ncol(result), length(rgb_examples))
})

test_that("rgb -> name with fallback=FALSE", {
  result <- sapply(rgb_examples, \(syn) from_css(syn, to = "name", fallback = FALSE))
  expect_true(is.na(result[["rgb(255 87 51)"]]))
  expect_equal(unname(result[["rgba(0, 255, 0, 0.5)"]]), "Green")
  expect_true(is.na(result[["rgb(100% 34% 20%)"]]))
  expect_equal(unname(result[["rgb(18 52 86 / 80%)"]]), "Incremental Blue")
})

test_that("rgb -> name with fallback=TRUE", {
  result <- suppressWarnings(
    sapply(rgb_examples, \(syn) from_css(syn, to = "name"))
  )
  expect_equal(unname(result), c(
    "Poppy Surprise", "Green", "Poppy Surprise", "Incremental Blue"
  ))
})

test_that("rgb major round-trip: name -> hex -> rgb -> hex -> name", {
  fallback_names <- suppressWarnings(
    sapply(rgb_examples, \(syn) from_css(syn, to = "name"))
  )
  roundtrip <- name_to_hex(unname(fallback_names)) |>
    hex_to_rgb() |>
    round(4) |>
    rgb_to_hex() |>
    hex_to_name()
  expect_equal(unname(roundtrip), unname(fallback_names))
})


# ==========================================
# 4. OKLAB Space Tests
# ==========================================

oklab_examples <- c(
  "oklab(0.628 0.225 0.125)",
  "oklab(55% -0.15 -0.05)",
  "oklab(0.85 0.05 -0.1 / 0.75)",
  "oklab(0.40 0.10 0.05)"
)

test_that("oklab -> oklab parses correctly (single values)", {
  result <- from_css("oklab(0.628 0.225 0.125)", to = "oklab")
  expect_equal(result, c(0.628, 0.225, 0.125))
})

test_that("oklab -> oklab handles percentage L and negative a/b", {
  result <- from_css("oklab(55% -0.15 -0.05)", to = "oklab")
  expect_equal(result, c(0.55, -0.15, -0.05))
})

test_that("oklab -> oklab drops alpha", {
  result <- from_css("oklab(0.85 0.05 -0.1 / 0.75)", to = "oklab")
  expect_equal(result, c(0.85, 0.05, -0.1))
})

test_that("oklab -> oklab returns matrix for multiple inputs", {
  result <- sapply(oklab_examples, \(syn) from_css(syn, to = "oklab"))
  expect_true(is.matrix(result))
  expect_equal(nrow(result), 3)
  expect_equal(ncol(result), length(oklab_examples))
})

test_that("oklab -> name with fallback=FALSE returns all NA", {
  result <- sapply(oklab_examples, \(syn) from_css(syn, to = "name", fallback = FALSE))
  expect_true(all(is.na(result)))
})

test_that("oklab -> name with fallback=TRUE returns closest names", {
  result <- suppressWarnings(
    sapply(oklab_examples, \(syn) from_css(syn, to = "name"))
  )
  expect_equal(unname(result), c(
    "Left on Red", "Tempo Teal", "Lavender Tonic", "Incubus"
  ))
})

test_that("oklab major round-trip: name -> hex -> oklab -> hex -> name", {
  fallback_names <- suppressWarnings(
    sapply(oklab_examples, \(syn) from_css(syn, to = "name"))
  )
  roundtrip <- name_to_hex(unname(fallback_names)) |>
    hex_to_oklab() |>
    round(4) |>
    oklab_to_hex() |>
    hex_to_name()
  expect_equal(unname(roundtrip), unname(fallback_names))
})


# ==========================================
# 5. HSL Space Tests
# ==========================================

hsl_examples <- c(
  "hsl(14 100% 60%)",
  "hsla(120, 100%, 50%, 0.5)"
)

test_that("hsl -> hsl parses modern space-separated syntax", {
  result <- from_css("hsl(14 100% 60%)", to = "hsl")
  expect_equal(result, c(14, 100, 60))
})

test_that("hsl -> hsl parses legacy hsla comma syntax", {
  result <- from_css("hsla(120, 100%, 50%, 0.5)", to = "hsl")
  expect_equal(result, c(120, 100, 50))
})

test_that("hsl -> hsl returns matrix for multiple inputs", {
  result <- sapply(hsl_examples, \(syn) from_css(syn, to = "hsl"))
  expect_true(is.matrix(result))
  expect_equal(nrow(result), 3)
  expect_equal(ncol(result), length(hsl_examples))
})

test_that("hsl -> name with fallback=FALSE", {
  result <- sapply(hsl_examples, \(syn) from_css(syn, to = "name", fallback = FALSE))
  expect_true(is.na(result[["hsl(14 100% 60%)"]]))
  expect_equal(unname(result[["hsla(120, 100%, 50%, 0.5)"]]), "Green")
})

test_that("hsl -> name with fallback=TRUE", {
  result <- suppressWarnings(
    sapply(hsl_examples, \(syn) from_css(syn, to = "name"))
  )
  expect_equal(unname(result), c("Halt and Catch Fire", "Green"))
})

test_that("hsl major round-trip: name -> hex -> hsl -> hex -> name", {
  fallback_names <- suppressWarnings(
    sapply(hsl_examples, \(syn) from_css(syn, to = "name"))
  )
  roundtrip <- name_to_hex(unname(fallback_names)) |>
    hex_to_hsl() |>
    round(4) |>
    hsl_to_hex() |>
    hex_to_name()
  expect_equal(unname(roundtrip), unname(fallback_names))
})


# ==========================================
# 6. Vectorization Tests
# ==========================================

test_that("from_css handles vectorized input across color spaces", {
  colors <- c(
    "oklch(62.792% 0.258 29.221 / 1)",
    "rgb(0 255 0 / 1)",
    "hsl(240 100% 50% / 1)"
  )
  result <- from_css(colors, to = "hex")
  expect_equal(result, c("#ff0000", "#00ff00", "#0000ff"))
})
