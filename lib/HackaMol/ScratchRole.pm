package HackaMol::ScratchRole;

#ABSTRACT:  
use 5.008;
use Moose::Role;
use MooseX::Types::Path::Class;

has 'homedir' => (
    is       => 'ro',
    isa      => 'Path::Class::Dir',
    coerce   => 1,
);
 
has 'scratch' => (
    is       => 'ro',
    isa      => 'Path::Class::Dir',
    coerce   => 1,
);

has 'data' => (
    is       => 'ro',
    isa      => 'Path::Class::Dir',
    coerce   => 1,
); 

no Moose::Role;

1;

__END__

=pod

=head1 NAME

HackaMol::ScratchRole -  

=head1 VERSION

version 0.00_16

=head1 DESCRIPTION

This role adds directories to a class. This is still a work in progress, and it
will probably change (suggestions welcome).  The goal is to reduce the amount
code required for manipulating several paths used for work, and to allow 
scripts to be more platform independent. MooseX::Types::Path::Class is used to
coerce the attributes into Path::Class::Dir objects. See Path::Class for 
associated methods. 

=head1 ATTRIBUTES

=head2 scratch 

isa Path::Class::Dir that is 'ro'  

Intended to be temporary, but there's nothing enforcing that for now.

=head2 homedir

isa Path::Class::Dir that is 'ro'

Intended to be the mother ship, but there's nothing enforcing that for now.

=head2 homedir

isa Path::Class::Dir that is 'ro'

Intended to be a place that data is retrieved from, but there's nothing 
enforcing that for now.

=head1 AUTHOR

Demian Riccardi <demianriccardi@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Demian Riccardi.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
