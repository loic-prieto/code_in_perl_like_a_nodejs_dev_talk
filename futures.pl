#!/usr/bin/env perl

use AnyEvent::HTTP;
use AnyEvent;
use Future;

sub do_something_async {
  my $future = Future->new;
	
	http_get 'http://www.google.com' => sub {
		my ($body,$headers) = @_;
		sleep 5;

		$headers->{Status} == 200?
			$future->done($body) :
			$future->fail('Received http error '.$headers->{Status});
	};

	return $future;
}

my $exit_cv = AnyEvent::condvar;

print "Before calling something async\n";
my $combined_future = do_something_async()
	->then(sub{
		my $result = shift;
		print "I've received an OK response from google\n";
    $exit_cv->send;
    return Future->done;
	})
	->else(sub{
		my $error = shift;
    $exit_cv->send;
		print "I've received an error from google: $error\n";
    return Future->done;
	});
print "After calling something async\n";

print "I'm waiting for the return of the async function...\n";
$exit_cv->recv;
print "I've received the exit signal, end of the program\n";
