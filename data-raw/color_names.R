# Download and prepare color names for package use
# Combines meodai color-names with R's built-in colors

library(grDevices)

# ============================================================================
# Get meodai color names
# ============================================================================

url <- "https://raw.githubusercontent.com/meodai/color-names/master/src/colornames.csv"
local_csv <- tempfile(fileext = ".csv")
utils::download.file(url, destfile = local_csv, mode = "wb", quiet = TRUE)

raw <- utils::read.csv(local_csv, stringsAsFactors = FALSE)

colornames_extended <- unique(raw[c("name", "hex")])
colornames_extended$name <- trimws(colornames_extended$name)
colornames_extended$hex <- tolower(trimws(colornames_extended$hex))

# Ensure HEX strings start with '#'
needs_hash <- !grepl("^#", colornames_extended$hex)
colornames_extended$hex[needs_hash] <- paste0("#", colornames_extended$hex[needs_hash])

colornames_extended$source <- "extended"

# ============================================================================
# Get R's built-in colors
# ============================================================================

r_colors <- colors()
r_hex <- tolower(rgb(t(col2rgb(r_colors)), maxColorValue = 255))

# rgb() already returns '#'-prefixed strings; no extra paste needed

colornames_r <- data.frame(
    name = tolower(r_colors),
    hex = r_hex,
    source = "r",
    stringsAsFactors = FALSE
)

# ============================================================================
# Combine and deduplicate
# ============================================================================

colornames_all <- rbind(colornames_r, colornames_extended)

# Strategy: One name per hex
# Prefer R colors first, then shortest extended name
hex_groups <- split(colornames_all, colornames_all$hex)

color_names <- do.call(rbind, lapply(hex_groups, function(group) {
    # Prioritize R colors
    r_names <- group$name[group$source == "r"]
    if (length(r_names) > 0) {
        chosen_name <- r_names[1]
        chosen_source <- "r"
    } else {
        # Otherwise, use shortest name from extended database
        extended_names <- group$name[group$source == "extended"]
        shortest_idx <- which.min(nchar(extended_names))
        chosen_name <- extended_names[shortest_idx]
        chosen_source <- "extended"
    }

    data.frame(
        hex = group$hex[1],
        name = chosen_name,
        source = chosen_source,
        stringsAsFactors = FALSE
    )
}))

# Remove rownames
rownames(color_names) <- NULL

# ============================================================================
# Save dataset
# ============================================================================

usethis::use_data(color_names, overwrite = TRUE)
