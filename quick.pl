use Modern::Perl;
use Math::Vector::Real;


my $a = V (1,0);
my $b = V (0,2);

my $c = ($a->versor+$b->versor)->versor;

print $c;

