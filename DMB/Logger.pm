#example config file ~/.logger
## DEBUG -> INFO -> WARN
#[default]
#log_level = INFO
#
#[logger_test]
#log_level = DEBUG
#suppress_stderr = 0

package DMB::Logger;

use v5.38.2;
use strict;
use warnings;

require Exporter;

our $VERSION = '0.0.1';

my $LOG_LEVEL = 'DEBUG';
my $APP = (split('/', $0))[-1];
my $LOG_DIR = "$ENV{HOME}/logs/";

use Config::Tiny;
use Data::Dumper::Compact 'ddc';
use Sys::Hostname;
use Time::HiRes qw(gettimeofday);
my (%levels, $log);

sub new {
    my ($class, %args) = @_;
    my $self = {
        level => $args{level} // $LOG_LEVEL,
        app => $args{app} // $APP,
        dir => $args{dir} // $LOG_DIR,
    };
    $self->{_levels} = {DEBUG => 1, INFO => 2, WARN => 3};
    $self->{_log} = "$self->{dir}$self->{app}." . sprintf("%s-%d.%06d", hostname(), $$, (gettimeofday)[1]) . ".log";
    return bless $self, $class;
}

sub do_log {
    my ($self, $level, $message) = @_;
    my ($levels, $log, $app) = @$self{qw(_levels _log app)};
    my $config = Config::Tiny->read("$ENV{HOME}/.logger");
    my $log_level = $config->{$app}->{log_level} // $config->{default}->{log_level} // $self->{level};
    return if !(exists $levels->{$level} && $levels->{$level} >= $levels->{$log_level});
    $message = ddc($message) if ref $message;
    my $line = "[" . localtime() . "] [$level] $message\n";
    print STDERR $line if !$config->{$app}->{suppress_stderr};
    open(my $ofh, ">>", $log) or die "Can't open $log: $!";
    print $ofh $line;
    close $ofh;
}

1;

