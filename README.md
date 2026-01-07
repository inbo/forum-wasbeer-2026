# forum-wasbeer-2026

This repository contains the source code and the generated graphs related to the distribution of occurrences of *Procyon lotor* in Belgium from 2020 up to 2025, based on occurrence data obtained from Global Biodiversity Information Facility (GBIF).

## Repository Structure

-   `src`: Contains the R scripts used for data processing and visualization.
-   `figures`: Contains the generated graphs and visualizations.

## Data Sources

-   GBIF Download of occurrences to create the leaflet heatmap (script: `heatmap_occurrences.R`): GBIF.org (06 January 2026) GBIF Occurrence Download https://doi.org/10.15468/dl.juf58a
-   GBIF Download of species occurrence cubes to plot the number of occupied grid cells per year (script: `occupied_grid_cells.R`): GBIF.org (06 January 2026) GBIF Occurrence Download https://doi.org/10.15468/dl.zu6kf4