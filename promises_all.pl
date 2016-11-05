#!/usr/bin/env perl

use Promises qw(deferred collect);
use AnyEvent;
use AnyEvent::Util qw(fork_call);

sub do_something_async {
	my $param = shift;
	my $d = deferred;
	fork_call { sleep 1; return $param; } sub {
		my $result = shift;
		$d->resolve($result);
	};

	return $d->promise;
}

my $exit_cv = AnyEvent::condvar;

print "Before calling 4 async functions\n";
collect(
	do_something_async(1),
	do_something_async(2),
	do_something_async(3),
	do_something_async(4)
)
->then(sub{
	foreach my $result (@_) {
		print "I've received a result: ".$result->[0]."\n";
	}
})
->catch(sub{
	my $error = shift;
	print "$error\n";
})
->finally(sub{
	$exit_cv->send;
});
print "After calling 4 async functions\n";

print "I'm waiting for the return of the async functions...\n";
$exit_cv->recv;
print "I've received the exit signal, end of the program\n";
