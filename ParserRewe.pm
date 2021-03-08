#!/usr/bin/perl

#
# Rewe Parser.
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

package ParserRewe;

use strict;
use warnings;
use utf8;

require Product;
require Helpers;

sub convert_to_tag($)
{
    my $s = shift;

    my $res = $s;
    $res =~ s/,//g;
    $res =~ s/"//g; #"

    return $res;
}

sub parse_pic($)
{
    my $pic = shift;

    my $res = $pic;

    $res =~ s/resize=152px:152px&//;
    $res =~ s/\?output-quality=80&output-format=jpeg&im=BackgroundColor,color=fff//;

    return $res;
}

sub parse_weight($)
{
    my $w = shift;

    my $res = $w;

    $res =~ s/\(.*\)//;

    $res = Helpers::parse_weight( $res );

    return $res;
}

sub conv_fields_to_shopify($$$$$$$)
{
    my ( $fields_ref, $handles_ref, $categories_ref, $vendor_id, $price_factor, $should_round_up, $outp ) = @_;

    my @fields = @{ $fields_ref };

    #my $num_fields = scalar @fields; # DEBUG

    #print "DEBUG: fields=$num_fields\n";

    my $handle = Helpers::convert_title_to_handle( $fields[4] );

    if( Helpers::is_handle_unique( $handles_ref, $handle ) == 0 )
    {
        print "WARNING: duplicate handle '$handle'\n";
        return;
    }

    my $title  = Helpers::sanitize_title( $fields[4] );

    my $tag_1  = convert_to_tag( $fields[2] );
    my $tag_2  = convert_to_tag( $fields[3] );

    my $tags = '"' . $tag_1 ."," . $tag_2 . '"';

    Helpers::add_or_update_categories( $categories_ref, $tag_1, $tag_2 );

    my $cost_per_item  = Helpers::parse_price( $fields[6] );

    if( $cost_per_item == -1 )
    {
        $cost_per_item  = Helpers::parse_price( $fields[8] );
    }

    my $price = Helpers::apply_price_factor( $cost_per_item, $price_factor, $should_round_up );

    my $pic  = parse_pic( $fields[10] );

    my $weight = parse_weight( $fields[5] );

    #print "DEBUG: field '$fields[5]', weight = $weight\n";

    my $product = new Product(
        $handle,
        $title,
        '', #  body_html
        $vendor_id,
        $fields[1], # type
        $tags, # tags
        'TRUE', # published
        'Title', # option1_name
        'Default Title', # option1_value
        '', # option2_name
        '', # option2_value
        '', # option3_name
        '', # option3_value
        '', # variant_sku
        $weight, # variant_grams
        '', # variant_inventory_tracker
        '', # variant_inventory_qty
        'deny', # variant_inventory_policy
        'manual', # variant_fulfillment_service
        $price, # variant_price
        '', # variant_compare_at_price
        'TRUE', # variant_requires_shipping
        '', # variant_taxable
        '', # variant_barcode
        $pic, # image_src
        '', # image_position
        '', # image_alt_text
        'FALSE', # gift_card
        '', # seo_title
        '', # seo_description
        '', # google_shopping_metafields
        '', # variant_image
        '', # variant_weight_unit
        '', # variant_tax_code_shopify_plus
        $cost_per_item, # cost_per_item
        'active' # status
        );

    #print $handle, ",", $title, ",", $price,",", $pic, "\n";

    # Shopify fields
    # https://help.shopify.com/en/manual/products/import-export/using-csv#product-csv-file-format

    print $outp $product->to_csv() . "\n";
}

1;
