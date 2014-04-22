package HackaMol::FileRole;

#ABSTRACT:  
use 5.008;
use Moose::Role;
use MooseX::Types::Path::Class;

has 'in_fn' => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    coerce   => 1,
);
 
has 'out_fn' => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    coerce   => 1,
);

has 'log_fn' => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    coerce   => 1,
); 

has "$_\_fn" => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    coerce   => 1,
) foreach qw(fort1 fort2 fort3 fort4 fort5);

no Moose::Role;

1;

__END__

=pod

=head1 NAME

HackaMol::FileRole -  

=head1 VERSION

version 0.00_16

=head1 DESCRIPTION

This role adds files (log_fn,in_fn,out_fn) to a class. This is still a work in progress, 
and it will probably change (suggestions welcome).  The goal is to reduce the amount
code required for creating inputs, processing outputs, and monitoring it all
in a platform independent way. MooseX::Types::Path::Class is used to
coerce the attributes into Path::Class::File objects. See Path::Class for 
associated methods. 

=head1 ATTRIBUTES

=head2 log_fn 

isa Path::Class::File that is 'ro'  

Intended for logging, but there's nothing enforcing that for now.

=head2 in_fn

isa Path::Class::File that is 'ro'

writing input, but there's nothing enforcing that for now.

=head2 out_fn

isa Path::Class::File that is 'ro'

reading output, but there's nothing enforcing that for now.

=head2 fort1_fn fort2_fn fort3_fn fort4_fn fort5_fn

isa Path::Class::File that is 'rw'

a place for those extra, annoying files

=head1 AUTHOR

Demian Riccardi <demianriccardi@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Demian Riccardi.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
