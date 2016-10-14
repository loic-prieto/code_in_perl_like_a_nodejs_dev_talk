#!/usr/bin/env perl

use Promises qw(deferred); 
use AnyEvent::HTTP;
use AnyEvent;

sub do_something_async {
	my $d = deferred;
	
	http_get 'http://www.google.com' => sub {
		my ($body,$headers) = @_;
		sleep 5;

		$headers->{Status} == 200?
			$d->resolve($body) :
			$d->reject('Received http error '.$headers->{Status});
	};

	return $d->promise;
}

my $exit_cv = AnyEvent::condvar;

print "Before calling something async\n";
do_something_async()
	->then(sub{
		my $result = shift;
		print "I've received an OK response from google\n";
	})
	->catch(sub{
		my $error = shift;
		print "I've received an error from google: $error\n";
	})
	->finally(sub{
		$exit_cv->send;
	});
print "After calling something async\n";

print "I'm waiting for the return of the async function...\n";
$exit_cv->recv;
print "I've received the exit signal, end of the program\n";
