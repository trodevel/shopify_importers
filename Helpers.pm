#!/usr/bin/perl

#
# Helpers.
#
# Copyright (C) 2021 Dr. Sergey Kolevatov
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

package Helpers;

use strict;
use warnings;
use POSIX;
use utf8;

sub sanitize_title($)
{
    my $title = shift;

    $title =~ s/[\xc2\xad]/ /g;

    return $title;
}

sub convert_title_to_handle($)
{
    my $title = shift;

    my $res = lc $title;
    $res =~ s/ /-/g;
    $res =~ s/,/-/g;
    $res =~ s/['"!\.&%´:\/()\+=®*²]//g;     #'
    $res =~ s/ü/ue/g;
    $res =~ s/ä/ae/g;
    $res =~ s/ö/oe/g;
    $res =~ s/ß/ss/g;
    $res =~ s/β/ss/g;

    $res =~ s/[àâá]/a/g;
    $res =~ s/ç/c/g;
    $res =~ s/[éèë]/e/g;
    $res =~ s/ñ/n/g;
    $res =~ s/å/ae/g;
    $res =~ s/[ìîí]/i/g;
    $res =~ s/ó/o/g;
    $res =~ s/[úû]/u/g;

    $res =~ s/--/-/g;
    $res =~ s/--/-/g;
    $res =~ s/-$//g;

    return $res;
}

sub replace_commas($)
{
    my $res = shift;

    $res =~ s/,/./g;

    return $res;
}

sub parse_weight($)
{
    my $weight = shift;

    my $res = 0;

    my $multiplier = 1;

    #print "DEBUG: parse_weight: $weight\n";

    if( $weight =~ /([0-9]+)x/ )
    {
        $multiplier = $1 + 0;
        $weight =~ s/[0-9]+x//;
    }

    if( $weight eq "" )
    {
        $res = 97;
    }
    elsif( $weight eq "0" )
    {
        $res = 0;
    }
    elsif( $weight =~ /([0-9]+[,0-9]*)\s*(g|ml)/ )
    {
        $res = replace_commas( $1 ) + 0;
    }
    elsif( $weight =~ /([0-9]+[,0-9]*)\s*(kg|l)/ )
    {
        $res = replace_commas( $1 ) + 0;
        $res *= 1000;
    }
    elsif( $weight =~ /([0-9]+)\s*([Ss]tück)/ )
    {
        $res = $1 + 0;
        $res *= 99;            # virtual weight
    }
    elsif( $weight =~ /([0-9]+[,0-9]*)\s*[c]*m/ )
    {
        $res = replace_commas( $1 ) + 0;
        $res *= 98;
    }
    else
    {
        die "unknown weight format";
    }

    $res *= $multiplier;

    $res = ceil( $res );

    return $res;
}

sub parse_price($)
{
    my $price = shift;

    my $res = $price;

    $res =~ s/€//g;
    $res =~ s/,/./;
    $res += 0.0;

    return $res;
}

sub round_up_price($)
{
    my ( $price ) = @_;

    my $fixed_point_price = int( $price * 100 );

    my $last_digit = $fixed_point_price % 10;

    my $delta = 0;

    if( $last_digit > 0 )
    {
        if( $last_digit > 5 )
        {
            $delta = 9 - $last_digit;
        }
        else
        {
            $delta = 5 - $last_digit;
        }
    }

    my $res = $price + ( $delta / 100 );

    return $res;
}

sub apply_price_factor($$$)
{
    my ( $price, $price_factor, $should_round_up ) = @_;

    my $res = $price * $price_factor;

    $res = sprintf( "%.2f", $res );

    $res += 0.0;

    $res = ( $should_round_up == 1 ) ? round_up_price( $res ) : $res;

    return $res;
}

sub is_handle_unique($$)
{
    my ( $handles_ref, $handle ) = @_;

    if( exists( $handles_ref->{ $handle } ) )
    {
        $handles_ref->{ $handle }++;

        return 0;
    }

    $handles_ref->{ $handle } = 1;

    return 1;
}

sub add_or_update_categories($$$)
{
    my ( $categories_ref, $category, $sub_category ) = @_;

    if( exists $categories_ref->{$category} )
    {
        if( not exists $categories_ref->{$category}->{$sub_category} )
        {
            $categories_ref->{$category}->{$sub_category} = 1;
        }
    }
    else
    {
        my %hash;
        $categories_ref->{$category} = \%hash;

        $categories_ref->{$category}->{$sub_category} = 1;
    }
}

1;
