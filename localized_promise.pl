#!/usr/bin/env perl

use Promises qw(deferred collect);
use AnyEvent;
use AnyEvent::Util qw(fork_call);
use Data::Dumper;

sub do_something_async {
	my $param = shift;
	my $d = deferred;
	fork_call { sleep 1; return $param; } sub {
		my $result = shift;
		$d->resolve($result);
	};

	return $d->promise;
}

sub do_something_async_locally {
	my $exit_cv = AnyEvent::condvar;

	collect(
		do_something_async(1),
		do_something_async(2),
		do_something_async(3),
		do_something_async(4),
	)
	->then(sub{
		my $sum = 0;
		foreach my $result (@_) {
			$sum += $result->[0];
		}
		$exit_cv->send($sum);
	});

	return $exit_cv->recv;
}

print "I'm going to call synchronously async code.\n";

my $result = do_something_async_locally;
print "I've obtained the result $result without knowing that the function has done async stuff inside.\n";
