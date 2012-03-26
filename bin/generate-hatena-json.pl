#!/usr/bin/perl
use strict;
use warnings;
use Path::Class;
use lib glob file(__FILE__)->dir->parent->subdir('modules', '*', 'lib')->stringify;
use JSON::Functions::XS qw(perl2json_bytes_for_record);
use Char::Prop::Unicode::Age;
use XML::DOM;

my $tables_d = file(__FILE__)->dir->parent->subdir('tables');

my $input_xml_f = $tables_d->file('emoji4unicode.xml');
my $input_hatena_1_f = $tables_d->file('hatena-00e000.txt');
my $input_hatena_2_f = $tables_d->file('hatena-0fa700.txt');
my $input_imode_f = $tables_d->file('imode_emoji.txt');
my $input_mixi_f = $tables_d->file('mixi-emoji_list.txt');
my $names_list_f = $tables_d->file('NamesList.txt');
my $images_d = $tables_d->parent->subdir('images');
my $output_f = $tables_d->file('hatena.json');

BEGIN { require (file(__FILE__)->dir->parent->subdir('lib')->file('charnames.pl')->stringify) }

my $CodeToName = {};

{
    for ($names_list_f->slurp) {
        if (/^([0-9A-F]+)\s+(.+)/) {
            $CodeToName->{hex $1} = $2;
        }
    }
}

sub with_dom (&$) {
    my $code = shift;
    my $f = shift;
    my $parser = new XML::DOM::Parser;
    my $doc = $parser->parsefile($f->stringify);
    $code->($doc);
    $doc->dispose;
}

sub parse_emoji4unicode_code ($$) {
    my ($s, $name) = @_;
    return undef unless defined $s;
    if ($s =~ /^([0-9A-Fa-f]{4,6})$/) {
        return hex $1;
    } elsif ($s =~ /^>([0-9A-Fa-f]{4,6})$/) {
        return \ hex $1;
    } elsif ($s =~ /^\+([0-9A-Fa-f]{4,6})$/) {
        my $code = hex $1;
        if ($CodeToName->{$code} and $CodeToName->{$code} eq $name) {
            return $code;
        } else {
            return undef;
        }
    } elsif ($s =~ /^([0-9A-Fa-f]{4,6})\+([0-9A-Fa-f]{4,6})$/) {
        return [hex $1, hex $2];
    } else {
        return undef;
    }
}

sub format_unicode ($) {
    my $s = shift;
    return '' unless defined $s;
    return sprintf '%06X', $s;
}

sub format_url ($) {
    my $s = shift;
    return '' unless defined $s;
    return $s;
}

sub ifne ($$) {
    my ($v, $c) = @_;
    return undef unless defined $v;
    return $v if $v != $c;
    return undef;
}

sub parse_uplus_code ($) {
    my $s = shift;
    if ($s =~ /^U\+([0-9A-Fa-f]{4,6})$/) {
        return hex $1;
    } else {
        return undef;
    }
}

sub parse_eminus_code ($) {
    my $s = shift;
    if ($s =~ /^e-([0-9A-Fa-f]{3})$/) {
        my $c = hex $1;
        return (0xFE000 + $c, uc $1)
    } else {
        return ();
    }
}

sub is_private ($) {
    return 0 unless $_[0];
    return 0 if $_[0] < 0xE000;
    return 1 if $_[0] < 0xF900;
    return 0 if $_[0] < 0xEFFFF;
    return 1 if $_[0] < 0x110000;
    return 0;
}

my $chars = {};

my $additional_unicode = {
    
};

my $DocomoUnicodeToEmojiID = {};

with_dom {
    my $doc = shift;
    my $es = $doc->getElementsByTagName('e');
    for my $e (@$es) {
        my $eid = $e->getAttribute('id');
        my $name = $e->getAttribute('name');
        
        for my $type (qw/google unicode docomo kddi softbank/) {
            my $code = parse_emoji4unicode_code $e->getAttribute($type), $name;
            next unless defined $code;
            if (ref $code) {
                if (ref $code eq 'ARRAY') {
                    $chars->{$eid}->{"$type\_sequence"} = $code;
                } else {
                    $chars->{$eid}->{"$type\_fallback"} = $$code;
                }
            } else {
                $chars->{$eid}->{$type} = $code;
            }
        }
        
        $DocomoUnicodeToEmojiID->{$chars->{$eid}->{docomo}} = $eid
            if $chars->{$eid}->{docomo};
        $chars->{$eid}->{hatena} = $chars->{$eid}->{google};
        $chars->{$eid}->{google_eid} = $eid;
        $chars->{$eid}->{has_image}->{colored_16x16_gif} = 1
            if -f $images_d->file('0FE000', 'e-' . $eid . '.gif');
        
        if (not defined $chars->{$eid}->{hatena} and defined $eid) {
            $chars->{$eid}->{hatena} = 0xFE000 + hex $eid;
        }

        my $text = $e->getAttribute('text_fallback') || $name || '';
        $text =~ s/^\[//;
        $text =~ s/\]$//;
        $chars->{$eid}->{text} = $text;
    }
} $input_xml_f;


{
    my $hatena_1_file = $input_hatena_1_f->openr;
    while (<$hatena_1_file>) {
        next if /^\s*\x23/;
        next if /^\s*$/;
        chomp;
        my ($hatena, $uni, $uni_f, $google, $name) = split /\t/, $_;
        $hatena = parse_uplus_code $hatena;
        $uni = parse_uplus_code $uni;
        $uni_f = parse_uplus_code $uni_f;
        my $google_eid;
        ($google, $google_eid) = parse_eminus_code $google;
        my $eid = sprintf 'n%02X', $hatena - 0xE000;
        my $hatena_eid = $eid;
        if (defined $google_eid) {
            $eid = $google_eid;
        }
        $chars->{$eid}->{hatena_00e000} = $hatena;
        $chars->{$eid}->{unicode} = $uni if defined $uni;
        $chars->{$eid}->{unicode_fallback} = $uni_f if defined $uni_f;
        $chars->{$eid}->{google} = $google if defined $google;
        $chars->{$eid}->{hatena} = $hatena if $eid eq $hatena_eid;
        $chars->{$eid}->{hatena_00e000_eid} = $hatena_eid;
        $name =~ s/\# //;
        $chars->{$eid}->{text} ||= $name;
    }
}

{
    my $hatena_2_file = $input_hatena_2_f->openr;
    while (<$hatena_2_file>) {
        next if /^\s*\x23/;
        next if /^\s*$/;
        chomp;
        my ($code, $uni_f, $img, $name) = split /\t/, $_;
        $code = parse_uplus_code $code;
        $uni_f = parse_uplus_code $uni_f;
        my $eid = sprintf 'h%02X', $code - 0xFA700;
        $chars->{$eid}->{hatena} = $code;
        $chars->{$eid}->{unicode_fallback} = $uni_f if defined $uni_f;
        $chars->{$eid}->{image_url} = $img
            || sprintf q<http://www.hatena.ne.jp/images/hatenaemoji/hatenaext/%04X.png>, $code;
        $chars->{$eid}->{has_image}->{black_16x16_png} = 1
            if -f $images_d->file('0FA700', sprintf '%04X.png', $code);
        $chars->{$eid}->{has_image}->{colored_16x16_gif} = 1
            if -f $images_d->file('0FA700', sprintf '%04X-c.gif', $code);
        $name =~ s/\# //;
        $chars->{$eid}->{text} ||= $name;
    }
}

{
    my $DocomoNumberToEmojiID = {};
    for (split /[\x0D\x0A]+/, scalar $input_imode_f->slurp) {
        my ($no, undef, undef, $ucode) = split /\s+/, $_;
        
        next unless $no =~ /^\[(\d+)\]$/;
        $no = 0+$1;
        
        next unless $ucode =~ /^U([0-9A-F]+)$/;
        $ucode = hex $1;
        
        my $eid = $DocomoUnicodeToEmojiID->{$ucode}
            or warn sprintf "Emoji ID not defined for docomo U+%04X (#%d)",
                $ucode, $no;
        $DocomoNumberToEmojiID->{$no} = $eid;
    }

    for (split /[\x0D\x0A]+/, scalar $input_mixi_f->slurp) {
        my @code = split /\s+/, $_;
        my $docomo_number = [map { /^\[i:([0-9]+)\]$/ ? $1 : () } grep { /\[i:/ } @code]->[0];
        warn "Docomo number not specified for mixi @code"
            unless $docomo_number;

        # Extended emojis
        $docomo_number += 1001 - 206 if $docomo_number > 206;
        
        my $eid = $DocomoNumberToEmojiID->{$docomo_number}
            or warn sprintf "Emoji ID not defined for docomo #%d",
                $docomo_number;
        push @{$chars->{$eid}->{mixi} ||= []}, @code;
    }        
}

$chars->{BA3}->{hatena} = 0xFEBA3; # e-BA3 is unified with e-B67 by Google.

my %data;
for my $id (keys %$chars) {
    my $char = $chars->{$id};

    my @code = ({unicode => $char->{hatena}, emoji_id => $id});
    for my $key (qw/unicode google hatena_00e000/) {
        if (defined $char->{$key} and $char->{$key} != $char->{hatena}) {
            my $emoji_id = $id;
            if (defined $char->{"$key\_eid"}) {
                $emoji_id = $char->{"$key\_eid"};
            }
            push @code, {unicode => $char->{$key}, emoji_id => $emoji_id};
        }
    }
    
    for my $code (@code) {
        my $v = format_unicode $code->{unicode};
        my $c = {
            emoji_id => $code->{emoji_id},
            charname => charname $char->{unicode},

            unicode => format_unicode $char->{unicode},
            unicode_age => is_private $code->{unicode}
                ? undef : unicode_age_n $code->{unicode},
            unicode_fallback => format_unicode $char->{unicode_fallback},
            unicode_sequence => $char->{unicode_sequence}
                ? [map { format_unicode $_ } @{$char->{unicode_sequence}}] : undef,
            docomo => format_unicode $char->{docomo},
            docomo_fallback => format_unicode $char->{docomo_fallback},
            kddi => format_unicode $char->{kddi},
            kddi_fallback => format_unicode $char->{kddi_fallback},
            softbank => format_unicode $char->{softbank},
            softbank_fallback => format_unicode $char->{softbank_fallback},
            google => format_unicode $char->{google},
            hatena => format_unicode $char->{hatena},
            hatena_00e000 => format_unicode $char->{hatena_00e000},
            mixi => $char->{mixi},
            has_image => $char->{has_image},
            image_url => format_url $char->{image_url},
            text => $char->{text},
        };
        for (keys %$c) {
            delete $c->{$_} if not defined $c->{$_} or not length $c->{$_};
        }
        $data{$v} = $c;
    }
}

{
    my $output_file = $output_f->openw;
    print $output_file perl2json_bytes_for_record \%data;
}
