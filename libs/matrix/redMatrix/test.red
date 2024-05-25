#!/usr/local/bin/red
Red [
]

;unsigned char (ou uchar)	8 bits	1	0..255	
;signed char (ou schar)	8 bits	1	-127..128	
;unsigned short (ou ushort)	16 bits	2	0.. 65535	
;signed short (ou short)	16 bits	2	-32767..32768	
;float	32 bits	4	0.0..1.0
;double	64 bits	8	0.0..1.0

;for 8 bits : value and FFh << 24 >> 24



random/seed 0 bi: copy [] loop 10 [append bi random 255] bi
probe bi


mc: make vector! reduce  ['char! 8 0];'
foreach i bi [append mc to-char i]
probe mc

foreach value mc [
	if value < 0 [value: value and 7Fh + 80h]
	print to-integer value]


mi: make vector! compose/only [integer! 8 (bi)]
i: 1
foreach value mi [
	if value < 0 [value: value and 7Fh + 80h]
	print value
	mi/:i: value
	i: i + 1
]

probe mi
mi: make vector! compose/only [integer! 16 (bi)]
probe mi
