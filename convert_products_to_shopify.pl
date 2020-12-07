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
if( $ARGC < 3 || $ARGC > 4 )
{
    print STDERR "\nUsage: convert_products_to_shopify.sh <input_file.csv> <output.csv> <vendor_id> [<price_factor>]\n";
    exit;
}

my $file = $ARGV[0] or die "Need to get CSV file on the command line\n";
my $outp = $ARGV[1];
my $vendor_id = $ARGV[2];
my $price_factor = ( $ARGC == 4 ) ? ( $ARGV[3] + 0.0 ) : ( 1.0 );

sub create_title($)
{
    my $title = shift;

    $title =~ s/"/""/g;  #"

    return '"' . $title . '"';
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

sub apply_price_factor($$)
{
    my ( $price, $price_factor ) = @_;

    my $res = $price * $price_factor;

    $res = sprintf( "%.2f", $res );

    $res += 0.0;

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

sub conv_fields_to_shopify($$$$)
{
    my ( $fields_ref, $handles_ref, $vendor_id, $price_factor ) = @_;

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

    my $price  = parse_price( $fields[6] );

    if( $price == -1 )
    {
        $price  = parse_price( $fields[8] );
    }

    $price = apply_price_factor( $price, $price_factor );

    my $pic  = parse_pic( $fields[10] );

    my $product = new Product(
        $handle,
        $title,
        '', #  body_html
        $vendor_id,
        $fields[1], # type
        $fields[1], # tags
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
        '', # variant_requires_shipping
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
        $price, # cost_per_item
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

my $num_lines = 0;

while( my $line = <$data> )
{
    chomp $line;

    $num_lines++;

    if( $csv->parse( $line ) )
    {
        my @fields = $csv->fields();

        conv_fields_to_shopify( \@fields, \%handles, $vendor_id, $price_factor );
    }
    else
    {
        warn "Line could not be parsed: $line\n";
    }
}

close $data;

close OUTPUT;

my $outp_size = scalar keys %handles;

my $num_ignored = $num_lines - $outp_size;

print "INFO: input lines $num_lines, output lines $outp_size, ignored lines $num_ignored\n";
