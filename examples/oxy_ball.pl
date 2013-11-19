#!/usr/bin/env perl
use Modern::Perl;
use HackaMol;
use Math::Vector::Real;
use Math::Vector::Real::Random;
use Math::Trig;
use Time::HiRes qw(time);
use MCE::Map     chunk_size => 1;
use MCE::Stream  chunk_size => 1;

my $t1 = time;
# let's create a 20 Angstrom ball of oxygen atoms from density of water
my $radius = 30;
my $natoms = int( 0.0334 * ( $radius**3 ) * 4 * pi / 3 );

my @sphatoms =
  map { HackaMol::Atom->new( Z => 8, charges => [0], coords => [$_] ) }
  map { Math::Vector::Real->random_in_sphere( 3, $radius ) } 1 .. $natoms;

say scalar (@sphatoms);

my $t2 = time;
printf ("time    %10.2f\n", $t2-$t1);

my @dist3 = mce_map_s {

   my $i = $_;
   my $ati = $sphatoms[$i];

   map { $ati->distance( $_ )  } @sphatoms[$i+1 .. $#sphatoms];

} 0, $#sphatoms - 1;

my $t3 = time;
printf ("time mce %10.2f\n", $t3-$t2);

my @dist4; 

mce_stream_s \@dist4, sub {

   my $i = $_;
   my $ati = $sphatoms[$i];

   map { $ati->distance( $_ )  } @sphatoms[$i+1 .. $#sphatoms];

}, 0, $#sphatoms - 1;

my $t4 = time;
printf ("time mce %10.2f\n", $t4-$t3);
my @d;

for (my $i=0 ; $i < $#sphatoms; $i++){
  my $ati = $sphatoms[$i];
  push @d, map { $ati->distance( $_ )  } @sphatoms[$i+1 .. $#sphatoms];
}

my $t5 = time;
printf ("time mce %10.2f\n", $t5-$t4);

print scalar(@d), " ", scalar(@dist3), " ", scalar(@dist4) . "\n";

exit;
foreach (0 .. $#d){

  printf ("%10.6f %10.6f %10.6f\n", $d[$_], $dist3[$_], $dist4[$_]);

}

