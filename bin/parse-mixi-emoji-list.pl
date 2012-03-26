#!/usr/bin/perl
use strict;
use warnings;

my $html = do {
    local $/ = undef;
    <>;
};

while ($html =~ m{
    <td>
      \s*
      (\[.+?)
    </td>
}gxs) {
    my $codes = $1;
    $codes =~ s{\s*<br\s*/?>\s*}{ }g;
    $codes =~ s{\]\[}{] [}g;
    print join ' ', grep { not /:-\]$/ } split /\s+/, $codes;
    print "\n";
}
