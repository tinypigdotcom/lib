package DMB::Tools;

use 5.14.0;
use strict;
use warnings;

require Exporter;
use IO::File;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration   use Foo ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
    dt_first_value
    dt_log
    column_output
);

our $VERSION = '0.01';


# Preloaded methods go here.

sub dt_first_value {
    my $value = shift;
    while(ref $value eq 'ARRAY') {
        $value = $value->[0];
    }
    return $value;
}

sub dt_log {
    my ($filestring,$data) = @_;

    my $fh = IO::File->new();
    if ( -e '/tmp/debug_on' ) {
        my $file = "/tmp/dt_$filestring";
        $fh = IO::File->new(">> $file");
        my $mode = 0666;
        chmod $mode, $file;
        if (defined $fh) {
            if ( ref $data ) {
                $data = Dumper($data);
            }
            print $fh '=' x 79, "\n";
            print $fh (scalar localtime), "\n";
            print $fh '=' x 79, "\n";
            print $fh " $data\n";
            $fh->close;
        }
    }
}

sub column_output {
    my ($nn) = @_;
    my @lengths=();
    my $jj;
    for (@$nn) {
        $jj=0;
        for my $ii (@$_) {
            $ii //= '';
            my $len = length $ii;
            $lengths[$jj] //= 0;
            if ( $len > $lengths[$jj] ) {
                $lengths[$jj] = $len;
            }
            $jj++;
        }
    }

    for (@$nn) {
        $jj=0;
        for my $ii (@$_) {
            $ii //= '';
            printf "%-$lengths[$jj]s | ", $ii;
            $jj++;
        }
        print "\n";
    }
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Foo - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Foo;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Foo, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Dave Bradford, E<lt>dbradford@office.omniti.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Dave Bradford

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.16.3 or,
at your option, any later version of Perl 5 you may have available.


=cut

