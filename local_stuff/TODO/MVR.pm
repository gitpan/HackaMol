package MVR;
#ABSTRACT: Moose subclass of Math::Vector::Real
use 5.008;
use Moose;
use namespace::autoclean;
use MooseX::NonMoose::InsideOut;
use MooseX::Storage;
with Storage ('io' => 'StorableFile' );
extends 'Math::Vector::Real';

sub FOREIGNBUILDARGS { return @{$_[2]}} 

__PACKAGE__->meta->make_immutable;

1;

