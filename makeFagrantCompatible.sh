#!/bin/bash

# Create user fagrant
groupadd admin
useradd -m -g admin -s /bin/bash fagrant
usermod -a -G users fagrant

pacman -S virtualbox-guest-utils
mkdir /fagrant
chown fagrant:users /fagrant
VBoxControl guestproperty set /VirtualBox/GuestAdd/SharedFolders/MountDir /fagrant/
echo "sudo mount -t vboxsf -o uid=$(id -u),gid=$(id -g) guestfolder /fagrant" >> /home/fagrant/.bashrc
echo "vboxguest" > /etc/modules-load.d/virtualbox.conf 
echo "vboxsf" >> /etc/modules-load.d/virtualbox.conf 
usermod -a -G vboxsf fagrant

# Set password
passwd fagrant

# Put fagrant public key in authorized keys
mkdir -p /home/fagrant/.ssh/
chown fagrant:users /home/fagrant/.ssh/
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkAbNSCuu6drc7gGi0J5UaLD7m7VbwxS+H6Ij/uqVl61A4iqCY4+/HDZl9gIRM/eeMYxPX/T8/mt+P4khJaXl8HBiwhRlj6cbJwZOU+AyYJ2rT8eCHTXlY0DmUp9wvvrXqY/vt4qbYkUWonmYJ3nDUKkCmLDe81NuqhIl6QpCtWVlO3XT3Rpf0hcoy5+qIqDI5y8y9c2v8DnCDyAezZoe80dYW7/1HA07WhcHTSe1TyhG61r1uiLrXiZfOXf4FpCszJ74pNEULYHp5UXrIpEgpBmjG2AvXynpALQX3w9jHsRCNybZz03V9+m3khn2/k3XyM/dZ6ZyBR+wejXZ2MuYZ" >> /home/fagrant/.ssh/authorized_keys
chmod 600 /home/fagrant/.ssh/authorized_keys 
chown fagrant:users /home/fagrant/.ssh/authorized_keys

# Add "%admin ALL=(ALL) NOPASSWD: ALL"
visudo

# Install puppet
pacman -S puppet
