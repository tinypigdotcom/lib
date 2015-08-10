package DMB::Tools;

use 5.016;
use strict;
use warnings;

require Exporter;

use Data::Dumper;
use Date::Parse;
use IO::File;
use Term::ReadKey;
use Time::Local;

our $VERSION = '0.0.7';

our @ISA = qw(Exporter);

our %EXPORT_TAGS = (
    'all' => [
        qw(
          column_output
          directory_read
          dt_first_value
          dt_log
          file_contents
          file_contents_flat
          file_slurp
          get_epoch_seconds
          infile
          multi_input
          nice_timestamp
          outfile
          pseudo_uuid
          random_date_past_year
          random_element
          random_names
          random_profile_id
          random_words
          timestamp
          write_file
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT    = qw();

sub dt_first_value {
    my $value = shift;
    while ( ref $value eq 'ARRAY' ) {
        $value = $value->[0];
    }
    return $value;
}

sub dt_log {
    my ( $filestring, $data ) = @_;

    my $fh = IO::File->new();
    if ( -e '/tmp/debug_on' ) {
        my $file = "/tmp/dt_$filestring";
        $fh = IO::File->new(">> $file");
        my $mode = 0666;
        chmod $mode, $file;
        if ( defined $fh ) {
            if ( ref $data ) {
                $data = Dumper($data);
            }
            print $fh '=' x 79, "\n";
            print $fh ( scalar localtime ), "\n";
            print $fh '=' x 79, "\n";
            print $fh " $data\n";
            $fh->close;
        }
    }
}

sub column_output {
    my ($nn) = @_;
    my @lengths = ();
    my $jj;
    for (@$nn) {
        $jj = 0;
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
        $jj = 0;
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
        $retval .= $hex_list[ int( rand( scalar @hex_list ) ) ];
    }
    return $retval;
}

sub pseudo_uuid {
    my $pseudo_uuid =
        _hexy(8) . '-'
      . _hexy(4) . '-'
      . _hexy(4) . '-'
      . _hexy(4) . '-'
      . _hexy(12);
    return $pseudo_uuid;
}

sub random_date_past_year {
    my $ago         = int( rand( 24 * 60 * 60 * 365 ) );
    my $random_date = timelocal( localtime() ) - $ago;
    my ( $sec, $min, $hour, $mday, $mon, $year ) = localtime($random_date);

    my $formatted = sprintf "%02d/%02d/%04d %02d:%02d:%02d", $mon + 1, $mday,
      $year + 1900, $hour, $min, $sec;
    return $formatted;
}

my $wordlist = "$ENV{HOME}/data/words_pg";

sub random_words {
    my ( $length, $numwords ) = @_;
    my @words;

    open WORDS, '<', $wordlist or die "Cannot open $wordlist:$!";

    while (<WORDS>) {
        chomp;
        next if m{'} || m{s$} || m{^[A-Z]};
        push @words, $_ if ( length($_) == $length );
    }

    close WORDS;

    my @return_words;
    for ( 0 .. ( $numwords - 1 ) ) {
        push @return_words, $words[ int( rand( scalar @words ) ) ];
    }

    return @return_words;
}

my @profile_ids = ( 111, 222, 333, 1234, 54321, 999 );

sub random_profile_id {
    return $profile_ids[ int( rand( scalar @profile_ids ) ) ];
}

my %file = (
    first => "$ENV{HOME}/data/firstname",
    last  => "$ENV{HOME}/data/lastname",
);
my %names = (
    first => [],
    last  => [],
);

my $init_random_names = 0;

sub init_random_names {
    return if $init_random_names++;
    for my $ff ( 'first', 'last' ) {
        open I, '<', $file{$ff} or die "Cannot open $file{$ff}:$!";

        while (<I>) {
            chomp;
            push @{ $names{$ff} }, $_;
        }

        close I;
    }
}

sub random_names {
    my ($num_names) = @_;
    init_random_names();
    my @return_names;
    for ( 0 .. ( $num_names - 1 ) ) {
        my $total_first = scalar @{ $names{first} };
        my $total_last  = scalar @{ $names{last} };
        push @return_names,
          $names{first}->[ int( rand($total_first) ) ] . ' '
          . $names{last}->[ int( rand($total_last) ) ];
    }

    return @return_names;
}

sub random_element {
    my ($list) = @_;

    return $list->[ int( rand( scalar @$list ) ) ];
}

sub directory_read {

   # example
   # my @dot_files = grep { /^\./ && -f "$some_dir/$_" } get_directory($target);
    sub get_directory {
        my ($dir) = @_;
        opendir( my $dh, $dir ) || die "can't opendir $dir: $!";
        my @files = readdir($dh);
        closedir $dh;
        return @files;
    }

    my $target = $ENV{HOME};
    my @bins = grep { /^bin\d?/ && -d "$target/$_" } get_directory($target);
}

sub write_file {
    my ( $filename, $contents ) = @_;
    my $ofh = IO::File->new( $filename, '>' );
    die if ( !defined $ofh );

    print $ofh $contents;
    $ofh->close;
}

sub file_contents {
    return unless defined wantarray;
    my $filename = shift;

    my $ifh = IO::File->new( $filename, '<' );
    die if ( !defined $ifh );

    $ifh->binmode();

    my @contents;
    while ( my $line = <$ifh> ) {
        $line =~ s/[\x0a\x0d]//g if wantarray;
        push @contents, $line;
    }

    $ifh->close;

    return wantarray ? @contents : join('',@contents);
}

sub file_contents_flat {
    my $contents = file_contents(shift);
    $contents =~ s/[\x0a\x0d]//g;
    return $contents;
}

sub file_slurp {
    my $fh;
    my $contents = do { local $/; <$fh> };
}

sub infile {
    my $ifh = IO::File->new( $0, '<' );
    die if ( !defined $ifh );

    while (<$ifh>) {
        chomp;
        print "l: $_\n";
    }
    $ifh->close;
}

sub outfile {
    my $ofh = IO::File->new( 'a.out', '>' );
    die if ( !defined $ofh );

    print $ofh "bar\n";
    $ofh->close;
}

#    my ($ss,$mm,$hh,$day,$month,$year) = gmtime($time-1);
sub get_epoch_seconds {
    my @params = @_;
    my $time;
    if ( @params == 0 ) {
        return time();
    }
    if ( @params == 1 ) {
        $time = str2time($params[0],'GMT');
    }
    return $time if $time;
    my ( $sec, $min, $hour, $mday, $mon, $year ) = @params;
    $time = timegm( $sec, $min, $hour, $mday, $mon, $year );
    return $time;
}

sub timestamp {
    my @params = @_;
    my ( $sec, $min, $hour, $mday, $mon, $year );

    if ( @params == 0 ) {
        ( $sec, $min, $hour, $mday, $mon, $year ) = localtime(time);
    }
    elsif ( @params == 1 ) {
        ( $sec, $min, $hour, $mday, $mon, $year ) = gmtime(str2time($params[0],'GMT'));
    }

    $mon++;
    $year += 1900;

    return sprintf( "%04s%02s%02s%02s%02s%02s",
        $year, $mon, $mday, $hour, $min, $sec );
}

sub nice_timestamp {
    my @params = @_;
    my ( $sec, $min, $hour, $mday, $mon, $year );

    if ( @params == 0 ) {
        ( $sec, $min, $hour, $mday, $mon, $year ) = localtime(time);
    }
    elsif ( @params == 1 ) {
        ( $sec, $min, $hour, $mday, $mon, $year ) = gmtime($params[0]);
    }

    $mon++;
    $year += 1900;

    return sprintf( "%04s-%02s-%02s %02s:%02s:%02s",
        $year, $mon, $mday, $hour, $min, $sec );
}

sub multi_input {
    my $input = '';

    my %INPUT_TYPE = (
       NONE     => 0,
       ARGS     => 1,
       FILEARGS => 2,
       STDIN    => 3,
       DEFAULT  => 4,
    );
    my %INPUT_LABEL = reverse %INPUT_TYPE;

    my $current_input_type = $INPUT_TYPE{NONE};

    my $char;
    if ( @ARGV ) {
        if ( -f $ARGV[0] ) {
            $current_input_type = $INPUT_TYPE{FILEARGS};
        }
        else {
            $current_input_type = $INPUT_TYPE{ARGS};
        }
    }
    else {
        ReadMode ('cbreak');
        if (defined ($char = ReadKey(-1)) ) {
            $current_input_type = $INPUT_TYPE{STDIN};
        }
        ReadMode ('normal');

        if ( $current_input_type == $INPUT_TYPE{NONE} ) {
            $current_input_type = $INPUT_TYPE{DEFAULT};
        }
    }
    # warn "input_type is: $INPUT_LABEL{$input_type}\n";

    if ( $current_input_type == $INPUT_TYPE{FILEARGS} ) {
        local $/;
        for my $file (@ARGV) {
            my $ifh = IO::File->new($file, '<');
            die "Can't open $file: $!" if (!defined $ifh);

            $input .= <$ifh>;
            $ifh->close;
        }
    }
    elsif ( $current_input_type == $INPUT_TYPE{ARGS} ) {
        $input = join ' ', @ARGV;
    }
    elsif ( $current_input_type == $INPUT_TYPE{STDIN} ) {
            $input = $char . do { local $/; <STDIN> };
    }
    else {
        my $file = "$ENV{HOME}/a.cp";
        my $ifh = IO::File->new($file, '<');
        die "Can't open $file: $!" if (!defined $ifh);
        $input = do { local $/; <$ifh> };
        $ifh->close;
    }
    return $input;
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

