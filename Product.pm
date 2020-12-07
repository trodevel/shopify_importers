#!/usr/bin/perl -w

# Product
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

package Product;

use strict;
use warnings;

sub new($$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$)
{
    my $class = shift;
    my $self =
    {
        handle          => shift,
        title           => shift,
        body_html       => shift,
        vendor_min_2_characters      => shift,
        type            => shift,
        tags            => shift,
        published       => shift,
        option1_name    => shift,
        option1_value   => shift,
        option2_name    => shift,
        option2_value   => shift,
        option3_name    => shift,
        option3_value   => shift,
        variant_sku     => shift,
        variant_grams   => shift,
        variant_inventory_tracker   => shift,
        variant_inventory_qty       => shift,
        variant_inventory_policy    => shift,
        variant_fulfillment_service => shift,
        variant_price   => shift,
        variant_compare_at_price    => shift,
        variant_requires_shipping   => shift,
        variant_taxable     => shift,
        variant_barcode     => shift,
        image_src           => shift,
        image_position      => shift,
        image_alt_text      => shift,
        gift_card           => shift,
        seo_title           => shift,
        seo_description     => shift,
        google_shopping_metafields  => shift,
        variant_image               => shift,
        variant_weight_unit         => shift,
        variant_tax_code_shopify_plus      => shift,
        cost_per_item       => shift,
        status              => shift,
    };

    bless $self, $class;
    return $self;
}

sub create_from_array($)
{
    my ( $class, $args_ref ) = @_;

    die "class method invoked on object" if ref $class;

    my @args = @{ $args_ref };

    die "wrong number of arguments" if ( scalar @args != 36 );

    return new(
        $args[0],
        $args[1],
        $args[2],
        $args[3],
        $args[4],
        $args[5],
        $args[6],
        $args[7],
        $args[8],
        $args[9],
        $args[0],
        $args[11],
        $args[12],
        $args[13],
        $args[14],
        $args[15],
        $args[16],
        $args[17],
        $args[18],
        $args[19],
        $args[20],
        $args[21],
        $args[22],
        $args[23],
        $args[24],
        $args[25],
        $args[26],
        $args[27],
        $args[28],
        $args[29],
        $args[30],
        $args[31],
        $args[32],
        $args[33],
        $args[34],
        $args[35] );

    # your code
}

sub to_csv()
{
    my ( $self ) = @_;

    my $res = $self->{handle} . "," .
    $self->{title} . "," .
    $self->{body_html} . "," .
    $self->{vendor_min_2_characters} . "," .
    $self->{type} . "," .
    $self->{tags} . "," .
    $self->{published} . "," .
    $self->{option1_name} . "," .
    $self->{option1_value} . "," .
    $self->{option2_name} . "," .
    $self->{option2_value} . "," .
    $self->{option3_name} . "," .
    $self->{option3_value} . "," .
    $self->{variant_sku} . "," .
    $self->{variant_grams} . "," .
    $self->{variant_inventory_tracker} . "," .
    $self->{variant_inventory_qty} . "," .
    $self->{variant_inventory_policy} . "," .
    $self->{variant_fulfillment_service} . "," .
    $self->{variant_price} . "," .
    $self->{variant_compare_at_price} . "," .
    $self->{variant_requires_shipping} . "," .
    $self->{variant_taxable} . "," .
    $self->{variant_barcode} . "," .
    $self->{image_src} . "," .
    $self->{image_position} . "," .
    $self->{image_alt_text} . "," .
    $self->{gift_card} . "," .
    $self->{seo_title} . "," .
    $self->{seo_description} . "," .
    $self->{google_shopping_metafields} . "," .
    $self->{variant_image} . "," .
    $self->{variant_weight_unit} . "," .
    $self->{variant_tax_code_shopify_plus} . "," .
    $self->{cost_per_item} . "," .
    $self->{status};

    return $res;
}

sub merge($)
{
    my ( $self, $obj_ref ) = @_;

    die "mismatching handle" if ( $self->{handle} ne $obj_ref->{handle} );

    $self->{title} = $obj_ref->{title};
    $self->{body_html} = $obj_ref->{body_html};
    $self->{vendor_min_2_characters} = $obj_ref->{vendor_min_2_characters};
    $self->{type} = $obj_ref->{type};
    $self->{tags} = $obj_ref->{tags};
    $self->{published} = $obj_ref->{published};
    $self->{option1_name} = $obj_ref->{option1_name};
    $self->{option1_value} = $obj_ref->{option1_value};
    $self->{option2_name} = $obj_ref->{option2_name};
    $self->{option2_value} = $obj_ref->{option2_value};
    $self->{option3_name} = $obj_ref->{option3_name};
    $self->{option3_value} = $obj_ref->{option3_value};
    $self->{variant_sku} = $obj_ref->{variant_sku};
    $self->{variant_grams} = $obj_ref->{variant_grams};
    $self->{variant_inventory_tracker} = $obj_ref->{variant_inventory_tracker};
    $self->{variant_inventory_qty} = $obj_ref->{variant_inventory_qty};
    $self->{variant_inventory_policy} = $obj_ref->{variant_inventory_policy};
    $self->{variant_fulfillment_service} = $obj_ref->{variant_fulfillment_service};
    $self->{variant_price} = $obj_ref->{variant_price};
    $self->{variant_compare_at_price} = $obj_ref->{variant_compare_at_price};
    $self->{variant_requires_shipping} = $obj_ref->{variant_requires_shipping};
    $self->{variant_taxable} = $obj_ref->{variant_taxable};
    $self->{variant_barcode} = $obj_ref->{variant_barcode};
    $self->{image_src} = $obj_ref->{image_src};
    $self->{image_position} = $obj_ref->{image_position};
    $self->{image_alt_text} = $obj_ref->{image_alt_text};
    $self->{gift_card} = $obj_ref->{gift_card};
    $self->{seo_title} = $obj_ref->{seo_title};
    $self->{seo_description} = $obj_ref->{seo_description};
    $self->{google_shopping_metafields} = $obj_ref->{google_shopping_metafields};
    $self->{variant_image} = $obj_ref->{variant_image};
    $self->{variant_weight_unit} = $obj_ref->{variant_weight_unit};
    $self->{variant_tax_code_shopify_plus} = $obj_ref->{variant_tax_code_shopify_plus};
    $self->{cost_per_item} = $obj_ref->{cost_per_item};
    $self->{status} = $obj_ref->{status};

    return $res;
}

############################################################

1;
