package HTTP::AnyUA::Util::NetCurl;

use strict;
use warnings;

use Net::Curl::Easy ();

use constant _DEFAULT_TIMEOUT => 60;    # from HTTP::Tiny’s documentation

sub set_up {
    my ($ua, $method, $url, $args) = @_;

    if ($method eq 'GET') {
        $ua->setopt(Net::Curl::Easy::CURLOPT_HTTPGET(), 1);
    }
    elsif ($method eq 'HEAD') {
        $ua->setopt(Net::Curl::Easy::CURLOPT_NOBODY(), 1);
    }

    $ua->setopt( Net::Curl::Easy::CURLOPT_TIMEOUT(), $args->{'timeout'} || _DEFAULT_TIMEOUT() );

    if (my $content = $args->{content}) {
        if (ref($content) eq 'CODE') {
            my $content_length;
            for my $header (keys %{$args->{headers} || {}}) {
                if (lc($header) eq 'content-length') {
                    $content_length = $args->{headers}{$header};
                    last;
                }
            }

            if ($content_length) {
                my $chunk;
                $ua->setopt(Net::Curl::Easy::CURLOPT_READFUNCTION(), sub {
                    my $ua      = shift;
                    my $maxlen  = shift;

                    if (!$chunk) {
                        $chunk = $content->();
                        return 0 if !$chunk;
                    }

                    my $part = substr($chunk, 0, $maxlen, '');
                    return \$part;
                });
                $ua->setopt(Net::Curl::Easy::CURLOPT_POSTFIELDSIZE(), $content_length);
            }
            else {
                # if we don't know the length we have to just read it all in
                $content = HTTP::AnyUA::Util::coderef_content_to_string($content);
            }
        }
        if (ref($content) ne 'CODE') {
            $ua->setopt(Net::Curl::Easy::CURLOPT_POSTFIELDS(), $content);
            $ua->setopt(Net::Curl::Easy::CURLOPT_POSTFIELDSIZE(), length $content);
        }
    }

    $ua->setopt(Net::Curl::Easy::CURLOPT_URL(), $url);
    $ua->setopt(Net::Curl::Easy::CURLOPT_CUSTOMREQUEST(), $method);

    # munge headers
    my @headers;
    for my $header (keys %{$args->{headers} || {}}) {
        my $value  = $args->{headers}{$header};
        my @values = ref($value) eq 'ARRAY' ? @$value : $value;
        for my $v (@values) {
            push @headers, "${header}: $v";
        }
    }
    $ua->setopt(Net::Curl::Easy::CURLOPT_HTTPHEADER(), \@headers) if @headers;

    my @hdrdata;

    $ua->setopt(Net::Curl::Easy::CURLOPT_HEADERFUNCTION(), sub {
        my $ua      = shift;
        my $data    = shift;
        my $size    = length $data;

        my %headers = _parse_header($data);

        if ($headers{Status}) {
            push @hdrdata, {};
        }

        my $resp_headers = $hdrdata[-1];

        for my $key (keys %headers) {
            if (!$resp_headers->{$key}) {
                $resp_headers->{$key} =  $headers{$key};
            }
            else {
                if (ref($resp_headers->{$key}) ne 'ARRAY') {
                    $resp_headers->{$key} = [$resp_headers->{$key}];
                }
                push @{$resp_headers->{$key}}, $headers{$key};
            }
        }

        return $size;
    });

    my $resp_body = '';

    my $data_cb = $args->{data_callback};

    $ua->setopt(Net::Curl::Easy::CURLOPT_WRITEFUNCTION(), sub {
        my $ua      = shift;
        my $data    = shift;

        if ($data_cb) {
            my $resp = munge_response($ua, undef, undef, [@hdrdata], $data_cb);
            $data_cb->($data, $resp);
        }
        else {
            $resp_body .= $data;
        }

        return length $data;
    });

    return ( \@hdrdata, \$resp_body );
}

sub munge_response {
    my $ua    = shift;
    my $error   = shift;
    my $body    = shift;
    my $hdrdata = shift;
    my $data_cb = shift;

    my %headers = %{pop @$hdrdata || {}};

    my $code    = delete $headers{Status} || $ua->getinfo(Net::Curl::Easy::CURLINFO_RESPONSE_CODE()) || 599;
    my $reason  = delete $headers{Reason};
    my $url     = $ua->getinfo(Net::Curl::Easy::CURLINFO_EFFECTIVE_URL());

    my $resp = {
        success => 200 <= $code && $code <= 299,
        url     => $url,
        status  => $code,
        reason  => $reason,
        headers => \%headers,
    };

    my $version = delete $headers{HTTPVersion} || _http_version($ua->getinfo(Net::Curl::Easy::CURLINFO_HTTP_VERSION()));
    $resp->{protocol} = "HTTP/$version" if $version;

    # We have the headers for the redirect chain in $hdrdata, but we don't have the contents, and we
    # would also need to reconstruct the URLs.

    if ($error) {
        my $err = $ua->strerror($error);
        return HTTP::AnyUA::Util::internal_exception($err, $resp);
    }

    $resp->{content} = $body if $body && !$data_cb;

    return $resp;
}

# get the HTTP version according to the user agent object
sub _http_version {
    my $version = shift;
    return $version == Net::Curl::Easy::CURL_HTTP_VERSION_1_0() ? '1.0' :
           $version == Net::Curl::Easy::CURL_HTTP_VERSION_1_1() ? '1.1' :
           $version == Net::Curl::Easy::CURL_HTTP_VERSION_2_0() ? '2.0' : '';
}

# parse a header line (or status line) and return as key-value pairs
sub _parse_header {
    my $data = shift;

    $data =~ s/[\x0A\x0D]*$//;

    if ($data =~ m!^HTTP/([0-9.]+) [\x09\x20]+ (\d{3}) [\x09\x20]+ ([^\x0A\x0D]*)!x) {
        return (
            HTTPVersion => $1,
            Status      => $2,
            Reason      => $3,
        );
    }

    my ($key, $val) = split(/:\s*/, $data, 2);
    return if !$key;
    return (lc($key) => $val);
}

1;
