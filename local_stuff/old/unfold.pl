use Modern::Perl;
use lib 'lib/HackaMol','t/lib';
use Molecule;
use Dihedral;
use Math::Trig;
use PDBintoAtoms qw(readinto_atoms);
use Time::HiRes qw(time);
use Scalar::Util qw(refaddr);

my $t1 = time; 
my $angle = shift ;
$angle = 180 unless (defined($angle));

my @atoms = readinto_atoms("t/lib/1L2Y.pdb");
#to keep example simple, keep only the backbone
@atoms = grep {
               $_->name eq 'N'  or
               $_->name eq 'CA' or
               $_->name eq 'C'
              } @atoms;
#reset iatom
$atoms[$_]->iatom($_) foreach 0 .. $#atoms;

my $max_t = $atoms[0]->count_coords -1;
my $mol = Molecule->new(name=> 'trp-cage', atoms=>[@atoms]);

my @dihedrals ; 

# build the dihedrals 
my $k = 0;
while ($k+3 <= $#atoms){
  my $name; 
  $name .= $_->name.$_->resid foreach (@atoms[$k .. $k+3]);
  push @dihedrals, Dihedral->new(name=>$name, atoms=>[ @atoms[$k .. $k+3] ]);
  $k++;
}

my $natoms = $mol->count_atoms;
my $t = 0;
$mol->t($t);

my @iatoms = map{$_->iatom} @atoms;

foreach my $dihe (@dihedrals){
  my $ratom1 = $dihe->get_atoms(1);
  my $ratom2 = $dihe->get_atoms(2);
  my $rvec = ($ratom2->inter_dcoords($ratom1))->versor;

  #translate all so that ratom1 is at zero
  my $xyz_tr = $ratom1->xyz;
  foreach my $atom (@atoms){
    $atom->set_coords($t, $atom->xyz - $xyz_tr); 
  } 

  # atoms from nterm to ratom1 and from ratom2 to cterm
  my @nterm = 0 .. $ratom1->iatom - 1;
  my @cterm = $ratom2->iatom +1 .. $natoms-1;

  # use the smaller list for rotation
  my $r_these = \@nterm;
  $r_these = \@cterm if (@nterm > @cterm);

  my @cor = map{$_->get_coords($t)} @atoms[@{ $r_these }]; # r_these slice of atoms array
 
  my $rang = -deg2rad($dihe->dihe + $angle) ;
 
  $rang *= -1 if (@nterm>@cterm); #switch nterm to cterm switches sign on angle

  #rotate the coordinates and set them into atoms
  my @rcor = $rvec->rotate_3d($rang, @cor);
  $atoms[ $r_these->[$_] ]->set_coords($t, $rcor[$_]) foreach 0 .. $#rcor;

}
 
print "$natoms \n\n"; 
printf("%5s %8.3f %8.3f %8.3f\n", $_->symbol, @{$_->get_coords($t)}) foreach @atoms;

my $t2 = time;

printf("time: %10.6f\n", $t2-$t1);
