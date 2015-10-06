#!/bin/bash

statpath="/var/www/html/display/stats"

x1=$(/bin/less $statpath/shower.txt)
x2=$(/bin/less $statpath/viewer.txt)
x3=$(/bin/less $statpath/evt.txt)
x4=$(/bin/less $statpath/sddeploy.txt)
x5=$(/bin/less $statpath/googearth.txt)
x6=$(/bin/less $statpath/voices.txt)
x7=$(/bin/less $statpath/watson.txt)
x8=$(/bin/less $statpath/timelapse.txt)
x9=$(/bin/less $statpath/aera.txt)
x10=$(/bin/less $statpath/gallery.txt)

/bin/echo $x1 $x2 $x3 $x4 $x5 $x6 $x7 $x8 $x9 $x10 $(/bin/date +%Y_%m_%d) >> $statpath/master_log.txt

/bin/echo 0 | /usr/bin/tee $statpath/shower.txt $statpath/viewer.txt $statpath/evt.txt $statpath/sddeploy.txt $statpath/googearth.txt $statpath/voices.txt $statpath/watson.txt $statpath/timelapse.txt $statpath/aera.txt $statpath/gallery.txt > /dev/null

