# GMT Surface XYZ — Spatial Interpolation and Surface Modelling Scripts

A collection of GMT (Generic Mapping Tools) shell scripts for interpolating scattered XYZ point data into continuous gridded surfaces and mapping the results. Raw ASCII point data (topography, gravity, sediment thickness) are block-averaged and gridded with GMT's surface adjustable-tension continuous-curvature spline algorithm, then illuminated and rendered as shaded-relief maps. The scripts have been used to generate figures across the author's marine-geophysical and cartographic publications.

## What the scripts do

Each script builds a complete surface-modelling figure, typically chaining:

- inspection of the XYZ data range (gmtinfo)
- block-mean averaging of the raw ASCII XYZ table to the grid resolution (blockmean)
- interpolation to a continuous grid with adjustable tension (surface -T)
- gradient / illumination computation (grdgradient)
- colour palette generation (makecpt)
- shaded raster rendering of the modelled surface (grdimage)
- colour scale bars (psscale), grids, frames, scale bars and roses (psbasemap)
- annotations describing the modelling parameters (pstext), GMT logo (logo)
- export to raster (psconvert) at high resolution

Typical workflow: 1-arc-minute raw XYZ, blockmean filtered, surfaced to a 30-arc-second netCDF grid with a spline tension factor of 0.25 and 45-degree shading azimuth.

## Data sources

Scattered XYZ point data (topography, free-air gravity, sediment) exported from global grids (e.g. TOPEX/UCSD, ETOPO, satellite-altimetry gravity). Sample .xyz tables are included for selected areas.

## File naming

Scripts follow GMT-16-surface-VAR-XX.sh, where VAR is the modelled quantity (topo, grav, sedim) and XX is an ocean-trench tag (e.g. MAT = Middle America Trench, KKT = Kuril-Kamchatka Trench, AT = Aleutian Trench, MT = Mariana Trench, PCT = Peru-Chile Trench).

## Requirements

- GMT 6.x (Generic Mapping Tools): https://www.generic-mapping-tools.org
- A POSIX shell (bash/sh)
- The relevant XYZ point table(s) available locally

## Usage

Place the required XYZ table in the working directory, adjust the -R region, -I resolution and -T tension at the top of the chosen script, then run:

    bash GMT-16-surface-topo-MAT.sh

The script writes a PostScript file and converts it to a raster image (JPG/PNG) via psconvert.

## Author and citation

Polina Lemenkova
ORCID: https://orcid.org/0000-0002-5759-1089

These scripts accompany figures in the author's marine-geophysical and cartographic papers; please cite the specific article a given figure appears in. The full publication list is available via the ORCID record above.

## License

See the LICENSE file in this repository.
