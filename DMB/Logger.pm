#example config file ~/.logger
## DEBUG -> INFO -> WARN
#[default]
#log_level = INFO
#
#[logger_test]
#log_level = DEBUG
#no_print = 0

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

my $logger;
sub get_logger {
    my ($class, %args) = @_;
    return $logger if $logger;
    $logger = {
        level => $args{level} // $LOG_LEVEL,
        app => $args{app} // $APP,
        dir => $args{dir} // $LOG_DIR,
    };
    $logger->{_levels} = {DEBUG => 1, INFO => 2, WARN => 3};
    $logger->{_log} = "$logger->{dir}$logger->{app}." . sprintf("%s-%d.%06d", hostname(), $$, (gettimeofday)[1]) . ".log";
    bless $logger, $class;
    return $logger;
}

sub log {
    my ($self, $level, $message) = @_;
    my ($levels, $log, $app) = @$self{qw(_levels _log app)};
    my $config = Config::Tiny->read("$ENV{HOME}/.logger");
    my $log_level = $config->{$app}->{log_level} // $config->{default}->{log_level} // $self->{level};
    return if !(exists $levels->{$level} && $levels->{$level} >= $levels->{$log_level});
    $message = ddc($message) if ref $message;
    my $line = "[" . localtime() . "] [$level] $message\n";
    print STDERR $line if !$config->{$app}->{no_print};
    open(my $ofh, ">>", $log) or die "Can't open $log: $!";
    print $ofh $line;
    close $ofh;
}

1;

