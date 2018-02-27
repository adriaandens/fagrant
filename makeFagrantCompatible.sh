#!/bin/bash

USERNAME=fagrant
MOUNTDIR="/fagrant"

# Create user fagrant
groupadd admin
useradd -m -g admin -s /bin/bash $USERNAME
usermod -a -G users $USERNAME

pacman -S virtualbox-guest-utils
mkdir $MOUNTDIR
chown $USERNAME:users $MOUNTDIR
VBoxControl guestproperty set /VirtualBox/GuestAdd/SharedFolders/MountDir $MOUNTDIR/
echo "sudo mount -t vboxsf -o uid=\$(id -u),gid=\$(id -g) guestfolder $MOUNTDIR" >> /home/$USERNAME/.bashrc
echo "vboxguest" > /etc/modules-load.d/virtualbox.conf 
echo "vboxsf" >> /etc/modules-load.d/virtualbox.conf 
usermod -a -G vboxsf $USERNAME

# Set password
passwd $USERNAME

# Put fagrant public key in authorized keys
mkdir -p /home/$USERNAME/.ssh/
chown $USERNAME:users /home/$USERNAME/.ssh/
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkAbNSCuu6drc7gGi0J5UaLD7m7VbwxS+H6Ij/uqVl61A4iqCY4+/HDZl9gIRM/eeMYxPX/T8/mt+P4khJaXl8HBiwhRlj6cbJwZOU+AyYJ2rT8eCHTXlY0DmUp9wvvrXqY/vt4qbYkUWonmYJ3nDUKkCmLDe81NuqhIl6QpCtWVlO3XT3Rpf0hcoy5+qIqDI5y8y9c2v8DnCDyAezZoe80dYW7/1HA07WhcHTSe1TyhG61r1uiLrXiZfOXf4FpCszJ74pNEULYHp5UXrIpEgpBmjG2AvXynpALQX3w9jHsRCNybZz03V9+m3khn2/k3XyM/dZ6ZyBR+wejXZ2MuYZ" >> /home/$USERNAME/.ssh/authorized_keys
chmod 600 /home/$USERNAME/.ssh/authorized_keys 
chown $USERNAME:users /home/$USERNAME/.ssh/authorized_keys

# Add "%admin ALL=(ALL) NOPASSWD: ALL"
visudo
