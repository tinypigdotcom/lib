package DMB::Hash;

use 5.014002;
use strict;
use warnings;

use Data::Dumper;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT = qw(
  key_diff
  key_diff_detail
);

our $VERSION = '0.01';

sub key_diff {
    my ( $hashref1, $hashref2 ) = @_;

    my %hash1 = %$hashref1;
    my %hash2 = %$hashref2;
    my %common;

    for my $ii ( keys %$hashref1 ) {
        if ( delete $hash2{$ii} ) {
            $common{$ii}++;
        }
    }

    for my $jj ( keys %$hashref2 ) {
        if ( delete $hash1{$jj} ) {
            $common{$jj}++;
        }
    }

    return ( [ keys %hash1 ], [ keys %hash2 ], [ keys %common ] );
}

sub key_diff_detail {
    my @hrefs = @_;

    my @arefs = key_diff( $hrefs[0], $hrefs[1] );

    my $output;
    my @titles;

    @titles = ( "In one:", "In two:", );

    for my $jj ( 0 .. 1 ) {
        my $mm = $jj ? $hrefs[0] : $hrefs[1];
        $output .= ( shift @titles ) . "\n";
        for my $ii ( sort { $a cmp $b } keys %{$hrefs[$jj]} ) {
            $output .= ( $mm->{$ii} ? '*' : ' ' ) . " $ii\n";
        }
        $output .= "\n";
    }

    @titles = ( "In one, not in two:", "In two, not in one:", "In both:", );

    for my $aa ( 0 .. $#arefs ) {
        $output .= "$titles[$aa]\n";
        for my $ii ( sort { $a cmp $b } @{ $arefs[$aa] } ) {
            $output .= "$ii\n";
        }
        $output .= "\n";
    }

    return $output;
}

1;
__END__

=head1 NAME

DMB::Hash - Perl extension for my hash utility functions. I am probably
re-inventing the wheel on my utility functions in my DMB:: namespace but the
idea is for me to have my own commonly-used tools I can easily upload
anywhere.

=head1 SYNOPSIS

  use DMB::Hash;
  my %hash1 = ( a => 1, b => 2, c => 3 );
  my %hash2 = ( b => 2, c => 3, d => 4, e => 5 );

  my ($unique1aref, $unique2aref, $common_aref) =
      key_diff( $hrefs[0], $hrefs[1] );

  print key_diff_detail( \%hash1, \%hash2 );

=head1 DESCRIPTION

Perform common hash functions

=head2 EXPORT

key_diff()

key_diff_detail()

=head1 SEE ALSO

Nothing yet

=head1 AUTHOR

David M. Bradford, E<lt>davembradford@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by David M. Bradford

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

