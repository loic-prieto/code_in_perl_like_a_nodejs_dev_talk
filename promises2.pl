#!/usr/bin/env perl

use Promises qw(deferred);
use AnyEvent;
use AnyEvent::Util qw(fork_call);

sub do_something_async {
	my $d = deferred;
	
	fork_call { sleep 1 } sub {
		rand() > 0.50?
			$d->resolve("All worked great") :
			$d->reject("YOLO");
	};

	return $d->promise;
}

my $exit_cv = AnyEvent::condvar;

print "Before calling something async\n";
do_something_async()
	->then(sub{
		my $result = shift;
		print "$result\n";
	})
	->catch(sub{
		my $error = shift;
		print "$error\n";
	})
	->finally(sub{
		$exit_cv->send;
	});
print "After calling something async\n";

print "I'm waiting for the return of the async function...\n";
$exit_cv->recv;
print "I've received the exit signal, end of the program\n";
