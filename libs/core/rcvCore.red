Red [
	Title:   "Red Computer Vision: Core functions"
	Author:  "Francois Jouen"
	File: 	 %rcvCore.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


{To know: loaded images by red are in ARGB format (a tuple )
Images are 8-bit [0..255] by channel and internally use bytes as a binary string
Actually Red can't create 1 2 or 3 channels images : only 4 channels
Actually Red can't create 16-bit (0..65536) 32-bit or 64-bit (0.0..1.0) images
pixel >>> 24				: Alpha
pixel and FF0000h >> 16 	: Red
pixel and FF00h >> 8		: Green
pixel and FFh				: Blue
}


;********* Red System Colors **********
;based on Vladimir Vasilyev's idea
rcvGetSystemColors: function [
"Get system colors"
	return: 	[block!]
][
	sColors: collect [
		foreach word words-of system/words [
			if tuple? get/any word [keep word] ;--use get/any for unset words
		]
	]
	exclude sort sColors [transparent glass]
]


; ********* image basics **********

rcvCreateImage: function [
"Create empty (black) image"
	size 	[pair!]  "Image size"
][
	make image! reduce [size black]
]


rcvReleaseImage: routine [
"Delete image from memory"
	src [image!]
][
	image/delete src
]


rcvReleaseAllImages: function [
"Delete all images"
	list [block!] "List of images to delete"
][
	foreach img list [rcvReleaseImage img]
]


rcvLoadImage: function [
"Loads image from file"
	fileName [file!]  
	/grayscale		
][
	src: load fileName
	if grayscale [
		gray: rcvCreateImage src/size
		rcv2Gray/average src gray 
		rcvCopyImage gray src
	]
	src
]

;new
; [bmp png jpeg gif]
rcvLoadImageAs: function [
"Loads image from file and specifies the type of image"
	fileName 	[file!]  
	type		[word!]			
][
	load/as fileName type
]


rcvLoadImageAsBinary: function [
"Load image from file and return image as binary"
	fileName [file!] 
	/alpha			 
][
	tmp: load fileName
	either alpha [str: tmp/argb] [str: tmp/rgb]
	rcvReleaseImage tmp
	str
]

rcvGetImageFileSize: function [
"Gets Image File Size as a pair!"
	fileName 	[file!] 
][
	tmp: load fileName
	isize: tmp/size
	rcvReleaseImage tmp
	isize
]

rcvGetImageSize: function [
"Returns Image Size as a pair!"
	src 	[image!]  
][
	src/size
]



rcvSaveImage: function [
"Save image to file (only png actually)"
	src 		[image!] 
	fileName 	[file!] 
][
	save fileName src
]

;new
; [bmp png jpeg gif]
rcvSaveImageAs: function [
"Save image to file"
	src 		[image!] 
	fileName 	[file!] 
	type		[word!]
][
	save/as fileName src type
]


rcvCopyImage: routine [
"Copy source image to destination image"
    src 	[image!]
    dst  	[image!]
    /local
        pixS [int-ptr!]
        pixD [int-ptr!]
        handleS handleD i n [integer!]
][
    handleS: 0
    handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    i: 0
    while [i < n] [
    	pixD/value: pixS/value
        pixS: pixS + 1
        pixD: pixD + 1
    	i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

rcvCloneImage: function [
"Returns a copy of source image"
	src 	[image!] 
][
	;dst: make image! reduce [src/size black]
	dst: make image! src/size
	rcvCopyImage src dst
	dst
]

rcvRandImage: routine [
	dst			[image!]
	/local
	pixel1 pixel2	[subroutine!]
    pixD 			[int-ptr!]
    handleD i n		[integer!]
    r g b int		[integer!]
][
	handleD: 0
	r: g: b: 0
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(dst/size) * IMAGE_HEIGHT(dst/size)
    ;--subroutines
    pixel1: [r: _random/rand and FFh g: _random/rand and FFh b: _random/rand and FFh]
    pixel2: [(255 << 24) OR (r << 16) OR (g  << 8) OR b] 
    
    i: 0
    while [i < n] [
    	pixel1
      	pixD/value: pixel2
        pixD: pixD + 1
    	i: i + 1
    ]
	image/release-buffer dst handleD yes	
]


rcvRandomImage: function [
"Create a random uniform or pixel random image"
	size 	[pair!] 	
	value 	[tuple!] 	
	return: [image!]
	/uniform /alea /fast 

][
	case [
		uniform [img: make image! reduce [size random value]]
		alea 	[img: make image! reduce [size black] forall img [img/1: random value ]]
		fast 	[img: make image! reduce [size black] rcvRandImage img]
	] 
	img
]

rcvZeroImage: function [src [image!]
"All pixels to 0"
][
	src/argb: black
]

rcvColorImage: function [src [image!] acolor [tuple!]
"All pixels to color"
][
	src/rgb: 	acolor	;--rgb value 
	src/alpha: 	0		;--opaque image
]


;************** Pixel Access Routines **********
rcvGetPixel_old: routine [
"Returns pixel value at xy coordinates as tuple"
	src1 		[image!] 
	coordinate 	[pair!] 
	return: 	[tuple!]
	/local 
		pix1 	[int-ptr!]
		handle1	[integer!] 
		w		[integer!] 
		pos		[integer!] 
		t		[red-tuple!]
][
    handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    pos: (coordinate/y * w) + coordinate/x
   	pix1: pix1 + pos		; for img/node offset
    t: image/rs-pick src1 pos
    image/release-buffer src1 handle1 no
    as red-tuple! stack/set-last as cell! t
]

rcvGetPixel: routine [
"Returns pixel value at xy coordinates as tuple"
	src1 		[image!] 
	coordinate 	[pair!] 
	return: 	[tuple!]
	/local 
		pix1 			[int-ptr!]
		handle1 w pos	[integer!]  
		t				[red-tuple!]
][
    handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    pos: (coordinate/y * w) + coordinate/x
   	pix1: pix1 + pos		; for img/node offset
    t: tuple/rs-make [
			pix1/value and FF0000h >> 16
			pix1/value and FF00h >> 8
			pix1/value and FFh
			255 - (pix1/value >>> 24)
	]
    image/release-buffer src1 handle1 no
    as red-tuple! stack/set-last as cell! t
]

rcvGetPixelAsInteger: routine [
"Returns pixel value at xy coordinates as integer"
	src1 		[image!] 
	coordinate 	[pair!] 
	return: 	[integer!]
	/local 
		pix1 			[int-ptr!]
		handle1 w pos	[integer!] 
		a r g b			[integer!]
][
    handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    pos: (coordinate/y * w) + coordinate/x
    pix1: pix1 + pos
    a: 255 - (pix1/value >>> 24)
    r: pix1/value and FF0000h >> 16
    g: pix1/value and FF00h >> 8
    b: pix1/value and FFh
   	image/release-buffer src1 handle1 no
    (a << 24) OR (r << 16 ) OR (g << 8) OR b
]

rcvSetPixel: routine [
"Set pixel value at xy coordinates"
	src1 		[image!] 
	coordinate 	[pair!] 
	color 		[tuple!]
	/local
		p				[byte-ptr!]
		pix1 			[int-ptr!]
		handle1 w pos 	[integer!] 
		r g b a			[integer!]
		tp				[red-tuple!]
][
	tp: as red-tuple! color
	p: (as byte-ptr! tp) + 4
	r: as-integer p/1
	g: as-integer p/2
	b: as-integer p/3
	a: either TUPLE_SIZE?(tp) > 3 [255 - as-integer p/4][255]
    handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    pos: (coordinate/y * w) + coordinate/x
    pix1: pix1 + pos
    pix1/value: (a << 24) or (r << 16) or (g << 8) or b
    image/release-buffer src1 handle1 yes
]

rcvIsAPixel: routine [
"Returns true if  pixel value is greater than threshold"
	src 		[image!] 
	coordinate 	[pair!] 
	threshold 	[integer!] 
	return: 	[logic!]
	/local 
		v a r g b mean	[integer!]
][
	v: rcvGetPixelAsInteger src coordinate
	a: 255 - (v >>> 24)
    r: v and 00FF0000h >> 16 
    g: v and FF00h >> 8 
    b: v and FFh
    mean: (r + g + b) / 3
    either mean > threshold [true] [false]
]


;************** Pixel Access Functions **********
rcvPickPixel: function [
"Returns pixel value at xy coordinates as tuple"
	src 		[image!] 
	coordinate 	[pair!]  
][
	pick src coordinate
]


rcvPokePixel: function [
"Set pixel value at xy coordinates"
	src 		[image!]  
	coordinate  [pair!]   
	val 		[tuple!]  

] [
	poke src coordinate val
]

;***************** IMAGE CONVERSION ROUTINES *****************
rcvConvert: routine [
"General image conversion routine"
    src [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pixS 			[int-ptr!]
        pixD 			[int-ptr!]
        rf gf bf sf		[float!]
        handleS	handleD	[integer!] 
        n i r g b a		[integer!] 
        s mini maxi		[integer!]
        argb			[subroutine!] 
][
    handleS: 0
    handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    a: r: g: b: s: 0
    rf: gf: bf: sf: 0.0
    ;--subroutine
    argb: [
    	a: pixS/value >>> 24 r: pixS/value and 00FF0000h >> 16 
        g: pixS/value and FF00h >> 8 b: pixS/value and FFh 
        s: ((4899 * r) + (9617 * g) + (1868 * b) + 8192) >>> 14 and FFh
        rf: as float! r gf: as float! g bf: as float! b
    ]
   	i: 0
    mini: maxi: 0
    while [i < n] [
    	argb
        switch op [
        	0 [pixD/value: pixS/value]
        	1 [pixD/value: (a << 24) OR (s << 16 ) OR (s << 8) OR s] ;RGB2Gray average
          111 [ 	r: (r * 21) / 100
              		g: (g * 72) / 100 
              		b: (b * 7) / 100
              		s: r + g + b
                  	pixD/value: (a << 24) OR (s << 16 ) OR (s << 8) OR s] ;RGB2Gray luminosity
          112 [ either r > g [mini: g][mini: r] 
              		  either b > mini [mini: mini][ mini: b] 
              		  either r > g [maxi: r][maxi: g] 
              		  either b > maxi [maxi: b][ maxi: maxi] 
              		  s: (mini + maxi) / 2
              		  pixD/value: (a << 24) OR (s << 16 ) OR (s << 8) OR s] ;RGB2Gray lightness
          113 [sf: rf + gf + bf 
          		r: as integer! ((rf / sf) * 255.0)
          		g: as integer! ((gf / sf) * 255.0)
          		b: as integer! ((bf / sf) * 255.0)
          		pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b
          	] ; Normalized RGB by sum
          114 [ sf: sqrt((pow rf 2.0) + (pow gf 2.0) + (pow bf 2.0))
          		r: as integer! ((rf  / sf) * 255.0)
          		g: as integer! ((gf  / sf) * 255.0)
          		b: as integer! ((bf  / sf) * 255.0)
          		pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b
          	] ; Normalized RGB by square sum
        	2 [pixD/value: (a << 24) OR (b << 16 ) OR (g << 8) OR r] ;2BGRA
            3 [pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b] ;2RGBA
            4 [either s > 127 [r: 255 g: 255 b: 255] [r: 0 g: 0 b: 0] 
            	   pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b] ;2BW
            5 [ either s > 127 [r: 0 g: 0 b: 0] [r: 255 g: 255 b: 255] 
            	   pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b] ;2WB
        ]
        pixS: pixS + 1
        pixD: pixD + 1
       i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]
;***************** IMAGE CONVERSION FUNCTIONS *****************
rcv2NzRGB: function [ 
"Normalizes the RGB values of an image" 
	src [image!]    
	dst [image!]    
	/sum/sumsquare  
][
	case [
		sum  		[rcvConvert src dst 113]
		sumsquare 	[rcvConvert src dst 114]
	] 
]
 
rcv2Gray: function [ 
"Convert RGB image to Grayscale acording to refinement" 
	src [image!]  
	dst [image!] 
	/average /luminosity /lightness 
][
	case [
		average 	[rcvConvert src dst 1]
		luminosity 	[rcvConvert src dst 111]
		lightness 	[rcvConvert src dst 112]
	]
]

rcv2BGRA: function [
"Convert RGBA => BGRA"
	src [image!] 
	dst [image!] 
][
	rcvConvert src dst 2 
]

rcv2RGBA: function [
"Convert BGRA => RGBA"
	src [image!] 
	dst [image!]
][
	rcvConvert src dst 3 
]

rcv2BW: function [
"Convert RGB image => Black and White" 
	src [image!] 
	dst [image!]
][
	rcvConvert src dst 4
]

rcv2WB: function [
	"Convert RGB image => White and Black" 
	src [image!] 
	dst [image!]
][
	rcvConvert src dst 5
]

;******************** BW Filter Routine ******************
rcvFilterBW: routine [
"General B&W Filter routine"
    src 		[image!]
    dst  		[image!]
    thresh		[integer!]
    maxValue 	[integer!]
    op	 		[integer!]
    /local
    	v pixel2		[subroutine!]
        pixS pixD		[int-ptr!]
        handleS	handleD [integer!] 
        i n r g b a 	[integer!] 
][
    handleS: 0 handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    i: 0
    v: [(r + g + b) / 3]								;--subroutine
    pixel2: [(a << 24) OR (r << 16) OR (g << 8) OR b] 	;--subroutine
    while [i < n] [
    	a: pixS/value >>> 24
       	r: pixS/value and 00FF0000h >> 16 
       	g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh
        r: g: b: v
        switch op [
        	0 [either v >= thresh [r: 255 g: 255 b: 255] [r: 0 g: 0 b: 0]]
        	1 [either v > thresh  [r: maxValue g: maxValue b: maxValue] [r: 0 g: 0 b: 0]]
        	2 [either v > thresh  [r: 0 g: 0 b: 0] [r: maxValue g: maxValue b: maxValue]]
        	3 [either v > thresh  [r: thresh g: thresh b: thresh] [r: r g: g b: b]]
        	4 [either v > thresh  [r: r g: g b: b] [r: 0 g: 0 b: 0]]
        	5 [either v > thresh  [r: 0 g: 0 b: 0] [r: r g: g b: b]]
        	6 [either v > thresh  [r: 1 g: 1 b: 1] [r: 0 g: 0 b: 0]]
        ]  
        pixD/value: pixel2	       
        pixS: pixS + 1
        pixD: pixD + 1
        i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

;******************** BW Filter Functions ******************
rcv2BWFilter: function [
"Convert RGB image => Black and White according to threshold"
	src [image!] 
	dst [image!] 
	thresh [integer!]
][
	rcvFilterBW src dst thresh 0 0
]

rcvThreshold: function [
"Applies fixed-level threshold to image"
	src [image!] 
	dst [image!] 
	thresh [integer!] 
	mValue [integer!]
	/binary /binaryInv /trunc /toZero /toZeroInv /toZeroOne
][
	case [
		binary 		[rcvFilterBW src dst thresh mValue 1]
		binaryInv 	[rcvFilterBW src dst thresh mValue 2]
		trunc		[rcvFilterBW src dst thresh mValue 3]
		toZero 		[rcvFilterBW src dst thresh mValue 4]
		toZeroInv 	[rcvFilterBW src dst thresh mValue 5]
		toZeroOne	[rcvFilterBW src dst thresh mValue 5]
	]
]
 
rcvInvert: function [
"Similar to NOT image"
	src [image!] 
	dst [image!]
][
	dst/rgb: complement src/rgb 
]

;***************** LOGICAL OPERATOR ON IMAGE ROUTINES ************
rcvNot: routine [
"dst: NOT src"
    src 		[image!]
    dst  		[image!]
    /local
        pixS 	[int-ptr!]
        pixD 	[int-ptr!]
        handleS	[integer!] 
        handleD	[integer!] 
        i 		[integer!]
        n		[integer!] 
][
    handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    i: 0
    while [i < n] [
        pixD/value: FF000000h or NOT pixS/value
        pixS: pixS + 1
        pixD: pixD + 1
        i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]


rvcLogical: routine [
"General routine for logical operators on image"
	src1 [image!]
	src2 [image!]
	dst	 [image!]
	op [integer!]
	/local 
	pix1 [int-ptr!]
	pix2 [int-ptr!]
	pixD [int-ptr!]
	handle1 handle2 handleD n i [integer!]
][
	handle1: 0
	handle2: 0
	handleD: 0
	pix1: image/acquire-buffer src1 :handle1
	pix2: image/acquire-buffer src2 :handle2
	pixD: image/acquire-buffer dst :handleD
	n: IMAGE_WIDTH(src1/size) * IMAGE_HEIGHT(src1/size)
	i: 0
	while [i < n] [
		switch op [
			1 [pixD/value: FF000000h or (pix1/Value AND pix2/value)]
			2 [pixD/value: FF000000h or (pix1/Value OR pix2/Value)]
			3 [pixD/value: FF000000h or (pix1/Value XOR pix2/Value)]
			4 [pixD/value: FF000000h or (NOT pix1/Value AND pix2/Value)]
			5 [pixD/value: FF000000h or (NOT pix1/Value OR pix2/Value)]
			6 [pixD/value: FF000000h or (NOT pix1/Value XOR pix2/Value)]
			7 [either pix1/Value > pix2/Value [pixD/value: pix2/Value][pixD/value: FF000000h or pix1/Value]]
           	8 [either pix1/Value > pix2/Value [pixD/value: pix1/Value] [pixD/value: FF000000h or pix2/Value]]
		]
		pix1: pix1 + 1
		pix2: pix2 + 1
		pixD: pixD + 1
		i: i + 1
		
	]
	image/release-buffer src1 handle1 no
	image/release-buffer src2 handle2 no
	image/release-buffer dst handleD yes
]

; ************* Logical operator functions ***************************
rcvAND: function [
"dst: src1 AND src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rvcLogical src1 src2 dst 1
]

rcvOR: function [
"dst: src1 OR src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rvcLogical src1 src2 dst 2
]

rcvXOR: function [
"dst: src1 XOR src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rvcLogical src1 src2  dst 3
]

rcvNAND: function [
"dst: src1 NAND src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rvcLogical src1 src2 dst 4
]

rcvNOR: function [
"dst: src1 NOR src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rvcLogical src1 src2 dst 5
]

rcvNXOR: function [
"dst: src1 NXOR rc2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rvcLogical src1 src2 dst 6
]


; ********** Math Operators on image **********
rcvMath: routine [
"General Routine for math operators on image"
	src1 	[image!]
	src2 	[image!]
	dst	 	[image!]
	op 		[integer!]
	/local 
	pix1 	[int-ptr!]
	pix2 	[int-ptr!]
	pixD 	[int-ptr!]
	handle1	[integer!] 
	handle2 [integer!]
	handleD [integer!]
	n		[integer!] 
	i 		[integer!]
][
	handle1: handle2: handleD: 0
	pix1: image/acquire-buffer src1 :handle1
	pix2: image/acquire-buffer src2 :handle2
	pixD: image/acquire-buffer dst :handleD	
	n: IMAGE_WIDTH(src1/size) * IMAGE_HEIGHT(src1/size)
	i: 0
	while [i < n] [
		switch op [
			0 [pixD/value: pix1/Value]
			1 [pixD/value: FF000000h or (pix1/Value + pix2/value)]
			2 [pixD/value: FF000000h or (pix1/Value - pix2/Value)]
			3 [pixD/value: FF000000h or (pix1/Value * pix2/Value)]
			4 [pixD/value: FF000000h or (pix1/Value / pix2/Value)]
			5 [pixD/value: FF000000h or (pix1/Value // pix2/Value)]
			6 [pixD/value: FF000000h or (pix1/Value % pix2/Value)]
			7 [either pix1/Value > pix2/Value 
					[pixD/value: FF000000h or (pix1/Value - pix2/Value) ]
				    [pixD/value: FF000000h or (pix2/Value - pix1/Value)]]
			8 [pixD/value: FF000000h or ((pix1/Value + pix2/value) / 2)]
		]
		pix1: pix1 + 1
		pix2: pix2 + 1
		pixD: pixD + 1
		i: i + 1
	]
	image/release-buffer src1 handle1 no
	image/release-buffer src2 handle2 no
	image/release-buffer dst handleD yes
]

rcvAdd: function [
"dst: src1 + src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvMath src1 src2 dst 1
]

rcvSub: function [
"dst: src1 - src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvMath src1 src2 dst 2
]

rcvMul: function [
"dst: src1 * src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvMath src1 src2 dst 3
]

rcvDiv: function [
"dst: src1 / src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvMath src1 src2 dst 4
] 

rcvMod: function [
"dst: src1 // src2 (modulo)"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvMath src1 src2 dst 5
] 

rcvRem: function [
"dst: src1 % src2 (remainder)"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvMath src1 src2 dst 6
] 

rcvAbsDiff: function [
"dst: absolute difference src1 src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvMath src1 src2 dst 7
] 

rcvMIN: function [
"dst: minimum src1 src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rvcLogical src1 src2 dst 7
]

rcvMAX: function [
"dst: maximum src1 src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rvcLogical src1 src2 dst 8
]

;*************Logarithmic Image Processing Model ************
rcvLIP: routine [
	src1 [image!]
	src2 [image!]
	dst	 [image!]
	op [integer!]
	/local 
	pixel					[subroutine!]
	pix1 pix2 pixD 			[int-ptr!]
	handle1 handle2 handleD	[integer!] 
	i n 					[integer!]
	a1 r1 g1 b1				[integer!]
	a2 r2 g2 b2 			[integer!]
	fa fr fg fb				[integer!]
][
	handle1: handle2: handleD: 0
	pix1: image/acquire-buffer src1 :handle1
	pix2: image/acquire-buffer src2 :handle2
	pixD: image/acquire-buffer dst :handleD	
	pixel: [(255 << 24) OR (fr << 16) OR (fg << 8) OR fb]
	n: IMAGE_WIDTH(src1/size) * IMAGE_HEIGHT(src1/size)
	i: 0
	while [i < n] [
		a1: pix1/value >>> 24
    	r1: pix1/value and 00FF0000h >> 16 
    	g1: pix1/value and FF00h >> 8 
    	b1: pix1/value and FFh 	
    	a2: pix2/value >>> 24
    	r2: pix2/value and 00FF0000h >> 16 
    	g2: pix2/value and FF00h >> 8 
    	b2: pix2/value and FFh
		switch op [
			1 [fr: (r1 + r2) - ((r1 * r2) / 256) 
				fg: (g1 + g2) - ((g1 * g2) / 256)
			    fb: (b1 + b2) - ((b1 * b2) / 256)
			]
			2 [ fr: (256 * (r1 - r2)) / (256 - r2)
			    fg: (256 * (g1 - g2)) / (256 - g2)
			    fb: (256 * (b1 - b2)) / (256 - b2)
			]
		]
		pixD/value: pixel; (255 << 24) OR (fr << 16 ) OR (fg << 8) OR fb
		pix1: pix1 + 1
		pix2: pix2 + 1
		pixD: pixD + 1
		i: i + 1
	]
	image/release-buffer src1 handle1 no
	image/release-buffer src2 handle2 no
	image/release-buffer dst handleD yes
]

rcvAddLIP: function [
"dest(x,y)= src1(x,y)+ src(x,y) – (src1(x,y)* src2(x,y)) / M"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvLIP src1 src2 dst 1
]

rcvSubLIP: function [
"im_out(x,y) = M.(im_in1(x,y) - im_in2(x,y)) / ( M - im_in2(x,y))"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvLIP src1 src2 dst 2
]


; ********** Math operators routine with scalar (tuple or integer) *********
; integer scalar
rcvMathS: routine [
"General routine for scalar on image"
	src 	[image!]
	dst 	[image!]
	v	 	[integer!]
	op 		[integer!]
	/local 
	pixS 	[int-ptr!]
	pixD 	[int-ptr!]
	handleS	[integer!] 
	handleD	[integer!] 
	n		[integer!] 
	i		[integer!] 
][
	handleS: handleD: 0
	pixS: image/acquire-buffer src :handleS
	pixD: image/acquire-buffer dst :handleD
	n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
	i: 0
	while [i < n] [
		switch op [
			0 [pixD/value: pixS/Value ]
			1 [pixD/value: FF000000h or (pixS/Value + v)]
			2 [pixD/value: FF000000h or (pixS/Value - v)]
			3 [pixD/value: FF000000h or (pixS/Value * v)]
			4 [pixD/value: FF000000h or (pixS/Value / v)]
			5 [pixD/value: FF000000h or (pixS/Value // v)]
			6 [pixD/value: FF000000h or (pixS/Value % v)]
			7 [pixD/value: FF000000h or (pixS/Value << v)]
			8 [pixD/value: FF000000h or (pixS/Value >> v)]
			9 [pixD/value: FF000000h or as integer! (pow as float! pixS/Value as float! v)]
		   10 [pixD/value: FF000000h or as integer! (sqrt as float! pixS/Value >> v)]
		]
		pixS: pixS + 1
		pixD: pixD + 1
		i: i + 1
	]
	image/release-buffer src handleS no
	image/release-buffer dst handleD yes
]


; Float scalar
rcvMathF: routine [
	src 	[image!]
	dst 	[image!]
	v	 	[float!]
	op 		[integer!]
	/local 
	pixel			[subroutine!]
	pixS pixD 		[int-ptr!]
	handleS handleD	[integer!] 
	n i				[integer!] 
	a r g b			[integer!]
	fa fr fg fb		[integer!]
][
	handleS: handleD: 0
	pixS: image/acquire-buffer src :handleS
	pixD: image/acquire-buffer dst :handleD
	n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
	pixel: [FF000000h or ((fa << 24) OR (fr << 16 ) OR (fg << 8) OR fb)]
	i: 0
	while [i < n] [
		a: pixS/value >>> 24
    	r: pixS/value and 00FF0000h >> 16 
    	g: pixS/value and FF00h >> 8 
    	b: pixS/value and FFh 	
		switch op [
			1 [fa: as integer! (pow as float! a v)
					fr: as integer! (pow as float! r v)
					fg: as integer! (pow as float! g v)
					fb: as integer! (pow as float! b v)
				  ]
			2 [fa: as integer! (sqrt as float! a >> as integer! v)
			    	fr: as integer! (sqrt as float! r >> as integer! v)
					fg: as integer! (sqrt as float! g >> as integer! v)
					fb: as integer! (sqrt as float! b >> as integer! v)]
			3  [fa: as integer! (v * as float! a)
					 fr: as integer! (v * as float! r)
					 fg: as integer! (v * as float! g)
					 fb: as integer! (v * as float! b)] ; * for image intensity
			4 [fa: as integer! ((as float! a) / v)
					fr: as integer! ((as float! r) / v)
					fg: as integer! ((as float! g) / v)
					fb: as integer! ((as float! b) / v)] ; /
			5 [fa: as integer! (v + as float! a)
					fr: as integer! (v + as float! r)
					fg: as integer! (v + as float! g)
					fb: as integer! (v + as float! b)] ; +
			6 [fa: as integer! (v - as float! a)
					fr: as integer! (v - as float! r)
					fg: as integer! (v - as float! g)
					fb: as integer! (v - as float! b)] ; -
		]
		pixD/value: pixel
		pixS: pixS + 1
		pixD: pixD + 1
		i: i + 1
	]
	image/release-buffer src handleS no
	image/release-buffer dst handleD yes
]
; tuples mettre à jour la doc
rcvMathT: routine [
    src 	[image!]
    dst  	[image!]
    t		[tuple!]
    op1 	[integer!]
    flag	[logic!]
    /local
    	pixel				[subroutine!]
        pixS 				[int-ptr!]
        pixD 				[int-ptr!]
        handleS handleD i n [integer!]
        a r g b				[integer!]
        rt gt bt			[integer!]
        tp					[red-tuple!]
][
    handleS: 0
    handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    pixel: [(a << 24) OR (r << 16 ) OR (g  << 8) OR b]
    i: 0
    rt: t/array1 and FFh 
	gt: t/array1 and FF00h >> 8 
	bt: t/array1 and 00FF0000h >> 16 
    while [i < n] [
        a: pixS/value >>> 24
        r: pixS/value and 00FF0000h >> 16
        g: pixS/value and FF00h >> 8 
    	b: pixS/value and FFh    	
        switch op1 [
          	0 [r: r g: g b: b]
          	1 [r: r + rt g: g + gt b: b + bt]
           	2 [r: r - rt g: g - gt b: b - bt]
           	3 [r: r * rt g: g * gt b: b * bt]
           	4 [r: r / rt g: g / gt b: b / bt]
           	5 [r: r // rt g: g // gt b: b // bt]
           	6 [r: r % rt g: g % gt b: b % bt]
          ]
          if flag [
          		if all [r > 255 g > 255 b > 255] [r: 255 g: 255 b: 255]
          		if all [r < 0 g < 0 b < 0] [r: 0 g: 0 b: 0]
          ]
        pixD/value: pixel
        pixS: pixS + 1
        pixD: pixD + 1
        i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]



; ********** Math operators functions with scalar ****************
;mettre à jour dans la doc
rcvAddS: function [
"dst: src + integer or float value"
	src [image!] 
	dst [image!] 
	val [number!] 
][
	t: type? val
	if t = integer! [rcvMathS src dst val 1]
	if t = float!	[rcvMathF src dst val 5]
]

rcvSubS: function [
"dst: src - integer or float value"
	src [image!] 
	dst [image!] 
	val [number!]
][
	t: type? val
	if t = integer! [rcvMathS src dst val 2]
	if t = float!	[rcvMathF src dst val 6]
]

rcvMulS: function [
"dst: src * integer or float value"
	src [image!] 
	dst [image!] 
	val [number!] 
][
	t: type? val
	if t = integer! [rcvMathS src dst val 3]
	if t = float!	[rcvMathF src dst val 3]
]

rcvDivS: function [
"dst: src / integer or float value"
	src [image!] 
	dst [image!] 
	val [number!] 
][
	t: type? val
	if t = integer! [rcvMathS src dst val 4]
	if t = float!	[rcvMathF src dst val 4]
]

rcvPow: function [
"dst: src ^integer! or float! value"
	src [image!]  
	dst [image!] 
	val [number!] 
][
	t: type? val
	if t = float!   [rcvMathF src dst val 1] 
	if t = integer! [rcvMathS src dst val 9] 
]


rcvSQR: function [
"Image square root"
	src [image!] 
	dst [image!] 
	val [number!]  
][
	t: type? val
	if t = integer! [rcvMathS src dst val 10] 
	if t = float!   [rcvMathF src dst val 2]
]

rcvModS: function [
"dst: src // integer! value (modulo)"
	src [image!] 
	dst [image!] 
	val [integer!] 
][
	rcvMathS src dst val 5
]

rcvRemS: function [
"dst: src % integer! value (remainder)"
	src [image!] 
	dst [image!] 
	val [integer!] 
][
	rcvMathS src dst val 6
]


rcvLSH: function [
"Left shift image by value"
	src [image!] 
	dst [image!]
	val [integer!] 
][
	rcvMathS src dst val 7
]

rcvRSH: function [
"Right Shift image by value"
	src [image!] 
	dst [image!] 
	val [integer!] 
][
	rcvMathS src dst val 8
]


rcvAddT: function [
"dst: src + tuple! value"
	src 	[image!] 
	dst 	[image!] 
	val 	[tuple!] 
	flag	[logic!]
][
	rcvMathT src dst val 1 flag
]

rcvSubT: function [
"dst: src - tuple! value"
	src 	[image!] 
	dst 	[image!] 
	val 	[tuple!]
	flag	[logic!]
][
	rcvMathT src dst val 2 flag
]

rcvMulT: function [
"dst: src * tuple! value"
	src 	[image!] 
	dst 	[image!] 
	val 	[tuple!]
	flag	[logic!] 
][
	rcvMathT src dst val 3 flag
]

rcvDivT: function [
"dst: src / tuple! value"
	src 	[image!] 
	dst 	[image!] 
	val 	[tuple!]
	flag	[logic!] 
][
	rcvMathT src dst val 4 flag
]

rcvModT: function [
"dst: src // tuple! value (modulo)"
	src 	[image!] 
	dst 	[image!] 
	val 	[tuple!]
	flag	[logic!] 
][
	rcvMathT src dst val 5 flag
]

rcvRemT: function [
"dst: src % tuple! value (remainder)"
	src 	[image!] 
	dst 	[image!] 
	val 	[tuple!]
	flag	[logic!] 
][
	rcvMathT src dst val 6 flag
]

; ************ logical operators and scalar (tuple!) on image **********

rcvANDS: function [
"dst: src AND tuple! as image"
	src [image!] 
	dst [image!] 
	value [tuple!] 
][
	tmp: make image! reduce[src/size value]
	rvcLogical src tmp dst 1
	tmp: none
]

rcvORS: function [
"dst: src OR tuple! as image"
	src [image!] 
	dst [image!] 
	value [tuple!] 
][
	tmp: make image! reduce[src/size value]
	rvcLogical src tmp dst 2
	tmp: none
]

rcvXORS: function [
"dst: src XOR tuple! as image"
	src [image!] 
	dst [image!] 
	value [tuple!] 
][
	tmp: make image! reduce[src/size value]
	rvcLogical src tmp dst 3
	tmp: none
]

; ;********** stats on 2 images ***********************
 
rcvMeanImages: function [
"Calculates pixels mean value for 2 images"
	src1 [image!] 
	src2 [image!] dst [image!]
][
	rcvMath src1 src2 dst 8
]

;******************** SUB-ARRAYS ************************
;--new
rcvRChannel: routine [
    src  [image!]
    dst  [image!]
    op	 [integer!]
    /local
    	rpixel wpixel	[subroutine!]
        pixS 			[int-ptr!]
        pixD 			[int-ptr!]
        handleS handleD [integer!]
        i n				[integer!]
        r g b a			[integer!]
][
    handleS: 0
    handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    a: r: g: b: 0
    ;--subroutines read and write pixels
    rpixel: [
    	a: pixS/value >>> 24 r: pixS/value and 00FF0000h >> 16 
        g: pixS/value and FF00h >> 8 b: pixS/value and FFh 
    ]
    wpixel: [(a << 24) OR (r << 16 ) OR (g << 8) OR b]
    ;--end subroutines
    i: 0
    while [i < n] [
        rpixel
        switch op [
        	0 [pixD/value: pixS/value]
            1 [r: 0]	;remove Red Channel
            2 [g: 0] 	;remove Green Channel 
            3 [b: 0] 	;remove Blue Channel
            4 [b: g: 0]	;keep Red Channel
            5 [r: b: 0]	;keep Green Channel
            6 [r: g: 0]	;keep Blue Channel
        ]
        pixD/value: wpixel
        pixS: pixS + 1
        pixD: pixD + 1
        i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]
;--end new

rcvSChannel: routine [
    src  [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pixS 			[int-ptr!]
        pixD 			[int-ptr!]
        handleS handleD [integer!]
        i n				[integer!]
        r g b a			[integer!]
][
    handleS: 0
    handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    i: 0
    while [i < n] [
    	a: pixS/value >>> 24
       	r: pixS/value and 00FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh 
        switch op [
        	0 [pixD/value: pixS/value]
            1 [pixD/value: (a << 24) OR (r << 16 ) OR (r << 8) OR r]	;Red Channel
            2 [pixD/value: (a << 24) OR (g << 16 ) OR (g << 8) OR g] 	;Green Channel 
            3 [pixD/value: (a << 24) OR (b << 16 ) OR (b << 8) OR b] 	;blue Channel
            4 [pixD/value: (a << 24) OR (a << 16 ) OR (a << 8) OR a] 	;alpha Channel
        ]
        pixS: pixS + 1
        pixD: pixD + 1
        i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]


rcvSplit: function [
"Split source image in RGB and alpha separate channels"
	src [image!] 
	dst [image!]
	/red /green /blue /alpha
][
	case [
		red 	[rcvSChannel src dst 1]
		green 	[rcvSChannel src dst 2]
		blue 	[rcvSChannel src dst 3]
		alpha	[rcvSChannel src dst 4]
	]
]

rcvSplit2: function [
"Split source image in RGB and alpha separate channels"
	src 	[image!] 
	return: [block!]
][
	size: src/size
	r: make image! reduce [size black]
	g: make image! reduce [size black]
	b: make image! reduce [size black]
	a: make image! reduce [size black]
	rcvSChannel src r 1
	rcvSChannel src g 2
	rcvSChannel src b 3
	rcvSChannel src a 4
	reduce [r g b a]
]

rcvMerge: routine [
    src1  [image!]
    src2  [image!]
    src3  [image!]
    dst   [image!]
    /local
    	pixel			[subroutine!]
        pix1 			[int-ptr!]
        pix2 			[int-ptr!]
        pix3 			[int-ptr!]
        pixD 			[int-ptr!]
        handle1 handle2	[integer!]
        handle3 handleD [integer!]
        n i				[integer!]
        r g b a			[integer!]
][
    handle1: 0
    handle2: 0
    handle3: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pix2: image/acquire-buffer src2 :handle2
    pix3: image/acquire-buffer src3 :handle3
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src1/size) * IMAGE_HEIGHT(src1/size)
    pixel: [(a << 24) OR (r << 16 ) OR (g << 8) OR b]
    i: 0
    while [i < n] [
       	a: pix1/value >>> 24
       	r: pix1/value and 00FF0000h >> 16 
       	g: pix2/value and FF00h >> 8 
        b: pix3/value and FFh 
        pixD/value: pixel
        pix1: pix1 + 1
        pix2: pix2 + 1
        pix3: pix3 + 1
        pixD: pixD + 1
        i: i + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer src2 handle2 no
    image/release-buffer src3 handle3 no
    image/release-buffer dst handleD yes
]


rcvMerge2: routine [
"Merge 4 images to destination image"
    src1  [image!]	;--r
    src2  [image!]	;--g
    src3  [image!]	;--b
    src4  [image!]	;--a
    dst   [image!]	;-result
    /local
    	pixel			[subroutine!]
        pix1 pix2 		[int-ptr!]
        pix3 pix4 		[int-ptr!]
        pixD 			[int-ptr!]
        handle1 handle2 [integer!]
        handle3 handle4	[integer!]
        handleD 		[integer!]
        n i				[integer!]
        r g b a			[integer!]
][
    handle1: 0
    handle2: 0
    handle3: 0
    handle4: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pix2: image/acquire-buffer src2 :handle2
    pix3: image/acquire-buffer src3 :handle3
    pix4: image/acquire-buffer src4 :handle4
    pixD: image/acquire-buffer dst :handleD
    pixel: [(a << 24) OR (r << 16 ) OR (g << 8) OR b]
    n: IMAGE_WIDTH(src1/size) * IMAGE_HEIGHT(src1/size)
    i: 0
    while [i < n] [
       	a: pix4/value >>> 24
       	r: pix1/value and FF0000h >> 16 
       	g: pix2/value and FF00h >> 8 
        b: pix3/value and FFh 
        pixD/value: pixel
        pix1: pix1 + 1
        pix2: pix2 + 1
        pix3: pix3 + 1
        pix4: pix4 + 1
        pixD: pixD + 1
        i: i + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer src2 handle2 no
    image/release-buffer src3 handle3 no
    image/release-buffer src4 handle4 no
    image/release-buffer dst handleD yes
]


_rcvInRange: routine [
	src  	[image!]
    dst   	[image!]
    lowr 	[integer!]
    lowg 	[integer!]
    lowb 	[integer!]
    upr 	[integer!]
    upg 	[integer!]
    upb 	[integer!]
    op		[integer!]
    /local
    range?  		[subroutine!]
    pixel			[subroutine!]
	pixS 			[int-ptr!]
    pixD 			[int-ptr!]
    handleS handleD [integer!]
    n i r g b a 	[integer!]
   
][
	handleS: 0
    handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    ;--subroutines
    range?: [all [r > lowr r <= upr g > lowg g <= upg b > lowb b <= upb]]
    pixel:  [(a << 24) OR (r << 16) OR (g << 8) OR b]
    i: 0
    while [i < n] [
       	a: pixS/value >>> 24
       	r: pixS/value and 00FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh 
        either range? [
        	switch op [
        		0 [r: FFh g: FFh b: FFh]
        		1 [r: r g: g b: b]
        	]
        ][r: 0 g: 0 b: 0] 
       	pixD/value: pixel
        pixS: pixS + 1
        pixD: pixD + 1
        i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]


rcvInRange: function [
"Extracts sub array from image according to lower and upper rgb values"
	src 	[image!] 
	dst 	[image!] 
	lower 	[tuple!] 
	upper 	[tuple!] 
	op 		[integer!]
][
	lr: lower/1 lg: lower/2 lb: lower/3
	ur: upper/1 ug: upper/2 ub: upper/3
	_rcvInRange src dst lr lg lb ur ug ub op

]

; ********** image intensity and blending ******************

; ********* Image Alpha Routine **********
rcvSetAlpha: routine [
"Sets image transparency"
	src  	[image!]
    dst   	[image!]
    alpha 	[integer!]
    /local
    pixel rgb		[subroutine!]
	pixS pixD 		[int-ptr!]
    handleS	handleD	[integer!] 
    n i				[integer!]
    r g b			[integer!]
][
	handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    pixel: [(alpha << 24) OR (r << 16 ) OR (g << 8) OR b]
    rgb: [r: pixS/value and 00FF0000h >> 16 g: pixS/value and FF00h >> 8 b: pixS/value and FFh]
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    i: 0
    while [i < n] [
       	rgb
       	pixD/value: pixel
        pixS: pixS + 1
        pixD: pixD + 1
        i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]


rcvSetIntensity: function [
"Sets image intensity"
	src [image!] 
	dst [image!] 
	alpha	[float!]
][
	rcvMathF src dst alpha 3
]	

rcvBlend: routine [
"Mixes 2 images"
    src1  	[image!]
    src2  	[image!]
    dst  	[image!]
    alpha	[float!]
    /local
    	pixel rgb1 rgb2	rgb3	[subroutine!]
        pix1 pix2 pixD 			[int-ptr!]
        handle1 handle2 handleD	[integer!] 
        n i						[integer!]					
        a1 r1 g1 b1				[integer!]
        a2 r2 g2 b2				[integer!]
        a3 r3 g3 b3				[integer!]
        calpha					[float!]
][
	handle1: handle2: handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pix2: image/acquire-buffer src2 :handle2
    pixD: image/acquire-buffer dst  :handleD
    n: IMAGE_WIDTH(src1/size) * IMAGE_HEIGHT(src1/size)
    calpha: 1.0 - alpha
    a1: r1: g1: b1: 0
    a2: r2: g2: b2: 0
    a3: r3: g3: b3: 0
    ;--subroutines
    pixel: [(a3 << 24) OR (r3 << 16 ) OR (g3 << 8) OR b3]
    rgb1: [a1: pix1/value >>> 24 r1: pix1/value and 00FF0000h >> 16 
    	g1: pix1/value and FF00h >> 8 b1: pix1/value and FFh ]
	rgb2: [a2: pix2/value >>> 24 r2: pix2/value and 00FF0000h >> 16 
    	g2: pix2/value and FF00h >> 8 b2: pix2/value and FFh]
    rgb3: [
    	a3: as integer! (alpha * as float! a1) + (calpha * as float! a2) 
        r3: as integer! (alpha * as float! r1) + (calpha * as float! r2) 
        g3: as integer! (alpha * as float! g1) + (calpha * as float! g2)
        b3: as integer! (alpha * as float! b1) + (calpha * as float! b2)
    ]
    i: 0
    while [i < n] [
        rgb1 rgb2 rgb3
        pixD/value: pixel
		pix1: pix1 + 1
		pix2: pix2 + 1
		pixD: pixD + 1
		i: i + 1
	]
	image/release-buffer src1 handle1 no
	image/release-buffer src2 handle2 no
	image/release-buffer dst handleD yes
]

rcvAlphaBlend: routine [
"Alpha blending with 2 images"
    src1  	[image!]
    src2  	[image!]
    dst  	[image!]
    /local
    	pixel rgb1 rgb2 rgb3	[subroutine!]
    	rgba					[subroutine!]
        pix1 pix2 pixD 			[int-ptr!]
        handle1 handle2 handleD	[integer!] 
        i n						[integer!]
        a1 r1 g1 b1				[float!]
        a2 r2 g2 b2				[float!]
        a3 r3 g3 b3				[float!]
        calpha alphaR			[float!]	
        a r g b					[integer!]		
        aInt rInt gInt bInt		[integer!]
][
	handle1: handle2: handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pix2: image/acquire-buffer src2 :handle2
    pixD: image/acquire-buffer dst  :handleD
	n: IMAGE_WIDTH(src1/size) * IMAGE_HEIGHT(src1/size)
	a: r: g: b: 0
	a1: r1: g1: b1: 0.0
	a2: r2: g2: b2: 0.0
    a3: r3: g3: b3: 0.0
    ;--subroutines
    rgba: [
    	a: pix1/value >>> 24
    	r: pix1/value and FF0000h >> 16
    	g: pix1/value and FF00h >> 8
    	b: pix1/value and FFh
    ]
    
    rgb1: [ 
    	a1: (as float! a) / 255.0
       	r1: as float! r
        g1: as float! g
		b1: as float! b
		a1: a1 / 255.0 r1: r1 / 255.0
		g1: g1 / 255.0 b1: b1 / 255.0
	]
	
	rgb2: [
		a2: as float! (pix2/value >>> 24)
		r2: as float! (pix2/value and FF0000h >> 16) 
		g2: as float! (pix2/value and FF00h >> 8) 
		b2: as float! (pix2/value and FFh) 
		a2: a2 / 255.0 r2: r2 / 255.0
		g2: g2 / 255.0 b2: b2 / 255.0
	]
	
	rgb3: [
		aInt: as integer! a3 rInt: as integer! r3
		gInt: as integer! g3 bInt: as integer! b3
	]
	
	pixel: [(aInt << 24) OR (rInt << 16 ) OR (gInt << 8) OR bInt]
	
	
    i: 0
    while [i < n] [
    	rgba
    	rgb1 rgb2 
		calpha: 1.0 - a1
		alphaR: a1 + (a2 * calpha)
		a3: alphaR * 255.0
		r1: r1 * a1
		r2: (r2 * calpha) * a2
		r3: ((r1 + r2) / alphaR) * 255.0
		g1: g1 * a1
		g2: (g2 * calpha) * a2
		g3: ((g1 + g2) / alphaR) * 255.0
		b1: b1 * a1
		b2: (b2 * calpha) * a2
		b3: ((b1 + b2) / alphaR) * 255.0
		rgb3
		pixD/value: pixel
		pix1: pix1 + 1
		pix2: pix2 + 1
		pixD: pixD + 1
		i: i + 1
	]
	image/release-buffer src1 handle1 no
	image/release-buffer src2 handle2 no
	image/release-buffer dst handleD yes
]

;Specific version for Windows until rcvBlend problem solved
rcvBlendWin: function [
"Mixes 2 images"
	src1 	[image!] 
	src2 	[image!] 
	dst 	[image!] 
	alpha	[float!]
][	 
	img1: rcvCreateImage src1/size
	img2: rcvCreateImage src2/size
	rcvMathF src1 img1 alpha 3
	rcvMathF src2 img2 1.0 - alpha 3
	rcvMath img1 img2 dst 1
	rcvReleaseImage img1
	rcvReleaseImage img2
]

rcvResizeImage: routine [
"Resizes image"
	src 	[image!] 
	iSize 	[pair!] 
	return: [image!]
][
	as red-image! stack/set-last as cell! image/resize src iSize/x iSize/y
]







