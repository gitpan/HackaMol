
use strict;
use warnings;

use 5.008;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "HackaMol: Object-Oriented Library for Molecular Hacking",
  "AUTHOR" => "Demian Riccardi <demianriccardi\@gmail.com>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "HackaMol",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "HackaMol",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Data::Dumper" => 0,
    "Exporter" => 0,
    "FileHandle" => 0,
    "Math::Trig" => 0,
    "Math::Vector::Real" => "0.10",
    "Math::Vector::Real::Random" => "0.03",
    "Math::Vector::Real::XS" => "0.04",
    "Moose" => "2.10",
    "Moose::Role" => 0,
    "MooseX::Storage" => 0,
    "Scalar::Util" => 0,
    "namespace::autoclean" => 0
  },
  "TEST_REQUIRES" => {
    "Cwd" => 0,
    "File::Slurp" => 0,
    "Math::Vector::Real::Random" => 0,
    "Test::Fatal" => 0,
    "Test::Moose" => 0,
    "Test::More" => 0,
    "Test::Output" => 0,
    "Test::Warn" => 0,
    "Time::HiRes" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.00_04",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
  my $br = $WriteMakefileArgs{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



