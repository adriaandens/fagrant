print "\nPlease install VirtualBox first...\n\n" if system("VBoxManage -v > /dev/null 2>&1") != 0;
my $cwd_vm;
if(-e 'FagrantFile') {
    open(FH, '< FagrantFile');
    $cwd_vm = <FH>;
    close(FH);
    # Check if VM exists...
    if(!vm_state($cwd_vm, 'exists')) {
        print "VM from FagrantFile doesn't exist. :x\n";
        exit 1;
    }
}
sub vm_state {
    my ($vm_name, $state) = @_;

    my @lines;
    if($state eq 'exists') {@lines = `VBoxManage list vms`;}
    elsif($state eq 'running') {@lines = `VBoxManage list runningvms`;}

    my $found = 0;
    foreach(@lines) {
        /^"(.+)"\s{1}[^"]+$/;
        if($vm_name eq $1) {
            $found = 1;
            break;
        }
    }
    return $found;
}
$ARGV[0] && $ARGV[0] =~ /(add|init|up|ssh|halt|destroy)/ ? $ARGV[0]() : help();

sub init {
    if($cwd_vm) {
        print "Wow wow, there's already a fagrant box for this directory?! Are you crazy?\n";
        return;
    }
    if(vm_state($ARGV[1], "exists")) {
        # Clone it with random name
        $cwd_vm = $1 . "_" . time();
        print "Cloning VM with name '$cwd_vm'\n";
        `VBoxManage clonevm $1 --name $cwd_vm`;
        my @vmfolder = `VBoxManage list systemproperties`;
        my @vmdir = map {/Default machine folder:\s+(.+)$/;$1} grep {/^Default machine folder:/} @vmfolder;
        my $vmd = $vmdir[0];
        `VBoxManage registervm "$vmd/$cwd_vm/cwd_vm.vbox"`;
        
        # Store mapping in file in current working directory
        open(FH, "> FagrantFile") and print FH $name and close(FH);
    } else {
        print "That VM doesn't exist...\n";
    }
}

sub up {
    # Boot that VM
    # Setup ports
}

sub ssh {
    # Check if VM is running
    # SSH into VM
    # Give terminal to user
}

sub halt {
    # Maybe do something graceful first?

    if(vm_state($cwd_vm, 'running')) {
        `vboxmanage controlvm $cwd_vm poweroff`;
    }
}

sub destroy {
    if(vm_state($cwd_vm, 'running')) {
        halt();
    }

    # Delete VM
    my @lines = `VBoxManage showvminfo $cwd_vm`;

    unlink('FagrantFile');
}

sub help {
    print "\nFagRant - does what vagrant does, only in 100 loc.\n\n";
    print "\t$0 init <VM name> - Initialize new VM in current working directory, cloned from <VM name>\n";
    print "\t$0 up - Boot the VM\n";
    print "\t$0 ssh - SSH into the box\n";
    print "\t$0 halt - Halt the VM\n";
    print "\t$0 destroy - Destroy the VM\n";
    print "\t$0 help - Print this\n\n";
}
