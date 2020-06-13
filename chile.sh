#!/bin/csh

## http://topex.ucsd.edu/cgi-bin/get_data.cgi
## E-40~-30£¬N280~290
xyzfile=Chile.xyz
grdfile=Chile.grd
psfile=Chile.ps
topocpt=t.cpt
scalecpt=c.pt

## set map parameters
gmtset MAP_GRID_CROSS_SIZE_PRIMARY 0 FONT_ANNOT_PRIMARY 15 MAP_FRAME_WIDTH 0.2c
gmtset MAP_GRID_PEN_PRIMARY 0.25p
gmtset FORMAT_GEO_MAP ddd:mm:ssF
gmtset MAP_FRAME_WIDTH 0.1c
gmtset FONT_LABEL 12 FONT_ANNOT_SECONDARY 1 FONT_LABEL 1
gmtdefaults -D > .gmtdefaults4
gmtset MAP_FRAME_TYPE Plain

## make color tables
gmt makecpt -Csealand -T-8000/4000/100 > $topocpt
gmt makecpt -Csealand -T-8/4/1 > $scalecpt

## from xyz format to grd format
gmt surface $xyzfile -G$grdfile -R280/290/-40/-30 -I1m
gmt grdgradient $grdfile -G$grdfile.int -A0/45 -Ne1 -fg
gmt grdimage $grdfile -C$topocpt -I$grdfile.int -Jm3 -R280.5/291.5/-40/-30 -P -K -V -U"test notes"> $psfile
gmt pscoast -R -Jm -Di -Ba2f1 -W0.8p,0/0/0 -P -K -O -V >> $psfile
gmt psscale -C$scalecpt -D2.8i/-0.4i/5i/0.15ih -O -Bx1 -By+lz -E+n >> $psfile
gmt ps2raster $psfile -A -P -Tg