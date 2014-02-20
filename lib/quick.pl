use Modern::Perl;
use Math::Vector::Real::kdTree;
 
use Math::Vector::Real;
use Math::Vector::Real::Random;
 
my @v = map Math::Vector::Real->random_normal(4), 1..100000;
 
my $tree = Math::Vector::Real::kdTree->new(@v);
 
my $ix = $tree->find_nearest_neighbor(V(0, 0, 0, 0));
 
say "nearest neighbor is $ix, $v[$ix]";
