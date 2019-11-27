package HTTP::AnyUA::Backend::Net::Curl::Promiser;

use strict;
use warnings;

use parent qw( HTTP::AnyUA::Backend );

use lib '/Users/felipe/code/p5-Promise-ES6/lib';

use Future ();
use Net::Curl::Easy ();
use Promise::ES6::Future ();

use HTTP::AnyUA::Util::NetCurl ();

use constant response_is_future => 1;

sub request {
    my ($self, $method, $url, $args_hr) = @_;

    my $promiser = $self->ua();

    my $easy = Net::Curl::Easy->new();

    my ($hdrs_ar, $body_sr) = HTTP::AnyUA::Util::NetCurl::set_up($easy, $method, $url, $args_hr);

    return Promise::ES6::Future::to_future(
        $promiser->add_handle($easy)->then( sub {
            my ($easy) = @_;

            return HTTP::AnyUA::Util::NetCurl::munge_response(
                $easy,
                undef,
                $$body_sr,
                $hdrs_ar,
                $args_hr->{'data_callback'},
            );
        } ),
    );
}

1;
