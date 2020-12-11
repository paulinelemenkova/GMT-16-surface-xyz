#!/bin/sh
# Purpose: Surface modelling of the topography along the Mariana Trench
# GMT modules: gmtset, gmtdefaults, makecpt, gmtinfo, blockmean, surface, grdimage, psbasemap, psscale, gmtlogo, pstext, psconvert

# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1.3c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,dimgray \
    MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=6p,Palatino-Roman,dimgray \
    FONT_LABEL=6p,Palatino-Roman,dimgray
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Download data:
### http://topex.ucsd.edu/cgi-bin/get_data.cgi
## E-144-162;N40-51.
# Step-5. Check up dimensions of the table (data range)
gmt info grav_MT.xyz
# output: grav_MT.xyz: N = 3815189    <120.0083/160.0083>    <5.002/30.0019>    <-354.7/416.6>

# Make color palette
# gmt makecpt --help
gmt makecpt -Cturbo -T-355/416 > colors.cpt
#gmt makecpt -Cturbo -T-110/110 > colors.cpt
# Generate 1 by 1 minute block mode values from the raw ASCII data (xyg table)
gmt blockmode grav_MT.xyz -R120/160/5/30 -I1m -Vv > grav_MT_BM.xyg
# Generate grid from xyz table format
gmt surface grav_MT_BM.xyg -R120/160/5/30 -T0.25 -I30s -GSurfaceG_MT.nc -Vv

# Generate a file
ps=SurfaceGMT.ps

# Make raster image
gmt grdimage SurfaceG_MT.nc -Ccolors  -R120/160/5/30 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --MAP_TITLE_OFFSET=1.2c \
    -Bpxg8f2a4 -Bpyg4f2a4 -Bsxg4 -Bsyg4 \
    -B+t"Surface gravity modelling along the Mariana Trench" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx0.8c/9.0c+w0.3i+f2+l+o0.0c \
    -Lx5.3i/-0.5i+c50+w750k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-40p -O -K >> $ps
    
# Add color legend
gmt psscale -R -J -Ccolors.cpt \
    -Dg120.5/4+w10c/0.4c+v+o-1.8/0.2c+ml  \
    --FONT_LABEL=8p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
    -Ba50g100f10+l"Surface gravimetric model color scale" \
    -I0.2 -By+lmGal -O -K >> $ps
    
# Add GMT logo
gmt logo -Dx6.2/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.0c -Y2.2c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
1.2 13.7 Modelling: GMT surface module, tension factor of the continuous curvature splines 0.25
0.5 13.2 Input raw table data: global 1-min grid resolution in ASCII XYZ-format, applied blockmode filter.
3.0 12.7 Output spatial model: 30-sec grid spacing in netCDF format
EOF

# Convert to image file using GhostScript
gmt psconvert SurfaceGMT.ps -A0.2c -E720 -P -Tj -Z
