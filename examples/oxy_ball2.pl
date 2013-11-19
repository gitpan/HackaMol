#!/usr/bin/env perl
use Modern::Perl;
use HackaMol;
use Math::Vector::Real;
use Math::Vector::Real::Random;
use Math::Trig;
use Time::HiRes qw(time);
use MCE::Map;

my $t1 = time;
# let's create a 20 Angstrom ball of oxygen atoms from density of water
my $radius = 280;
my $natoms = int( 0.0334 * ( $radius**3 ) * 4 * pi / 3 );

my @sphatoms =
  mce_map { HackaMol::Atom->new( Z => 8, charges => [0], coords => [$_] ) }
  mce_map { Math::Vector::Real->random_in_sphere( 3, $radius ) } 1 .. $natoms;

my $t2 = time;
printf ("time    %10.2f\n", $t2-$t1);
my $i = 0;
#for (my $i=0 ; $i < $#sphatoms; $i++){
  my $ati = $sphatoms[$i];
  my @d = mce_map { $ati->distance( $_ )  } @sphatoms[$i+1 .. $#sphatoms];
  #push @dist3, @d;
#}

my $t3 = time;
printf ("time mce %10.2f\n", $t3-$t2);

#for (my $i=0 ; $i < $#sphatoms; $i++){
  $ati = $sphatoms[$i];
  my @dd = map { $ati->distance( $_ )  } @sphatoms[$i+1 .. $#sphatoms];
  #push @dist3, @d;
#}

my $t4 = time;
printf ("time mce %10.2f\n", $t4-$t3);
