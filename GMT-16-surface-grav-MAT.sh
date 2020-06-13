#!/bin/sh
# Purpose: Surface modelling of the topography along the Guatemala Trench
# GMT modules: gmtset, gmtdefaults, makecpt, gmtinfo, blockmean, surface, grdgradient, grdimage, psbasemap, psscale, gmtlogo, pstext, psconvert
# Step-1. Generate a file
ps=SurfaceGMAT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1.7c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=6p,Palatino-Roman,dimgray \
    FONT_LABEL=6p,Palatino-Roman,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Download data:
# http://topex.ucsd.edu/cgi-bin/get_data.cgi
# here (0-360; 0-90): Lon 263/278; Lat 7/17.
# Step-5. Check up dimensions of the table (data range)
gmt info grav_MAT.xyz
# N = 554115    <263.0083/278.0083>    <7.0076/17.0032>    <-157.1/452.4>
# Step-6. Make color palette
gmt makecpt -Ccyclic.cpt -V -T-160/455 > surface.cpt
# Step-7. Generate 1 by 1 minute block mean values from the raw ASCII data (xyg table)
gmt blockmean grav_MAT.xyz -R263/278/7/17 -I1m -Vv > grav_MAT_BM.xyg
# Step-8. Generate grid from xyz table format
gmt surface grav_MAT_BM.xyg -R263/278/7/17 -T0.25 -I30s -GSurface_MAT.nc -Vv
# Step-9. Make gradient illumination with azimuth 45 degree
gmt grdgradient Surface_MAT.nc -GSurface_MAT.int -A0/45 -Ne1 -fg
# Step-10. Make raster image
gmt grdimage Surface_MAT.nc -Csurface.cpt -R263/278/7/17 -JM6i -P -ISurface_MAT.int -Xc -K > $ps
# Step-11. Add grid
gmt psbasemap -R -J \
    -Bpxg6f2a2 -Bpyg6f1a2 -Bsxg2 -Bsyg2 \
    -B+t"Surface modelling of the gravity along the Guatemala Trench" -O -K >> $ps
# Step-12. Add scale
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx13.0c/-1.3c+c50+w300k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-40p -O -K >> $ps
# Step-13. Add directional rose
gmt psbasemap -R -J \
    --FONT=10p,Palatino-Roman,white \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx1.0c/0.8c+w0.3i+f2+l+o0.15i \
    -O -K >> $ps
# Step-14. Add color legend
gmt psscale -R -J -Csurface.cpt \
    -Dg262/7+w10.0c/0.4c+v+o-1.0/0.2c+ml  \
    --FONT_LABEL=8p,Palatino-Roman,dimgray \
    --FONT_ANNOT_PRIMARY=5p,Palatino-Roman,dimgray \
    -Baf+l"Surface gravimetric model color scale" \
    -I0.2 -By+lmGal -O -K >> $ps
# Step-15. Add GMT logo
gmt logo -Dx6.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-16. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.0c -Y4.5c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
0.7 11.3 Modelling: GMT surface module, tension factor of the continuous curvature splines 0.25
0.0 10.8 Input raw table data: global 1-min grid resolution in ASCII XYZ-format, applied blockmean filter.
0.5 10.3 Output spatial model: 30-sec grid spacing in netCDF format, shading azimuth gradient: 45\232
EOF
# Step-17. Convert to image file using GhostScript
gmt psconvert SurfaceGMAT.ps -A0.2c -E720 -P -Tj -Z
