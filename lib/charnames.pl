use strict;
use warnings;

{
my @name = split /\n/, require 'unicore/Name.pl';
my %name;
for (@name) {
if (/^(....)\s+([^\t]+)/) {
  $name{hex $1} = $2;
}
}
sub charname ($) {
  my $U = shift;
  return '' unless defined $U;
  if ($U =~ /[^0-9]/) {
    $U =~ s/^[Uu]\+|^0[Xx]//;
    $U = hex $U;
  }
  ## TODO: be more strict!
  $U < 0x0020 ? '<control>' :
  $U < 0x007F ? $name{$U} :
  $U < 0x00A0 ? '<control>' :
  $name{$U} ? $name{$U} :
  $U < 0x00A0 ? '<control>' :
  $U < 0x3400 ? '' :
  $U < 0xA000 ? '<cjk>' :
  $U < 0xE000 ? '<hangul>' :
  $U < 0xF900 ? '<private>' :
  $U < 0xEFFFF ? '' :
  $U < 0x110000 ? '<private>' :
  '';
}
}

1;
