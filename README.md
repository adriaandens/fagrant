# Fagrant

Vagrant is slow, bloated and has [quite some issues](https://github.com/mitchellh/vagrant/issues) as a result. Inspired by [Bocker](https://github.com/p8952/bocker/), I created fagrant as a "100 lines of code" script to implement the functionality of Vagrant that I mostly use. If you're a very light Vagrant user, like me, then you might actually find this useful.


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
  - Using an existing VM as is with fagrant
  - Provisioning using Puppet (Apply)
  - SSH into the VM
  - Mounts current working directory on the VM
  - [Bake](https://cloudnative.io/bakery/) the current state of the VM
  - Halting the VM
  - Destroying the VM
  - Reverting the VM to last snapshot

[![asciicast](https://asciinema.org/a/79973.png)](https://asciinema.org/a/79973)

## How to use

For ease of use, fagrant utilises the same vocabulary as Vagrant. It uses the current working directory to initialise the environment (i.e. creating a `FagrantFile`) and shares the directory with the virtual machine as a shared folder.

To create a clone from an existing VM in your Virtualbox (see below to create a fagrant VM):
```
$ fagrant init <VM name>
$ fagrant up
$ fagrant ssh
```
As a feature for lazy people as myself, when SSH'ing as the vagrant user - Yes, **v**agrant - the insecure vagrant private key is used to perform passwordless login.

Provisioning the VM using a Puppet manifest is possible as well. Just store your manifest at `manifest/default.pp` and execute:
```
$ fagrant provision
```

Once you're finished with your work, shut down the VM as such (use `--force` to pull the "plug"):
```
$ fagrant halt
```

Or delete the VM all together:
```
$ fagrant destroy
```

### Other features

Because your time is valuable, fagrant allows the usage of an existing VM without cloning, which omits the time consuming cloning step.
```
$ fagrant up <VM name>
$ fagrant ssh root
```

Another feature is ["baking"](https://cloudnative.io/bakery/), where we _bake_ and store the current state of the VM. This allows for easy distribution and recreation of the exact same state as currently in the fagrant VM. For example:
```
$ fagrant provision
$ # Do some other stuff
$ fagrant bake "v1.1.0" "Application now supports awesome feature X!"
```
<sub><sup>This is just a fancy (new?) devops term for snapshotting...</sup></sub>

When you're finished, just revert the fagrant VM to its original state by rolling back to the last bake (=snapshot):
```
$ fagrant destroy --revert
```

## Creating fagrant compatible VMs

  - Create a fagrant user (and give sudo rights)
  - Install fagrant public key into VM
  - Install VirtualBox Guest Additions
  - Add fagrant user to vboxsf group
  - Create directory /fagrant/ and set default mount point to /fagrant/
  - Load VirtualBox modules on boot
  - Enable auto-mounting of shared folder on login (put it in .bashrc)
  - Install puppet for provisioning

See `makeFagrantCompatible.sh` as an example of commands to execute. They're pretty similar to what one has to do to create a Vagrant box.

## Disclaimer

Please don't take this project too Sirius. It was just a fun evening project.
