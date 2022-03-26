-module(koatuu_abc).
-export([cyr_lat/1, id/1, padId/1]).

id(Name) -> list_to_binary(string:pad(cyr_lat(string:uppercase(Name)), 50, trailing)).
padId(Name) -> list_to_binary(string:pad(Name, 50, trailing)).

cyr_lat(<<Symbol/utf8, Tail/binary>>) -> iolist_to_binary([convert(Symbol), cyr_lat(Tail)]);
cyr_lat(<<Symbol/utf8>>) -> convert(Symbol);
cyr_lat(_) -> <<>>.

convert($А) -> $A;
convert($Б) -> $B;
convert($В) -> <<$B, $b>>;
convert($Г) -> $C;
convert($Ґ) -> <<$C, $g>>;
convert($Д) -> $D;
convert($Е) -> $E;
convert($Є) -> $F;
convert($Ж) -> $G;
convert($З) -> $H;
convert($И) -> $I;
convert($І) -> <<$I, $a>>;
convert($Ї) -> <<$I, $b>>;
convert($Й) -> $J;
convert($К) -> $K;
convert($Л) -> $L;
convert($М) -> $M;
convert($Н) -> $N;
convert($О) -> $O;
convert($П) -> $P;
convert($Р) -> $R;
convert($С) -> $S;
convert($Т) -> $T;
convert($У) -> $U;
convert($Ф) -> $V;
convert($Х) -> $W;
convert($Ц) -> $X;
convert($Ч) -> $Y;
convert($Ш) -> $Z;
convert($Щ) -> <<$Z, $a>>;
convert($Ь) -> <<$Z, $b>>;
convert($Ю) -> <<$Z, $c>>;
convert($Я) -> <<$Z, $d>>;
convert(39) -> $z;
convert(AsIs) when AsIs < 128 -> AsIs;
convert(_) -> <<>>.
