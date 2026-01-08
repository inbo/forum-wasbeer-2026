# forum-wasbeer-2026

This repository contains the source code and the generated graphs related to the distribution of occurrences of *Procyon lotor* in Belgium from 2020 up to 2025, based on occurrence data obtained from Global Biodiversity Information Facility (GBIF).

## Repository Structure

```
├── README.md              : Description of this repository
├── LICENSE                : Repository license
├── .gitignore             : Files and directories to be ignored by git
│
├── .github
│   └── workflows
│       └── deploy_leaflet_github_pages.yaml : GitHub Actions workflow for deployment GitHub Pages with the leaflet density heatmap, see /figures/heatmap_occurrences.html
│
├── .vscode
│   ├── extensions.json    : VSCode workspace extensions (e.g. linting and formatting via Air)
│   └── settings.json      : VSCode workspace settings
│
├── src
│   ├── heatmap_occurrences.R  : R script used for creating and saving the leaflet density heatmap
│   └── occupied_grid_cells.R  : R script used for plotting and saving the number of occupied grid cells per year
│
└── figures
    ├── heatmap_occurrences.html : Leaflet density heatmap of Procyon lotor occurrences in Belgium
    ├── heatmap_occurrences_files : Supporting files for the leaflet heatmap
    ├── occupied_grid_cells_full_cube.png  : Plot of the number of occupied grid cells in Belgium
    ├── occupied_grid_cells_protected_areas_cube.png : Plot of the number of occupied grid cells in Natura2000 protected areas
    └── occupied_grid_cells_combined.png : Combined plot of occupied grid cells in Belgium and protected areas
```

## Data Sources

### Main Data Sources

-   GBIF Download of occurrences to create the leaflet heatmap (script: `heatmap_occurrences.R`): GBIF.org (06 January 2026) GBIF Occurrence Download https://doi.org/10.15468/dl.juf58a
-   GBIF Download of species occurrence cubes to plot the number of occupied grid cells per year (script: `occupied_grid_cells.R`): GBIF.org (08 January 2026) GBIF Occurrence Download https://doi.org/10.15468/dl.uttqsh

### Additional Data Sources

File [intersect_EEA_ref_grid_protected_areas.tsv](https://raw.githubusercontent.com/trias-project/indicators/refs/heads/main/data/interim/intersect_EEA_ref_grid_protected_areas.tsv): tab separated text file containing information whether a EEA reference grid cell intersects with a Natura2000 protected area in Belgium. Sourced from the TRIAS project GitHub repository: https://github.com/trias-project/indicators.
