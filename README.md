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
  - SSH into the VM
  - Mounts current working directory on the VM so your files are accessible in the VM.
  - [Bake](https://cloudnative.io/bakery/) the current state of the VM
  - Halting the VM
  - Destroying the VM

[![asciicast](https://asciinema.org/a/79973.png)](https://asciinema.org/a/79973)

## How to use

For ease of use, fagrant utilises the same vocabulary as Vagrant. It uses the current working directory to initialise the environment (i.e. creating a `VMFile`) and shares the directory with the virtual machine as a shared folder.

To create a clone from an existing VM in your Virtualbox (see below to create a fagrant VM):
```
$ fagrant init <VM name>
$ fagrant up
$ fagrant ssh
```
As a feature for lazy people as myself, when SSH'ing as the vagrant user - Yes, **v**agrant - the insecure vagrant private key is used to perform passwordless login.

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
```

You can also define the user to log in with:
```
$ fagrant ssh root
```

Another feature is ["baking"](https://cloudnative.io/bakery/), where we _bake_ and store the current state of the VM. This allows for easy distribution and recreation of the exact same state as currently in the fagrant VM. For example:
```
$ # Do some stuff inside VM
$ fagrant bake "Application now supports awesome feature X!"
```
<sub><sup>This is just a fancy (new?) devops term for snapshotting...</sup></sub>

If you want to boot the VM with a GUI (not headless), use the `--gui` option:
```
$ fagrant up --gui
```

If you don't like the default user for SSH'ing into the box, you can configure your own default user:
```
$ echo "defaultuser" > ~/.fagrant
```

If you don't like the name "fagrant", you can just alias it in your `.bashrc`:
```
alias vm="fagrant"
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

See `make_vm.sh` as an example of commands to execute. They're pretty similar to what one has to do to create a Vagrant box.

## Disclaimer

Please don't take this project too Sirius. It was just a fun evening project.
