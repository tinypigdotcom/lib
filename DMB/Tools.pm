package DMB::Tools;

use 5.016;
use strict;
use warnings;

require Exporter;

use Carp 'longmess';
use Data::Dumper;
use Date::Parse;
use IO::File;
use JSON;
use Term::ReadKey;
use Time::Local;
use URI::Escape;
use Time::HiRes qw( usleep );

our $VERSION = '0.0.9';

our @ISA = qw(Exporter);

our %EXPORT_TAGS = (
    'all' => [
        qw(
          clip
          column_output
          debug_log
          directory_read
          dt_first_value
          dt_log
          file_contents
          file_contents_flat
          file_slurp
          get_epoch_seconds
          infile
          json
          multi_input
          nice_timestamp
          outfile
          percent_encode
          print_to_debug_log
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

sub clip {
    my $data = shift;
    if ( $data ) {
        my $cfh = IO::File->new('/dev/clipboard', '>');
        if (defined $cfh) {
            print $cfh $data;
            $cfh->close;
        }
    }
    else {
        my $ifh = IO::File->new('/dev/clipboard', '<');
        die if (!defined $ifh);
        my $contents = do { local $/; <$ifh> };
        $ifh->close;
        return $contents;
    }
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
    my ( $params ) = @_;
    my $time_text = $params->{time_text};
    my ( $sec, $min, $hour, $mday, $mon, $year, $format );

    if ( $time_text ) {
        ( $sec, $min, $hour, $mday, $mon, $year ) = gmtime(str2time($time_text,'GMT'));
    }
    else {
        ( $sec, $min, $hour, $mday, $mon, $year ) = localtime(time);
    }

    if ( $params->{readable} ) {
        $format = '%04s%02s%02s%02s%02s%02s';
    }
    else {
        $format = '%04s-%02s-%02s %02s:%02s:%02s';
    }

    $mon++;
    $year += 1900;

    return sprintf( $format, $year, $mon, $mday, $hour, $min, $sec );
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

sub debug_log {
    my ( $debug_file_path, @messages ) = @_;
    return unless $debug_file_path;
    my $timestamp = timestamp();
    my $message = longmess( join ' ', @messages );
    my $log_entry = "$timestamp $message";
    print_to_debug_log($debug_file_path, "$log_entry\n");
    return;
}

sub print_to_debug_log {
    my ( $debug_file_path, $message ) = @_;

    my $ofh = IO::File->new($debug_file_path, '>>');
    die if (!defined $ofh);

    print $ofh $message;
    $ofh->close;
}

sub json {
    my ($text,$args) = @_;
    my $json = JSON->new->allow_nonref;
    $text =~ s{^(\s*)(\w+)}{$1"$2"}mg;
    if ( !$args->{ugly} ) {
        $json = $json->pretty;
    }
    my $perlvar = $json->decode( $text );
    my $utf8_encoded_json_text = $json->encode( $perlvar );
    return $utf8_encoded_json_text;
}

sub percent_encode {
    my ($text) = @_;
    my $uri_encoded_text = uri_escape_utf8( $text );
    return $uri_encoded_text;
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
        for ( 1..30 ) {
            if (defined ($char = ReadKey(-1)) ) {
                $current_input_type = $INPUT_TYPE{STDIN};
            }
            last if $char;
            usleep (100_000);
        }
        ReadMode ('normal');

        if ( $current_input_type == $INPUT_TYPE{NONE} ) {
            $current_input_type = $INPUT_TYPE{DEFAULT};
        }
    }
    my $PROG = $0;
    $PROG =~ s{.*/}{};
    warn "$PROG: input_type is $INPUT_LABEL{$current_input_type}\n";

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

=head1 NAME

DMB::Tools - A collection of utilities I like to have handy

=head1 SYNOPSIS

  use DMB::Util ':all';

  # OR

  use DMB::Util qw(
      clip
      column_output
      debug_log
      directory_read
      dt_first_value
      dt_log
      file_contents
      file_contents_flat
      file_slurp
      get_epoch_seconds
      infile
      init_random_names
      json
      multi_input
      nice_timestamp
      outfile
      percent_encode
      print_to_debug_log
      pseudo_uuid
      random_date_past_year
      random_element
      random_names
      random_profile_id
      random_words
      timestamp
      write_file
  );

  file_contents_flat('/tmp/file');

=head1 DESCRIPTION

C<DMB::Tools> contains a collection of utilities I like to have handy

By default C<DMB::Tools> does not export anything.

=over 4

=item B<clip>

B<NOTE> this is an example documentation and has nothing to do with the actual
function.

  all_keys(%hash,@keys,@hidden);

all_keys() returns blahblah seed bytes used to randomise ordering.

Populates the arrays @keys with the all the keys that would pass
keys that have not been utilized.

In the case of an unrestricted hash this will be equivalent to

  $ref = do {
      @keys = keys %hash;
  };

=item B<column_output>
=item B<debug_log>
=item B<directory_read>
=item B<dt_first_value>
=item B<dt_log>
=item B<file_contents>
=item B<file_contents_flat>

B<NOTE> this is an example documentation and has nothing to do with the actual
function.

  my $contents = file_contents_flat('/tmp/file');

file_contents_flat() returns the entire contents of the specified file, minus
any newline characters.

=item B<file_slurp>
=item B<get_epoch_seconds>
=item B<infile>
=item B<init_random_names>
=item B<json>
=item B<multi_input>
=item B<nice_timestamp>
=item B<outfile>
=item B<percent_encode>
=item B<print_to_debug_log>
=item B<pseudo_uuid>
=item B<random_date_past_year>
=item B<random_element>
=item B<random_names>
=item B<random_profile_id>
=item B<random_words>
=item B<timestamp>
=item B<write_file>

=back

=head1 CAVEATS

Don't use clip() as there is a standard module that does it.

=head1 BUGS

None that I know of.

=head1 AUTHOR

David M Bradford <davembradford@gmail.com>

=head1 SEE ALSO

I don't know. Modules that this module uses, perhaps.

=cut

