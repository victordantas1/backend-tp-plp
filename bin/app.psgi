#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib/routes";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use sgl_perl;

sgl_perl->to_app;

