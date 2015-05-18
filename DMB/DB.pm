package DMB::DB;

use 5.016;
use strict;
use warnings;

require Exporter;
use IO::File;
use Data::Dumper;
use base 'DBI';

our $VERSION = '0.0.1';

sub connect {
    my $class = shift;

    my $password = file_contents_flat("$ENV{HOME}/.dbradford");

    my @options = ("DBI:mysql:database=menagerie;host=localhost",
                   "dbradford", $password,
                   {'RaiseError' => 1});

    return $class->SUPER::connect(@options);
}

sub greet {
    my ( $self, $name ) = @_;
    print $self->{greeting} . " $name!\n";
}

sub file_contents {
    use IO::File;
    my $filename = shift;

    my $ifh = IO::File->new($filename, '<');
    die if (!defined $ifh);

    $ifh->binmode();

    my $contents = do { local $/; <$ifh> };

    $ifh->close;

    return $contents;
}

sub file_contents_flat {
    my $contents = file_contents(shift);
    $contents =~ s/[\x0a\x0d]//g;
    return $contents;
}

package DMB::DB::db;
use base 'DBI::db';
# do()
# prepare()
package DMB::DB::st;
use base 'DBI::st';
# execute()

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


