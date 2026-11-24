use strict;
use warnings;

use Test::More;

use Games::Dice::Advanced;

# A tiny repeatable generator: the same seed always gives the same sequence.
sub generator {
    my $state = shift;
    return sub {
        my $n = shift;
        $state = ($state * 1103515245 + 12345) % 2147483648;
        return ($state / 2147483648) * $n;
    };
}

my @calls;
my $die = Games::Dice::Advanced->new('d6', { rand => sub { push @calls, $_[0]; 0 } });
is($die->roll(), 1, 'rand returning 0 gives the lowest face');
is_deeply(\@calls, [6], 'rand is called with the number of faces');

$die = Games::Dice::Advanced->new('d6', { rand => sub { $_[0] - 0.001 } });
is($die->roll(), 6, 'rand returning just under N gives the highest face');

@calls = ();
$die = Games::Dice::Advanced->new('3d4', { rand => sub { push @calls, $_[0]; 0 } });
is($die->roll(), 3, 'NdM rolls N dice');
is_deeply(\@calls, [4, 4, 4], 'rand is used once per die');

$die = Games::Dice::Advanced->new('d6', 3, { rand => sub { 0 } });
is($die->roll(), 3, 'options can follow a multiplier');
$die = Games::Dice::Advanced->new(3, 'd6', { rand => sub { 0 } });
is($die->roll(), 3, 'options can follow arguments in either order');

my @first  = map { Games::Dice::Advanced->new('2d6', { rand => generator(7) })->roll() } 1 .. 5;
my @second = map { Games::Dice::Advanced->new('2d6', { rand => generator(7) })->roll() } 1 .. 5;
is_deeply(\@first, \@second, 'the same generator seed gives the same rolls');

my $source = generator(42);
my @sequence = map { Games::Dice::Advanced->roll('2d6', 'd4', { rand => $source }) } 1 .. 20;
$source = generator(42);
is_deeply(
    [ map { Games::Dice::Advanced->roll('2d6', 'd4', { rand => $source }) } 1 .. 20 ],
    \@sequence,
    'class method roll() passes the options to each die'
);

my $own = Games::Dice::Advanced->new('d6', { rand => sub { 0 } });
is(Games::Dice::Advanced->roll($own, 'd6', { rand => sub { $_[0] - 0.001 } }), 1 + 6,
    'a die object keeps the rand it was created with');

is(Games::Dice::Advanced->new(5, { rand => sub { die "not called" } })->roll(), 5,
    'constants never call rand');
is(Games::Dice::Advanced->new(sub { 9 }, { rand => sub { die "not called" } })->roll(), 9,
    'SUBREF dice never call rand');

srand(11);
my @global_first = map { Games::Dice::Advanced->roll('3d6') } 1 .. 10;
srand(11);
my @global_second = map { Games::Dice::Advanced->roll('3d6') } 1 .. 10;
is_deeply(\@global_first, \@global_second, 'without the option the global rand is used, so srand() still works');

eval { Games::Dice::Advanced->new('d6', { rand => 'rand' }) };
like($@, qr/rand option must be a subroutine/, 'a non-code rand is rejected');

eval { Games::Dice::Advanced->new('d6', { raned => sub { 0 } }) };
like($@, qr/isn't valid|called incorrectly|Bad arguments/, 'a hashref with unknown keys is not taken as options');

done_testing();
