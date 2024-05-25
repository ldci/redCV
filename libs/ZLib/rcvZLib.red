Red [
	Title:   "Red Computer Vision: ZLib"
	Author:  "Francois Jouen"
	File: 	 %rcvZLib.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

#system-global [
	#include %zlib.reds ; for ZLib compression
	; Thanks to Bruno Anselme
]

; ZLib routines for binary values such as images

rcvCompressRGB: routine [rgb [binary!] level [integer!] return: [binary!]
	/local 
	byte-count	[integer!]
	data		[byte-ptr!]
	buffer		[byte-ptr!] 		
][
	byte-count: 0 ;--for integer pointer that returns output buffer size
	data: binary/rs-head as red-binary! rgb
	buffer: zlib/compress data binary/rs-length? rgb :byte-count level
	as red-binary! stack/set-last as red-value! binary/load buffer byte-count	
]


rcvDecompressRGB: routine [rgb [binary!] bCount [integer!] return: [binary!]
	/local 
	data		[byte-ptr!]
	buffer		[byte-ptr!] 
][
	data: binary/rs-head as red-binary! rgb
	buffer: zlib/decompress data bCount
	as red-binary! stack/set-last as red-value! binary/load buffer bCount
]
