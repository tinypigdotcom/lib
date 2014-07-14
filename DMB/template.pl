#!/usr/bin/perl

use 5.14.0;
use warnings;
use autodie;

#------------------------------------------------------------------------
use IO::File;

my $ifh = IO::File->new($0, '<');
die if (!defined $ifh);

while(<$ifh>) {
    chomp;
    print "l: $_\n";
}
$ifh->close;

my $ofh = IO::File->new('a.out', '>');
die if (!defined $ofh);

print $ofh "bar\n";
$ofh->close;
#------------------------------------------------------------------------

