package DMB::Taskman;

use 5.016003;
use strict;
use warnings;

use Data::Dumper;
use IO::File;
use WWW::Mechanize;
use utf8;

our $VERSION = '0.02';

sub new {
    my $class = shift;
    my $self = bless { }, $class;
    return $self;
}

sub get_pw {
    my ($self,$which_pw) = @_;
    open I, "</cygdrive/e/$which_pw.txt" or die "Can't find file for $which_pw.";
    my $return_pw = <I>;
    close I;
    $return_pw =~ s/\s//gsm;
    return $return_pw
}

sub tid {
    my ($self,$tid) = @_;

    my $taskman_password = $self->get_pw('taskman');

    my $mech = WWW::Mechanize->new( autocheck => 1 );

    if ( !$tid ) {
        die "No task ID";
    }

    $mech->get( "https://taskman.omniti.com/task/$tid" );

    $mech->submit_form(
        with_fields => {
            loginemail => 'dbradford@omniti.com',
            loginpassword => $taskman_password,
        },
    );

    my $content = $mech->content;
    utf8::encode($content);
    return $content;
}


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


=cut

