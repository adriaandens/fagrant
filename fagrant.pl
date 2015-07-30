#!/usr/bin/perl
use strict;
use warnings;

print "\nPlease install VirtualBox first...\n\n" if system("VBoxManage -v > /dev/null 2>&1") != 0;
my $vm_name;
if(-e 'FagrantFile') {
    open(FH, '< FagrantFile');
    chomp($vm_name = <FH>);
    close(FH);
    if(!vm_state($vm_name, 'exists')) {
        print "VM from FagrantFile doesn't exist. :x\n";
        exit 1;
    }
}
my $subroutines = {'init' => \&init, 'up' => \&up, 'provision' => \&provision, 'ssh' => \&ssh, 'halt' => \&halt, 'destroy' => \&destroy};
$ARGV[0] && $ARGV[0] =~ /(init|up|provision|ssh|halt|destroy)/ ? $subroutines->{$ARGV[0]}->() : help();

sub vm_state {
    my ($vm_name, $state) = @_;
    return grep {/^"(.+)"\s{1}[^"]+$/;$vm_name eq $1} `VBoxManage list vms` if $state eq 'exists';
    return grep {/^"(.+)"\s{1}[^"]+$/;$vm_name eq $1} `VBoxManage list runningvms` if $state eq 'running';
}

sub init {
    if($vm_name) {
        print "Wow wow, there's already a fagrant VM for this directory?! Are you crazy?\n";
        return;
    }
    if(vm_state($ARGV[1], "exists")) {
        $vm_name = $ARGV[1] . "_" . time();
        print "Cloning VM with name '$vm_name'.\n";
        print `VBoxManage clonevm $ARGV[1] --name "$vm_name"`;
        my $vm_directory = shift [ map {/Default machine folder:\s+(.+)$/;$1} grep {/^Default machine folder:/} `VBoxManage list systemproperties` ];
        my $vm_location = $vm_directory . '/' . $vm_name . '/' . $vm_name . '.vbox';
        print `VBoxManage registervm "$vm_location"`;
        
        open(FH, "> FagrantFile") and print FH $vm_name and close(FH);
    } else {
        print "Sorry, couldn't find a VM with the name '$vm_name'.\n";
    }
}

sub up {
    if($vm_name) {
        my $port = 2000 + int(rand(1000));
        `VBoxManage modifyvm "$vm_name" --natpf1 delete "guestssh" > /dev/null 2>&1`;
        `VBoxManage modifyvm "$vm_name" --natpf1 "guestssh,tcp,,$port,,22" > /dev/null 2>&1`;
        `VBoxManage sharedfolder remove "$vm_name" --name guestfolder > /dev/null 2>&1`;
        `VBoxManage sharedfolder add "$vm_name" --name "guestfolder" --hostpath $ENV{PWD} --automount > /dev/null 2>&1`;
        print "Booting VM...\n";
        system("VBoxHeadless --startvm \"$vm_name\" > /dev/null 2>&1 &");
        sleep(15); # Find a better way?
    }
}

sub provision {
    ssh("sudo mount -t vboxsf -o uid=\$(id -u),gid=\$(id -g) guestfolder /fagrant");
    ssh("puppet apply /fagrant/manifests/default.pp");
}

sub ssh {
    my $user = $ARGV[1] // "fagrant";
    my $command = $_[0] // "";
    my $keyfile = $user eq 'vagrant' ? $ENV{HOME} . '/.vagrant.d/insecure_private_key' : $ENV{HOME} . '/.ssh/fagrant';
    my $ssh_port = shift [ map {/host port = (\d+),/;$1} grep {/NIC \d+ Rule.+guest port = 22/} `VBoxManage showvminfo "$vm_name"` ];
    system("ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $keyfile $user\@localhost -p $ssh_port $command") if $vm_name && vm_state($vm_name, 'running');
}

sub halt {
    my $method = $ARGV[1] && $ARGV[1] eq '--force' ? 'poweroff' : 'acpipowerbutton';
    `VBoxManage controlvm "$vm_name" $method` if $vm_name && vm_state($vm_name, 'running');
}

sub destroy {
    if($vm_name) {
        halt() if vm_state($vm_name, 'running');
        if(not defined $ARGV[1]) {
            print "Not so fast José! U sure? "; # I know myself, I need this.
            `VBoxManage unregistervm "$vm_name" --delete` if <STDIN> =~ /^ye?s?/i;
        }
        `VBoxManage snapshot restorecurrent "$vm_name"` if $ARGV[1] && $ARGV[1] eq '--revert';
        unlink('FagrantFile');
    }
}

sub help {
    print "\nFagrant - does what vagrant does, only in 100 loc.\n\n";
    print "\t$0 init <VM name> - Initialize new VM in current working directory, cloned from <VM name>\n";
    print "\t$0 up - Boot the VM\n";
    print "\t$0 provision - Provision the VM\n";
    print "\t$0 ssh <user> - SSH into the box\n";
    print "\t$0 halt - Halt the VM\n";
    print "\t$0 destroy - Destroy the VM\n";
    print "\t$0 destroy --revert - Revert the VM to latest snapshot and remove FagrantFile\n";
    print "\t$0 help - Print this\n\n";
}
