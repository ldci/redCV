Red [
	Title:   "Red Computer Vision: Integral Image"
	Author:  "Francois Jouen"
	File: 	 %rcvIntegral.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


; #include %../../libs/matrix/rcvMatrix.red ; if necessary


; ****************integral image routines ************************
rcvIntegralImg: routine [
"Direct integral image"
   	src  	[image!]
    dst1  	[vector!]
    dst2	[vector!]
    /local
    pixel 	[int-ptr!]
    pIndexS	[int-ptr!]	
    d1value [byte-ptr!]
    d2value	[byte-ptr!]
    idxD1	[byte-ptr!]
    idxD2	[byte-ptr!]
    unit	[integer!]
    x		[integer!] 
    y 		[integer!]
    w 		[integer!]
    h		[integer!]
    pIndexD [integer!]
    val		[integer!] 
    val2	[integer!]
    ssum 	[integer!]
    sqsum	[integer!]
    handle1	[integer!]
    r 		[integer!]
    g 		[integer!]
    b 		[integer!]
    rgb		[integer!]
    rgbf	[float!]
] [
	handle1: 0
    pixel: image/acquire-buffer src :handle1 
	d1value: vector/rs-head dst1	
	d2value: vector/rs-head dst2
	unit: rcvGetMatBitSize dst1
    idxD1: d1value
    idxD2: d2value
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    while [x < w] [
    	y: 0
    	ssum: 0
    	sqsum: 0
    	val: 0
    	val2: 0
       	while [y < h][
       		pIndexS: pixel + (x + (y * w))
       		r: pIndexS/value and 00FF0000h >> 16 
        	g: pIndexS/value and FF00h >> 8 
        	b: pIndexS/value and FFh 
        	rgbf: (0.2989 * as float! r) + (0.587 * as float! g) + (0.114 * as float! b) 
       		val: (as integer! rgbf) >> 0
       		ssum: ssum + val                             
       		sqsum: sqsum + (val * val)
       		pIndexD: (x + (y * w)) * unit 
       		d1value: idxD1 + pIndexD
       		d2value: idxD2 + pIndexD 
       		either (x = 0) [
       			rcvSetIntValue as integer! d1Value ssum unit
       			rcvSetIntValue as integer! d2Value sqsum unit] 
       			[
					;sum
					d1value: d1value - unit
       				val: rcvGetIntValue as integer! d1value unit
       				d1value: d1value + unit
       				val2: ssum + val
       				rcvSetIntValue as integer! d1Value val2 unit
       				; square sum
       				d2value: d2value - unit
       				val: rcvGetIntValue as integer! d2value unit
       				d2value: d2value + unit
       				val2: sqsum + val
       				rcvSetIntValue as integer! d2Value val2 unit
       			]
       		y: y + 1
       	]
    	x: x + 1   	
    ]
    image/release-buffer src handle1 no
]



; uses float vector to avoid math overflow with integer
rcvIntegralFloatImg: routine [
"Direct  integral on image "
    src  			[image!]
    dst1  			[vector!]
    dst2 			[vector!]
    /local
        pix1 		[int-ptr!]
        pixD1 		[byte-ptr!]
        pixD2 		[byte-ptr!]
        idxD1		[byte-ptr!]
        idxD2		[byte-ptr!]
        handle1 	[integer!]
        unit		[integer!]
        h 			[integer!]
        w 			[integer!]
        x 			[integer!]
        y 			[integer!]
        pIndexD		[integer!] 
        pindex2 	[integer!]
        val			[integer!]
        ssum 		[float!]
        sqsum   	[float!]  
        t			[float!]
        tq			[float!]
        r 			[integer!]
        g 			[integer!]
        b			[integer!] 
        rgb			[integer!]
        rgbf		[float!]
][
    handle1: 0
    pix1:  image/acquire-buffer src :handle1 
    pixD1: vector/rs-head dst1
    pixD2: vector/rs-head dst2
    idxD1: pixD1
    idxD2: pixD2
    pIndexD: 0
    unit: rcvGetMatBitSize dst1
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    y: 0
    while [y < h] [
    	ssum: 0.0
    	sqsum: 0.0
    	x: 0
    	;loop over the number of columns
       	while [x < w][
       		pIndexD: ((y * w) + x) * unit 
       		; grayscale luminance
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
        	b: pix1/value and FFh      
			rgbf: (0.2989 * as float! r) + (0.587 * as float! g) + (0.114 * as float! b) 
        	rgb: (as integer! rgbf) >> 0
       		;sum of the current row
       		ssum: ssum + as float! rgb
       		sqsum: sqsum + as float! (rgb * rgb)
       		t: ssum
       		tq: sqsum
       		if y <> 0 [
       			pIndexD: (((y - 1) * w) + x) * unit
       			;sum
				pixD1: idxD1 + pIndexD 
				t: t + rcvGetFloatValue as integer! pixD1 unit
       			; square sum
       			pixD2: idxD2 + pIndexD 
       			tq: tq + rcvGetFloatValue as integer! pixD2 unit
       			
			]
        	pIndexD: ((y * w) + x) * unit
        	pixD1: idxD1 + pIndexD 
        	rcvSetFloatValue as integer! pixD1 t unit
        	pixD2: idxD2 + pIndexD 
        	rcvSetFloatValue as integer! pixD2 tq unit
        	pix1: pix1 + 1
        	x: x + 1
       ]
       y: y + 1
    ]
    image/release-buffer src handle1 no
]



;*********************** Integral Matrices *************************
; integer Matrices 
rcvIntegralMat: routine [
"Direct integral image on matrix"
   	src  	[vector!]
    dst1  	[vector!]
    dst2	[vector!]
    mSize	[pair!]
    /local
    svalue 	[byte-ptr!]
    d1value [byte-ptr!]
    d2value	[byte-ptr!]
    idx1 	[byte-ptr!]
    idxD1	[byte-ptr!]
    idxD2	[byte-ptr!]
    unit	[integer!]
    x		[integer!] 
    y 		[integer!]
    w 		[integer!]
    h		[integer!]
    pIndexD [integer!]
    val		[integer!] 
    val2	[integer!]
    ssum 	[integer!]
    sqsum	[integer!]
][
    svalue: vector/rs-head src  
	d1value: vector/rs-head dst1	
	d2value: vector/rs-head dst2
	unit: rcvGetMatBitSize src
	idx1:  svalue
    idxD1: d1value
    idxD2: d2value
    w: mSize/x
    h: mSize/y
    x: 0
    while [x < w] [
    	y: 0
    	ssum: 0
    	sqsum: 0
    	val: 0
    	val2: 0
       	while [y < h][
       		pIndexD: (x + (y * w)) * unit 
       		svalue: idx1 + pIndexD
       		d1value: idxD1 + pIndexD
       		d2value: idxD2 + pIndexD 
       		val: rcvGetIntValue as integer! svalue unit 
       		ssum: ssum + val                             
       		sqsum: sqsum + (val * val)
       		either (x = 0) [
       					rcvSetIntValue as integer! d1Value ssum unit
       					rcvSetIntValue as integer! d2Value sqsum unit][
       					 ;sum
       					 d1value: d1value - unit
       					 val: rcvGetIntValue as integer! d1value unit
       					 d1value: d1value + unit
       					 val2: ssum + val
       					 rcvSetIntValue as integer! d1Value val2 unit
       					 ; square sum
       					 d2value: d2value - unit
       					 val: rcvGetIntValue as integer! d2value unit
       					 d2value: d2value + unit
       					 val2: sqsum + val
       					 rcvSetIntValue as integer! d2Value val2 unit
       		]
       		y: y + 1
       	]
    x: x + 1   	
    ]
]

rcvProcessIntegralMat: routine [
"Gets boxes in integral image"
	mat 	[vector!]
	w 		[integer!] 
	h 		[integer!]
	boxW 	[integer!]
	boxH 	[integer!]
	thresh	[integer!]
	points  [block!]
	/local
	x		[integer!] 
	y		[integer!]
	scal0	[integer!] 
	scal1	[integer!] 
	scal2	[integer!] 
	scal3	[integer!]
	val		[integer!]
	s		[c-string!]
][
	s: "box"
	y: boxH 
	while [y < (h - 1)] [
		x: boxW
		while [x < (w - 1)] [
			scal0: rcvGetInt2D mat w x y
			scal1: rcvGetInt2D mat w (x - boxW) (y - boxH)
			scal2: rcvGetInt2D mat w  x (y - boxH) 
			scal3: rcvGetInt2D mat w  (x - boxW) y
			val: (scal0 + scal1 - scal2 - scal3)
			val: val / (boxW * boxH)
			if val <= thresh [
				word/load-in s points				  		; draw dialect word
				pair/make-in points (x - boxW) (y - boxH) 	; top left
				pair/make-in points x y					  	; bottom right
			]
			x: x + 1
		]
		y: y + 1
	]
]


;********************** Integral Images  Functions **************************


rcvIntegral: function [
"Calculates integral images"
	src 	[image! vector!] 
	ssum 	[vector!] 
	sqsum 	[vector!] 
	mSize 	[pair!]
][
	t: type? src
	if t = image!  [rcvIntegralImg src ssum sqsum]
	if t = vector! [rcvIntegralMat src ssum sqsum msize]
]


rcvProcessIntegralImage: function [
"Gets boxes in integral image"
	src 	[image! vector!] 
	w 		[integer!] 
	h 		[integer!] 
	boxW [	integer!] 
	boxH 	[integer!] 
	thresh	[integer!] 
	points 	[block!]
][
	t: type? src
	if t = vector! [rcvProcessIntegralMat src w h boxW boxH thresh points] 
	if t = image! [
		n: src/size/x * src/size/y
		mat: make vector! n
		rcvImage2Mat src mat ; in libs/matrix/rcvMatrix.red
		rcvProcessIntegralMat mat w h boxW boxH thresh points
	]
]






