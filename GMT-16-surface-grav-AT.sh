#!/bin/sh
# Purpose: Surface modelling of the topography along the Aleutian Trench
# GMT modules: gmtset, gmtdefaults, makecpt, gmtinfo, blockmean, surface, grdimage, psbasemap, psscale, gmtlogo, pstext, psconvert
# Step-1. Generate a file
ps=SurfaceGAT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1.5c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=6p,Palatino-Roman,dimgray \
    FONT_LABEL=6p,Palatino-Roman,dimgray
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Download data:
# http://topex.ucsd.edu/cgi-bin/get_data.cgi
# here (0-360; 0-90): Lon 175-192; Lat 47-56.
# Step-5. Check up dimensions of the table (data range)
gmt info grav_AT.xyz
# output: N = 360375    <176.0083/192.0083>    <47.9997/52.0032>    <-227.7/257.6>
# Step-6. Make color palette
gmt makecpt -Cdrywet.cpt -V -T-230/260 > surfgrav.cpt
# Step-7. Generate 1 by 1 minute block mode values from the raw ASCII data (xyg table)
gmt blockmode grav_AT.xyz -R175/192/47/56 -I1m -Vv > grav_AT_BM.xyg
# Step-8. Generate grid from xyz table format
gmt surface grav_AT_BM.xyg -R175/192/47/56 -T0.25 -I30s -GSurfaceG_AT.nc -Vv
# Step-9. Make raster image
gmt grdimage SurfaceG_AT.nc -Csurfgrav.cpt -R175/192/47/56 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
# Step-10. Add grid and title
gmt psbasemap -R -J\
    -Bpxg8f1a2 -Bpyg4f1a2 -Bsxg2 -Bsyg2\
    -B+t"Surface modelling of the gravity along the Aleutian Trench" -O -K >> $ps
# Step-11. Add scale bar and directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx13.0c/1.0c+w0.3i+f2+l+o0.15i \
    -Lx13.0c/-1.3c+c50+w300k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-40p -O -K >> $ps
# Step-12. Add color legend
gmt psscale -R -J -Csurfgrav.cpt \
    -Dg175/47+w12.7c/0.4c+v+o-1.8/0.2c+ml  \
    --FONT_LABEL=8p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
    -Baf+l"Surface gravimetric model color scale" \
    -I0.2 -By+lmGal -O -K >> $ps
# Step-13. Add GMT logo
gmt logo -Dx6.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-14. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.0c -Y5.5c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
0.7 13.2 Modelling: GMT surface module, tension factor of the continuous curvature splines 0.25
0.0 12.7 Input raw table data: global 1-min grid resolution in ASCII XYZ-format, applied blockmode filter.
2.7 12.2 Output spatial model: 30-sec grid spacing in netCDF format
EOF
# Step-15. Convert to image file using GhostScript
gmt psconvert SurfaceGAT.ps -A0.2c -E720 -P -Tj -Z
