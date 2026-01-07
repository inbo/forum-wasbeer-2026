# Description: This R script downloads GBIF occurrence data from a GBIF download and creates a heatmap
# of occurrences based on geographic coordinates using the leaflet package.
# GBIF Download DOI: https://doi.org/10.15468/dl.juf58a

library(readr)
library(dplyr)
library(here)
library(leaflet)
library(htmlwidgets)
library(webshot2)


# Download and load GBIF occurrence data
zip_url <- "https://api.gbif.org/v1/occurrence/download/request/0077450-251120083545085.zip"
zip_file <- tempfile(fileext = ".zip")
download.file(zip_url, zip_file, mode = "wb")

# Find and extract occurrence.txt
zip_listing <- unzip(zip_file, list = TRUE)
occ_file <- "occurrence.txt"
exdir <- tempdir()
unzip(zip_file, files = occ_file, exdir = exdir, overwrite = TRUE)

# Read with high guess_max to avoid parsing issues
occ_path <- file.path(exdir, occ_file)
occs <- readr::read_tsv(occ_path, guess_max = 100000, show_col_types = FALSE)

# Create a leaflet heatmap of occurrences based on columns "decimalLongitude" and "decimalLatitude".
# The heatmap should refer to the number of occurrences in each area, i.e. number of rows with similar coordinates.
# Add a layer with occurrences as circles. This layer should be toggleable on/off. Default: off.
# Add base tiles: gray, topo, streetmap, hybrid, satellites.
heatmap_occs <- leaflet::leaflet(data = occs) %>%
  leaflet::setView(lng = 4.5, lat = 50.5, zoom = 8) %>%
  leaflet::addProviderTiles("CartoDB.Positron", group = "Gray") %>%
  leaflet::addProviderTiles("OpenTopoMap", group = "Topo") %>%
  leaflet::addProviderTiles("OpenStreetMap.Mapnik", group = "Streetmap") %>%
  leaflet::addProviderTiles("Esri.WorldImagery", group = "Satellite") %>%
  leaflet::addProviderTiles("Esri.WorldImagery", group = "Hybrid") %>%
  leaflet.extras::addHeatmap(
    lng = ~decimalLongitude,
    lat = ~decimalLatitude,
    intensity = ~1,
    blur = 20,
    max = 0.05,
    radius = 15
  ) %>%
  leaflet::addCircleMarkers(
    lng = ~decimalLongitude,
    lat = ~decimalLatitude,
    radius = 1,
    color = "black",
    fillOpacity = 0.5,
    group = "Occurrences"
  ) %>%
  leaflet::addLayersControl(
    baseGroups = c("Gray", "Topo", "Streetmap", "Satellite", "Hybrid"),
    overlayGroups = c("Occurrences"),
    options = leaflet::layersControlOptions(collapsed = TRUE)
  ) %>%
  leaflet::hideGroup("Occurrences")
heatmap_occs

# Save heatmap as HTML
htmlwidgets::saveWidget(
  heatmap_occs,
  here::here("figures", "heatmap_occurrences.html")
)

# Save screenshot as PNG using webshot2
webshot2::webshot(
  url = here::here("figures", "heatmap_occurrences.html"),
  file = here::here("figures", "heatmap_occurrences.png"),
  vwidth = 1000,
  vheight = 800,
  delay = 2
)
