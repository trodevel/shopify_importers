#!/usr/bin/perl

#
# Convert Products to Shopify.
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
require ParserRewe;

binmode(STDOUT, "encoding(UTF-8)");

my $ARGC = $#ARGV + 1;
if( $ARGC < 4 || $ARGC > 6 )
{
    print STDERR "\nUsage: convert_products_to_shopify.sh <PARSER> <input_file.csv> <output.csv> <vendor_id> [<price_factor> [<-r>]]\n";
    exit;
}

my $parser = $ARGV[0] or die "Need to get CSV file on the command line\n";
my $file = $ARGV[1] or die "Need to get CSV file on the command line\n";
my $outp = $ARGV[2];
my $vendor_id = $ARGV[3];
my $price_factor = ( $ARGC >= 5 ) ? ( $ARGV[4] + 0.0 ) : ( 1.0 );
my $should_round_up = ( $ARGC == 6 ) ? ( ( $ARGV[5] =~ /\-r/ ) ? 1 : 0 ) : 0;

#print STDERR "DEBUG: price_factor = $price_factor\n";
#print STDERR "DEBUG: should_round_up = $should_round_up\n";

sub categories_to_csv($)
{
    my ( $categories_ref, $category, $sub_category ) = @_;

    my $num_cat = scalar keys %{ $categories_ref };

    my $res = "$num_cat,";

    keys %{ $categories_ref };
    while( my( $k, $v ) = each %{ $categories_ref } )
    {
        my $num_sub_cat = scalar keys %{ $v };

        $res .= "$k,$num_sub_cat,";

        foreach my $s ( keys %{ $v } )
        {
            $res .= "$s,";
        }
    }

    return $res;
}

sub add_aux_product($$$)
{
    my ( $categories_ref, $vendor_id, $outp ) = @_;

    my $categories = categories_to_csv( $categories_ref );

    my $id = 'aux_product';
    my $handle = "${id}_${vendor_id}";

    my $product = new Product(
        $handle,
        $id,
        $categories, #  body_html
        $id, # vendor_id
        $vendor_id, # type
        '', # tags
        'TRUE', # published
        'Title', # option1_name
        'Default Title', # option1_value
        '', # option2_name
        '', # option2_value
        '', # option3_name
        '', # option3_value
        '', # variant_sku
        '0', # variant_grams
        '', # variant_inventory_tracker
        '', # variant_inventory_qty
        'deny', # variant_inventory_policy
        'manual', # variant_fulfillment_service
        0, # variant_price
        '', # variant_compare_at_price
        '', # variant_requires_shipping
        '', # variant_taxable
        '', # variant_barcode
        '', # image_src
        '', # image_position
        '', # image_alt_text
        'FALSE', # gift_card
        '', # seo_title
        '', # seo_description
        '', # google_shopping_metafields
        '', # variant_image
        '', # variant_weight_unit
        '', # variant_tax_code_shopify_plus
        0, # cost_per_item
        'active' # status
        );

    print $outp $product->to_csv() . "\n";
}

sub conv_fields_to_shopify($$$$$$$$)
{
    my ( $parser, $fields_ref, $handles_ref, $categories_ref, $vendor_id, $price_factor, $should_round_up, $outp ) = @_;

    if( $parser =~ "REWE" )
    {
        ParserRewe::conv_fields_to_shopify( $fields_ref, $handles_ref, $categories_ref, $vendor_id, $price_factor, $should_round_up, $outp );
    }
    else
    {
        die "FATAL: unsupported parser $parser";
    }
}

my $csv = Text::CSV->new ({
  binary    => 1,
  auto_diag => 1,
  sep_char  => ';'
});

open(my $data, '<:encoding(utf8)', $file) or die "Could not open '$file' $!\n";

open( my $OUTPUT, "> $outp" ) or die "Couldn't open file for writing: $!\n";

binmode( $OUTPUT, "encoding(UTF-8)" );

print $OUTPUT Product::get_csv_header() . "\n";

my %handles;

my %categories;

my $num_lines = 0;

while( my $line = <$data> )
{
    chomp $line;

    $num_lines++;

    if( $csv->parse( $line ) )
    {
        my @fields = $csv->fields();

        conv_fields_to_shopify( $parser, \@fields, \%handles, \%categories, $vendor_id, $price_factor, $should_round_up, $OUTPUT );
    }
    else
    {
        warn "Line could not be parsed: $line\n";
    }
}

close $data;

add_aux_product( \%categories, $vendor_id, $OUTPUT );

close $OUTPUT;

my $outp_size = scalar keys %handles;

my $num_ignored = $num_lines - $outp_size;

print "INFO: input lines $num_lines, output lines $outp_size, ignored lines $num_ignored\n";
