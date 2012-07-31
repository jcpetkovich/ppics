#!/usr/bin/perl -w
# ppics.pl --- Pretty print iCal calendar events.
# Author: Jean-Christophe Petkovich <me@jcpetkovich.com>
# Created: 31 Jul 2012
# Version: 0.01

# Field Formatter Class
package FieldFormatter;
use Moose;

has header => (
    is      => 'rw',
    isa     => 'Str',
    default => ''
);
has footer => (
    is      => 'rw',
    isa     => 'Str',
    default => ""
);
has inline => (
    is      => 'rw',
    isa     => 'Str',
    default => ""
);

sub format_string {
    my $self    = shift;
    my ($value) = @_;
    my $str     = $self->header . "\n";
    $str .= $self->inline . $value . "\n";
    $str .= $self->footer . "\n";
    return $str;
}

# Main
package main;

use strict;
use warnings;
use Data::Dumper;
use Data::ICal;
use Getopt::Long qw( :config auto_help );

# =============Customization==============
# Customize printing rules here.
my %printing_rules = (
    summary => FieldFormatter->new(
        header => "------------------Summary-----------------"
    ),
    organizer   => FieldFormatter->new( inline => 'Organizer: ' ),
    location    => FieldFormatter->new( inline => 'Location: ' ),
    description => FieldFormatter->new(
        header => "----------------Description---------------"
    ),
    method => FieldFormatter->new( inline => 'Type: ' )
);

# Add calendar properties that you want printed here
my @calendar_values = qw( method );

# Add event properties that you want printed here
my @event_values = qw( organizer summary location description );

# ============End Customization===========

my $filename;
GetOptions( 'file|f=s' => \$filename );

my $calendar = Data::ICal->new( filename => $filename );

my @events =
  grep { 'Data::ICal::Entry::Event' eq ref($_) } @{ $calendar->entries };

sub grab_values {
    my ( $self, @values ) = @_;

    my %stuff = map { $_, $self->property($_) }
      grep { defined $self->property($_) } @values;

    while ( my ( $property, $value ) = each %stuff ) {
        $stuff{$property} = [ map { $_->decoded_value } @$value ];
    }
    return %stuff;
}

for my $event (@events) {

    my %calendar_values = grab_values( $calendar, @calendar_values );

    my %event_values = grab_values( $event, @event_values );

    for my $calendar_value (@calendar_values) {
        for ( @{ $calendar_values{$calendar_value} } ) {
            print $printing_rules{$calendar_value}->format_string($_);
        }
    }
    for my $event_value (@event_values) {
        for ( @{ $event_values{$event_value} } ) {
            print $printing_rules{$event_value}->format_string($_);
        }
    }

    print Dumper \%calendar_values;
    print Dumper \%event_values;
}

__END__

=head1 NAME

B<ppics.pl> - Pretty print ics events from file.

=head1 SYNOPSIS

ppics.pl [options] args

      -h --help            Print this help documentation.
      -f --file filespec   Pick the file to process

=head1 DESCRIPTION

B<ppics.pl> prints out ics files as specified in %printing_rules.

Depends on Data::ICal and Moose.

=head1 AUTHOR

Jean-Christophe Petkovich, E<lt>me@jcpetkovich.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Jean-Christophe Petkovich

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
