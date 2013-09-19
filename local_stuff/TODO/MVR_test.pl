use Modern::Perl;
use MVR;

my $a = MVR->new(vec=>[0,0,0]);
my $b = MVR->new(vec=>[1,1,1]);


print $_ ."\n" foreach (@{$a - $b});
print $a->dist($b) . "\n";

