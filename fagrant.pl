#!/usr/bin/perl
use strict;
use warnings;

die "Error: Install Virtualbox.\n" if system("VBoxManage -v > /dev/null 2>&1") != 0;
my $vm_name; my $fh;
my $conffile = 'VMFile';
my $globalconffile = $ENV{HOME} . '/.fagrant';
my $default_user = 'fagrant';

if( -e $conffile ) {
    open $fh, '<', $conffile or die "Error: Can't open $conffile: $!\n";
    chomp( $vm_name = <$fh> );
    close $fh or die "Error: Can't close $conffile: $!\n";
    vm_state( $vm_name, 'exists' ) or die "Error: VM '$vm_name' from '$conffile' doesn't exist.\n";
}
if( -e $globalconffile ) {
    open $fh, '<', $globalconffile or die "Error: Can't open $globalconffile: $!\n";
    chomp( $default_user = <$fh> );
    close $fh or die "Error: Can't close $globalconffile: $!\n";
}
my $subroutines = {'init' => \&init, 'up' => \&up, 'ssh' => \&ssh, 'bake' => \&bake, 'halt' => \&halt, 'destroy' => \&destroy};
$ARGV[0] && $ARGV[0] =~ /(init|up|ssh|bake|halt|destroy)/ ? $subroutines->{$ARGV[0]}->() : help();

sub vm_state {
    my ($vm_name, $state) = @_;
    return grep {/^"(.+)"\s{1}[^"]+$/;$vm_name eq $1} `VBoxManage list vms` if $state eq 'exists';
    return grep {/^"(.+)"\s{1}[^"]+$/;$vm_name eq $1} `VBoxManage list runningvms` if $state eq 'running';
}

sub init {
    $vm_name and die "Error: There's already a VM ('$vm_name') configured in this directory.\n";
    !$ARGV[1] and print STDERR "Error: No argument given to '$0 init'.\n" and help() and die;
    vm_state($ARGV[1], 'exists') or die "Error: No VM found with name '$ARGV[1]'.\n";
    $vm_name = $ARGV[1] . '_' . pop(@{[split(m#/#,$ENV{PWD})]}) . '_' . time();

    print "Cloning VM '$vm_name'.\n";
    print `VBoxManage clonevm "$ARGV[1]" --name "$vm_name"`;
    my $vm_directory = shift @{ [ map {/Default machine folder:\s+(.+)$/;$1} grep {/^Default machine folder:/} `VBoxManage list systemproperties` ] };
    my $vm_location = $vm_directory . '/' . $vm_name . '/' . $vm_name . '.vbox';
    print `VBoxManage registervm "$vm_location"`;

    open $fh, '>', $conffile or die "Error: Can't open $conffile: $!\n";
    print {$fh} $vm_name;
    close $fh or die "Error: Can't close $conffile: $!\n";
}

sub up {
    if( !$vm_name && $ARGV[1] && vm_state($ARGV[1], 'exists') ) {
        $vm_name = $ARGV[1];
        open $fh, '>', $conffile or die "Error: Can't open $conffile: $!\n";
        print {$fh} $vm_name;
        close $fh or die "Error: Can't close $conffile: $!\n";
    } 
    $vm_name or die "Error: No VM was configured to boot. Either use '$0 up <vm_name>' or '$0 init <vm_name> && $0 up'.\n";
    my $port = 2000 + int(rand(9000));
    `VBoxManage modifyvm "$vm_name" --natpf1 delete "guestssh" > /dev/null 2>&1`;
    `VBoxManage modifyvm "$vm_name" --natpf1 "guestssh,tcp,,$port,,22" > /dev/null 2>&1`;
    `VBoxManage sharedfolder remove "$vm_name" --name guestfolder > /dev/null 2>&1`;
    `VBoxManage sharedfolder add "$vm_name" --name "guestfolder" --hostpath $ENV{PWD} --automount > /dev/null 2>&1`;
    my $window_type = 'headless';
    $window_type = 'gui' if grep { /^(--)?gui$/ } @ARGV; # Boot with GUI if user asks for it.
    print "Booting VM...\n";
    system("VBoxManage startvm --type $window_type \"$vm_name\" > /dev/null 2>&1 &");
}

sub ssh {
    $vm_name or die "Error: You haven't called '$0 (init|up)'.\n";
    my $user = $ARGV[1] // $default_user;
    my $keyfile = $user eq 'vagrant' ? $ENV{HOME} . '/.vagrant.d/insecure_private_key' : $ENV{HOME} . '/.ssh/fagrant';
    my $ssh_port = shift @{ [ map {/host port = (\d+),/;$1} grep {/NIC \d+ Rule.+guest port = 22/} `VBoxManage showvminfo "$vm_name"` ] };
    system("ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $keyfile $user\@localhost -p $ssh_port") if $vm_name && vm_state($vm_name, 'running');
}

sub bake {
    $vm_name or return;
    my $snapshot_name = "snapshot_" . time();
    my $comment = join(' ', splice(@ARGV, 1)); # Handle user not using quotes.
    `VBoxManage snapshot "$vm_name" take "$snapshot_name" --description "$comment"`;
    `VBoxManage controlvm "$vm_name" resume > /dev/null 2>&1`;
}

sub halt {
    my $method = $ARGV[1] && $ARGV[1] eq '--force' ? 'poweroff' : 'acpipowerbutton';
    system("VBoxManage controlvm \"$vm_name\" $method") if $vm_name && vm_state($vm_name, 'running');
}

sub destroy {
    $vm_name or return;
    halt() if vm_state($vm_name, 'running');
    print "Confirm the destruction of the VM by typing 'y[es]': ";
    return if <STDIN> !~ /^ye?s?/i; # User changed their mind
    `VBoxManage unregistervm "$vm_name" --delete`;
    unlink($conffile);
}

sub help {
    print "\n\t$0 init <VM name>: Initialize a new VM in this directory.\n\t$0 up [name] [--gui]: Boot the VM.\n\t$0 ssh [user]: SSH into the VM as [user]. Default user can be set in ~/.fagrant\n\t$0 bake [description]: Make a snapshot of the VM.\n\t$0 halt [--force]: Halt the (running) VM.\n\t$0 destroy: Destroy the VM.\n\n";
}
