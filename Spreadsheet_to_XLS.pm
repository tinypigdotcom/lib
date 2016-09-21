package Spreadsheet_to_XLS;
use parent 'CommonApplication';

use 5.016003;
use strict;
use warnings;

use File::Copy;
use Spreadsheet::ParseExcel;
use Spreadsheet::WriteExcel;
use Spreadsheet::XLSX;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my %args = @_;

    my $self = bless { }, $class;

    return $self;
}

sub convert {
    my $self = shift;
    my ($spreadsheet) = @_;
    my $new_filename = $spreadsheet;
    $new_filename =~ s/\./_x./;

    my $swx = Spreadsheet::WriteExcel->new($new_filename);
    my $date_format = $swx->add_format(num_format => 'M/DD/YYYY H:MM');
    my $new_worksheet = $swx->add_worksheet();

    my $parser   = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse($spreadsheet);

    if ( defined $workbook ) {
        for my $worksheet ( $workbook->worksheets() ) {
            my ( $row_min, $row_max ) = $worksheet->row_range();
            my ( $col_min, $col_max ) = $worksheet->col_range();

            for my $row ( $row_min .. $row_max ) {
                for my $col ( $col_min .. $col_max ) {
                    my $cell = $worksheet->get_cell( $row, $col );
                    if ( $cell ) {
                        my $value = $cell->value();
                        if($value =~ /\d\.\d/) {
                            $new_worksheet->write($row, $col, $value, $date_format);
                        }
                        else {
                            $new_worksheet->write($row, $col, $value);
                        }
                    }
                    else {
                        $new_worksheet->write($row, $col, '');
                    }
                }
            }
        }
    }
    else {
        my $excel = Spreadsheet::XLSX->new($spreadsheet);

        foreach my $sheet (@{$excel -> {Worksheet}}) {
            $sheet -> {MaxRow} ||= $sheet -> {MinRow};

            foreach my $row ($sheet -> {MinRow} .. $sheet -> {MaxRow}) {
                $sheet -> {MaxCol} ||= $sheet -> {MinCol};

                foreach my $col ($sheet -> {MinCol} ..  $sheet -> {MaxCol}) {
                    my $cell = $sheet -> {Cells} [$row] [$col];
                    my $value = $cell -> {Val};
                    if ($cell) {
                        if($value && $value =~ /\d\.\d/) {
                            $new_worksheet->write($row, $col, $value, $date_format);
                        }
                        else {
                            $new_worksheet->write($row, $col, $value);
                        }
                    }
                    else {
                        $new_worksheet->write($row, $col, '');
                    }
                }
            }
        }
    }
    $swx->close();
    move($new_filename,$spreadsheet);
}

# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

MyDocumentation - Perl extension for blah blah blah

=head1 SYNOPSIS

  use MyDocumentation;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for MyDocumentation, created by h2xs. It looks like the
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

A. U. Thor, E<lt>a.u.thor@a.galaxy.far.far.awayE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by A. U. Thor

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.16.3 or,
at your option, any later version of Perl 5 you may have available.



<MALL> <REASON>, <DATE>

./import/users.pl -w 0 -m <MALL_ID> -s <SOURCE_ID> -f import/registration_lists/<MALL>{_kidsclub}_tid<TID>.xls {-k}

--column email=#
--column firstname=#
--column lastname=#
--column name=#
--column address=#
--column address2=#
--column city=#
--column state=#
--column postal_code=#
--column country=#
--column phone=#
--column birth_date=#
--column gender=#
--column ebulletins=#
--column kid_name=#
--column kid_first_name=#
--column kid_last_name=#
--column kid_dob=#
--column kid_birth_month=#
--column kid_birth_year=#

-d

(and then shift-J to put them all on the call line)

=cut
