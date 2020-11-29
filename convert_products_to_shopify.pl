#!/usr/bin/perl
use strict;
use warnings;
use utf8;

use Text::CSV;
#use Text::Unidecode;

binmode(STDOUT, "encoding(UTF-8)");

my $ARGC = $#ARGV + 1;
if( $ARGC != 3 )
{
    print STDERR "\nUsage: convert_products_to_shopify.sh <input_file.csv> <output.csv> <vendor_id>\n";
    exit;
}

my $file = $ARGV[0] or die "Need to get CSV file on the command line\n";
my $outp = $ARGV[1];
my $vendor_id = $ARGV[2];

sub create_handle_from_title($)
{
    my $title = shift;

    my $res = lc $title;
    $res =~ s/ /-/g;
    $res =~ s/'//g;     #'
    $res =~ s/"//g;     #"
    $res =~ s/,/_/g;
    $res =~ s/ü/ue/g;
    $res =~ s/ä/ae/g;
    $res =~ s/ö/oe/g;
    $res =~ s/ß/ss/g;

    $res =~ s/é/e/g;
    $res =~ s/ñ/n/g;
    $res =~ s/å/ae/g;

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

sub conv_fields_to_shopify($$)
{
    my ( $fields_ref, $vendor_id ) = @_;

    my @fields = @{ $fields_ref };

    my $num_fields = scalar @fields;

    #print "DEBUG: fields=$num_fields\n";

    my $handle = create_handle_from_title( $fields[1] );

    my $title  = $fields[1];

    my $price  = parse_price( $fields[3] );

    my $pic  = parse_pic( $fields[7] );

    #my $handle = '';
    #my $title = '';
    my $body_html = '';
    my $vendor_min_2_characters = $vendor_id;
    my $type = $fields[0];
    my $tags = '';
    my $published = 'TRUE';
    my $option1_name = '';
    my $option1_value = '';
    my $option2_name = '';
    my $option2_value = '';
    my $option3_name = '';
    my $option3_value = '';
    my $variant_sku = '';
    my $variant_grams = '0';
    my $variant_inventory_tracker = '';
    my $variant_inventory_qty = '';
    my $variant_inventory_policy = 'deny';
    my $variant_fulfillment_service = 'manual';
    my $variant_price = $price;
    my $variant_compare_at_price = '';
    my $variant_requires_shipping = '';
    my $variant_taxable = '';
    my $variant_barcode = '';
    my $image_src = $pic;
    my $image_position = '';
    my $image_alt_text = '';
    my $gift_card = 'FALSE';
    my $seo_title = '';
    my $seo_description = '';
    my $google_shopping_metafields = '';
    my $variant_image = '';
    my $variant_weight_unit = '';
    my $variant_tax_code_shopify_plus = '';
    my $cost_per_item = $price;
    my $status = 'active';

    #print $handle, ",", $title, ",", $price,",", $pic, "\n";

    # Shopify fields
    # https://help.shopify.com/en/manual/products/import-export/using-csv#product-csv-file-format

    print
    $handle, ",",
    $title, ",",
    $body_html, ",",
    $vendor_min_2_characters, ",",
    $type, ",",
    $tags, ",",
    $published, ",",
    $option1_name, ",",
    $option1_value, ",",
    $option2_name, ",",
    $option2_value, ",",
    $option3_name, ",",
    $option3_value, ",",
    $variant_sku, ",",
    $variant_grams, ",",
    $variant_inventory_tracker, ",",
    $variant_inventory_qty, ",",
    $variant_inventory_policy, ",",
    $variant_fulfillment_service, ",",
    $variant_price, ",",
    $variant_compare_at_price, ",",
    $variant_requires_shipping, ",",
    $variant_taxable, ",",
    $variant_barcode, ",",
    $image_src, ",",
    $image_position, ",",
    $image_alt_text, ",",
    $gift_card, ",",
    $seo_title, ",",
    $seo_description, ",",
    $google_shopping_metafields, ",",
    $variant_image, ",",
    $variant_weight_unit, ",",
    $variant_tax_code_shopify_plus, ",",
    $cost_per_item, ",",
    $status,
    "\n";
}

my $csv = Text::CSV->new ({
  binary    => 1,
  auto_diag => 1,
  sep_char  => ';'
});

print "Handle,Title,Body (HTML),Vendor,Type,Tags,Published,Option1 Name,Option1 Value,Option2 Name,Option2 Value,Option3 Name,Option3 Value,Variant SKU,Variant Grams,Variant Inventory Tracker,Variant Inventory Qty,Variant Inventory Policy,Variant Fulfillment Service,Variant Price,Variant Compare at Price,Variant Requires Shipping,Variant Taxable,Variant Barcode,Image Src,Image Position,Image Alt Text,Gift Card,SEO Title,SEO Description,Google Shopping metafields,Variant Image,Variant Weight Unit,Variant Tax Code,Cost per item,Status\n";

open(my $data, '<:encoding(utf8)', $file) or die "Could not open '$file' $!\n";

while( my $line = <$data> )
{
    chomp $line;

    if( $csv->parse( $line ) )
    {
        my @fields = $csv->fields();

        conv_fields_to_shopify( \@fields, $vendor_id );
    }
    else
    {
        warn "Line could not be parsed: $line\n";
    }
}

close $data;
