# Building an Auger themed kiosk

Here you'll find all the necessary code and instructions to install your own visitor kiosk. This kiosk uses a variety of publicly available resources and also records statistics about which pages user visit. These instructions assume the user is working on a Linux based desktop. Moderate Linux/command line skill also assumed. Let's get started.

The finished product should resemble something like this

![](http://headisplay.student.cwru.edu/display/img/display_scrnshot.png)

And the statistics page, which has a plot that corresponds to each tile on the display page, will look like this

![](http://headisplay.student.cwru.edu)

## Hardware 

 * Large computer monitor or television
 * Small desktop machine
   * 1 GHz single core processor should be fine (or better)
   * 2 GB system memory
   * 80 GB hard disk
   * Ethernet network adapter
   * Preferably HDMI video output
   * OFC audio jacks
 * 4GB USB thumb drive
 * Trackwheel or keyboard with touchpad: a device whose right click can be disabled is essential to prevent tampering with the web browser.
 
## Installing the operating system

Our kiosk uses Ubuntu Server available at http://www.ubuntu.com/download/server

To create a bootable install image on your thumb drive first insert it into your machine.  Next you want to identify the device ID. A nice tool for this is ```lsblk```

```bash
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda      8:0    0 465.8G  0 disk 
└─sda1   8:1    0 465.8G  0 part /
sdb      8:16   0 3.8G  0 disk 
└─sdb1   8:17   0 3.8G  0 part /media/user
```

Since we're using a 4 GB drive the device name is ```sdb```.

unmount the thumb drive using ```umount /dev/sdb1```

Now write the image to the thumb drive using (as root)

```
dd bs=4M if=ubuntu-server-image of=/dev/sdb
```

This will take a couple minutes.

Once ```dd``` is finished, run ```sync``` and remove the drive from the machine.

Now use this thumb drive to install the OS on the kiosk machine. When this finishes, login and use ```ifconfig``` to grab the machines IP address so you can connect remotely.

## Configuring the system

After the server boots we need to add a repository and some additional software. We follow the recommendations of Oli Warner to set up the kiosk as a minimal system running Google Chrome in an X session. Our approach introduces some modifications, but his original article can be found here http://thepcspy.com/read/building-a-kiosk-computer-ubuntu-1404-chrome/

Add the official Chrome repo

```
sudo add-apt-repository 'deb http://dl.google.com/linux/chrome/deb/ stable main'
wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
```

Update apt list and install minimal required packages

```
sudo apt-get update
sudo apt install --no-install-recommends xorg openbox google-chrome-stable pulseaudio
```

Now install additional packages required for our version of the kiosk

```
sudo apt-get install python3 python3-numpy python3-matlotplib apache2 php5 squid git fail2ban xscreensaver
```

Add user to audio group

```
sudo usermod -a -G audio $USER
```

Next clone this repository to a convenient location

```
git clone git@github.com:seanpquinn/auger_display.git
```

## Installing the kiosk

The start up script which launches the X window and Chrome browser is ```scripts/kiosk.sh``` (assuming one is currently in the ```auger_display``` directory). Copy this to a safe place and make it executable

```
sudo cp scripts/kiosk.sh opt/; sudo chmod 755 /opt/kiosk.sh
```

Next copy the upstart script used to execute the previous script on start up. IMPORTANT: please replace the variable ```$USER``` with your username!

```
sudo cp config/kiosk.conf /etc/init/
```

Next we need to copy the web files. Since our kiosk needs to run very simple PHP scripts that collect statistics about page visits, we need to have the pages served by Apache.

First remove the default ```index.html``` page.

```
sudo rm /var/www/html/index.html
```

Copy the files to this directory

```
sudo cp -r display/* /var/www/html; sudo cp index.html /var/www/html
```

Now we need to make some group and ownership adjustments.

```
cd /var/www/html
sudo chgrp www-data display/; sudo chmod 755 display/; cd display
sudo chgrp www-data css/ img/ js/ php/ stats/ stats/*
sudo chmod 755 css/ img/ js/ php/; sudo chmod 776 stats/
sudo chmod 611 stats/master_log.txt; sudo chmod 755 sh/daily_accum.sh
```

At this point the base kiosk system is installed. Next we're going to add some convenience and security utilities.

## Installing and configuring the web proxy server

Since 2 of the sub pages in the kiosk are embedded web pages a proxy server is used to prevent users from following external links in these pages. When a user follows an external link the connection is intercepted and presented with an "access denied" page. This is also true when a user attempts to download files which otherwise would open a Chrome download dialog.

The proxy server ```squid``` was installed in an earlier step. After some experimentation we've built a customized list of rules to prevent users from visiting links that might compromise the kiosk. These files are stored in ```config/squid/```. Place these in ```/etc/squid3/``` with

```
sudo cp config/squid/* /etc/squid3
```

This server will run on localhost using default port 3128. It should start automatically after a reboot (which we will do eventually). If you ever need to manually start or restart, use

```
sudo service start squid3
```

## Installing Dropbox

When the kiosk is in idle mode it is configured to display images linked to a Dropbox account. In our case, this set up allows secretaries to easily upload department info about events, colloquiums or directories.

Dropbox provides useful instructions for installing their software on a headless machine https://www.dropbox.com/install?os=lnx and linking it to your account. Make sure you have the Dropbox user credentials handy for this step.

We also take advantage of their supplied Python script to start the daemon. We can run their script by making a simple shell script to be executed by upstart

```
sudo touch /opt/dropboxd.sh
sudo chmod 755 /opt/dropboxd.sh
```

And add these two lines

```
#!/bin/bash

python /home/$USER/dropbox.py start
```

where ```$USER``` is your username.

Assuming the Dropbox Python script was downloaded to your home directory. If not, put the appropriate directory after the ```python``` command.

Next create the upstart script to execute this script

```
sudo touch /etc/init/dropboxd.conf
```

and fill it with

```
start on (filesystem and stopped udevtrigger)
stop on runlevel [06]

console output

exec sudo -u $USER bash /opt/dropboxd.sh --
```

where ```$USER``` is your username.

Now the daemon will start at boot and automatically sync the Dropbox account with the display machine.

## Configuring xscreensaver

Now let's set up the screen saver to display images from the Dropbox folder when the kiosk is idle. This is easiest to do using the ```xscreensaver-demo``` GUI. Before proceeding, if you are currently setting up the kiosk over ssh, disconnect and then reconnect with X forwarding: ```ssh -X user@host```

Once connected run

```
xscreensaver-demo
```

and customize the screen saver to your liking.

## Setting up cron jobs

The kiosk system comes with with scripts that log usage statistics. In order to collect these daily, we will edit the crontab to execute the scripts every 24 hours.

```
crontab -e
```

insert the following lines to update statistics everyday at 20 hours local time

```
00 20 * * * /var/www/html/display/sh/daily_accum.sh
02 20 * * * /usr/bin/python3 /var/www/html/display/py/plot_usage.py
```

Assuming your machine has been correctly set up on your network with a given domain name, you can access the stats page at ```host.com/index.html```

## Reboot

To bring up a fresh kiosk reboot your machine

```
sudo reboot
```

Enjoy!

## Feedback

All feedback, favorable or critical, is welcomed for this project. Feedback which points out errors or bugs is especially helpful. Design suggestions and ways to make the display more user friendly are also encouraged!

The author can be reached at spq@case.edu

Thanks for reading






