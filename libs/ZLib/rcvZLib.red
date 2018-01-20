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

compressRGB: routine [rgb [binary!] level [integer!] return: [binary!]
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


decompressRGB: routine [rgb [binary!] bCount [integer!] return: [binary!]
	/local 
	data
	buffer 
	] [
	data: binary/rs-head as red-binary! rgb
	buffer: zlib/decompress data bCount
	as red-binary! stack/set-last as red-value! binary/load buffer bCount
]


; exported functions

rcvCompressRGB: function [rgb [binary!] level [integer!] return: [binary!]
"Compresses rgb image values"
][
	compressRGB rgb level
]

rcvDecompressRGB: function [rgb [binary!] bCount [integer!] return: [binary!]
"Uncompresses rgb image values"
][
	decompressRGB rgb bcount
]