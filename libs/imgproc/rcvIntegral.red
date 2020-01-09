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

; ****************integral image routines ************************
rcvIntegralImg: routine [
"Direct  integral image"
    src  			[image!]
    dst  			[image!]
    dst2 			[image!]
    /local
        pix1 		[int-ptr!]
        pixD 		[int-ptr!]
        pixD2 		[int-ptr!]
        idxD		[int-ptr!]
        idxD2		[int-ptr!]
        handle1 	[integer!]
        handleD 	[integer!]	
        handleD2	[integer!]
        h 			[integer!]
        w 			[integer!]
        x 			[integer!]
        y 			[integer!]
        pindex		[integer!] 
        pindex2 	[integer!]
        val			[integer!]
        sum 		[integer!]
        sqsum   	[integer!]  
][
    handle1: 	0
    handleD: 	0
    handleD2: 	0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    pixD2: image/acquire-buffer dst2 :handleD2
    idxD: pixD
    idxD2: pixD2
    pindex: 0
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    while [x < w] [
    	sum: 0
    	sqsum: 0
    	y: 0
       	while [y < h][
       		pindex: x + (y * w) 
       		sum: sum + pix1/value
       		sqsum: sqsum + (pix1/value * pix1/value)
       		either x = 0 [pixD/value: sum pixD2/value: sqsum] 
       					 [
       					 ;sum
       					 pixD: idxD + pindex - 1
       					 val: pixD/value + sum
       					 pixD: idxD + pindex
       					 pixD/value: val
       					 ; square sum
       					 pixD2: idxD2 + pindex - 1
       					 val: pixD2/value + sqsum
       					 pixD2: idxD2 + pindex
       					 pixD2/value: val
       					 ]
        	pix1: pix1 + 1
        	y: y + 1
       ]
       x: x + 1
    ]
    
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
    image/release-buffer dst2 handleD2 yes
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
    pindex 	[integer!]
    val		[integer!] 
    val2	[integer!]
    sum 	[integer!]
    sqsum	[integer!]
] [
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
    	sum: 0
    	sqsum: 0
    	val: 0
    	val2: 0
       	while [y < h][
       		pindex: (x + (y * w)) * unit 
       		svalue: idx1 + pindex
       		d1value: idxD1 + pindex
       		d2value: idxD2 + pindex 
       		val: rcvGetIntValue as integer! svalue unit 
       		sum: sum + val                             
       		sqsum: sqsum + (val * val)
       		either (x = 0) [
       					rcvSetIntValue as integer! d1Value sum unit
       					rcvSetIntValue as integer! d2Value sqsum unit
       					 ] 
       					 [
       					 ;sum
       					 d1value: d1value - unit
       					 val: rcvGetIntValue as integer! d1value unit
       					 d1value: d1value + unit
       					 val2: sum + val
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


;********************** Integral Images ****************************

rcvIntegral: function [
"Calculates integral images"
	src 	[image! vector!] 
	sum 	[image! vector!] 
	sqsum 	[image! vector!] 
	mSize 	[pair!]
][
	t: type? src
	if t = image!  [rcvIntegralImg src sum sqsum]
	if t = vector! [rcvIntegralMat src sum sqsum msize]
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
]






