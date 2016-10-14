#!/usr/bin/env perl

use Promises qw(deferred); 
use AnyEvent::HTTP;

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

print "Before calling something async\n";
do_something_async()
	->then(sub{
		my $result = shift;
		print "I've received an OK response from google\n";
	})
	->catch(sub{
		my $error = shift;
		print "I've received an error from google: $error\n";
	});
print "After calling something async\n";
