package HackaMol::Molecule;

#ABSTRACT: Molecule class for HackaMol
use 5.008;
use Moose;
use namespace::autoclean;
use Carp;
use Math::Trig;
use Scalar::Util qw(refaddr);
use MooseX::StrictConstructor;
#use MooseX::Storage;
#with Storage( 'io' => 'StorableFile' ), 
with 'HackaMol::NameRole', 'HackaMol::PhysVecMVRRole',
  'HackaMol::BondsAnglesDihedralsRole', 'HackaMol::QmMolRole';

extends 'HackaMol::AtomGroup';

has 'atomgroups' => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[HackaMol::AtomGroup]',
    default => sub { [] },
    lazy    => 1,
    handles => {
        "has_groups"    => 'count',
        "push_groups"   => 'push',
        "get_groups"    => 'get',
        "set_groups"    => 'set',
        "all_groups"    => 'elements',
        "count_groups"  => 'count',
        "delete_groups" => 'delete',
        "clear_groups"  => 'clear',
    },
);

sub BUILD {
    my $self = shift;
    foreach my $bond ( $self->all_bonds ) {
        $_->inc_bond_count foreach $bond->all_atoms;
    }
    return;
}

# need to increase atom bond_count when push
after 'push_bonds' => sub {
    my $self = shift;
    foreach my $bond (@_) {
        $_->inc_bond_count foreach $bond->all_atoms;
    }
};

# need to reduce atom bond_count when set,delete, or clear
before 'delete_bonds' => sub {
    my $self = shift;
    my $bond = $self->get_bonds(@_);
    $_->dec_bond_count foreach $bond->all_atoms;
};

around 'set_bonds' => sub {
    my ( $orig, $self, $index, $bond ) = @_;
    my $oldbond = $self->get_bonds($index);
    if ( defined($oldbond) ) {
        $_->dec_bond_count foreach $oldbond->all_atoms;
    }
    $_->inc_bond_count foreach $bond->all_atoms;
    $self->$orig( $index, $bond );
};

before 'clear_bonds' => sub {
    my $self = shift;
    foreach my $bond ( $self->all_bonds ) {
        $_->dec_bond_count foreach $bond->all_atoms;
    }
};

after 't' => sub {
    my $self = shift;
    $self->gt(@_) if (@_);    # set t for all in group
};

sub _build_mass {
    my $self = shift;
    my $mass = 0;
    $mass += $_->mass foreach $self->all_atoms;
    return ($mass);
}

sub all_bonds_atoms  { return ( shift->_all_these_atoms( 'bonds',  @_ ) ) }
sub all_angles_atoms { return ( shift->_all_these_atoms( 'angles', @_ ) ) }

sub all_dihedrals_atoms {
    return ( shift->_all_these_atoms( 'dihedrals', @_ ) );
}

sub _all_these_atoms {

    #these bonds, these angles, these dihedrals
    #this bond, this angle, this dihedral
    my $self      = shift;
    my $these     = shift;
    my @atoms     = @_;
    my $method    = "all_$these";
    my @all_these = $self->$method;
    my @atoms_these;
    foreach my $this (@all_these) {
        my @thatoms = $this->all_atoms;
        foreach my $atom (@atoms) {
            push @atoms_these, $this
              if ( grep { refaddr($atom) == refaddr($_) } @thatoms );
        }
    }
    return (@atoms_these);
}

sub bond_stretch_groups {
    my $self = shift;
    croak "pass Bond, trans distance (Angstroms), 1+ groups to trans"
      unless @_ > 2;
    my $t = $self->t;
    my ( $bond, $dist ) = ( shift, shift );
    my $vec    = $bond->bond_vector;
    my @groups = @_;
    my $tvec   = $dist * $vec->versor;
    $_->translate( $tvec, $t ) foreach @groups;
}

sub bond_stretch_atoms {
    my $self = shift;
    croak "pass Bond, trans distance (Angstroms), 1+ atoms to trans"
      unless @_ > 2;
    my $t = $self->t;
    my ( $bond, $dist ) = ( shift, shift );
    my $vec   = $bond->bond_vector;
    my @atoms = @_;
    my $tvec  = $dist * $vec->versor;
    $_->set_coords( $t, $_->xyz + $tvec ) foreach @atoms;
}

sub angle_bend_groups {
    my $self = shift;
    croak "pass Angle, ang to rotate (degrees), 1+ groups effected"
      unless @_ > 2;
    my $t = $self->t;
    my ( $angle, $dang ) = ( shift, shift );
    my $origin = $angle->get_atoms(1)->get_coords($t);
    my $rvec   = $angle->ang_normvec;
    my @groups = @_;
    $_->rotate( $rvec, $dang, $origin, $t ) foreach @groups;
}

sub angle_bend_atoms {
    my $self = shift;
    croak "pass Angle, ang to rotate (degrees), 1+ groups effected"
      unless @_ > 2;
    my $t = $self->t;
    my ( $angle, $dang ) = ( shift, shift );
    my $origin = $angle->get_atoms(1)->get_coords($t);
    my $rvec   = $angle->ang_normvec;
    my @atoms  = @_;

    my @cor =
      map { $_->get_coords($t) - $origin } @atoms;    #shift origin
    my @rcor = $rvec->rotate_3d( deg2rad($dang), @cor );

    #shift origin back
    $atoms[$_]->set_coords( $t, $rcor[$_] + $origin ) foreach 0 .. $#rcor;
}

sub dihedral_rotate_atoms {
    my $self = shift;
    croak "pass Dihedral, rotation angle (deg), atoms to rotate" unless @_ > 2;
    my $t = $self->t;
    my ( $dihe, $dang ) = ( shift, shift );
    my ( $atom0, $ratom1, $ratom2, $atom3 ) = $dihe->all_atoms;
    my $rvec   = ( $ratom2->inter_dcoords($ratom1) )->versor;
    my $origin = $ratom1->xyz;
    my @atoms  = @_;
    my @cor =
      map { $_->get_coords($t) - $origin } @atoms;    #shift origin too
    my @rcor = $rvec->rotate_3d( deg2rad($dang), @cor );

    #shift origin back
    $atoms[$_]->set_coords( $t, $rcor[$_] + $origin ) foreach 0 .. $#rcor;

}

sub dihedral_rotate_groups {
    my $self = shift;
    croak "pass Dihedral, rotation angle (deg), atoms to rotate" unless @_ > 2;
    my $t = $self->t;
    my ( $dihe, $dang ) = ( shift, shift );
    my ( $atom0, $ratom1, $ratom2, $atom3 ) = $dihe->all_atoms;
    my $rvec   = ( $ratom2->inter_dcoords($ratom1) )->versor;
    my $origin = $ratom1->xyz;
    my @groups = @_;
    $_->rotate( $rvec, $dang, $origin, $t ) foreach @groups;

}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

HackaMol::Molecule - Molecule class for HackaMol

=head1 VERSION

version 0.00_14

=head1 SYNOPSIS

    use HackaMol;
    use Math::Vector::Real;
    
    my $hack  = HackaMol->new(name => "hackitup");
    my @atoms = $hack->read_file_atoms("t/lib/1L2Y.pdb"); 
    
    my $mol = HackaMol::Molecule->new(name=> 'trp-cage', atoms=>[@atoms]);
    $mol->translate(-$mol->COM);
    $mol->rotate(V(1,0,0), 180, V(10,10,10));
    
    $mol->print_xyz;
    # see examples

=head1 DESCRIPTION

The Molecule class provides methods and attributes for collections of atoms that may be divided
into groups, placed into bonds, angles, and dihedrals. The Molecule class extends the AtomGroup 
parent class, which consumes the AtomGroupRole, and consumes PhysVecMVRRole, QmRole, and 
BondsAnglesDihedralsRole. See the documentation of those classes and roles for details.  

In addition to Bonds, Angles, and Dihedrals, which also consume the AtomGroupRole, the Molecule
class has the atomgroups attr.  The atomgroups attr is an ArrayRef[AtomGroup] with native array
traits that allows all the atoms in the Molecule to be grouped and regroup at will. Thus, the 
Molecule class provides a suite of methods and attributes that is very powerful. For example,
a HackaMolX extension for proteins could group the atoms by sidechains and backbones, populate 
bonds, and then use Math::Vector::Real objects to sample alternative conformations of the 
sidechains and backbone. 

=head1 METHODS

=head2 t 

t is the same attr as before.  Molecule modifies t.  the $mol->t accessor behaves as before.  The $mol->(1)
setter $self->gt(1) to set t for all atoms in the molecule.

=head2 push_groups_by_atom_attr

takes atom attribute as argument.  pushes the atoms into the atomgroup array by attribute

=head2 all_bonds_atoms  

takes array of atoms as argument, returns array of bonds that includes 1 or more of those atoms

=head2 all_angles_atoms  

takes array of atoms as argument, returns array of angles that includes 1 or 
more of those atoms

=head2 all_dihedrals_atoms  

takes array of atoms as argument, returns array of dihedrals that includes 1 or 
more of those atoms 

=head2 bond_stretch_atoms

takes Bond object, a distance (angstroms, typically), and active atoms as arguments. 
translates the active atoms along the bond_vector by the distance and stores coordinates 
in place ($atom->set_coords($mol->t,$translated_coors)).

=head2 bond_stretch_groups

takes Bond object, a distance (angstroms, typically), and active groups as arguments. 
translates the atoms in the active groups along the bond_vector by the distance and 
stores coordinates in place.

=head2 angle_bend_atoms

takes Angle object, an angle (degress), and active atoms as arguments. rotates the active atoms
about the vector normal to be angle and stores rotated coordinates in place 
($atom->set_coords($mol->t,$rotated_coor)).

=head2 angle_bend_groups

takes Angle object, an angle (degress), and active groups as arguments. rotates the atoms
in the active groups about the vector normal to be angle and stores rotated coordinates 
in place ($atom->set_coords($mol->t,$rotated_coor)).

=head2 dihedral_rotate_atoms

takes Dihedral object, an angle (degress), and active atoms as arguments. rotates the active atoms
about the dihedral and stores rotated coordinates in place 
($atom->set_coords($mol->t,$rotated_coor)).

=head2 dihedral_rotate_groups

takes Dihedral object, an angle (degress), and active groups as arguments. rotates atoms in 
groups about the dihedral and stores rotated coordinates in place 
($atom->set_coords($mol->t,$rotated_coor)).

=head1 ARRAY METHODS

=head2 push_groups, get_groups, set_groups, all_groups, count_groups, delete_groups, clear_groups

ARRAY traits for the groups attribute, respectively: push, get, set, elements, count, delete, clear

=head2 push_groups

push bond on to groups array

$group->push_groups($bond1, $bond2, @othergroups);

=head2 all_groups

returns array of all elements in groups array

print $_->bond_order, "\n" foreach $group->all_groups; 

=head2 get_groups

return element by index from groups array

print $group->get_groups(1); # returns $bond2 from that pushed above

=head2 set_groups

set groups array by index

$group->set_groups(1, $bond1);

=head2 count_groups

return number of groups in the array  

print $group->count_groups; 

=head2 has_groups

same as count_groups, allows clearer conditional code. i.e.  doing something if $mol->has_groups;

=head2 push_bonds, set_bonds, delete_bonds, clear_bonds

MODIFIED ARRAY traits for the bonds attribute provided by BondsAnglesDihedralsRole

=head2 push_bonds

before push_bonds, bond_count is incremented for all atoms in all bonds to be pushed.

=head2 set_bonds

around set_bonds, bound_count decremented for all atoms in bond being replaced. Then, bond_count is 
incremented for all atoms in new bond

=head2 delete_bonds

before deleting bond, bond_count decremented for all atoms in bond.

=head2 clear_bonds

before clearing bonds, bond_count decremented for all atoms in all bonds.

=head1 SEE ALSO

=over 4

=item *

L<HackaMol::PhysVecMVRRole>

=item *

L<HackaMol::BondsAnglesDihedralsRole>

=item *

L<HackaMol::QmMolRole>

=item *

L<Chemistry::Molecule>

=back

=head1 EXTENDS

=over 4

=item * L<HackaMol::AtomGroup>

=back

=head1 CONSUMES

=over 4

=item * L<HackaMol::BondsAnglesDihedralsRole>

=item * L<HackaMol::NameRole>

=item * L<HackaMol::NameRole|HackaMol::PhysVecMVRRole|HackaMol::BondsAnglesDihedralsRole|HackaMol::QmMolRole>

=item * L<HackaMol::PhysVecMVRRole>

=item * L<HackaMol::QmAtomRole>

=item * L<HackaMol::QmMolRole>

=back

=head1 AUTHOR

Demian Riccardi <demianriccardi@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Demian Riccardi.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
