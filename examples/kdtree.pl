use Modern::Perl;
use Math::Vector::Real::kdTree;
use HackaMol;

my @xyzs = map{$_->xyz} HackaMol->new->read_file_atoms(shift);
my $t = Math::Vector::Real::kdTree->new(@xyzs);

say $t->size;

use Data::Dumper;
print Dumper $t;


