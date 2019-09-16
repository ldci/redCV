Red [
	Title:   "Red Computer Vision: ZLib functions"
	Author:  "Francois Jouen"
	File: 	 %rcvZLib.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

#system [
	#include %zlib.reds ; for ZLib compression
	; Thanks to Bruno Anselme
]

; ZLib routines for binary values

_compressRGB: routine [rgb [binary!] level [integer!] return: [binary!]
	/local 
	byte-count
	data
	buffer 
	] [
	byte-count: 0
	data: binary/rs-head as red-binary! rgb
	buffer: zlib/compress data binary/rs-length? rgb :byte-count level
	as red-binary! stack/set-last as red-value! binary/load buffer byte-count
]


_decompressRGB: routine [rgb [binary!] bCount [integer!] return: [binary!]
	/local 
	data
	buffer 
	] [
	data: binary/rs-head as red-binary! rgb
	buffer: zlib/decompress data bCount
	as red-binary! stack/set-last as red-value! binary/load buffer bCount
]


; exported functions

rcvCompressRGB: function [
"Compresses rgb image values"
	rgb 	[binary!] 
	level 	[integer!]
][
	_compressRGB rgb level
]

rcvDecompressRGB: function [
"Uncompresses rgb image values"
	rgb 	[binary!] 
	bCount 	[integer!] 
][
	_decompressRGB rgb bcount
]