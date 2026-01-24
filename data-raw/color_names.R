# Download and prepare the meodai color name list for package use

url <- "https://raw.githubusercontent.com/meodai/color-names/master/src/colornames.csv"
local_csv <- tempfile(fileext = ".csv")
utils::download.file(url, destfile = local_csv, mode = "wb", quiet = TRUE)

raw <- utils::read.csv(local_csv, stringsAsFactors = FALSE)

color_names <- unique(raw[c("name", "hex")])
color_names$name <- trimws(color_names$name)
color_names$hex <- tolower(color_names$hex)

# ensure HEX strings start with '#'
needs_hash <- !grepl("^#", color_names$hex)
color_names$hex[needs_hash] <- paste0("#", color_names$hex[needs_hash])

usethis::use_data(color_names, overwrite = TRUE)
