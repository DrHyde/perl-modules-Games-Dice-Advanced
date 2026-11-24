use strict;
use warnings;

use Test::More;

use Games::Dice::Advanced;

# A rand replacement that produces the given faces, in order, then repeats.
sub scripted {
    my @faces = @_;
    my $i = 0;
    return sub { return $faces[ $i++ % @faces ] - 0.5 };
}

sub roll_with {
    my($recipe, @faces) = @_;
    return Games::Dice::Advanced->new($recipe, { rand => scripted(@faces) })->roll();
}

# 4d6 showing 1, 6, 3, 5
is(roll_with('4d6kh3', 1, 6, 3, 5), 6 + 5 + 3, 'kh keeps the highest dice');
is(roll_with('4d6kl2', 1, 6, 3, 5), 1 + 3,     'kl keeps the lowest dice');
is(roll_with('4d6dh1', 1, 6, 3, 5), 1 + 3 + 5, 'dh drops the highest dice');
is(roll_with('4d6dl1', 1, 6, 3, 5), 6 + 5 + 3, 'dl drops the lowest dice');
is(roll_with('4d6dl2', 1, 6, 3, 5), 6 + 5,     'dl can drop more than one');
is(roll_with('4d6kh4', 1, 6, 3, 5), 1 + 6 + 3 + 5, 'keeping every die changes nothing');
is(roll_with('4d6kh1', 1, 6, 3, 5), 6, 'keep a single die');

is(roll_with('4d6kh3', 2, 2, 2, 2), 6, 'equal dice are fine');

# advantage and disadvantage
is(roll_with('2d20kh1', 7, 15), 15, 'advantage');
is(roll_with('2d20kl1', 7, 15), 7,  'disadvantage');

# the multiplier applies to the kept dice
my $die = Games::Dice::Advanced->new('4d6kh3', 2, { rand => scripted(1, 6, 3, 5) });
is($die->roll(), 2 * 14, 'multiplier applies to the kept total');

# class method with several parts
is(Games::Dice::Advanced->roll('4d6kh3', 'd4', 2, { rand => scripted(1, 6, 3, 5) }), 14 + 1 + 2,
    'works in a recipe, so a modifier is just another constant');

# the result is really random
my $source = do { my $s = 99; sub { $s = ($s * 1103515245 + 12345) % 2147483648; ($s / 2147483648) * $_[0] } };
my $best = Games::Dice::Advanced->new('4d6kh3', { rand => $source });
my @rolls = map { $best->roll() } 1 .. 20000;
my $mean = 0; $mean += $_ for @rolls; $mean /= @rolls;
ok($mean > 12.0 && $mean < 12.5, "mean of 4d6kh3 is near 12.24 (got $mean)");
ok(!grep({ $_ < 3 || $_ > 18 } @rolls), 'always between 3 and 18');

# errors
for my $bad ('4d6kh0', '4d6kh5', '4d6dl0', '4d6dl4', '4d6dl5', '1d6dl1') {
    eval { Games::Dice::Advanced->new($bad) };
    like($@, qr/isn't valid: you can only keep or drop between 1 and \d+ dice/, "$bad is rejected");
}
for my $bad ('4d6kh', '4d6xx3', '4d6kh3x', '4d6 kh3') {
    eval { Games::Dice::Advanced->new($bad) };
    ok($@, "$bad is rejected");
}

done_testing();
