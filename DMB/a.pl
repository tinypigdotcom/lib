#!/usr/bin/perl

use strict;
use warnings;

use DMB::Hash;
use Data::Dumper;

my @fruit_list;
init_fruit_list();

my $MAX=4;

my %hash1 = ();
my %hash2 = ();

for my $ii ([\%hash1], [\%hash1,\%hash2], [\%hash2]) {
    populate(@$ii);
}

print key_diff_detail( \%hash1, \%hash2 );

sub ir {
    return int(rand(shift));
}

sub populate {
    my (@hashrefs) = @_;

    for my $jj ( 0 .. ir( $MAX ) ) {
        my $ii = $fruit_list[ ir($#fruit_list) ];
        for my $hh (@hashrefs) {
            $hh->{$ii}++;
        }
    }
}

sub init_fruit_list {
    @fruit_list = qw(
      apple
      apricot
      avocado
      banana
      bartlett_pear
      bell_pepper
      bilberry
      blackberry
      blackcap
      blackcurrant
      blood_orange
      blueberry
      boysenberry
      breadfruit
      cantaloupe
      cantaloupe
      cherimoya
      cherry
      chili_pepper
      clementine
      cloudberry
      coconut
      cranberry
      cucumber
      currant
      damson
      date
      dragonfruit
      dried_plum
      durian
      eggplant
      elderberry
      feijoa
      fig
      goji_berry
      gooseberry
      grape
      grapefruit
      guava
      honeydew
      honeydew
      huckleberry
      jackfruit
      jambul
      jujube
      kiwi_fruit
      kumquat
      lemon
      lime
      loquat
      lychee
      mandarine
      mango
      melon
      miracle_fruit
      mulberry
      nectarine
      nut
      olive
      orange
      papaya
      passionfruit
      peach
      pear
      pepper
      persimmon
      physalis
      pineapple
      plum
      pomegranate
      pomelo
      prune
      purple_mangosteen
      quince
      raisin
      rambutan
      raspberry
      redcurrant
      rock_melon
      salal_berry
      satsuma
      star_fruit
      strawberry
      tamarillo
      tangerine
      ugli_fruit
      watermelon
      watermelon
      western_raspberry
      williams_pear
    );
}

