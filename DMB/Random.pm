package DMB::Random;

use 5.016;
use strict;
use warnings;

require Exporter;
use IO::File;
use Data::Dumper;
use Time::Local;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration   use Foo ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
    dt_first_value
    xdt_log
    column_output
    get_fake_uuid
    random_date_past_year
    get_random_words
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
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

sub xdt_log {
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

my $hexes = '0123456789abcdef';
my @hex_list = split '', $hexes;

sub _hexy {
    my ($num) = @_;
    my $retval;
    for ( 1 .. $num ) {
        $retval .= $hex_list[int(rand(scalar @hex_list))];
    }
    return $retval;
}

sub get_fake_uuid {
    my $fake_uuid = _hexy(8) . '-' .
                    _hexy(4) . '-' .
                    _hexy(4) . '-' .
                    _hexy(4) . '-' .
                    _hexy(12);
    return $fake_uuid;
}

sub random_date_past_year {
    my $ago = int(rand(24 * 60 * 60 * 365));
    my $random_date = timelocal(localtime()) - $ago;
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime($random_date);

    my $formatted = sprintf "%02d/%02d/%04d %02d:%02d:%02d", $mon+1, $mday, $year+1900, $hour, $min, $sec;
    return $formatted;
}

my $wordlist = "$ENV{HOME}/data/words_pg";

sub get_random_words {
    my ($length, $numwords) = @_;
    my @words;

    open WORDS, '<', $wordlist or die "Cannot open $wordlist:$!";

    while (<WORDS>) {
        chomp;
        next if m{'} || m{s$} || m{^[A-Z]};
        push @words, $_ if (length($_) == $length);
    }

    close WORDS;

    my @return_words;
    for (0 .. ($numwords-1)) {
        push @return_words, $words[int(rand(scalar @words))];
    }

    return @return_words;
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

