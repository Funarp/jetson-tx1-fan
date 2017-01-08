#!/usr/bin/env perl

use strict;
use POSIX 'setsid';

# Shall we allow the fan to stop 
use constant fan_can_stop => 1;

# minimal fan pwm value
use constant min_pwm => 65;

# Stop or minimize the fan if temp is below than thremal_lower_bound
use constant thremal_lower_bound => 35000;

# maxmize the fan speed if temp exceeds
use constant thremal_upper_bound => 50000;

# Just a constant
use constant thremal_gap => thremal_upper_bound - thremal_lower_bound;

sub become_daemon {
	die "Can't fork" unless defined (my $child = fork);
	exit 0 if $child;
	setsid() or die "setsid: $!";
	open( STDIN, "</dev/null" );
	open( STDOUT, ">/dev/null" );
	open( STDERR, ">&STDOUT" );
	chdir '/';
	umask 0;
	$ENV{PATH} = '/bin:/sbin:/usr/bin:/usr/sbin';
}

sub get_thremal {
	open FILE, '/sys/class/thermal/thermal_zone0/temp' or return 0;
	my $content = do { local $/=undef; <FILE>; };
	close FILE;
	return $content;
}

sub set_fan_pwm {
	my $pwm = int(shift);
	$pwm = 0 if (!(defined $pwm) || ($pwm < 0 || $pwm > 255));
	open FILE, '>', '/sys/kernel/debug/tegra_fan/target_pwm' or return;
	print FILE $pwm;
	close FILE;
}

become_daemon;

while (1) {
	my $thremal = get_thremal;
	$thremal =~ s/^\s+|\s+$//g;
	my $pwm = fan_can_stop ? 0 : min_pwm;
	$pwm = 255 if $thremal >= thremal_upper_bound;
	if ($thremal >= thremal_lower_bound && $thremal < thremal_upper_bound) {
		$pwm = (255.0 - min_pwm)/thremal_gap*($thremal - thremal_lower_bound)+min_pwm;
	}
	print "$thremal $pwm\n";
	set_fan_pwm $pwm;
	sleep 1;
}
