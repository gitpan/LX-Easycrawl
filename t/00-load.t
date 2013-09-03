#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'LX::Easycrawl' ) || print "Bail out!\n";
}

diag( "Testing LX::Easycrawl $LX::Easycrawl::VERSION, Perl $], $^X" );
