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
#use Text::Unidecode;

require Product;

binmode(STDOUT, "encoding(UTF-8)");

my $ARGC = $#ARGV + 1;
if( $ARGC < 3 || $ARGC > 5 )
{
    print STDERR "\nUsage: convert_products_to_shopify.sh <input_file.csv> <output.csv> <vendor_id> [<price_factor> [<-r>]]\n";
    exit;
}

my $file = $ARGV[0] or die "Need to get CSV file on the command line\n";
my $outp = $ARGV[1];
my $vendor_id = $ARGV[2];
my $price_factor = ( $ARGC >= 4 ) ? ( $ARGV[3] + 0.0 ) : ( 1.0 );
my $should_round_up = ( $ARGC == 5 ) ? ( ( $ARGV[4] =~ /\-r/ ) ? 1 : 0 ) : 0;

#print STDERR "DEBUG: price_factor = $price_factor\n";
#print STDERR "DEBUG: should_round_up = $should_round_up\n";

sub create_title($)
{
    my $title = shift;

    $title =~ s/[\xc2\xad]/ /g;

    return $title;
}

sub create_handle($)
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

sub convert_to_tag($)
{
    my $s = shift;

    my $res = $s;
    $res =~ s/,//g;
    $res =~ s/"//g; #"

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

sub parse_pic($)
{
    my $pic = shift;

    my $res = $pic;

    $res =~ s/resize=152px:152px&//;
    $res =~ s/\?output-quality=80&output-format=jpeg//;

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
    my ( $handles_ref, $categories_ref, $vendor_id ) = @_;

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

    print OUTPUT $product->to_csv() . "\n";
}

sub conv_fields_to_shopify($$$$$$)
{
    my ( $fields_ref, $handles_ref, $categories_ref, $vendor_id, $price_factor, $should_round_up ) = @_;

    my @fields = @{ $fields_ref };

    #my $num_fields = scalar @fields; # DEBUG

    #print "DEBUG: fields=$num_fields\n";

    my $handle = create_handle( $fields[4] );

    if( is_handle_unique( $handles_ref, $handle ) == 0 )
    {
        print "WARNING: duplicate handle '$handle'\n";
        return;
    }

    my $title  = create_title( $fields[4] );

    my $tag_1  = convert_to_tag( $fields[2] );
    my $tag_2  = convert_to_tag( $fields[3] );

    my $tags = '"' . $tag_1 ."," . $tag_2 . '"';

    add_or_update_categories( $categories_ref, $tag_1, $tag_2 );

    my $cost_per_item  = parse_price( $fields[6] );

    if( $cost_per_item == -1 )
    {
        $cost_per_item  = parse_price( $fields[8] );
    }

    my $price = apply_price_factor( $cost_per_item, $price_factor, $should_round_up );

    my $pic  = parse_pic( $fields[10] );

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
        '0', # variant_grams
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

    print OUTPUT $product->to_csv() . "\n";
}

my $csv = Text::CSV->new ({
  binary    => 1,
  auto_diag => 1,
  sep_char  => ';'
});

open(my $data, '<:encoding(utf8)', $file) or die "Could not open '$file' $!\n";

open( OUTPUT, "> $outp" ) or die "Couldn't open file for writing: $!\n";

binmode( OUTPUT, "encoding(UTF-8)" );

print OUTPUT Product::get_csv_header() . "\n";

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

        conv_fields_to_shopify( \@fields, \%handles, \%categories, $vendor_id, $price_factor, $should_round_up );
    }
    else
    {
        warn "Line could not be parsed: $line\n";
    }
}

close $data;

add_aux_product( \%handles, \%categories, $vendor_id );

close OUTPUT;

my $outp_size = scalar keys %handles;

my $num_ignored = $num_lines - $outp_size;

print "INFO: input lines $num_lines, output lines $outp_size, ignored lines $num_ignored\n";
