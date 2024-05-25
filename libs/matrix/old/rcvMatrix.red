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

;********************** NEW MATRIX OBJECT **************************

#include %matrix-as-obj/matrix-obj.red
#include %matrix-as-obj/routines-obj.red

;********************** MATRICES ROUTINES **************************

; integer or float matrix type
rcvGetMatType: routine [
"Returns matrix type (integer or float)"
	mObj  	[object!]
	return: [integer!]
	/local
	vec 	[red-vector!]
	unit	[integer!] 
	type	[integer!]
] [
	vec: mat/get-data mObj
	switch vec/type [
		TYPE_CHAR 		[type: 1]
		TYPE_INTEGER 	[type: 2]
		TYPE_FLOAT		[type: 3]
	]
	type
]

rcvGetMatUnit: routine [
"Returns matrice unit"
	mObj  	[object!] ;--replace [vector!]
	return: [integer!]
] [
	mat/get-unit mObj
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
	pt32	[float32-ptr!]	
] [
	;vector/get-value-float as byte-ptr! p 4 
	pt32: as float32-ptr! p
	as float! pt32/value
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
	mObj  		[object!]
	x           [integer!]	; x coordinate		
	y           [integer!]	; y coordinate
	return:		[integer!]
	/local
	vec 		[red-vector!]
	width       [integer!] 	; matrix width
	mvalue		[integer!]
	unit		[integer!]
	idx			[integer!]
][
	vec: mat/get-data mObj
	unit: mat/get-unit mObj
	width: mat/get-cols mObj
	mvalue: as integer! vector/rs-head vec
	idx: (y - 1 * width + x)	;--red 1-based index
	idx: (idx - 1) * unit		;--red/S 0-based index
    rcvGetIntValue mvalue + idx unit
] 

rcvGetReal2D: routine [
"Get float matrix value"
	mObj  		[object!]
	x           [integer!]
	y           [integer!]
	return:		[float!]
	/local
	vec 		[red-vector!]
	width       [integer!]
	mvalue		[integer!]
	unit		[integer!]
	idx			[integer!]
][
	vec: mat/get-data mObj
	unit: mat/get-unit mObj
	width: mat/get-cols mObj
	mvalue: as integer! vector/rs-head vec
    idx: (y - 1 * width + x)	;--red 1-based index
	idx: idx - 1 * unit			;--red/S 0-based index
    rcvGetFloatValue  mvalue + idx
] 

rcvGetReal322D: routine [
"Get float matrix value"
	mObj  		[object!]
	x           [integer!]
	y           [integer!]
	return:		[float!]
	/local
	vec 		[red-vector!]
	width       [integer!]
	mvalue		[integer!]
	unit		[integer!]
	idx			[integer!]
][
	vec: mat/get-data mObj
	unit: mat/get-unit mObj
	width: mat/get-cols mObj
	mvalue: as integer! vector/rs-head vec
    idx: (y - 1 * width + x)	;--red 1-based index
	idx: idx - 1 * unit			;--red/S 0-based index
    rcvGetFloat32Value  mvalue + idx
] 

rcvSetInt2D: routine [
"Set integer matrix value"
	mObj  		[object!]
	coordinate 	[pair!]
	val			[integer!]
	/local
	vec 		[red-vector!]
	mvalue		[integer!]
	width       [integer!]
	x           [integer!]
	y           [integer!]
	unit		[integer!]
	idx			[integer!]
][
	x: coordinate/x
	y: coordinate/y
	vec: mat/get-data mObj
	unit: mat/get-unit mObj
	width: mat/get-cols mObj
	mvalue: as integer! vector/rs-head vec
    idx: (y - 1 * width + x)	;--red 1-based index
	idx: idx - 1 * unit			;--red/S 0-based index
    rcvSetIntValue mvalue + idx val unit
]

rcvSetReal2D: routine [
"Set integer matrix value"
	mObj  		[object!]
	coordinate 	[pair!]
	val			[float!]
	/local
	vec 		[red-vector!]
	mvalue		[integer!]
	width       [integer!]
	x           [integer!]
	y           [integer!]
	unit		[integer!]
	idx			[integer!]
][
	x: coordinate/x
	y: coordinate/y
	vec: mat/get-data mObj
	unit: mat/get-unit mObj
	width: mat/get-cols mObj
	mvalue: as integer! vector/rs-head vec
    idx: (y - 1 * width + x)	;--red 1-based index
	idx: idx - 1 * unit			;--red/S 0-based index
    rcvSetFloatValue mvalue + idx val unit
]

; gets coordinates from a binary mat as x y values
rcvGetPoints: routine [
"Gets coordinates from a binary matrix as pair values"
	mObj  		[object!]
	points		[vector!]
	/local
	vec 		[red-vector!]
	mvalue 		[integer!]
	x 			[integer!]
	y 			[integer!]
	idx			[integer!]
	width		[integer!]
	height		[integer!]	
	v			[integer!]
	unit		[integer!]
][
	vec: mat/get-data mObj
	unit: mat/get-unit mObj
	width: mat/get-cols mObj
	height: mat/get-rows mObj
	mvalue: as integer! vector/rs-head vec
	vector/rs-clear points
    y: 0
    while [y < height] [
    	x: 0
        while [x < width][
       		v: rcvGetIntValue mvalue unit
       		if (v <> 0) [
       			vector/rs-append-int points x
       			vector/rs-append-int points y
       		]
       		x: x + 1
       		mvalue: mvalue + unit
       ]
       y: y + 1
    ]
]

;Thanks to Nenad
rcvGetPairs: routine [
"Gets coordinates from a binary mat as pair values"
    mObj  		[object!]     
    points      [block!]
    /local
    vec			[red-vector!]
    width		[integer!]
    height		[integer!]   
    x 			[integer!]
    y 			[integer!]
    idx			[integer!]
    mvalue 		[integer!]
    unit		[integer!]
    v			[integer!]
][
    vec: mat/get-data mObj
	unit: mat/get-unit mObj
	width: mat/get-cols mObj
	height: mat/get-rows mObj
	mvalue: as integer! vector/rs-head vec
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
"Returns the coordinates of the centroid of the matrix"
	mObj  		[object!]  
    return: 	[pair!]   
	/local
	vec 		[red-vector!]
	loc			[red-pair!]
	mvalue 		[integer!]
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
	vec: mat/get-data mObj
	unit: mat/get-unit mObj
	width: mat/get-cols mObj
	height: mat/get-rows mObj
	mvalue: as integer! vector/rs-head vec
    y: 0
    sumX: 0 sumY: 0 sumXY: 0
    loc: pair/make-at stack/push* 0 0
    while [y < height] [
    	x: 0
       	while [x < width][
       		;v: rcvGetIntValue mvalue unit
       		v: vector/get-value-int as int-ptr! mvalue unit
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


;-- this routine allows fast computation but requires integer matrix
_rcvMakeBinaryMat: routine [
"Makes  0 1 matrix"
   	src  	[vector!]
    dst  	[vector!]
    /local
    svalue	[byte-ptr!] 
    tail 	[byte-ptr!]
    dvalue	[byte-ptr!] 
    p4 		[int-ptr!]
    val		[integer!] 
    s		[series!]
    unit	[integer!]
][
    svalue: vector/rs-head src  	
    tail: vector/rs-tail src		
	dvalue: vector/rs-head dst	
	s: GET_BUFFER(src)
	unit: GET_UNIT(s)	
   	while [svalue < tail][
		val: rcvGetIntValue as integer! svalue unit
		either val > 0 [val: 1] [val: 0]
		p4: as int-ptr! dvalue
		p4/value: switch unit [
					1 [val and FFh or (p4/value and FFFFFF00h)]
					2 [val and FFFFh or (p4/value and FFFF0000h)];
					4 [val]
		]
		svalue: svalue + unit
		dvalue: dvalue + unit
    ]
]

_rcvConvertMatIntScale: routine [
"Converts integer matrix scale"
	src			[vector!]
	dst			[vector!]
	srcScale	[float!] ; eg FFh
	dstScale	[float!] ; eg FFFFh	
	/local
	svalue 		[byte-ptr!]
	tail 		[byte-ptr!]
	int 		[integer!]
	v			[float!]
	s			[series!]
    unit		[integer!]
][
	s: GET_BUFFER(src)
	unit: GET_UNIT(s)	
	svalue: vector/rs-head src  ; get a pointer address of the source matrix first value
	tail:  vector/rs-tail src	; last
	vector/rs-clear dst 		; clears destination for append calculated value
	while [svalue < tail][
		int: vector/get-value-int as int-ptr! svalue unit
		if unit = 1 [int: int and FFh]
		v: as float! int
		v: (v / srcScale) * dstScale 
		int: as integer! v
		vector/rs-append-int dst int
		svalue: svalue + unit
	]
]

;--grayscale matrices
rcvImage2Mat: routine [
"Red Image to integer or char [0..255] 2-D Matrix "
	src		[image!]
	mObj	[object!]
	/local
	pix1 	[int-ptr!]
	dvalue 	[byte-ptr!]
	vec 	[red-vector!]
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
    vec: mat/get-data mObj
	unit: mat/get-unit mObj
    dvalue: vector/rs-head vec	; a byte ptr
    while [y < h] [
    	x: 0
       	while [x < w][
			a: pix1/value >>> 24
       		r: pix1/value and FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
        	b: pix1/value and FFh 
        	;OK RGBA are correct
        	; -> to Grayscale mat
        	rgb: ((4899 * r) + (9617 * g) + (1868 * b) + 8192) >>> 14 and FFh
        	;rgb: r + g + b / 3
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

rcvMat2Image: routine [
"Matrix to Red Image"
	mObj	[object!]
	dst		[image!]
	/local
	vec 	[red-vector!]
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
    vec: mat/get-data mObj
	unit: mat/get-unit mObj
    value: vector/rs-head vec ; get pointer address of the matrice
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
       		i: rcvGetIntValue as integer! value unit; get mat value as integer
       		if unit = 1 [i: i and FFh] ; for 8-bit values [-127 .. 127]
       		if i < 0 [i: 0]
       		if i > 255 [i: 255]
       		pixD/value: ((255 << 24) OR (i << 16 ) OR (i << 8) OR i)
       		value: value + unit
           	pixD: pixD + 1
           	x: x + 1
       ]
       y: y + 1
    ]
    image/release-buffer dst handle yes
]

;--color matrices: only 32-bit
rcvImage2Mat32: routine [
"Red Image to 32-bit integer 2-D Matrix "
	src		[image!]
	mObj	[object!]
	/local
	pix 	[int-ptr!]
	dvalue 	[byte-ptr!]
	vec 	[red-vector!]
	handle1	[integer!]
	unit	[integer!]
	h 		[integer!]
	w 		[integer!]
	x 		[integer!]
	y 		[integer!]
] [
	handle1: 0
    pix: image/acquire-buffer src :handle1
    w: IMAGE_WIDTH(src/size) 
    h: IMAGE_HEIGHT(src/size) 
    y: 0 
    vec: mat/get-data mObj
	unit: mat/get-unit mObj
    dvalue: vector/rs-head vec	; a byte ptr
    while [y < h] [
    	x: 0
       	while [x < w][
        	rcvSetIntValue as integer! dvalue pix/value unit
           	x: x + 1
           	pix: pix + 1
           	dValue: dValue + unit
       	]
       	y: y + 1
    ]
    image/release-buffer src handle1 no
]

;--only 32-bit
rcv32Mat2Image: routine [
"Matrix to Red Image"
	mObj	[object!]
	dst		[image!]
	/local
	vec 	[red-vector!]
	pixD 	[int-ptr!]
	value	[byte-ptr!]
	handle	[integer!]
	unit   	[integer!]
	h		[integer!] 
	w		[integer!] 
	x 		[integer!]
	y		[integer!]	
][
	handle: 0
    pixD: image/acquire-buffer dst :handle
    w: IMAGE_WIDTH(dst/size) 
    h: IMAGE_HEIGHT(dst/size) 
    vec: mat/get-data mObj
	unit: mat/get-unit mObj
    value: vector/rs-head vec ; get pointer address of the matrice data
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
       		pixD/value: rcvGetIntValue as integer! value unit; get mat value as integer
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

_rcvSplit2Mat: routine [
"Splits an image to 4 8-bit vecros"
	src			[image!]
	vec0		[vector!]
	vec1		[vector!]
	vec2		[vector!]
	vec3		[vector!]
	/local
	s			[series!]
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
    s: GET_BUFFER(vec0)
	unit: GET_UNIT(s)
    dvalue0: vector/rs-head vec0	; a byte ptr
    dvalue1: vector/rs-head vec1	; a byte ptr
    dvalue2: vector/rs-head vec2	; a byte ptr
    dvalue3: vector/rs-head vec3	; a byte ptr
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


; 4 1-channel 2-D matrices (grayscale) -> Red Image 
_rcvMerge2Image: routine [
"Merge 4 8-bit matrices to image"
	vec0		[vector!]
	vec1		[vector!]
	vec2		[vector!]
	vec3		[vector!]
	dst			[image!]
	/local
	s			[series!]
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
    s: GET_BUFFER(vec0)
	unit: GET_UNIT(s)
    y: 0
    value0: vector/rs-head vec0 ; get pointer address of the matrice
    value1: vector/rs-head vec1 
    value2: vector/rs-head vec2
    value3: vector/rs-head vec3
    while [y < h] [
    	x: 0
       	while [x < w][
       		a: rcvGetIntValue as integer! value0 unit; get mat value as integer
       		r: rcvGetIntValue as integer! value1 unit; get mat value as integer
       		g: rcvGetIntValue as integer! value2 unit; get mat value as integer
       		b: rcvGetIntValue as integer! value3 unit; get mat value as integer
       		; for 8-bit values [-127 .. 127]
       		if unit = 1 [a: a and FFh r: r and FFh g: g and FFh b: b and FFh] 
       		if a < 0 [a: 0] if a > 255 [a: 255]
       		if r < 0 [r: 0] if r > 255 [r: 255]
       		if g < 0 [g: 0] if g > 255 [g: 255]
       		if b < 0 [b: 0] if b > 255 [b: 255]
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
       			0 [ptr/value: idx/value]		;rgba 
       			1 [ptr/value:  r]				;r channel
       			2 [ptr/value:  g]				;g channel
       			3 [ptr/value:  b]				;b channel
       			4 [ptr/value:  a]				;alpha channel
       			5 [ptr/value: (r + b + g) / 3]	;grayscale
       		]
			i: i + 1
		]
		block/rs-append blk as red-value! vect
		j: j + 1
	]
	image/release-buffer src handle no
	blk
]

rcvMat2Array: routine [
"Matrix/data (vector) to block of vectors (Array)"
	mx 		[object!] 
	return: [block!]
	/local
	blk		[red-block!]
	*vec	[byte-ptr!]
	idx 	[byte-ptr!]
	vec1 	[red-vector!]
	vec2	[red-vector!]
	w 		[integer!]
	h		[integer!]
	i 		[integer!]
	j 		[integer!]	 
	p		[byte-ptr!]
	p4		[int-ptr!]
	p8		[float-ptr!]
	unit	[integer!]	
	t		[integer!]
	s		[series!]
][
	vec1: 	mat/get-data mx
	unit: 	mat/get-unit mx
	w: 		mat/get-cols mx
	h:		mat/get-rows mx
	t: 		mat/get-type mx
	*vec: 	vector/rs-head vec1
	blk: 	as red-block! stack/arguments
	block/make-at blk h
	j: 0
	while [j < h] [
		i: 0 	
		switch t [
			1 [vec2: vector/make-at stack/push* w TYPE_INTEGER unit]	
			2 [vec2: vector/make-at stack/push* w TYPE_INTEGER unit] 
			3 [vec2: vector/make-at stack/push* w TYPE_FLOAT unit] 
		]
		
		while [i < w] [
			idx: *vec + (j * w + i * unit)
			s: GET_BUFFER(vec2)
			p: alloc-tail-unit s unit
			p4: as int-ptr! p
			p8: as float-ptr! p	
			switch t [
				1 [p4/value: vector/get-value-int as int-ptr! idx unit] 
				2 [p4/value: vector/get-value-int as int-ptr! idx unit] 
				3 [p8/value: as float! vector/get-value-float idx unit]
			]
			i: i + 1
		]
		block/rs-append blk as red-value! vec2
		j: j + 1
	]
	as red-block! stack/set-last as cell! blk 
]



_rcvBlendMat: routine [
"Computes the alpha blending of two vectors"
	mat1		[vector!]
	mat2		[vector!]
	dst			[vector!]
	alpha		[float!]
	/local
	s			[series!]
	svalue1 	[byte-ptr!]
	svalue2 	[byte-ptr!]
	tail 		[byte-ptr!]
	unit 		[integer!]
	int1 		[integer!]
	int2 		[integer!]
	v			[integer!]
	calpha		[float!]
][
	s: GET_BUFFER(mat1)
	unit: GET_UNIT(s)
	calpha: 1.0 - alpha
	svalue1: vector/rs-head mat1 
	svalue2: vector/rs-head mat2 
    tail: vector/rs-tail mat1
    vector/rs-clear dst 
    while [svalue1 < tail][
		int1: vector/get-value-int as int-ptr! svalue1 unit
		int2: vector/get-value-int as int-ptr! svalue2 unit
		v: as integer! (alpha * int1 + calpha * int2)
		vector/rs-append-int dst v
		svalue1: svalue1 + unit
		svalue2: svalue2 + unit
	]
]

_rcvInRangeMat: routine [
"Extracts sub array from matrix according to lower and upper values"
	vec1		[vector!]
	dst			[vector!]
	lower		[integer!]
	upper		[integer!]
	op			[integer!]
	/local
	s			[series!]
	svalue1 	[byte-ptr!]
	tail 		[byte-ptr!]
	unit 		[integer!]
	int1 		[integer!]
	v			[integer!]
] [
	s: GET_BUFFER(vec1)
	unit: GET_UNIT(s)
	vector/rs-clear dst
	svalue1: vector/rs-head vec1
	tail: vector/rs-tail vec1
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

rcvCopyMatI: routine [
"Copy integer matrix"
   	src  	[vector!]
    dst  	[vector!]
    /local
    s		[series!]
    svalue 	[byte-ptr!]
    tail 	[byte-ptr!]
    dvalue 	[byte-ptr!]
    p4 		[int-ptr!]
    unit	[integer!] 
    val		[integer!]
][
	s: GET_BUFFER(src)
	unit: GET_UNIT(s)
    svalue: vector/rs-head src  	
    tail: vector/rs-tail src		
	dvalue: vector/rs-head dst			 
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
    s		[series!]
    svalue	[byte-ptr!] 
    tail	[byte-ptr!] 
    dvalue 	[byte-ptr!]
    p64		[float-ptr!] 
    p32 	[float32-ptr!]
    unit	[integer!]  
    val		[float!] 		
] [
	s: GET_BUFFER(src)
	unit: GET_UNIT(s)
    svalue: vector/rs-head src	  
    tail: vector/rs-tail src	
	dvalue: vector/rs-head dst	
   	while [svalue < tail][
		val: vector/get-value-float svalue unit
		either unit = 8 [p64: as pointer! [float!] dvalue  p64/value: val]
					    [p32: as pointer! [float32!] dvalue p32/value: as float32! val]
		svalue: svalue + unit
		dvalue: dvalue + unit
    ]
]



;************************** Mat Functions ******************************

;************************** matrices creation **************************
 
comment [{
see matrix-object documentation
for matrices creation we use now the matrix object methods matrix/create or matrix/init
e.g. 
mx: matrix/create 1 8 3x3 []: Creates a 3x3 8-bit char matrix with no data.
mx: matrix/create 2 32 3x3 [1 2 3 4 5 6 7 8 9]: a 3x3 matrix of 32-bit integer with data.
matrix/init/value/rand 2 16 3x3 255: a 3x3 integer matrix filled with a random value.
}]

;rcvMakeIndenticalMat -> matrix/init/value 

makeRange: func [
	a 		[number!] 
	b 		[number!] 
	step 	[number!]][
    collect [i: a - step until [keep i: i + step i = b]]
]

rcvMakeRangeMat: function [
"Creates an ordered matrix"
	type	[integer!]
	bits	[integer!]
	mSize	[pair!]
	a 		[number!] 
	b 		[number!] 
	step 	[number!] 
	return: [object!]
][
	tmp: makeRange a b step
	make vector! tmp
	matrix/init type bits mSize
]



;rcvCloneMat deleted


rcvCopyMat: function [
"Copy source matrix to destination matrix"
	src [object!] 
	dst [object!]
][
	t: rcvGetMatType src
	if t = 1 [rcvCopyMatI src/data dst/data]
	if t = 2 [rcvCopyMatF src/data dst/data] 
]


;we use a fast general copy function similar to matrix/copy
;to be tested

_rcvCopyMat: function [
"Returns a copy of the matrix"
	mx 		[object!] "Matrix"
	return: [object!]
][
	make mx [data: copy mx/data]
]

rcvReleaseMat: function [
"Releases Matrix"
	mx [object!]
][
	mx: none
]

;********************** matrices conversions ********************
;--binary matrices 0/1
;--standard version
rcvMakeBinaryMat: function [
"Makes a [0/1] 8-bit integer matrix from another matrix"
	mx 		[object!] "Matrix"
	return: [object!]
][
	mxInt: matrix/init 2 8 as-pair mx/cols mx/rows
	i: 1
	foreach v mx/data [
		either (to-integer v) > 0 [mxInt/data/:i: 1][mxInt/data/:i: 0] 
		i: i + 1
	]
	mxInt
]

;--fast version with routine 
rcvMakeFastBinaryMat: function [
"Makes a [0/1] 32-bit integer matrix. Source object MUST BE integer matrix"
	mx 		[object!] "Integer matrix"
	return: [object!]
][
	mxInt: matrix/init 2 32 as-pair mx/cols mx/rows
	if m/type = 2 [_rcvMakeBinaryMat mx/data mxInt/data]
	mxInt
]

rcvConvertMatIntScale: function [
"Changes integer matrix scale. Returns a 32-bit integer matrix"
	mx 			[object!] "Integer matrix"
	srcScale	[scalar!] ; eg FFh
	dstScale	[scalar!] ; eg FFFFh	
	return: 	[object!]
][
	mxInt: matrix/init 2 32 as-pair mx/cols mx/rows
	if mx/type = 2 [
		_rcvConvertMatIntScale mx/data mxInt/data to-float srcScale to-float dstScale
	]
	mxInt
]

rcvMatInt2Float: function [
"Convert integer matrix to float matrix with scaling"
	mx 		[object!] 
	bits	[integer!] 	;--32 or 64
	scale	[float!]	;--1.0 no scaling
	return:	[object!]
][
	_mx: matrix/init 3 bits as-pair mx/cols mx/rows
	if mx/type = 2 [
		i: 1
		foreach v mx/data [
			_mx/data/:i: to-float (mx/data/:i * scale) 
			i: i + 1
		]
	]
	_mx
]

rcvMatFloat2Int: function [
"Return float matrix as integer matrix with scaling"
	mx 		[object!] 
	bits	[integer!] 	;--8, 16 OR 32
	scale	[float!]	;--1.0 no scaling
	return:	[object!]
][
	_mx: matrix/init 2 bits as-pair mx/cols mx/rows
	if mx/type = 3 [
		n: length? _mx/data
		repeat i n [
			_mx/data/:i: to-integer round (mx/data/:i * scale) 
		]
	]
	_mx
]

rcvLogMatFloat: function [
"Return log-10 scale transform on float matrice"	
	mx	 		[object!]
	bias		[float!]
	return: 	[object!] 	 
][
	_mx: matrix/init 3 mx/bits as-pair mx/cols mx/rows
	if mx/type = 3 [
		n: length? mx/data
		repeat i n [mx/data/:i: log-10 (bias + mx/data/:i)]
		maxi: matrix/maxi mx
		mini: matrix/mini mx
		either (maxi - mini) <> 0 [dividor: maxi - mini] [dividor: 1.0]
		repeat i n [_mx/data/:i: (mx/data/:i - mini) / dividor]
	]
	_mx
]


rcvSplit2Mat: function [
"Splits an image to 4 matrices. Returns a block of 4 matrices"
	img		[image!]
	bits	[integer!]
	return:	[block!]
][
	mx1: matrix/init 2 bits img/size		;--A
	mx2: matrix/init 2 bits img/size		;--R
	mx3: matrix/init 2 bits img/size		;--G
	mx4: matrix/init 2 bits img/size		;--B
	_rcvSplit2Mat img mx1/data mx2/data mx3/data mx4/data
	reduce [mx1 mx2 mx3 mx4]
]

rcvMerge2Image: function [
"Merge 4  matrices to a Red image"
	mx1		[object!]
	mx2		[object!]
	mx3		[object!]
	mx4		[object!]
	img		[image!]			
][
	_rcvMerge2Image mx1/data mx2/data mx3/data mx4/data img
]

rcvBlendMat: function [
"Computes the alpha blending of two matrices"
	mx1		[object!]
	mx2		[object!]
	mx3		[object!]
	alpha	[float!]
][
	_rcvBlendMat mx1/data mx2/data mx3/data alpha
]

rcvInRangeMat: function [
"Extracts sub array from matrix according to lower and upper values"
	mx			[object!]
	lower		[integer!]
	upper		[integer!]
	op			[integer!]
	return:		[object!]
][
	_mx: matrix/init 2 mx/bits as-pair mx/cols mx/rows
	_rcvInRangeMat mx/data _mx/data lower upper op
	_mx
]

;******************** matrices operations ***********************

comment [
These functions are deleted. Please use matrix object functions
rcvAddMat: matrix/addition mx1 mx2
rcvSubMat: matrix/subtraction  mx1 mx2
rcvMulMat: matrix/standardProduct  mx1 mx2
rcvDivMat: matrix/division  mx1 mx2
rcvRemMat: deleted
;scalar operation on matrices
rcvAddSMat: scalarAddition mx value
rcvSubSMat: matrix/scalarSubtraction mx value
rcvMulSMat: matrix/scalarProduct mx value
rcvDivSMat: matrix/scalarDivision mx value
rcvRemSMat: matrix/scalarRemainder mx value
rcvANDSMat: matrix/scalarAnd mx value
rcvORSMat:  matrix/scalarOr mx/value
rcvXORSMat: matrix/scalarXor mx/value
new
scalarRightShift mx value (>>)
scalarRightShiftUnsigned mx value (>>>)
scalarLeftShift mx value (<<)
]

; matrices with the same type and size
rcvMeanMats: function [
"dst: src1 + src2 / 2"
	mx1 	[object!] 
	mx2 	[object!] 
	mx3		[object!]
][
	if all [matrix/_matSimilar?  mx1 mx2 matrix/_matSimilar? mx2 mx3]
		[mx3/data: (mx1/data + mx2/data) / 2]
]

;********************** Logical **********************************
;only for integer matrices
rcvANDMat: function [
"dst: mat1 AND  mat2"
	mx1 [object!] 
	mx2 [object!] 
	mx3 [object!]
][
	if all [mx1/type = 2 mx2/type = 2 mx3/type = 2][
		if all [matrix/_matSimilar?  mx1 mx2 matrix/_matSimilar? mx2 mx3]
			[mx3/data: mx1/data and mx2/data]
	]
]

rcvORMat: function [
"dst: mat1 OR  mat2"
	mx1 [object!] 
	mx2 [object!] 
	mx3	[object!]
][
	if all [mx1/type = 2 mx2/type = 2 mx3/type = 2][
		if all [matrix/_matSimilar?  mx1 mx2 matrix/_matSimilar? mx2 mx3]
			[mx3/data: mx1/data or mx2/data]
	]
]

rcvXORMat: function [
"dst: mat1 XOR  mat2"
	mx1 [object!] 
	mx2 [object!] 
	mx3	[object!]
][
	if all [mx1/type = 2 mx2/type = 2 mx3/type = 2][
		if all [matrix/_matSimilar?  mx1 mx2 matrix/_matSimilar? mx2 mx3]
			[mx3/data: mx1/data xor mx2/data]
	]
]

;**************************** misc *******************************

rcvMat2Binary: function [
"Returns matrix data as binary values"
	mx [object!] 
][
	to-binary to-block mx/data
]

rcvSortMat: function [
"Sort integer matrix"
	mat1	[object!]
	dir		[integer!]
][
	switch dir [
		1 [sort mat1/data]
	   -1 [sort/reverse mat1/data]
	]
]

rcvFlipMat: function [
"Reverses matrix"
	mx 		[object!] 
][
	reverse mx/data
]

rcvLengthMat: function [
"Matrix length as integer value"
	mx [object!] 
] [
	length? mx/data
]

