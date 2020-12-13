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

require ProductList;

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

my $pl_1 = new ProductList();
my $pl_2 = new ProductList();

$pl_1->read_products( $inp_file1 );
$pl_2->read_products( $inp_file2 );

$pl_1->merge( $pl_2 );

pl_1->save_products( $outp );
