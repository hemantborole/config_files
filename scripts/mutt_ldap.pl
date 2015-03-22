#!/usr/bin/perl

use strict;
use Net::LDAP;

#use constant HOST => '10.150.2.10';
use constant HOST => 'mail.yp.com:3268';
use constant PORT => '3268';
use constant BASE => 'dc=yellowpages,dc=local';
use constant VERSION => 3;
use constant SCOPE => 'sub';

my $name;
my @attributes = qw( dn givenName sn mail );
my $filter;
{
    print "Searching directory... ";
    $name = shift || die "Usage: $0 filter\n";
    $filter = "(|(sn=$name*)(givenName=$name*))";
    my $ldap = Net::LDAP->new( HOST, onerror => 'die' )
            || die "Cannot connect: $@";

    $ldap->bind( 'hborole@yellowpages.local', password => 'October2013' ) or die "Cannot bind: $@";

    my $result = $ldap->search( base => BASE,
                            scope => SCOPE,
                            attrs => \@attributes,
                            filter => $filter
                            );

    my @entries = $result->entries;

    $ldap->unbind();

    print scalar @entries, " entries found.\n";

    foreach my $entry ( @entries ) {
        my @emailAddr = $entry->get_value('mail');
        foreach my $addr (@emailAddr) {
            print $addr , "\t";
            print $entry->get_value('givenName'), " ";
            print $entry->get_value('sn'), "\n";
        }
    }
}
