#!/usr/bin/perl

#
# Products List.
#
# Copyright (C) 2020 Dr. Sergey Kolevatov
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

############################################################

package ProductList;

use strict;
use warnings;
use utf8;

use Text::CSV;

require Product;

sub new()
{
    my $class = shift;

    my %handles;

    my $self =
    {
        handle          => \%handles,
        aux_product     => undef,
    };

    bless $self, $class;
    return $self;
}

sub read_products($)
{
    my ( $self, $filename ) = @_;

    my $csv = Text::CSV->new ({
        binary    => 1,
        auto_diag => 1,
        sep_char  => ','
        });

    open( my $data, '<:encoding(utf8)', $filename ) or die "Could not open '$filename' $!\n";

    my $num_lines = 0;

    while( my $line = <$data> )
    {
        chomp $line;

        $num_lines++;

        if( $num_lines == 1 )
        {
            next; # skip header
        }

        if( $csv->parse( $line ) )
        {
            my @fields = $csv->fields();

            my $product = Product->create_from_array( \@fields );

            $self->{handles}->{ $product->{handle} } = $product;
        }
        else
        {
            warn "Line could not be parsed: $line\n";
        }
    }

    close $data;

    my $num_handles = scalar keys %{ $self->{handles} };

    print "INFO: read $num_lines lines, $num_handles handles from '$filename'\n";
}

sub save_products($)
{
    my ( $self, $filename ) = @_;

    open( my $data, "> $filename" ) or die "Couldn't open file for writing: $!\n";

    binmode( $data, "encoding(UTF-8)" );

    print $data Product::get_csv_header() . "\n";

    foreach my $val( values %{ $self->{handles} } )
    {
        print $data $val->to_csv() . "\n";
    }

    close $data;

    my $size = scalar keys %{ $self->{handles} };

    print "INFO: saved $size lines to '$filename'\n";
}

sub merge_kern($$$)
{
    my ( $self, $rhs, $is_diff ) = @_;

    my %merged;

    my $num_updated = 0;
    my $num_deleted = 0;
    my $num_added = 0;
    my $num_modified = 0;

    keys %{ $self->{handles} };
    while( my( $k, $v ) = each %{ $self->{handles} } )
    {
        if( exists( $rhs->{handles}->{ $k } ) )
        {
            $num_updated += 1;

            my $v2 = $rhs->{handles}->{ $k };

            my $is_modified = $v->merge( $v2 );

            $num_modified += ( $is_modified == 1 ) ? 1 : 0;

            if( $is_diff == 0 || ( $is_diff == 1 && $is_modified ) )
            {
                $merged{ $k } = $v;
            }
        }
        else
        {
            $num_deleted += 1;

            $v->set_status_archived();

            $merged{ $k } = $v;
        }
    }

    keys %{ $rhs->{handles} };
    while( my( $k, $v ) = each %{ $rhs->{handles} } )
    {
        if( not exists( $self->{handles}->{ $k } ) )
        {
            $num_added += 1;

            $merged{ $k } = $v;
        }
    }

    my $res = $self;

    if( $is_diff )
    {
        $res = new ProductList();
        $res->{handles} = \%merged;
    }
    else
    {
        $self->{handles} = \%merged;
    }

    print "INFO: common items $num_updated (modified $num_modified), deleted $num_deleted, added $num_added\n";

    return $res;
}

sub merge($$)
{
    my ( $self, $rhs ) = @_;

    merge_kern( $self, $rhs, 0 );
}

sub diff($$)
{
    my ( $self, $rhs ) = @_;

    return merge_kern( $self, $rhs, 1 );
}

1;

