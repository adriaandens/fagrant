# Fagrant

Vagrant is slow, bloated and has the weirdest problems (with Virtualbox). Inspired by https://github.com/p8952/bocker/, I created fagrant as a "100 lines of code" script to implement (part of) the functionality of Vagrant.

> Top definition: Fagrant
> 
>    A fake vagrant.
> 
> > "Jeromy is too lazy to work 9-5, so he puts on dirty clothes and stands on a corner begging for change."
> > 
> > "That's pretty lame."
> > 
> > "Dude, he makes more than minimum wage as a fagrant." 

Source: http://www.urbandictionary.com/define.php?term=Fagrant

## Functionality

Currently, the following functionality is implemented in fagrant.

  - Creating a VM cloned from an existing VM
  - Using an existing VM as is with fagrant (although SSH and/or mounting might not work)
  - SSH into the VM
  - Mounts current working directory on the VM
  - Halting the VM
  - Destroying the VM

## How to use

For ease of use, fagrant utilises the same vocabulary as vagrant. It always uses the current working directory to initialise the environment (i.e. creating a FagrantFile).

To create a clone from an existing VM in your Virtualbox:
```
$ fagrant init <VM name>
$ fagrant up
$ fagrant ssh
```

If you want to use the VM as is but just have the benefits of using fagrant:
```
$ echo VMname > FagrantFile
$ fagrant up
$ fagrant ssh
```

And shutting down:
```
$ fagrant halt
```

Shutting down and deleting the VM:
```
$ fagrant destroy
```

## Creating Fagrant boxes

To have a good experience with Fagrant, you might have to modify your VM slightly. For example, SSH'ing into the VM is only possible if the default public key (id_rsa.pub) is an authorised key on the VM. If you create the fagrant user, consider giving it sudo rights without password confirmation, as such:
```
$ visudo
%admin ALL=(ALL) NOPASSWD: ALL
```

where "admin" is the group name of which fagrant is a member; for completeness sake:
```
# groupadd admin
# useradd -m -g admin -s /bin/bash fagrant
# usermod -a -G users fagrant
# usermod -a -G vboxsf fagrant
# passwd fagrant
```

To mount the current working directory into the fagrant VM, you'll have to install the Virtualbox Guest Additions. To make your life, once again, easier:
```
# pacman -S virtualbox-guest-utils
# mkdir /fagrant
# VBoxControl guestproperty set /VirtualBox/GuestAdd/SharedFolders/MountDir /fagrant/
# echo "sudo mount -t vboxsf guestfolder /fagrant" >> /home/fagrant/.bashrc
# echo "vboxguest" > /etc/modules-load.d/virtualbox.conf 
# echo "vboxsf" >> /etc/modules-load.d/virtualbox.conf 
```

## TODO

  - Make sure two VMs are not using the same SSH port
  - Make the SSH key pair configurable?
  - Login by default as Fagrant user, but use root as backup
