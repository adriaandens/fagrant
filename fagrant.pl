$ARGV[0] && $ARGV[0] =~ /(add|init|up|ssh|halt|destroy)/ ? $ARGV[0]() : help();

sub init {
    # Check if <VM name> exists
    # Clone it with random name
    # Store mapping in file in current working directory
}

sub up {
    # Read FagrantFile
    # Check if that VM exists
    # Boot that VM
    # Setup ports
}

sub ssh {
    # Check if VM exists and is running
    # SSH into VM
    # Give terminal to user
}

sub halt {
    # Check if VM exists and is running
    # Turn off VM
}

sub destroy {
    # Check if VM exists
    # If running, then halt it
    # Delete VM
    # Delete FagrantFile
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
