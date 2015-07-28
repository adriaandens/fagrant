# Fagrant

Vagrant is slow, bloated and has [quite some issues](https://github.com/mitchellh/vagrant/issues). Inspired by [Bocker](https://github.com/p8952/bocker/), I created fagrant as a "100 lines of code" script to implement the functionality of Vagrant, which I mostly use.

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
  - Reverting the VM to last snapshot

## How to use

For ease of use, fagrant utilises the same vocabulary as vagrant. It always uses the current working directory to initialise the environment (i.e. creating a `FagrantFile`).

To create a clone from an existing VM in your Virtualbox:
```
$ fagrant init <VM name>
$ fagrant up
$ fagrant ssh
```

As a feature for lazy people as myself, when SSH'ing as the vagrant user - Yes, **v**agrant - the insecure vagrant private key is used to perform passwordless login.

If you want to use an existing VM as a fagrant VM:
```
$ echo "VM name" > FagrantFile
$ fagrant up
$ fagrant ssh root
```
Notice that we login with the user root. No need to create the fagrant user to get up and running.

And shutting down (use `--force` to pull the "plug"):
```
$ fagrant halt
```

Shutting down and deleting the VM (use --revert to rollback to snapshot instead of deleting VM):
```
$ fagrant destroy
```

## Creating fagrant compatible VMs

  - Create a fagrant user (and give sudo rights)
  - Install fagrant public key into VM
  - Install VirtualBox Guest Additions
  - Add fagrant user to vboxsf group
  - Set default mount point to /fagrant/
  - Load VirtualBox modules on boot
  - Enable auto-mounting of shared folder on login (put it in .bashrc)

See `makeFagrantCompatible.sh` as an example of commands to execute. They're pretty similar to what one has to do to create a Vagrant box.

## TODO

  - Implement (Puppet) provisioning

## Disclaimer

Please don't take this project too Sirius. It was just a fun evening project.
