package SchemaManager;

use 5.016003;
use strict;
use warnings;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my $self = bless {
        source_dir => "/Volumes/WORKY/",
    }, $class;
    return $self;
}

sub get_schema {
    my ($self,$which_schema) = @_;
    open I, "<$self->{source_dir}$which_schema.txt" or die "Can't find file for $which_schema.";
    my $return_schema = <I>;
    close I;
    $return_schema =~ s/\s//gsm;
    return $return_schema
}


# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

MyTemplate - Perl extension for blah blah blah

=head1 SYNOPSIS

  use MyTemplate;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for MyTemplate, created by h2xs. It looks like the
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


=cut
