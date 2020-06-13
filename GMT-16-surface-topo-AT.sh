#!/bin/sh
# Purpose: Surface modelling of the topography along the Aleutian Trench
# GMT modules: gmtset, gmtdefaults, makecpt, gmtinfo, blockmean, surface, grdgradient, grdimage, psbasemap, psscale, gmtlogo, pstext, psconvert
# Step-1. Generate a file
ps=SurfaceTAT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1.7c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,lightgoldenrod1 \
    MAP_GRID_PEN_SECONDARY=thinnest,lightgoldenrod1 \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=6p,Palatino-Roman,dimgray \
    FONT_LABEL=6p,Palatino-Roman,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Download data:
# http://topex.ucsd.edu/cgi-bin/get_data.cgi
# here (0-360; 0-90): Lon 175-192; Lat 47-56.
# Step-5. Check up dimensions of the table (data range)
gmt info topo_AT.xyz
# output: N = 890312    <175.0083/192.0083>    <46.9976/55.9962>    <-7855/1865>
# Step-6. Make color palette
gmt makecpt -Crelief.cpt -V -T-8000/2000 > surface.cpt
# Step-7. Generate 1 by 1 minute block mean values from the raw ASCII data (xyg table)
gmt blockmean topo_AT.xyz -R175/192/47/56 -I1m -Vv > topo_AT_BM.xyg
# Step-8. Generate grid from xyz table format
gmt surface topo_AT_BM.xyg -R175/192/47/56 -T0.25 -I30s -GSurface_AT.nc -Vv
# Step-9. Make gradient illumination with azimuth 45 degree
gmt grdgradient Surface_AT.nc -GSurface_AT.int -A0/45 -Ne1 -fg
# Step-10. Make raster image
gmt grdimage Surface_AT.nc -Csurface.cpt -R175/192/47/56 -JM6i -P -ISurface_AT.int -Xc -K > $ps
# Step-11. Add grid
gmt psbasemap -R -J \
    -Bpxg6f2a2 -Bpyg6f1a2 -Bsxg2 -Bsyg2 \
    -B+t"Surface modelling of the topography along the Aleutian Trench" -O -K >> $ps
# Step-12. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx5.3i/-0.5i+c50+w300k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-40p -O -K >> $ps
# Step-13. Add directional rose
gmt psbasemap -R -J \
    --FONT=10p,Palatino-Roman,white \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx13.0c/0.8c+w0.3i+f2+l+o0.15i \
    -O -K >> $ps
# Step-14. Add color legend
gmt psscale -R -J -Csurface.cpt \
    -Dg174/47+w12.7c/0.4c+v+o-1.0/0.2c+ml  \
    --FONT_LABEL=8p,Palatino-Roman,dimgray \
    --FONT_ANNOT_PRIMARY=5p,Palatino-Roman,dimgray \
    -Baf+l"Surface topographic model color scale" \
    -I0.2 -By+lm -O -K >> $ps
# Step-15. Add GMT logo
gmt logo -Dx6.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-16. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.0c -Y5.5c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
0.7 13.7 Modelling: GMT surface module, tension factor of the continuous curvature splines 0.25
0.0 13.2 Input raw table data: global 1-min grid resolution in ASCII XYZ-format, applied blockmean filter.
0.5 12.7 Output spatial model: 30-sec grid spacing in netCDF format, shading azimuth gradient: 45\232
EOF
# Step-17. Convert to image file using GhostScript
gmt psconvert SurfaceTAT.ps -A0.2c -E720 -P -Tj -Z
