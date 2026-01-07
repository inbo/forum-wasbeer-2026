# This R script download a GBIF species occurrence cube from a GBIF Download and creates plots
# showing the number of occupied grid cells per year for all grid cells and for Natura2000 protected area grid cells only.
# GBIF Download DOI: https://doi.org/10.15468/dl.zu6kf4

# Install trias R package if not already installed. Needed for GAM smoothing and plotting.
if (!requireNamespace("trias", quietly = TRUE)) {
  install.packages("trias", repos = "https://inbo.r-universe.dev")
}
library(readr)
library(dplyr)
library(purrr)
library(ggplot2)
library(patchwork)
library(trias)

# Download and load GBIF occurrence data
zip_url <- "https://api.gbif.org/v1/occurrence/download/request/0077465-251120083545085.zip"
zip_file <- tempfile(fileext = ".zip")
download.file(zip_url, zip_file, mode = "wb")

# Find and extract 0077465-251120083545085.csv
zip_listing <- unzip(zip_file, list = TRUE)
cube_file <- "0077465-251120083545085.csv"
exdir <- tempdir()
unzip(zip_file, files = cube_file, exdir = exdir, overwrite = TRUE)

# Read with high guess_max to avoid parsing issues
cube_path <- file.path(exdir, cube_file)
cube <- readr::read_tsv(cube_path, guess_max = 100000, show_col_types = FALSE)

# Load grid cells with information about Natura2000 protected areas
grid_cells <- readr::read_tsv(
  file = "https://raw.githubusercontent.com/trias-project/indicators/refs/heads/main/data/interim/intersect_EEA_ref_grid_protected_areas.tsv",
  show_col_types = FALSE
)
grid_cells_pa <- grid_cells %>%
  dplyr::filter(natura2000 == TRUE)

# Create a cube for Natura2000 protected areas only
cube_pa <- cube %>%
  dplyr::filter(eeacellcode %in% grid_cells_pa$CELLCODE)

# Count occupied grid cells (number of `eeacellcode`) per year (`year`).
# Add to the output columns species (`specieskey`, `species`) for reference.
# Do it for both the full cube and the protected areas only cube.
# Add zeros for years without occupied grid cells.
# Create a function to avoid code duplication.
calc_occupied_grid_cells <- function(df) {
  start <- 2000
  end <- 2025
  occ_grid_cells <- df %>%
    dplyr::group_by(year, specieskey, species) %>%
    dplyr::summarise(
      occupied_cells = n_distinct(eeacellcode),
      .groups = "drop"
    ) %>%
    dplyr::arrange("year")
  # Add zeros for years without occupied grid cells
  all_years <- dplyr::tibble(year = start:end)
  occ_grid_cells <- all_years %>%
    dplyr::left_join(occ_grid_cells, by = "year") %>%
    dplyr::mutate(
      occupied_cells = dplyr::coalesce(occupied_cells, 0),
      specieskey = dplyr::coalesce(specieskey, unique(cube$specieskey)),
      species = dplyr::coalesce(species, unique(cube$species))
    )
}
# Calculate occupied grid cells for both cubes
occupied_grid_cells <- purrr::map(
  .x = list(full_cube = cube, protected_areas_cube = cube_pa),
  .f = calc_occupied_grid_cells
)

# Apply GAM smoothing using trias function `apply_gam()`
gam_occupied_grid_cells <- purrr::map(
  .x = occupied_grid_cells,
  .f = trias::apply_gam,
  y_var = "occupied_cells",
  eval_years = 2025, # Not relevant as we don't show the emerging trends for this plots
  year = "year", # As by default
  taxonKey = "specieskey",
  type_indicator = "occupancy",
  baseline_var = NULL, # No baseline variable as by default
)

# Extract GAM plots
gam_plots <- purrr::map(
  .x = gam_occupied_grid_cells,
  .f = purrr::pluck,
  "plot"
)
# Show GAM plots without title, legend and without the colored dots (emerging trend indicator)
gam_plots <- purrr::map(
  .x = gam_plots,
  .f = function(gam_plot) {
    gam_plot <- gam_plot +
      ggplot2::theme(legend.position = "none") +
      ggplot2::labs(
        title = NULL,
        y = "Aantal bezette kilometerhokken",
        x = "Jaar"
      )
    # Remove colored dots layer
    gam_plot$layers$geom_point...4 <- NULL
    return(gam_plot)
  }
)
gam_plots

# Save plots as PNG, 300 dpi
purrr::iwalk(
  .x = gam_plots,
  .f = function(gam_plot, name) {
    ggplot2::ggsave(
      filename = here::here(
        "figures",
        paste0("occupied_grid_cells_", name, ".png")
      ),
      plot = gam_plot,
      width = 15,
      height = 10,
      units = "cm",
      dpi = 300
    )
  }
)

# Combine two ggplots into one figure using patchwork.
# Place them side by side, avoid repeating the y axis label and use same y axis limits.
max_y_value <- max(gam_occupied_grid_cells$full_cube$output$ucl)

gam_plots$protected_areas_cube <- gam_plots$protected_areas_cube +
  ggplot2::labs(y = NULL)

gam_plots <- purrr::map(
  .x = gam_plots,
  .f = function(gam_plot) {
    gam_plot +
      ggplot2::coord_cartesian(ylim = c(0, max_y_value))
  }
)

combined_plot <- gam_plots$full_cube +
  gam_plots$protected_areas_cube
combined_plot

# Save combined plot as PNG, 300 dpi
ggplot2::ggsave(
  filename = here::here(
    "figures",
    "occupied_grid_cells_combined.png"
  ),
  plot = combined_plot,
  width = 30,
  height = 10,
  units = "cm",
  dpi = 300
)
