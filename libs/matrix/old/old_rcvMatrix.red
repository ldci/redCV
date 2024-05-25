Red [
	Title:   "Red Computer Vision: Matrix functions"
	Author:  "Francois Jouen"
	File: 	 %rcvMatrix.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;**********************IMPORTANT**************************

; Matrix uses a vector! datatype and will evolve 
; to Matrix! when available :)


;**********************MATRICES ROUTINES **************************

; integer or float matrix type
rcvGetMatType: routine [
"Returns matrix type (integer or float)"
	mat  	[vector!]
	return: [integer!]
	/local
	s		[series!] 
	unit	[integer!] 
	type	[integer!]
] [
	s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	; 1 integer 2 float
	either unit <= 4 [type: 1] [type: 2] 
	type
]

rcvGetMatBitSize: routine [
"Returns matrice bit size"
	mat  	[vector!]
	return: [integer!]
	/local
	s		[series!]  
] [
	s: GET_BUFFER(mat)
	GET_UNIT(s)
]

; gets and sets integer matrix element value
; p address must be passed as integer! since red routine doesn't know byte-ptr!
rcvGetIntValue: routine [
	p		[integer!] ; address of mat element as integer
	unit	[integer!] ; size of integer 8 16 32 [1 2 4]
	return:	[integer!]
] [
	vector/get-value-int as int-ptr! p unit
]

rcvSetIntValue: routine [
	p		[integer!] ; address of mat element as integer
	value	[integer!]
	unit	[integer!] ; size of integer 8 16 32 [1 2 4]
	/local 
	p4		[int-ptr!]	
] [
	 p4: as int-ptr! p
     p4/value: switch unit [
			1 [value and FFh or (p4/value and FFFFFF00h)]
			2 [value and FFFFh or (p4/value and FFFF0000h)]
			4 [value]
	]
]

; gets and sets real matrix element value
; p address must be passed as integer! since red routine doesn't know byte-ptr!
rcvGetFloatValue: routine [
	p		[integer!] ; address of mat element as integer
	return:	[float!]
	/local
	pt64	[float-ptr!]
] [
	pt64: as float-ptr! p
	pt64/value				
]


rcvGetFloat32Value: routine [
	p		[integer!] ; address of mat element as integer
	return:	[float!]
	/local
	pt32	[pointer! [float32!]]	
] [
	vector/get-value-float as byte-ptr! p 4 
]


rcvSetFloatValue: routine [
	p		[integer!] ; address of mat element as integer address
	f		[float!]
	unit	[integer!] ; size of float 32 64  [4 8]
	/local
	pt64 	[pointer! [float!]]
	pt32	[pointer! [float32!]]
	
][
	either unit = 8 [
					pt64: as float-ptr! p
					pt64/value: f
				][
					pt32: as float32-ptr! p
					pt32/value: as float32! f
	]
]

rcvGetInt2D: routine [
"Get integer matrix value"
	mat  		[vector!]
	width       [integer!] 	; matrix width
	x           [integer!]	; x coordinate		
	y           [integer!]	; y coordinate
	return:		[integer!]
	/local
	mvalue		[integer!]
	unit		[integer!]
	idx			[integer!]
][
	mvalue: as integer! vector/rs-head mat
    unit: rcvGetMatBitSize mat
    idx: (x + (y * width)) * unit
    rcvGetIntValue mvalue + idx unit
] 

rcvGetReal2D: routine [
"Get float matrix value"
	mat  		[vector!]
	width       [integer!]
	x           [integer!]
	y           [integer!]
	return:		[float!]
	/local
	mvalue		[integer!]
	unit		[integer!]
	idx			[integer!]
][
	mvalue: as integer! vector/rs-head mat
    unit: rcvGetMatBitSize mat
    idx: (x + (y * width)) * unit
    rcvGetFloatValue  mvalue + idx
] 

rcvGetReal322D: routine [
"Get float matrix value"
	mat  		[vector!]
	width       [integer!]
	x           [integer!]
	y           [integer!]
	return:		[float!]
	/local
	mvalue		[integer!]
	unit		[integer!]
	idx			[integer!]
][
	mvalue: as integer! vector/rs-head mat
    unit: rcvGetMatBitSize mat
    idx: (x + (y * width)) * unit
    rcvGetFloat32Value mvalue + idx 
] 

rcvSetInt2D: routine [
"Set integer matrix value"
	mat  		[vector!]
	mSize		[pair!]
	coordinate 	[pair!]
	val			[integer!]
	/local
	mvalue		[integer!]
	width       [integer!]
	x           [integer!]
	y           [integer!]
	unit		[integer!]
	idx			[integer!]
][
	width: mSize/x
	x: coordinate/x
	y: coordinate/y
	mvalue: as integer! vector/rs-head mat
    unit: rcvGetMatBitSize mat
    idx: (x + (y * width)) * unit
    rcvSetIntValue mvalue + idx val unit
]

rcvSetReal2D: routine [
"Set float matrix value"
	mat  		[vector!]
	mSize		[pair!]
	coordinate 	[pair!]
	val			[float!]
	/local
	mvalue		[integer!]
	width       [integer!]
	x           [integer!]
	y           [integer!]
	unit		[integer!]
	idx			[integer!]
][
	width: mSize/x
	x: coordinate/x
	y: coordinate/y
	mvalue: as integer! vector/rs-head mat
    unit: rcvGetMatBitSize mat
    idx: (x + (y * width)) * unit
    rcvSetFloatValue mvalue + idx val unit
]  

; gets coordinates from a binary mat as x y values

rcvGetPoints: routine [
"Gets coordinates from a binary matrix as pair values"
	binMatrix 	[vector!]
	mSize		[pair!]	
	points		[vector!]
	/local
	svalue 		[integer!]
	x 			[integer!]
	y 			[integer!]
	idx			[integer!]
	width		[integer!]
	height		[integer!]	
	v			[integer!]
	unit		[integer!]
][
	width: mSize/x 
	height: mSize/y
	svalue: as integer! vector/rs-head binMatrix
	vector/rs-clear points
	unit: rcvGetMatBitSize binMatrix
    y: 0
    while [y < height] [
    	x: 0
        while [x < width][
       		v: rcvGetIntValue svalue unit
       		if (v <> 0) [
       			vector/rs-append-int points x
       			vector/rs-append-int points y
       		]
       		x: x + 1
       		svalue: svalue + unit
       ]
       y: y + 1
    ]
]


;Thanks to Nenad
rcvGetPairs: routine [
"Gets coordinates from a binary mat as pair values"
    binMatrix     	[vector!]
    mSize			[pair!]     
    points          [block!]
    /local
    width           [integer!]
    height          [integer!]   
    x y idx x2
    mvalue 
    unit
    v
][
	width: 	mSize/x
	height: mSize/y
    mvalue: as integer! vector/rs-head binMatrix
    unit: rcvGetMatBitSize binMatrix
    block/rs-clear points
    y: 0
    while [y < height] [
    	x: 0
       	while [x < width][
               v: rcvGetIntValue mvalue unit
               if (v <> 0) [pair/make-in points x y]
               x: x + 1
               mvalue: mvalue + unit
       	]
       	y: y + 1
    ]
]

rcvGetMatCentroid: routine [
"Returns the centroid of the matrix"
	mat  		[vector!]
	mSize		[pair!]
    return: 	[pair!]   
	/local
	loc			[red-pair!]
	mvalue 		[byte-ptr!]
	width		[integer!]	
	height		[integer!]
	x			[integer!]
	y			[integer!]
	sumX		[integer!] 
	sumY 		[integer!]
	sumXY		[integer!]
    unit		[integer!]
    v			[integer!]
][	
	width: 	mSize/x
	height: mSize/y
	mvalue: vector/rs-head mat
    unit: rcvGetMatBitSize mat
    y: 0
    sumX: 0 sumY: 0 sumXY: 0
    loc: pair/make-at stack/push* 0 0
    while [y < height] [
    	x: 0
       	while [x < width][
       		v: rcvGetIntValue as integer! mvalue unit
       		if v > 0 [v: 1]
       		sumX: sumX + (x * v)
       		sumY: sumY + (y * v)
       		sumXY: sumXY + v
            x: x + 1
            mvalue: mvalue + unit
       	]
       	y: y + 1
    ]
    loc/x: (sumX / sumXY)
    loc/y: (sumY / sumXY)
    as red-pair! stack/set-last as cell! loc
]


rcvCopyMatI: routine [
"Copy integer matrix"
   	src  	[vector!]
    dst  	[vector!]
    /local
    svalue 	[byte-ptr!]
    tail 	[byte-ptr!]
    dvalue 	[byte-ptr!]
    p4 		[int-ptr!]
    unit	[integer!] 
    val		[integer!]
][
    svalue: vector/rs-head src  	
    tail: vector/rs-tail src		
	dvalue: vector/rs-head dst			
	unit: rcvGetMatBitSize src 
   	while [svalue < tail][
		val: vector/get-value-int as int-ptr! svalue unit
		p4: as int-ptr! dvalue
		p4/value: switch unit [
					1 [val and FFh or (p4/value and FFFFFF00h)]
					2 [val and FFFFh or (p4/value and FFFF0000h)]
					4 [val]
		]
		svalue: svalue + unit
		dvalue: dvalue + unit
    ]
]

; copy float matrices
rcvCopyMatF: routine [
"Copy float matrix"
   	src  	[vector!]
    dst  	[vector!]
    /local
    svalue	[byte-ptr!] 
    tail	[byte-ptr!] 
    dvalue 	[byte-ptr!]
    p64		[float-ptr!] 
    p32 	[float32-ptr!]
    unit	[integer!]  
    val		[float!] 		
] [
    svalue: vector/rs-head src	  
    tail: vector/rs-tail src	
	dvalue: vector/rs-head dst	
	unit: rcvGetMatBitSize src
   	while [svalue < tail][
		val: vector/get-value-float svalue unit
		either unit = 8 [p64: as pointer! [float!] dvalue  p64/value: val]
					    [p32: as pointer! [float32!] dvalue p32/value: as float32! val]
		svalue: svalue + unit
		dvalue: dvalue + unit
    ]
]


rcvMakeBinaryMat: routine [
"Makes  0 1 matrix"
   	src  	[vector!]
    dst  	[vector!]
    /local
    svalue	[byte-ptr!] 
    tail 	[byte-ptr!]
    dvalue	[byte-ptr!] 
    p4 		[int-ptr!]
    unit 	[integer!]
    val		[integer!] 
    val2	[integer!]	
][
    svalue: vector/rs-head src  	
    tail: vector/rs-tail src		
	dvalue: vector/rs-head dst			
	unit: rcvGetMatBitSize src 
   	while [svalue < tail][
		val: rcvGetIntValue as integer! svalue unit
		either val > 0 [val2: 1] [val2: 0]
		p4: as int-ptr! dvalue
		p4/value: switch unit [
					1 [val2 and FFh or (p4/value and FFFFFF00h)]
					2 [val2 and FFFFh or (p4/value and FFFF0000h)]
					4 [val2]
		]
		svalue: svalue + unit
		dvalue: dvalue + unit
    ]
]

;
; 8 -> 16-bits OK (for 8-bit -127..+127)
; 8 -> 32-bits OK
; 16 -> 32-bits OK

; a revoir
rcvConvertMatScale: function [
"Converts Matrix Scale"
	src 		[vector!] 
	dst 		[vector!] 
	srcScale 	[number!] 
	dstScale 	[number!] 
	/fast /std
][
	if type? srcScale = integer! [srcScale: to float! srcScale]
	if type? dstScale = integer! [dstScale: to float! dstScale]
	case [
		std  [n: length? src
					i: 1
					while [i <= n] [
						dst/(i): to integer! ((src/(i) / srcScale) * dstScale)
	 					i: i + 1]
	 				]
		fast	[rcvConvertMatIntScale src dst srcScale dstScale]
	]	
]
; a rajouter
rcvConvertMatIntScale: routine [
"Converts integer matrix scale"
	src			[vector!]
	dst			[vector!]
	srcScale	[float!] ; eg FFh
	dstScale	[float!] ; eg FFFFh	
	/local
	svalue 		[byte-ptr!]
	tail 		[byte-ptr!]
	int unit	[integer!]
	v			[float!]
][
	svalue: vector/rs-head src  ; get a pointer address of the source matrix first value
	tail:  vector/rs-tail src	; last
	vector/rs-clear dst 		; clears destination for append calculated value
	unit: rcvGetMatBitSize src ; bit size
	while [svalue < tail][
		int: vector/get-value-int as int-ptr! svalue unit
		switch unit [
			1 [int: int and FFh]
			2 [int: int and FFFFh]
			4 [int: int]
		]
		v: as float! int
		v: (v / srcScale) * dstScale 
		int: as integer! v
		vector/rs-append-int dst int
		svalue: svalue + unit
	]
]

; Red Image -> 1 channel 2-D matrice with a grayscale 
; conversion to 8 16 or 32-bit matrices 
; values are in 0..255 range for Char! matrix

rcvImage2Mat: routine [
"Red Image to integer or char [0..255] 2-D Matrix "
	src		[image!]
	mat		[vector!]
	/local
	pix1 	[int-ptr!]
	dvalue 	[byte-ptr!]
	handle1	[integer!]
	unit	[integer!]
	h 		[integer!]
	w 		[integer!]
	x 		[integer!]
	y 		[integer!]
	r 		[integer!]
	g 		[integer!]
	b		[integer!] 
	a 		[integer!]
	rgb		[integer!]
] [
	handle1: 0
    pix1: image/acquire-buffer src :handle1
    w: IMAGE_WIDTH(src/size) 
    h: IMAGE_HEIGHT(src/size) 
    y: 0 
    dvalue: vector/rs-head mat	; a byte ptr
	unit: rcvGetMatBitSize mat ; bit size
    while [y < h] [
    	x: 0
       	while [x < w][
			a: pix1/value >>> 24
       		r: pix1/value and FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
        	b: pix1/value and FFh 
        	;OK RGBA are correct
        	; -> to Grayscale mat
        	rgb: r + g + b / 3
        	rcvSetIntValue as integer! dvalue rgb unit
           	x: x + 1
           	pix1: pix1 + 1
           	dValue: dValue + unit
       	]
       	y: y + 1
    ]
    image/release-buffer src handle1 no
]

; 1 channel 2-D matrice (grayscale) -> Red Image 
; 8 16 and 32-bit integer matrices can be used
; for 8-bit -127..+127 values are transformed in 0..255 values
; for 8-bit byte matrix values remain unchnaged

rcvMat2Image: routine [
"Matrix to Red Image"
	mat		[vector!]
	dst		[image!]
	/local
	pixD 	[int-ptr!]
	value	[byte-ptr!]
	handle	[integer!]
	unit   	[integer!]
	i 		[integer!]
	h		[integer!] 
	w		[integer!] 
	x 		[integer!]
	y		[integer!]	
][
	handle: 0
    pixD: image/acquire-buffer dst :handle
    w: IMAGE_WIDTH(dst/size) 
    h: IMAGE_HEIGHT(dst/size) 
    value: vector/rs-head mat ; get pointer address of the matrice
    unit: rcvGetMatBitSize mat ; bit size
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
       		i: rcvGetIntValue as integer! value unit; get mat value as integer
       		if unit = 1 [i: i and FFh] ; for 8-bit values [-127 .. 127]
       		pixD/value: ((255 << 24) OR (i << 16 ) OR (i << 8) OR i)
       		value: value + unit
           	pixD: pixD + 1
           	x: x + 1
       ]
       y: y + 1
    ]
    image/release-buffer dst handle yes
]

; Splits image to 4 matrices including transparency
; image and matrices must have the same size!

rcvSplit2Mat: routine [
"Splits an image to 4 8-bit matrices"
	src			[image!]
	mat0		[vector!]
	mat1		[vector!]
	mat2		[vector!]
	mat3		[vector!]
	/local
	pix1 		[int-ptr!]
	dvalue0 	[byte-ptr!]
	dvalue1 	[byte-ptr!]
	dvalue2 	[byte-ptr!]
	dvalue3 	[byte-ptr!]
	handle1		[integer!]
	h			[integer!] 
	w 			[integer!]
	x 			[integer!]
	y 			[integer!]
	unit		[integer!]
] [
	handle1: 0
    pix1: image/acquire-buffer src :handle1
    w: IMAGE_WIDTH(src/size) 
    h: IMAGE_HEIGHT(src/size) 
    y: 0 
    unit: rcvGetMatBitSize mat0
    dvalue0: vector/rs-head mat0	; a byte ptr
    dvalue1: vector/rs-head mat1	; a byte ptr
    dvalue2: vector/rs-head mat2	; a byte ptr
    dvalue3: vector/rs-head mat3	; a byte ptr
    while [y < h] [
    	x: 0
       	while [x < w][
        	rcvSetIntValue as integer! dvalue0 pix1/value >>> 24 unit
        	rcvSetIntValue as integer! dvalue1 pix1/value and 00FF0000h >> 16 unit
        	rcvSetIntValue as integer! dvalue2 pix1/value and FF00h >> 8 unit
        	rcvSetIntValue as integer! dvalue3 pix1/value and FFh unit
           	x: x + 1
           	pix1: pix1 + 1
           	dValue0: dValue0 + unit
           	dValue1: dValue1 + unit
           	dValue2: dValue2 + unit
           	dValue3: dValue3 + unit
       	]
       	y: y + 1
    ]
    image/release-buffer src handle1 no
]

; 3 1-channel 2-D matrices (grayscale) -> Red Image 

rcvMerge2Image: routine [
"Merge 4 8-bit matrices to image"
	mat0		[vector!]
	mat1		[vector!]
	mat2		[vector!]
	mat3		[vector!]
	dst			[image!]
	/local
	pixD 		[int-ptr!]
	value0 		[byte-ptr!]
	value1 		[byte-ptr!]
	value2 		[byte-ptr!]
	value3 		[byte-ptr!]
	handle		[integer!]
	a			[integer!] 
	r 			[integer!]
	g 			[integer!]
	b  			[integer!]
	h			[integer!] 
	w 			[integer!]
	x 			[integer!]
	y			[integer!]
	unit		[integer!]
	
] [
	handle: 0
    pixD: image/acquire-buffer dst :handle
    w: IMAGE_WIDTH(dst/size) 
    h: IMAGE_HEIGHT(dst/size) 
    
    y: 0
	unit: rcvGetMatBitSize mat0
    value0: vector/rs-head mat0 ; get pointer address of the matrice
    value1: vector/rs-head mat1 
    value2: vector/rs-head mat2
    value3: vector/rs-head mat3
    while [y < h] [
    	x: 0
       	while [x < w][
       		a: rcvGetIntValue as integer! value0 unit; get mat value as integer
       		r: rcvGetIntValue as integer! value1 unit; get mat value as integer
       		g: rcvGetIntValue as integer! value2 unit; get mat value as integer
       		b: rcvGetIntValue as integer! value3 unit; get mat value as integer
       		pixD/value: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)
       		value0: value0 + unit
       		value1: value1 + unit
       		value2: value2 + unit
       		value3: value3 + unit
           	pixD: pixD + 1
           	x: x + 1
       	]
       	y: y + 1
    ]
    image/release-buffer dst handle yes
]



; new to be updated
rcvImg2Array: routine [
"Red image to array"
	src 	[image!] 
	op		[integer!]
	return: [block!]
	/local
	blk		[red-block!]
	*Mat	[int-ptr!]
	idx 	[int-ptr!]
	p		[byte-ptr!]
	ptr		[int-ptr!]
	vect 	[red-vector!]
	s	   	[series!]
	w 		[integer!]
	h		[integer!]
	i 		[integer!]
	j 		[integer!]
	handle  [integer!] 
	r g b a
][
	w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    handle: 0
	*Mat: image/acquire-buffer src :handle
	blk: as red-block! stack/arguments
	block/make-at blk h
	j: 0
	while [j < h] [
		i: 0
		vect: vector/make-at stack/push* w TYPE_INTEGER 4
		while [i < w] [
			idx: *Mat + (j * w + i)
			s: GET_BUFFER(vect)
			p: alloc-tail-unit s 4		
			ptr: as int-ptr! p
			r: idx/value and FF0000h >> 16
			g: idx/value and FF00h >> 8
			b: idx/value and FFh
			a: idx/value >>> 24
       		switch op [
       			1 [ptr/value:  r]				;r channel
       			2 [ptr/value:  g]				;g channel
       			3 [ptr/value:  b]				;b channel
       			4 [ptr/value:  a]				;alpha channel
       			5 [ptr/value:  idx/value]		;rgba 
       			6 [ptr/value: (r + b + g) / 3]	;grayscale
       		]
			i: i + 1
		]
		block/rs-append blk as red-value! vect
		j: j + 1
	]
	image/release-buffer src handle no
	blk
]


_rcvMat2Array: routine [
"Matrice to array"
	mat 	[vector!] 
	matSize [pair!]
	/local
	blk		[red-block!]
	*Mat	[byte-ptr!]
	idx 	[byte-ptr!]
	vect 	[red-vector!]
	s	   	[series!]
	w 		[integer!]
	h		[integer!]
	i 		[integer!]
	j 		[integer!]	 
	p		[byte-ptr!]
	p4		[int-ptr!]
	p8		[float-ptr!]
	unit	[integer!]	
][
	w: matSize/x
	h: matSize/y
	*Mat: vector/rs-head mat
	s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	blk: as red-block! stack/arguments
	block/make-at blk h
	j: 0
	while [j < h] [
		i: 0
		either unit <= 4 [vect: vector/make-at stack/push* w TYPE_INTEGER unit] 
						 [vect: vector/make-at stack/push* w TYPE_FLOAT unit] 
		while [i < w] [
			idx: *Mat + (j * w + i * unit)
			s: GET_BUFFER(vect)
			p: alloc-tail-unit s unit
			p4: as int-ptr! p
			p8: as float-ptr! p	
			either unit <= 4 [p4/value: vector/get-value-int as int-ptr! idx unit] 
				[p8/value: vector/get-value-float idx unit]
			i: i + 1
		]
		block/rs-append blk as red-value! vect
		j: j + 1
	]
	blk
]

rcvMat2Array: routine [
"Vector to block of vectors (Array)"
	mat 	[vector!] 
	matSize [pair!]
	return: [block!]
	/local
	blk		[red-block!]
	*Mat	[byte-ptr!]
	idx 	[byte-ptr!]
	vect 	[red-vector!]
	s	   	[series!]
	w 		[integer!]
	h		[integer!]
	i 		[integer!]
	j 		[integer!]	 
	p		[byte-ptr!]
	p4		[int-ptr!]
	p8		[float-ptr!]
	unit	[integer!]	
][
	w: matSize/x
	h: matSize/y
	*Mat: vector/rs-head mat
	s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	blk: as red-block! stack/arguments
	block/make-at blk h
	j: 0
	while [j < h] [
		i: 0
		either unit <= 4 [vect: vector/make-at stack/push* w TYPE_INTEGER unit] 
						 [vect: vector/make-at stack/push* w TYPE_FLOAT unit] 
		while [i < w] [
			idx: *Mat + (j * w + i * unit)
			s: GET_BUFFER(vect)
			p: alloc-tail-unit s unit
			p4: as int-ptr! p
			p8: as float-ptr! p	
			either unit <= 4 [p4/value: vector/get-value-int as int-ptr! idx unit] 
				[p8/value: vector/get-value-float idx unit]
			i: i + 1
		]
		block/rs-append blk as red-value! vect
		j: j + 1
	]
	as red-block! stack/set-last as cell! blk 
]


rcvArray2Mat: routine [
"Block of vectors (Array) to matrix (vector)"
	array 		[block!] 	; array of vectors
	return: 	[vector!]
	/local
	headX		[red-value!]
	tailX		[red-value!]
	x* 			[red-vector!]
	vectBlkX	[red-vector!]
	vx 			[byte-ptr!]
	s			[series!]
	unit		[integer!]
	nx			[integer!]
	ny			[integer!]
	y			[integer!]
	x			[integer!]
	idx			[integer!]
	p4			[int-ptr!]
	p8			[float-ptr!]
][
	headX: block/rs-head array
	tailX: block/rs-tail array
	ny: block/rs-length? array
	vectBlkX: as red-vector! headX
	vx: vector/rs-head vectBlkX
    nx: vector/rs-length? vectBlkX
    s: GET_BUFFER(vectBlkX)
	unit: GET_UNIT(s)
	either unit <= 4 [x*: vector/make-at stack/push* nx * ny TYPE_INTEGER unit] 
					 [x*: vector/make-at stack/push* nx * ny TYPE_FLOAT unit] 
	y: 0
	while [headX < tailX] [
		vectBlkX: as red-vector! headX
		vx: vector/rs-head vectBlkX
    	p4: as int-ptr! vector/rs-head x*
		p8: as float-ptr! vector/rs-head x*
		x: 0
		while [x < nx] [
			idx: y * nx + x + 1
			either unit <= 4 [p4/idx: vector/get-value-int as int-ptr! vx unit] 
				[p8/idx: vector/get-value-float vx unit]
			vx: vx + unit
			x: x + 1
		]
		y: y + 1
		headX: headX + 1
	]
	s: GET_BUFFER(x*)
	either unit <= 4 [s/tail: as cell! (as int-ptr! s/offset) + (nx * ny)]
					 [s/tail: as cell! (as float-ptr! s/offset) + (nx * ny)]  
	as red-vector! stack/set-last as cell! x* 
]

rcvBlendMat: routine [
"Computes the alpha blending of two matrices"
	mat1		[vector!]
	mat2		[vector!]
	dst			[vector!]
	alpha		[float!]
	/local
	svalue1 	[byte-ptr!]
	svalue2 	[byte-ptr!]
	tail 		[byte-ptr!]
	unit 		[integer!]
	int1 		[integer!]
	int2 		[integer!]
	v			[integer!]
	calpha		[float!]
][
	calpha: 1.0 - alpha
	svalue1: vector/rs-head mat1 
	svalue2: vector/rs-head mat2 
    tail: vector/rs-tail mat1
    vector/rs-clear dst 
	unit: rcvGetMatBitSize mat1
    while [svalue1 < tail][
		int1: vector/get-value-int as int-ptr! svalue1 unit
		int2: vector/get-value-int as int-ptr! svalue2 unit
		v: as integer! (alpha * int1 + calpha * int2)
		vector/rs-append-int dst v
		svalue1: svalue1 + unit
		svalue2: svalue2 + unit
	]
]

rcvInRangeMat: routine [
"Extracts sub array from matrix according to lower and upper values"
	mat1		[vector!]
	dst			[vector!]
	lower		[integer!]
	upper		[integer!]
	op			[integer!]
	/local
	svalue1 	[byte-ptr!]
	tail 		[byte-ptr!]
	unit 		[integer!]
	int1 		[integer!]
	v			[integer!]
] [
	vector/rs-clear dst
	svalue1: vector/rs-head mat1
	tail: vector/rs-tail mat1
	unit: rcvGetMatBitSize mat1
	while [svalue1 < tail][
		int1: vector/get-value-int as int-ptr! svalue1 unit
		either ((int1 >= lower) and (int1 <= upper)) [
			if op = 0 [v: FFh]
			if op = 1 [v: int1]
		] [v: 0]
		vector/rs-append-int dst v
		svalue1: svalue1 + unit
	]
]


;************************** Mat Functions ******************************
rcvCreateMat: function [ 
"Creates 2D matrix"
	type [word!] 
	bitSize [integer!] 
	mSize [pair!]
][
	xSize: mSize/x
	ySize: mSize/y
	make vector! reduce  [type bitSize xSize * ySize]
]

rcvInitMat: function [ 
"Creates 2D matrix"
	type 	[integer!] 
	bitSize [integer!] 
	mSize 	[pair!]
][
	matrix/init type bitSize mSize	
]



; should be modified as a routine with vector/delete mat
rcvReleaseMat: function [
"Releases Matrix"
	mat [vector!]
][
	mat: none
]

rcvCloneMat: function [
"Returns a copy of source matrix"
	src [vector!]
][
	t: rcvGetMatType src
	if t = 1 [dst: make vector! reduce  [integer! length? src] rcvCopyMatI src dst]
	if t = 2 [dst: make vector! reduce  [float!   length? src] rcvCopyMatF src dst] 
	dst
]

rcvCopyMat: function [
"Copy source matrix to destination matrix"
	src [vector!] 
	dst [vector!]
][
	t: rcvGetMatType src
	if t = 1 [rcvCopyMatI src dst]
	if t = 2 [rcvCopyMatF src dst] 
]

makeRange: func [
	a 		[number!] 
	b 		[number!] 
	step 	[number!]][
    collect [i: a - step until [keep i: i + step i = b]]
]

rcvMakeRangeMat: function [
"Creates an ordered matrix"
	a 		[number!] 
	b 		[number!] 
	step 	[number!] 
][
	tmp: makeRange a b step
	make vector! tmp
]

; A verifier pas utile
{rcvCreateRangeMat: function [
	a [number!] 
	b [number!] 
][
	tmp: makeRange a b
	make vector! tmp
]}

rcvMakeIndenticalMat: func [
"Creates a matrix with identical values"
	type 	[word!] 
	bitSize [integer!] 
	vSize 	[integer!] 
	value 	[number!]
][
	tmp: make vector! reduce  [type bitSize vSize]
	tmp + value
]


rcvSortMat: function [
"Ascending sort of matrix"
	v [vector!] 
][
	vv: copy v ; to avoid source modification
	sort vv
]


;news
rcvSortMatrix: routine [
"Sort integer matrix"
	arr 	[vector!]
	dir		[integer!]
	/local
	ptr		[int-ptr!]					
	n		[integer!]
	i 		[integer!]
	j		[integer!]
	j2		[integer!]
	tmp 	[integer!]
	t
][
	n: vector/rs-length? arr
	ptr: as int-ptr! vector/rs-head arr
	i: 1
	either dir = 1 [t: ptr/i < ptr/j] ;  1: sort 
				   [t: ptr/i > ptr/j] ; -1: reverse sort
	while [i <= n] [
		j: 1
		while [j < i] [
			if t [
				j2: j + 1
				tmp: ptr/i
				ptr/i: ptr/j2
				ptr/j2: ptr/j
				ptr/j: tmp
			]
			j: j + 1
		]
		i: i + 1
	]
]



rcvFlipMat: function [
"Reverses matrix"
	v [vector!] 
][
	vv: copy v ; to avoid source modification
	reverse vv
]

rcvLengthMat: function [
"Matrix length as integer value"
	mat [vector!] 
] [
	length? mat
]

rcvSumMat: function [
"Matrix sum as float value"
	mat [vector!]
][
	sum: 0.0
	foreach value mat [sum: sum + value]
	sum
]

rcvMeanMat: function [
"Matrix mean as float value"
	mat [vector!] 
][
	(rcvSumMat mat) / (rcvLengthMat mat)
]

rcvMeanMats: function [
"dst: src1 + src2 / 2"
	src1 [vector!] 
	src2 [vector!] 
][
	(src1 + src2) / 2
]

rcvProdMat: function [
"Matrix product as float value"
	mat [vector!] 
][
	prod: to-float mat/1
	n: length? mat
	i: 2
	while [i <= n] [
		prod: (prod * mat/:i)
		i: i + 1
	]
	prod
]

rcvMaxMat: function [
"Max value of the matrix as number"
	mat [vector!] 
][
	n: length? mat
	vMax: mat/1
	i: 2
	repeat i n [
		either (mat/:i > vMax) [vMax: mat/:i] [vMax: vMax]
	]
	vMax
]

rcvMinMat: function [
"Min value of the matrix as number"
	mat [vector!] 
][
	n: length? mat
	vMin: mat/1
	i: 2
	repeat i n [
		either (mat/:i < vMin) [vMin: mat/:i] [vMin: vMin]
	]
	vMin
]

rcvRandomMat: function [
"Randomize matrix"
	mat 	[vector!] 
	value 	[integer!]
][
	forall mat [mat/1: random value]
]

rcvColorMat: function [
	"Set matrix color"
	mat 	[vector!] 
	value 	[integer!]
][
	; for interpreted
	;n: length? mat
	;i: 1
	;while [i <= n] [mat/(i): value i: i + 1]
	forall mat [mat/1: value]
]

rcvMat2Binary: function [
"Matrix to binary value"
	mat [vector!] 
][
	to-binary to-block mat
]

rcvConvertMatScale2: function [
"Converts Matrix Scale"
	src 		[vector!] 
	dst 		[vector!] 
	srcScale 	[number!] 
	dstScale 	[number!] 
	/fast /std
][
	if type? srcScale = integer! [srcScale: to float! srcScale]
	if type? dstScale = integer! [dstScale: to float! dstScale]
	rcvConvertMatScale src dst srcScale dstScale
]

rcvMatInt2Float: function [
"Converts Integer Matrix to Float [0.0..1.0] matrix"	
	src 		[vector!] 
	dst 		[vector!] 
	srcScale 	[number!]
][
	if type? srcScale = integer! [srcScale: to float! srcScale]
	n: length? src
	repeat i n [dst/(i): to float! (src/(i)) / srcScale]
]

rcvMatFloat2Int: function [
"Converts float matrix [0.0 ..1.0] to integer [0..255] matrix"	
	src 		[vector!] 
	dst 		[vector!] 
	dstScale 	[number!]
][
	if type? dstScale = integer! [dstScale: to float! dstScale]
	mini: rcvMinMat src
	maxi: rcvMaxMat src
	f: dstScale / (maxi - mini)
	n: length? src
	repeat i n [if error? try [dst/:i: to integer! (src/:i * f)]
				[dst/:i: to integer! dstScale]
	]
]

rcvLogMatFloat: function [
"Applies log-10 transform"	
	src 		[vector!] 
	dst 		[vector!] 
][
	n: length? src
	forall src [
		src/1: log-10 (10.0 + src/1)
	]
	maxi: rcvMaxMat src
	mini: rcvMinMat src
	repeat i n [dst/(i): (src/(i) - mini) / (maxi - mini)]
]

;***********************Matrices Operations *********************

rcvAddMat: function [
"dst: src1 +  src2"
	src1 [vector!] 
	src2 [vector!] 
][
	src1 + src2
]


rcvSubMat: function [
"dst: src1 -  src2"
	src1 [vector!] 
	src2 [vector!] 
][
	src1 - src2
]

rcvMulMat: function [
"dst: src1 *  src2"
	src1 [vector!] 
	src2 [vector!] 
][
	src1 * src2
]

rcvDivMat: function [
"dst: src1 /  src2"
	src1 [vector!] 
	src2 [vector!] 
][
	src1 / src2
]

rcvRemMat: function [
"dst: src1 % src2"
	src1 [vector!] 
	src2 [vector!] 
][
	src1 % src2
]




; ****************************scalars*******************************
; Scalar operations directly modify vector
rcvAddSMat: function [
"src +  value"
	src 	[vector!] 
	value 	[integer!] 
][
	src + value
]

rcvSubSMat: function [
"src -  value"
	src 	[vector!] 
	value 	[integer!]
][
	src - value
]

rcvMulSMat: function [
"src *  value"
	src [vector!] 
	value [integer!] 
][
	src * value
]

rcvDivSMat: function [
"src /  value"
	src [vector!] 
	value [integer!]
][
	src / value
]

rcvRemSMat: function [ 
"dst: src %  value"
	src [vector!] 
	value [integer!]
][
	src % value
]

;**********************Logical ************************************

rcvANDMat: function [
"dst: src1 AND  src2"
	src1 [vector!] 
	src2 [vector!] 
][
	src1 AND src2
]

rcvORMat: function [
"dst: src1 OR src2"
	src1 [vector!] 
	src2 [vector!]
][
	src1 OR src2
]

rcvXORMat: function [
"dst: src1 XOR  src2"
	src1 [vector!] 
	src2 [vector!]
][
	src1 XOR src2
]

; Scalar operations directly modify vector

rcvANDSMat: function [
"src AND  value"
	src 	[vector!] 
	value 	[integer!]
][
	src AND value
]

rcvORSMat: function [
"src OR value"
	src 	[vector!] 
	value 	[integer!]
][
	src OR value
]

rcvXORSMat: function [
"src XOR value"
	src 	[vector!] 
	value 	[integer!]
][
	src XOR value
]















