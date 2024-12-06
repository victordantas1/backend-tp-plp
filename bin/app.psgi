#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib/routes";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use sgl_perl;

sgl_perl->to_app;

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use sgl_perl;
use Plack::Builder;

builder {
    enable 'Deflater';
    sgl_perl->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to mount several applications on different path

use sgl_perl;
use sgl_perl_admin;

use Plack::Builder;

builder {
    mount '/'      => sgl_perl->to_app;
    mount '/admin'      => sgl_perl_admin->to_app;
}

=end comment

=cut

