package HTTP::AnyUA::Backend::Net::Curl::Easy;
# ABSTRACT: A unified programming interface for Net::Curl::Easy

=head1 DESCRIPTION

This module adds support for the HTTP client L<Net::Curl::Easy> to be used with the unified
programming interface provided by L<HTTP::AnyUA>.

=head1 CAVEATS

=for :list
* The C<redirects> field in the response is currently unsupported.

=head1 SEE ALSO

=for :list
* L<HTTP::AnyUA::Backend>

=cut

use warnings;
use strict;

our $VERSION = '9999.999'; # VERSION

use parent 'HTTP::AnyUA::Backend';

use HTTP::AnyUA::Util;
use Scalar::Util;

use HTTP::AnyUA::Util::NetCurl;

sub request {
    my $self = shift;
    my ($method, $url, $args) = @_;

    my $ua = $self->ua;

    # reset
    $ua->setopt(Net::Curl::Easy::CURLOPT_HTTPGET(), 0);
    $ua->setopt(Net::Curl::Easy::CURLOPT_NOBODY(), 0);
    $ua->setopt(Net::Curl::Easy::CURLOPT_READFUNCTION(), undef);
    $ua->setopt(Net::Curl::Easy::CURLOPT_POSTFIELDS(), undef);
    $ua->setopt(Net::Curl::Easy::CURLOPT_POSTFIELDSIZE(), 0);

    my ( $hdrdata_ar, $body_sr ) = HTTP::AnyUA::Util::NetCurl::set_up( $ua, $method, $url, $args );

    my $ret;

    eval { $ua->perform(); 1 } or $ret = $@;

    return HTTP::AnyUA::Util::NetCurl::munge_response( $ua, $ret, $$body_sr, $hdrdata_ar, $args->{data_callback});
}

1;
