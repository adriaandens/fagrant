#!/bin/perl

print "\nPlease install VirtualBox first...\n\n" if system("VBoxManage -v > /dev/null 2>&1") != 0;
my $cwd_vm;
if(-e 'FagrantFile') {
    open(FH, '< FagrantFile');
    $cwd_vm = <FH>;
    chomp($cwd_vm);
    close(FH);
    if(!vm_state($cwd_vm, 'exists')) {
        print "VM from FagrantFile doesn't exist. :x\n";
        exit 1;
    }
}
$ARGV[0] && $ARGV[0] =~ /(init|up|ssh|halt|destroy)/ ? $ARGV[0]() : help();

sub vm_state {
    my ($vm_name, $state) = @_;

    my @lines;
    if($state eq 'exists') {
        @lines = `VBoxManage list vms`;
    } elsif($state eq 'running') {
        @lines = `VBoxManage list runningvms`;
    }

    my $found = grep {/^"(.+)"\s{1}[^"]+$/;$vm_name eq $1} @lines;
    return $found;
}

sub init {
    if($cwd_vm) {
        print "Wow wow, there's already a fagrant box for this directory?! Are you crazy?\n";
        return;
    }
    if(vm_state($ARGV[1], "exists")) {
        $cwd_vm = $ARGV[1] . "_" . time();
        print "Cloning VM with name '$cwd_vm'.\n";
        print `VBoxManage clonevm $ARGV[1] --name $cwd_vm`;
        my @vmdir = map {/Default machine folder:\s+(.+)$/;$1} grep {/^Default machine folder:/} `VBoxManage list systemproperties`;
        my $vm_location = $vmdir[0] . '/' . $cwd_vm . '/' . $cwd_vm . '.vbox';
        print `VBoxManage registervm "$vm_location"`;
        
        open(FH, "> FagrantFile") and print FH "$cwd_vm" and close(FH);
    } else {
        print "That VM doesn't exist...\n";
    }
}

sub up {
    if($cwd_vm) {
        my $port = 2000 + int(rand(1000));
        `VBoxManage modifyvm "$cwd_vm" --natpf1 delete "guestssh" > /dev/null 2>&1`; # Delete old rule
        `VBoxManage modifyvm "$cwd_vm" --natpf1 "guestssh,tcp,,$port,,22" > /dev/null 2>&1`;
        `VBoxManage sharedfolder add "$cwd_vm" --name "guestfolder" --hostpath $ENV{PWD} --automount > /dev/null 2>&1`;
        print "Booting VM...\n";
        system("VBoxHeadless --startvm \"$cwd_vm\" > /dev/null 2>&1 &");
        sleep(15);
    }
}

sub ssh {
    my $user = $ARGV[1] // "fagrant"; # http://www.effectiveperlprogramming.com/2010/10/set-default-values-with-the-defined-or-operator/
    my $keyfile = $user eq 'vagrant' ? $ENV{HOME} . '/.vagrant.d/insecure_private_key' : $ENV{HOME} . '/.ssh/fagrant';
    my @sshrules = map {/host port = (\d+),/;$1} grep {/NIC \d+ Rule.+guest port = 22/} `VBoxManage showvminfo $cwd_vm`;
    if($cwd_vm && vm_state($cwd_vm, 'running')) {
        system("ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $keyfile $user\@localhost -p " . $sshrules[0]);
    }
}

sub halt {
    my $method = $ARGV[1] eq '--force' ? 'poweroff' : 'acpipowerbutton';
    if($cwd_vm && vm_state($cwd_vm, 'running')) {
        `VBoxManage controlvm "$cwd_vm" $method`;
    }
}

sub destroy {
    if($cwd_vm) {
        halt() if vm_state($cwd_vm, 'running');
        `VBoxManage unregistervm $cwd_vm --delete` if not defined $ARGV[1];
        `VBoxManage snapshot restorecurrent $cwd_vm` if $ARGV[1] eq '--revert';
        unlink('FagrantFile');
    }
}

sub help {
    print "\nFagrant - does what vagrant does, only in 100 loc.\n\n";
    print "\t$0 init <VM name> - Initialize new VM in current working directory, cloned from <VM name>\n";
    print "\t$0 up - Boot the VM\n";
    print "\t$0 ssh <user> - SSH into the box\n";
    print "\t$0 halt - Halt the VM\n";
    print "\t$0 destroy - Destroy the VM\n";
    print "\t$0 destroy --revert - Revert the VM to latest snapshot and remove FagrantFile\n";
    print "\t$0 help - Print this\n\n";
}
