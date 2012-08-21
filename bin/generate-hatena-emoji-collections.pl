use strict;
use warnings;

my $Cols = {};

my $keitai_chars = [map { chr (0xFE000 + hex $_) } qw(

320 321 322 323 324

325 326 327 329 32b

32c 330 331 332 33d

33e 33f 340 349 335

339 33a b0c b0d b0e

b0f 823 b60 813 814

b59 b58 b5c b5d b57

b61 af4 af5 b04 b05

b06 b07 b08 b93 b94

b95 b96 b97 190 191

000 001 002 003 004

005 006 007 008 011

012 013 014 015 01b

01d 02a 02b 02c 02d

02e 02f 030 031 032

033 034 035 036 038

03c 03d 03e 03f 040

04f 050 051 195 19a



1b7 1b8 1b9 1ba 1bc

1bd 1be 1bf 553 4b0

4b2 4b3 4b4 4b5 4b6

4b7 4b9 4ba 4c3 4c9

4cd 4ce 4cf 4d0 4d1

4d6 4dc 4dd 4e2 4ef

4f0 4f1 4f2 4f3 50f

510 511 512 522 523

525 526 527 528 529

52b 536 537 538 539

53a 53e 546 7d0 7d1

7d2 7d3 7d4 7d5 7d6

7d7 7d8 7d9 7df 7e0

7e2 7e4 7e5 7e6 7e8

7e9 7ea 7eb 7f5 7f6

7f7 7fa 7fc 800 801

803 804 805 806 807

808 80a 81c 81d 824



825 960 961 962 963

964 980 981 982 983

984 985 986 b1a b1b

b1c b1d b1e b1f b20

506 b55 b56 b23

b22 b85 b82 b27 b28

b21 b36 b30 b2b b48

b2f b31 b81 82b b84

b29 b2d b2a b2c b83

af0 af1 af2 af3 af6

af7 82e 82f 830 831

832 833 834 835 836

837 82c e10 e11 e12

e13 e14 e15 82d 018

019 01a

)];

for my $i (1..(@$keitai_chars / 90 + 1)) {
    $Cols->{"hatena_keitai_$i"} = [grep {defined} @$keitai_chars[(90 * ($i - 1))..(90 * $i - 1)]];
    push @{$Cols->{"hatena_keitai"} ||= []}, @{$Cols->{"hatena_keitai_$i"}};
}

$Cols->{"hatena_ds"} = [map { chr(0xE000 + hex $_) } qw(008 009 00a 00b 00c 00d 00e 00f 012 013 007 000 001 002 003 004 005 006 015 016 017 018 010 011 019 01a 01b 01c 028)];
push @{$Cols->{"hatena_ds"}}, "\x{FA700}";

use JSON::Functions::XS qw(perl2json_bytes_for_record);
print perl2json_bytes_for_record $Cols;
