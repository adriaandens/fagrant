$ARGV[0] && $ARGV[0] =~ /(init|up|ssh|halt|destroy)/ ? $ARGV[0]() : help();

sub init {}

sub up {}

sub ssh {}

sub halt {}

sub destroy {}

sub help {
    print "\nFagRant - does what vagrant does, only in 100 loc.\n\n";
    print "\t$0 init <box name> - Initialize box in current working directory\n";
    print "\t$0 up - Boot the VM\n";
    print "\t$0 ssh - SSH into the box\n";
    print "\t$0 halt - Halt the VM\n";
    print "\t$0 destroy - Destroy the VM\n";
    print "\t$0 help - Print this\n\n";
}
