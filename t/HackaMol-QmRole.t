#!/usr/bin/env perl

use strict;
use warnings;
use Test::Moose;
use Test::More;
use Test::Warn;
use Test::Fatal qw(lives_ok);
use MooseX::ClassCompositor;    #use this for testing roles
use HackaMol::QmMolRole;                # v0.001;#To test for version availability

my @attributes = qw(
basis
ecp
multiplicity
basis_geom
dummy
              total_energy electronic_energy nuclear_energy 
              qm_dipole_moment ionization_energy gradient_norm
              heat_of_formation 
              U H G S
              S_t
              S_r
              S_v
              total_energy_mp2
              total_energy_ccsdt
              nonelectrostatic_energy
              qm_dipole frequencies eigvec alpha beta
);
my @methods = qw(
);

my $class = MooseX::ClassCompositor->new( { 
                                            class_basename => 'Test', 
                                          } )->class_for('HackaMol::QmMolRole');

map has_attribute_ok( $class, $_ ), @attributes;
map can_ok( $class, $_ ), @methods;
my $obj;
lives_ok {
    $obj = $class->new();
}
'Test creation of an obj';

is($obj->basis, '6-31+G*', 'basis default');
is($obj->multiplicity        , 1     , 'multiplicity default');

done_testing();