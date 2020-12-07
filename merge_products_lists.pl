#!/usr/bin/perl

#
# Merge Products Lists.
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

use strict;
use warnings;
use utf8;

use Text::CSV;

require Product;

binmode(STDOUT, "encoding(UTF-8)");

my $ARGC = $#ARGV + 1;
if( $ARGC != 3 )
{
    print STDERR "\nUsage: merge_products_lists.pl <inp_file1.csv> <inp_file2.csv> <outp_file.csv>\n";
    exit;
}

my $inp_file1 = $ARGV[0] or die "Need to get CSV file on the command line\n";
my $inp_file2 = $ARGV[1] or die "Need to get CSV file on the command line\n";
my $outp = $ARGV[2];

sub read_products($$)
{
    my ( $filename, $handles_ref ) = @_;

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

        if( $csv->parse( $line ) )
        {
            my @fields = $csv->fields();

            my $product = Product->create_from_array( \@fields );

            $handles_ref->{ $product->{handle} } = $product;
        }
        else
        {
            warn "Line could not be parsed: $line\n";
        }
    }

    close $data;

    my $num_handles = scalar keys %{ $handles_ref };

    print "INFO: read $num_lines lines, $num_handles handles from '$filename'\n";
}

sub save_products($$)
{
    my ( $filename, $handles_ref ) = @_;

    open( my $data, "> $filename" ) or die "Couldn't open file for writing: $!\n";

    binmode( $data, "encoding(UTF-8)" );

    print $data Product::get_csv_header() . "\n";

    foreach my $val( values %{ $handles_ref } )
    {
        print $data $val->to_csv() . "\n";
    }

    close $data;

    my $size = scalar keys %{ $handles_ref };

    print "INFO: saved $size lines to '$filename'\n";
}

my %handles_1;
my %handles_2;

my %merged;

read_products( $inp_file1, \%handles_1 );
read_products( $inp_file2, \%handles_2 );

my $num_updated = 0;
my $num_deleted = 0;
my $num_added = 0;

keys %handles_1;
while( my( $k, $v ) = each %handles_1 )
{
    if( exists( $handles_2{ $k } ) )
    {
        $num_updated += 1;

        my $v2 = $handles_2{ $k };

        $v->merge( $v2 );

        $merged{ $k } = $v;
    }
    else
    {
        $num_deleted += 1;

        $v->set_status_archived();

        $merged{ $k } = $v;
    }
}

keys %handles_2;
while( my( $k, $v ) = each %handles_2 )
{
    if( not exists( $handles_1{ $k } ) )
    {
        $num_added += 1;

        $merged{ $k } = $v;
    }
}

print "INFO: updated $num_updated, deleted $num_deleted, added $num_added\n";

save_products( $outp, \%merged );
