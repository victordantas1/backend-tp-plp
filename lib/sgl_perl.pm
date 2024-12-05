package sgl_perl;
use Dancer2;

our $VERSION = '0.1';

get '/' => sub {
    template 'index' => { 'title' => 'sgl_perl' };
};

true;
