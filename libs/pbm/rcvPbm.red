Red [
	Title:   "Red Computer Vision: PBM functions "
	Author:  "Francois Jouen"
	File: 	 %pbm.red
	Tabs:	 4
	Rights:  "Copyright (C) 2020 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

{
P1: Portable Bit Map ASCII 		0–1 (white & black)						;pbm
P2: Portable Gray Map ASCII 	0–255 (gray scale), 0–65535 (gray scale);pgm	
P5: Portable Gray Map Byte		0–255 (gray scale), 0–65535 (gray scale);pgm
P3: Portable Pixel Map ASCII 	16777216 (0–255 for each RGB channel)   ;ppm
P6: Portable Pixel Map Byte 	16777216 (0–255 for each RGB channel)	;ppm
for P1, P2 and P3 color maximal value is > 0 and < 65535 
}

MAGIC_P1:	#{5031}; "P1"
MAGIC_P2:	#{5032}; "P2"  
MAGIC_P3:	#{5033}; "P3" 
MAGIC_P5:	#{5035}; "P5" 
MAGIC_P6:	#{5036}; "P6"

comment: "# CREATOR: redCV Library"

rcvGetMagicNumberPBM: function [
"Return PBM file magic number"
	fName 	[file!]
	return: [binary!]
][
	read/binary/part fName 2
]

rcvReadPBMAsciiFile: func [
"Read Ascii PBM and PGM Files"
	fName 	[file!]
	magic	[binary!]
	return: [image!]
][	iter: 0 colorMax: 	0.0
	case [
		magic = MAGIC_P1 [iter: 3]
		magic = MAGIC_P2 [iter: 3]
		magic = MAGIC_P3 [iter: 1]
	]
	img: read/lines fName
	i: 2
	; process comments
	imgComment: copy ""
	until [
		c: to-string first img/:i
		append imgComment img/:i
		i: i + 1
		c <> "#" 
	]
	i: i - 1
	str: split img/:i " " 
	w: to-integer first str
	h: to-integer second str
	if any [magic = MAGIC_P2 magic = MAGIC_P3][
		i: i + 1
		colorMax: to-float img/:i
	]
	i: i + 1; header Length
	n: (length? img) 
	bin: copy #{}
	while [i <= n ] [
		str: split img/:i " " 
		foreach v str [
			unless empty? v [
				int: to-integer v 
				if magic =  MAGIC_P1 [int: int * 255]
				if magic <> MAGIC_P1 [
					f: (int / colorMax)  * 255.0
					int: to-integer f
				]
				append/dup bin int iter ; to Red image
			]
		]
		i: i + 1
	]
	make image! reduce [as-pair w h bin]
]


rcvWritePBMAsciiFile: func [
"Write ASCII pbm file"
	fName 		[file!]
	magic		[binary!]
	src			[image!]
	colorMax	[integer!]
][
	if any [magic = MAGIC_P1 magic = MAGIC_P2 magic = MAGIC_P3][
		w: src/size/x
		h: src/size/y
		data: src/rgb
		blk: copy []
		append blk rejoin [to-string magic newline]
		append blk rejoin [comment newline]
		append blk rejoin [w " " h newline]
		unless magic = MAGIC_P1 [append blk rejoin [form colorMax newline]]
		y: 0
		while [y < h] [
			x: 0
			line: copy []
			while [x < w][
				idx: (y * w) + x + 1 
				tp: src/:idx
				rgbf: (0.2989 * tp/1) + (0.587 * tp/2) + (0.114 * tp/3) 
        		rgb: (to-integer rgbf) >> 0
				case [
					magic = MAGIC_P1 [tp: tp / 255 append line  tp/1]
					magic = MAGIC_P2 [append line rgb]
					magic = MAGIC_P3 [append append append line tp/1 tp/2 tp/3]
				]
				x: x + 1
			]
			append blk rejoin [line newline]
			y: y + 1
		]
		write fName form blk
	]
]

rcvWritePBMByteFile: func [
"Write binary pbm file"
	fName 		[file!]
	magic		[binary!]
	src			[image!]
	colorMax	[integer!]
][
	if any [magic = MAGIC_P5 magic = MAGIC_P6 ][
		w: src/size/x
		h: src/size/y
		str: #{}
		append append str magic lf
		append append str  comment lf
		append append str to-string w space
		append append str to-string h lf 
		append append str to-string colorMax lf
		y: 0
		while [y < h] [
			x: 0
			while [x < w][
				idx: (y * w) + x + 1
				tp: src/:idx
				rgbf: (0.2989 * tp/1) + (0.587 * tp/2) + (0.114 * tp/3) 
        		rgb: (to-integer rgbf) >> 0
				case [
					;magic = MAGIC_P5 [append str ((tp/1 + tp/2 + tp/3) / 3)]
					magic = MAGIC_P5 [append str rgb]
					magic = MAGIC_P6 [append append append str tp/1 tp/2 tp/3]
				]
				x: x + 1
			]
			y: y + 1
		]
		write fName str
	]
]

rcvReadPBMByteFile: func [
"Read byte PPM Files"
	fName 	[file!]
	magic	[binary!]
	return: [image!]
][
	
	img: read/binary fName
	tmp: copy/part skip img 0 2 ; magic
	str: copy ""
	i: 3	;next line
	nlc: 0	; comment line?
	; if no comment get directly image size
	until [
		tmp: copy/part skip img i 1
		if tmp = #{23} [nlc: nlc + 1] ; yes comment included
		append str to-string tmp 
		i: i + 1
		tmp = #{0A}
	]
	; if comment get now image size
	if nlc > 0 [
		until [
			tmp: copy/part skip img i 1
			append str to-string tmp 
			i: i + 1
			tmp = #{0A}
		]
	]
	;get maxcolor
	loop 3 [
		tmp: copy/part skip img i 1
		append str to-string tmp 
		i: i + 1
	]
	headerLength: i + 1
	sp: split str "^/" ;to-string #{0A}
	n: length? sp
	i: 0
	colorMax: to-float sp/(n - i)
	i: i + 1
	imgSize: sp/(n - i)
	i: i + 1
	imgComment: copy ""
	while [i < n] [
		append imgComment sp/(n - i)
		i: i + 1
	]
	if empty? imgComment [imgComment: "Non documented"]
	w: to-integer first split imgSize " "
	h: to-integer second split imgSize " "
	head img
	img: skip img headerLength
	if magic = MAGIC_P5 [
		bin: copy #{}
		foreach v img [append/dup bin v 3] ; to Red image 
	]
	if magic = MAGIC_P6 [
		bin: copy img
	]
	make image! reduce [as-pair w h bin]
]
