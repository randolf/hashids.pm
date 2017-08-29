#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Test::Exception;
use Hashids;

plan tests => 1;

subtest 'collision with long salt' => sub {
    plan tests => 2;

    my $alphabet      = join '' => ( 'A' .. 'Z', 0 .. 9 );
    my $minHashLength = 20;
    my $longSecret    = '5b7130c6-8482-4800-a4d1-5a662e0a6a4f';
    my @salts         = qw(salt1 salt2);

    diag "alphabet length: ", length $alphabet;
    diag "salt length: ", 5 + length $longSecret;

    subtest 'secret at beginning of salt' => sub {
        plan tests => 6;

        for my $k (@salts) {
            my %encodes;
            my $h = Hashids->new(
                alphabet      => $alphabet,
                minHashLength => $minHashLength,
                salt          => join( '' => $longSecret, $k )
            );

            $encodes{ $h->encode($_) }++ for 1 .. 3;

        TODO: {
                local $TODO = 'needs fixing, see hashids.js issue #37';
                cmp_ok( $encodes{$_}, '==', 1, "No duplicate for Hashid $_" )
                    for keys %encodes;
            }
        }
    };

    subtest 'secret at end of salt' => sub {
        plan tests => 6;

        for my $k (@salts) {
            my %encodes;
            my $h = Hashids->new(
                alphabet      => $alphabet,
                minHashLength => $minHashLength,
                salt          => join( '' => $k, $longSecret )
            );

            $encodes{ $h->encode($_) }++ for 1 .. 3;

            cmp_ok( $encodes{$_}, '==', 1, "No duplicate for Hashid $_" )
                for keys %encodes;
        }
    };
};
