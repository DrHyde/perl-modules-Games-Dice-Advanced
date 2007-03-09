use strict; use warnings;
my($loaded, $test) = (0, 0);

BEGIN { $| = 1; print "1..13\n"; }
END { print "not ok 1\n" unless $loaded; }

use Data::Dumper;

use Games::Dice::Advanced;
$loaded++;

print 'ok '.(++$test)." module loaded\n";

my $die1 = Games::Dice::Advanced->new(3);
my $die2 = Games::Dice::Advanced->new(2);

print 'not ' if(grep { $_ != 3 } map { Games::Dice::Advanced->roll(3) } (1..5));
print 'ok '.(++$test)." class method: can roll constants\n";

print 'not ' if(grep { $_ != 5 } map { Games::Dice::Advanced->roll(3,2) } (1..5));
print 'ok '.(++$test)." class method: can add\n";

print 'not ' if(grep { $_ != 5 } map { Games::Dice::Advanced->roll($die1, $die2) } (1..5));
print 'ok '.(++$test)." class method: can roll dice\n";

print 'not ' if(grep { $_ != 3 } map { $die1->roll() } (1..5));
print 'ok '.(++$test)." object method: can roll constants\n";

$die1 = Games::Dice::Advanced->new('d6');
my @data = map { $die1->roll() } (1..10000);
my @distrib; $distrib[$_]++ foreach (@data);

print 'not ' if(grep { $_ < 1 || $_ > 6 || $_ != int($_) } @data);
print 'ok '.(++$test)." object method: dN returns values in the right range\n";

print 'not ' if(grep { $_ < 1500 || $_ > 1850 } @distrib[1..6]);
print 'ok '.(++$test)." distribution of dN looks sane\n";

$die1 = Games::Dice::Advanced->new('d6', 2);
@data = map { $die1->roll() } (1..10000);
@distrib = (); $distrib[$_]++ foreach (@data);

print 'not ' if(grep { $_ < 2 || $_ > 12 || $_/2 != int($_/2) } @data);
print 'ok '.(++$test)." M * dN returns values in the right range\n";

print 'not ' if(grep { $_ < 1500 || $_ > 1850 } @distrib[2,4,6,8,10,12]);
print 'ok '.(++$test)." distribution of M * dN looks sane\n";

$die1 = Games::Dice::Advanced->new('2d6');
@data = map { $die1->roll() } (1..100000);
@distrib = (); $distrib[$_]++ foreach (@data);

print 'not ' if(grep { $_ < 2 || $_ > 12 } @data);
print 'ok '.(++$test)." MdN returns values in the right range\n";

print 'not ' unless(
    $distrib[2]  < 3000  && $distrib[2]  > 2500  &&
    $distrib[12] < 3000  && $distrib[12] > 2500  &&
    $distrib[3]  < 6000  && $distrib[3]  > 5000  &&
    $distrib[11] < 6000  && $distrib[11] > 5000  &&
    $distrib[4]  < 8600  && $distrib[4]  > 8100  &&
    $distrib[10] < 8600  && $distrib[10] > 8100  &&
    $distrib[5]  < 12000 && $distrib[5]  > 10000 &&
    $distrib[9]  < 12000 && $distrib[9]  > 10000 &&
    $distrib[6]  < 14500 && $distrib[6]  > 12000 &&
    $distrib[8]  < 14500 && $distrib[8]  > 12000 &&
    $distrib[7]  < 17500 && $distrib[7]  > 16000
);
print 'ok '.(++$test)." distribution of MdN looks sane\n";

$die1 = Games::Dice::Advanced->new(sub { int(1+rand(4)) ** 2 });
@data = map { $die1->roll() } (1..10000);
@distrib = (); $distrib[$_]++ foreach (@data);

print 'not ' if(grep { $_ != 1 && $_ != 4 && $_ != 9 && $_ != 16 } @data);
print 'ok '.(++$test)." sub{} returns correct values\n";

print 'not ' if(grep { $_ < 2000 || $_ > 3000 } @distrib[1,4,9,16]);
print 'ok '.(++$test)." distribution of sub{} looks sane\n";

