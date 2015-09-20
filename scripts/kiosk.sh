#!/bin/bash

xset -dpms
xset s off
openbox-session &
start-pulseaudio-x11
xscreensaver -no-splash &

while true; do
  google-chrome --proxy-server="0.0.0.0:3128" --enable-udd-profiles --kiosk --kiosk-printing --no-first-run  'localhost/display/index.html'
done
