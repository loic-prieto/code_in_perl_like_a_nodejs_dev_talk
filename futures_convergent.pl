#!/usr/bin/env perl

use AnyEvent::HTTP;
use AnyEvent;
use Future;
use Data::Dumper;

sub return_number_async {
	my $param = shift;
	my $f = Future->new;
	fork_call { sleep 1; return $param; } sub {
		my $result = shift;
		$f->done($result);
	};

	return $f;
}

my $exit_cv = AnyEvent::condvar;

print "Asynching number in parallel\n";
my $combined_lengths = Future->wait_all(
  return_number_async(1),
  return_number_async(2),
  return_number_async(3),
  return_number_async(4)
);

print "I'm waiting for the return of the combined future...\n";
my @result = $combined_lengths->get;
print "Results: ".Dumper(@results);

$exit_cv->recv;
print "I've received the exit signal, end of the program\n";
