use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.15

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/HTTP/AnyUA.pm',
    'lib/HTTP/AnyUA/Backend.pm',
    'lib/HTTP/AnyUA/Backend/AnyEvent/HTTP.pm',
    'lib/HTTP/AnyUA/Backend/Furl.pm',
    'lib/HTTP/AnyUA/Backend/HTTP/AnyUA.pm',
    'lib/HTTP/AnyUA/Backend/HTTP/Tiny.pm',
    'lib/HTTP/AnyUA/Backend/LWP/UserAgent.pm',
    'lib/HTTP/AnyUA/Backend/Mojo/UserAgent.pm',
    'lib/HTTP/AnyUA/Backend/Net/Curl/Easy.pm',
    'lib/HTTP/AnyUA/Middleware.pm',
    'lib/HTTP/AnyUA/Middleware/ContentLength.pm',
    'lib/HTTP/AnyUA/Middleware/RequestHeaders.pm',
    'lib/HTTP/AnyUA/Middleware/Runtime.pm',
    'lib/HTTP/AnyUA/Util.pm',
    't/00-compile.t',
    't/00-report-prereqs.dd',
    't/00-report-prereqs.t',
    't/01-new.t',
    't/02-shortcuts.t',
    't/03-post_form.t',
    't/04-internal-exception.t',
    't/10-get.t',
    't/11-post.t',
    't/12-put.t',
    't/13-head.t',
    't/14-delete.t',
    't/15-custom-method.t',
    't/20-data_callback.t',
    't/21-basic-auth.t',
    't/22-redirects.t',
    't/23-content-coderef.t',
    't/40-middleware-content-length.t',
    't/40-middleware-request-headers.t',
    't/40-middleware-runtime.t',
    't/50-future-subclass.t',
    't/app.psgi',
    't/lib/AnyEvent/Future.pm',
    't/lib/Future/Mojo.pm',
    't/lib/MockBackend.pm',
    't/lib/Server.pm',
    't/lib/Util.pm',
    'xt/author/clean-namespaces.t',
    'xt/author/critic.t',
    'xt/author/eol.t',
    'xt/author/minimum-version.t',
    'xt/author/no-tabs.t',
    'xt/author/pod-coverage.t',
    'xt/author/pod-no404s.t',
    'xt/author/pod-syntax.t',
    'xt/author/portability.t',
    'xt/release/cpan-changes.t',
    'xt/release/distmeta.t'
);

notabs_ok($_) foreach @files;
done_testing;
