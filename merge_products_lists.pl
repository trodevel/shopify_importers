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

            my $product = Product::create_from_array( \@fields );

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


#open( OUTPUT, "> $outp" ) or die "Couldn't open file for writing: $!\n";

#binmode( OUTPUT, "encoding(UTF-8)" );

my %handles_1;
my %handles_2;

read_products( $inp_file1, \%handles_1 );
read_products( $inp_file2, \%handles_2 );

#close OUTPUT;


#print "INFO: input lines $num_lines, output lines $outp_size, ignored lines $num_ignored\n";
