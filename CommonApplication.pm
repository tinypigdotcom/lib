package CommonApplication;

use 5.016003;
use strict;
use warnings;
use JSON;
use Data::Dumper;
use SchemaManager;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my $json = JSON->new->allow_nonref;
    my $pm = SchemaManager->new();
    my $self = bless {
        json => $json,
        pm   => $pm,
    }, $class;
    my $outfile = "c:\\output\\" . ref($self);
    $self->{outfile} = $outfile;
    return $self;
}

sub run {
    die; # you have to implement this!
}

sub dumper {
    my $self = shift;
    return Dumper(@_);
}

sub redirect_output {
    my $self = shift;
    my $outfile_txt = "$self->{outfile}.txt";
    my $errfile_txt = "$self->{outfile}_err.txt";

    close STDOUT;
    open STDOUT, ">$outfile_txt" or die qq{Can't open file "$outfile_txt": $!};

    close STDERR;
    open STDERR, ">$errfile_txt" or die qq{Can't open file "$errfile_txt": $!};
}

sub freeze {
    my ($self, $input) = @_;
    my $json = $self->{json};
    my $outfile = "$self->{outfile}.json";

    open(my $fh, ">$outfile") or die qq{Can't open file "$outfile": $!};
    print $fh $json->encode($input);
    close $fh;
}

sub thaw {
    my ($self) = @_;
    my $json = $self->{json};
    my $outfile = "$self->{outfile}.json";

    return if ( ! -r $outfile );

    open(my $fh, "<$outfile") or die qq{Can't open file "$outfile": $!};
    local $/ = undef;
    my $content = <$fh>;
    my $decoded_json = $json->decode($content);
    close $fh;
    return $decoded_json;
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
