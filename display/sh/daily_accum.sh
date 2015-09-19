#!/bin/sh

cd ../stats

x1=$(less shower.txt)
x2=$(less viewer.txt)
x3=$(less evt.txt)
x4=$(less sddeploy.txt)
x5=$(less googearth.txt)
x6=$(less voices.txt)
x7=$(less watson.txt)
x8=$(less timelapse.txt)
x9=$(less aera.txt)
x10=$(less gallery.txt)

echo $x1 $x2 $x3 $x4 $x5 $x6 $x7 $x8 $x9 $x10 $(date +%Y_%m_%d) >> master_log.txt	
