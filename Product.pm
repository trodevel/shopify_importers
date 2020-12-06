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

sub new
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

############################################################

