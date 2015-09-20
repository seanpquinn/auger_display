# Building an Auger themed kiosk

Here you'll find all the necessary code and instructions to install your own visitor kiosk. This kiosk uses a variety of publicly available resources and also records statistics about which pages user visit. These instructions assume the user is working on a Linux based desktop. Moderate Linux/command line skill also assumed. Let's get started.

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
sudo apt-get install python3 python3-numpy python3-matlotplib apache2 php5 squid git
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

Next we need to copy the 
