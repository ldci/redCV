Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvMatrixRoutines.red
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

;**********************MATRICES**************************

; internal and not exported routines 

; integer or float matrix type
_rcvGetMatType: routine [
	mat  	[vector!]
	return: [integer!]
	/local
	s unit type
] [
	s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	; 1 integer 2 float
	either unit <= 4 [type: 1] [type: 2] 
	type
]

; matrix bit size
_rcvGetMatBitSize: routine [
	mat  	[vector!]
	return: [integer!]
	/local
	s  
] [
	s: GET_BUFFER(mat)
	GET_UNIT(s)
]


; gets and sets integer matrix element value
; p address must be passed as integer! since red routine doesn't know byte-ptr!

_getIntValue: routine [
	p		[integer!] ; address of mat element as integer
	unit	[integer!] ; size of integer 8 16 32 [1 2 4]
	return:	[integer!]
] [
	vector/get-value-int as int-ptr! p unit
]


_setIntValue: routine [
	p		[integer!] ; address of mat element as integer
	value	[integer!]
	unit	[integer!] ; size of integer 8 16 32 [1 2 4]
	/local 
	p4		
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


_getFloatValue: routine [
	p		[integer!] ; address of mat element as integer
	return:	[float!]
	/local
	pt64
] [
	;vector/get-value-float as byte-ptr! p 8 ; old version
	pt64: as float-ptr! p
	pt64/value				
]


_getFloat32Value: routine [
	p		[integer!] ; address of mat element as integer
	return:	[float!]
	/local
	pt32	
] [
	vector/get-value-float as byte-ptr! p 4 
]


_setFloatValue: routine [
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

_rcvGetInt2D: routine [
	mat  		[vector!]
	width       [integer!]
	x           [integer!]
	y           [integer!]
	return:		[integer!]
	/local
	mvalue
	unit
	idx
] [
	mvalue: as integer! vector/rs-head mat
    unit: _rcvGetMatBitSize mat
    idx: (x + (y * width)) * unit
    _getIntValue mvalue + idx unit
] 

_rcvGetReal2D: routine [
	mat  		[vector!]
	width       [integer!]
	x           [integer!]
	y           [integer!]
	return:		[integer!]
	/local
	mvalue
	unit
	idx
] [
	mvalue: as integer! vector/rs-head mat
    unit: _rcvGetMatBitSize mat
    idx: (x + (y * width)) * unit
    _getFloatValue  mvalue + idx unit
] 

_rcvGetReal322D: routine [
	mat  		[vector!]
	width       [integer!]
	x           [integer!]
	y           [integer!]
	return:		[integer!]
	/local
	mvalue
	unit
	idx
] [
	mvalue: as integer! vector/rs-head mat
    unit: _rcvGetMatBitSize mat
    idx: (x + (y * width)) * unit
    _getFloat32Value mvalue + idx unit
] 

_rcvSetInt2D: routine [
	mat  		[vector!]
	width       [integer!]
	x           [integer!]
	y           [integer!]
	val			[integer!]
	/local
	mvalue
	unit
	idx
] [
	mvalue: as integer! vector/rs-head mat
    unit: _rcvGetMatBitSize mat
    idx: (x + (y * width)) * unit
    _setIntValue mvalue + idx val unit
]

_rcvSetReal2D: routine [
	mat  		[vector!]
	width       [integer!]
	x           [integer!]
	y           [integer!]
	val			[float!]
	/local
	mvalue
	unit
	idx
] [
	mvalue: as integer! vector/rs-head mat
    unit: _rcvGetMatBitSize mat
    idx: (x + (y * width)) * unit
    _setFloatValue mvalue + idx val unit
]  

; gets coordinates from a binary mat as x y values

_rcvGetPoints: routine [
	bingradient 	[vector!]
	width			[integer!]
	height			[integer!]		
	points			[vector!]
	/local
	x y idx
	svalue 
	v
	unit
][
	svalue: vector/rs-head bingradient	; a byte ptr
	vector/rs-clear points
	unit: _rcvGetMatBitSize bingradient
    y: 0
    while [y < height] [
    	x: 0
        while [x < width][
       		v: _getIntValue as integer! svalue unit
       		if (v = 1) [
       			vector/rs-append-int points x
       			vector/rs-append-int points y
       		]
       		x: x + 1
       		svalue: svalue + unit
       ]
       y: y + 1
    ]
]

; gets coordinates from a binary mat as pair values
;Thanks to Nenad
_rcvGetPairs: routine [
    bingradient     [vector!]
    width           [integer!]
    height          [integer!]        
    points          [block!]
    /local
    x y idx x2
    mvalue 
    unit
    v
][
    mvalue: vector/rs-head bingradient
    unit: _rcvGetMatBitSize bingradient
    
    block/rs-clear points
    x: 0
    y: 0

    while [y < height] [
    	x: 0
       	while [x < width][
               v: _getIntValue as integer! mvalue unit
               if (v =  1) [pair/make-in points x y]
               x: x + 1
               mvalue: mvalue + unit
       	]
       	y: y + 1
    ]
]



; Hu Invariant Moments of 2D Matrix
; We use a binary [0..1] matrix rather [0..255] integer matrix

_rcvGetMatCentroid: routine [
	mat  			[vector!]
	width           [integer!]
    height          [integer!]
    minloc 			[pair!]
    return: 		[pair!]   
	/local
	loc
	x y
	sumX sumY sumXY
	mvalue 
    unit
    v
][	
	mvalue: vector/rs-head mat
    unit: _rcvGetMatBitSize mat
    x: 0
    y: 0
    sumX: 0 sumY: 0 sumXY: 0
    loc: as red-pair! minloc; stack/arguments
    while [y < height] [
    	x: 0
       	while [x < width][
       		v: _getIntValue as integer! mvalue unit
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


;Returns the central moment of the matrix
;p - the order of the moment (x order)
;q - the repetition of the moment (y order)



_rcvGetMatSpatialMoment: routine [
	mat  			[vector!]
	width           [integer!]
    height          [integer!]
    p				[float!]
    q				[float!]
    return:			[float!]
    /local 	
    moment
    x y
    xf yf
	mvalue 
    unit
    v
][
	mvalue: vector/rs-head mat
    unit: _rcvGetMatBitSize mat
    x: 0
    y: 0
    xf: 0.0
    xf: 0.0
    moment: 0.0
    while [y < height] [
    	x: 0
       	while [x < width][
       		v: as float! _getIntValue as integer! mvalue unit
       		xf: pow as float! x  p
       		yf: pow as float! y  q
       		moment: moment + (v * xf * yf)
            x: x + 1
            mvalue: mvalue + unit
       	]
       	y: y + 1
    ]
    moment
]


_rcvGetMatCentralMoment: routine [
	mat  			[vector!]
	width           [integer!]
    height          [integer!]
    centroid		[pair!]
    p				[float!]
    q				[float!]
    return:			[float!]
    /local 	
    moment
    x y
    xf yf
	mvalue 
    unit
    v
][
	mvalue: vector/rs-head mat
    unit: _rcvGetMatBitSize mat
    x: 0
    y: 0
    xf: 0.0
    xf: 0.0
    moment: 0.0
    while [y < height] [
    	x: 0
       	while [x < width][
       		v: as float! _getIntValue as integer! mvalue unit
       		xf: pow as float! (x - centroid/x)  p
       		yf: pow as float! (y - centroid/y)  q
       		moment: moment + (xf * yf * v)
            x: x + 1
            mvalue: mvalue + unit
       	]
       	y: y + 1
    ]
    moment
]


; copy integer matrices
_rcvCopyMat: routine [
   	src  	[vector!]
    dst  	[vector!]
    /local
    svalue tail dvalue p4 	; byte-ptr!
    unit val				; integer!
][
    svalue: vector/rs-head src  	
    tail: vector/rs-tail src		
	dvalue: vector/rs-head dst			
	unit: _rcvGetMatBitSize src 
   	while [svalue < tail][
		;val: vector/get-value-int as int-ptr! svalue unit
		val: _getIntValue as integer! svalue unit
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
_rcvCopyMatF: routine [
   	src  	[vector!]
    dst  	[vector!]
    /local
    svalue tail dvalue 	;byte-ptr!
    p p32 				;float ptr
    unit 				;integer
    val					;float!
] [
    svalue: vector/rs-head src	  
    tail: vector/rs-tail src	
	dvalue: vector/rs-head dst	
	unit: _rcvGetMatBitSize src
   	while [svalue < tail][
		val: vector/get-value-float svalue unit
		either unit = 8 [p: as pointer! [float!] dvalue  p/value: val]
					    [p32: as pointer! [float32!] dvalue p32/value: as float32! val]
		svalue: svalue + unit
		dvalue: dvalue + unit
    ]
]


; copy integer matrices
_rcvMakeBinaryMat: routine [
   	src  	[vector!]
    dst  	[vector!]
    /local
    svalue tail dvalue p4 	; byte-ptr!
    unit val val2				; integer!
][
    svalue: vector/rs-head src  	
    tail: vector/rs-tail src		
	dvalue: vector/rs-head dst			
	unit: _rcvGetMatBitSize src 
   	while [svalue < tail][
		;val: vector/get-value-int as int-ptr! svalue unit
		val: _getIntValue as integer! svalue unit
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




; converts Integer Matrix scale
; 8 -> 16-bits OK (for 8-bit -127..+127)
; 8 -> 32-bits OK
; 16 -> 32-bits OK

_convertMatScale: routine [
	src			[vector!]
	dst			[vector!]
	srcScale	[float!] ; eg FFh
	dstScale	[float!] ; eg FFFFh	
	/local
	svalue tail ;byte-ptr!
	int unit	;integer!
	v			;float!
][
	svalue: vector/rs-head src  ; get a pointer address of the source matrix first value
	tail:  vector/rs-tail src	; last
	vector/rs-clear dst 		; clears destination for append calculated value
	unit: _rcvGetMatBitSize src ; bit size
	while [svalue < tail][
		int: vector/get-value-int as int-ptr! svalue unit
		switch unit [
			1 [int: int and FFh]
			2 [int: int and FFFFh]
			3 [int: int]
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

_rcvImage2Mat: routine [
	src		[image!]
	mat		[vector!]
	/local
	pix1 	[int-ptr!]
	dvalue 	[byte-ptr!]
	handle1
	unit
	h w x y 
	r g b a rgb
] [
	handle1: 0
    pix1: image/acquire-buffer src :handle1
    w: IMAGE_WIDTH(src/size) 
    h: IMAGE_HEIGHT(src/size) 
    x: 0
    y: 0 
    dvalue: vector/rs-head mat	; a byte ptr
	unit: _rcvGetMatBitSize mat ; bit size
    while [y < h] [
       while [x < w][
			a: pix1/value >>> 24
       		r: pix1/value and FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
        	b: pix1/value and FFh 
        	;OK RGBA are correct
        	; -> to Grayscale mat
        	rgb: r + g + b / 3
        	_setIntValue as integer! dvalue rgb unit
           	x: x + 1
           	pix1: pix1 + 1
           	dValue: dValue + unit
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
]


; 1 channel 2-D matrice (grayscale) -> Red Image 
; 8 16 and 32-bit integer matrices can be used
; for 8-bit -127..+127 values are transformed in 0..255 values
; for 8-bit byte matrix values remain unchnaged

_rcvMat2Image: routine [
	mat		[vector!]
	dst		[image!]
	/local
	pixD 	[int-ptr!]
	handle	[integer!]
	unit   ; 1 2 or 4
	i value  
	h w x y
	
] [
	handle: 0
    pixD: image/acquire-buffer dst :handle
    w: IMAGE_WIDTH(dst/size) 
    h: IMAGE_HEIGHT(dst/size) 
    x: 0
    y: 0
    value: vector/rs-head mat ; get pointer address of the matrice
    unit: _rcvGetMatBitSize mat ; bit size
    while [y < h] [
       while [x < w][
       		;i: vector/get-value-int as int-ptr! value unit
       		i: _getIntValue as integer! value unit; get mat value as integer
       		if unit = 1 [i: i and FFh] ; for 8-bit values [-127 .. 127]
       		pixD/value: ((255 << 24) OR (i << 16 ) OR (i << 8) OR i)
       		value: value + unit
           	pixD: pixD + 1
           	x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer dst handle yes
]



; Splits image to 4 matrices including transparency
; image and matrices must have the same size!

_rcvSplit2Mat: routine [
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
	handle1
	h w x y 
	unit
] [
	handle1: 0
    pix1: image/acquire-buffer src :handle1
    w: IMAGE_WIDTH(src/size) 
    h: IMAGE_HEIGHT(src/size) 
    x: 0
    y: 0 
    unit: _rcvGetMatBitSize mat0
    dvalue0: vector/rs-head mat0	; a byte ptr
    dvalue1: vector/rs-head mat1	; a byte ptr
    dvalue2: vector/rs-head mat2	; a byte ptr
    dvalue3: vector/rs-head mat3	; a byte ptr
   ; vector/rs-clear mat 
    while [y < h] [
       while [x < w][
        	_setIntValue as integer! dvalue0 pix1/value >>> 24 unit
        	_setIntValue as integer! dvalue1 pix1/value and 00FF0000h >> 16 unit
        	_setIntValue as integer! dvalue2 pix1/value and FF00h >> 8 unit
        	_setIntValue as integer! dvalue3 pix1/value and FFh unit
           	x: x + 1
           	pix1: pix1 + 1
           	dValue0: dValue0 + unit
           	dValue1: dValue1 + unit
           	dValue2: dValue2 + unit
           	dValue3: dValue3 + unit
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
]


; 3 1 channel 2-D matrices (grayscale) -> Red Image 

_rcvMerge2Image: routine [
	mat0		[vector!]
	mat1		[vector!]
	mat2		[vector!]
	mat3		[vector!]
	dst			[image!]
	/local
	pixD 	[int-ptr!]
	handle
	a r g b value0 value1 value2 value3  
	h w x y
	unit
	
] [
	handle: 0
    pixD: image/acquire-buffer dst :handle
    w: IMAGE_WIDTH(dst/size) 
    h: IMAGE_HEIGHT(dst/size) 
    x: 0
    y: 0
	unit: _rcvGetMatBitSize mat0
    value0: vector/rs-head mat0 ; get pointer address of the matrice
    value1: vector/rs-head mat1 
    value2: vector/rs-head mat2
    value3: vector/rs-head mat3
    while [y < h] [
       while [x < w][
       		a: _getIntValue as integer! value0 unit; get mat value as integer
       		r: _getIntValue as integer! value1 unit; get mat value as integer
       		g: _getIntValue as integer! value2 unit; get mat value as integer
       		b: _getIntValue as integer! value3 unit; get mat value as integer
       		pixD/value: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)
       		value0: value0 + unit
       		value1: value1 + unit
       		value2: value2 + unit
       		value3: value3 + unit
           	pixD: pixD + 1
           	x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer dst handle yes
]




{ Convolution on matrices:  Non normalized convolution 
includes a  filter values < 0: 0 and values > 255: 255
can be used with 8,16 and 32-bit matrices
factor and delta modify convolution result
}

_rcvConvolveMat: routine [
    src  	[vector!]
    dst  	[vector!]
    mSize	[pair!]
    kernel 	[block!] 
    factor 	[float!]
    delta	[float!]
    /local
        h w x y i j
        svalue dvalue idx 
        weightAcc
        v f vc
        mx my 
		kWidth kHeight kBase kValue  
		unit
][
    ;get mat size will be improved in future
    w: mSize/x
    h: mSize/y
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
	svalue: vector/rs-head src   ; get pointer address of the source matrix first value
	dvalue: vector/rs-head dst	; a byte ptr
	;vector/rs-clear dst 		; clears destination matrix
	unit: _rcvGetMatBitSize src
    x: 0
    y: 0
    v: 0
    while [y < h] [
       while [x < w][
    	weightAcc: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		mx:  (x + (i - (kWidth / 2)) + w ) % w 
        			my:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: svalue + (((my * w) + mx) * unit)  ; corrected pixel index
           			v: _getIntValue as integer! idx unit 
           			if unit = 1 [v: v and FFh] ; for 8-bit image
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			weightAcc: weightAcc + (f/value * v)
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        
        vc: (weightAcc * factor) + delta						 			 
    	; classical convolution cut off
    	if vc < 0.0 [vc: 0.0]
    	if vc > 255.0 [vc: 255.0]
        _setIntValue as integer! dvalue as integer! vc unit
        dvalue: dvalue + unit
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
]

{ Convolution on matrices:  Normalized convolution 
two-pass : first looks for maxi and mini 
can be used with 8,16 and 32-bit matrices
}

_rcvConvolveMat2: routine [
    src  	[vector!]
    dst  	[vector!]
    mSize	[pair!]
    kernel 	[block!] 
    factor 	[float!]
    delta	[float!]
    /local
        h w x y i j
        svalue dvalue idx scale
        weightAcc
        v f vc vcc
        mx my 
		kWidth kHeight kBase kValue  
		unit
		mini maxi
][
    ;get mat size will be improved in future
    w: mSize/x
    h: mSize/y
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
	svalue: vector/rs-head src   ; get pointer address of the source matrix first value
	dvalue: vector/rs-head dst	; a byte ptr
	unit: _rcvGetMatBitSize src
    x: 0
    y: 0
    v: 0
    maxi: -16777215.0
    mini: 16777215.0
    while [y < h] [
       while [x < w][
    	weightAcc: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		mx:  (x + (i - (kWidth / 2)) + w ) % w 
        			my:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: svalue + (((my * w) + mx) * unit)  ; corrected pixel index
           			v: _getIntValue as integer! idx unit 
           			if unit = 1 [v: v and FFh] ; for 8-bit image
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			weightAcc: weightAcc + (f/value * v)
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        
       	vc: (weightAcc * factor) + delta					 			 
    	if vc > maxi [maxi: vc] 
    	if vc <= mini [mini: vc]
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    
    scale: 255.0 / (maxi - mini) 
    
    x: 0
    y: 0
    v: 0
    while [y < h] [
       while [x < w][
    	weightAcc: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		mx:  (x + (i - (kWidth / 2)) + w ) % w 
        			my:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: svalue + (((my * w) + mx) * unit)  ; corrected pixel index
           			v: _getIntValue as integer! idx unit 
           			if unit = 1 [v: v and FFh] ; for 8-bit image
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			weightAcc: weightAcc + (f/value * v)
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
    
    	vcc: (((weightAcc * factor) + delta) - mini) * scale 						 			 
        _setIntValue as integer! dvalue as integer! vcc unit
        dvalue: dvalue + unit
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
]



; Fast Sobel Detector on Matrix
; Computes the x component of the gradient vector
; at a given point in a matrix.
; returns gradient in the x direction

_xSMGradient: routine [
	p		[integer!]
	mSize	[pair!]
	x		[integer!]
	y		[integer!]
	return:	[integer!]
	/local
	h w idx sum v
][
	w: mSize/x
    h: mSize/y
    if x < 1 [x: w - 1]
    if y < 1 [y: h - 1]
    if x >= (w - 1) [x: 1]
	if y >= (h - 1) [y: 1]
    sum: 0
    idx: p + (y - 1 * w) + (x - 1) 
    v: _getIntValue idx 1
    sum: sum + v
    idx: p + (y * w) + (x - 1) 
    v: _getIntValue idx 1
    sum: sum + (v * 2)
    idx: p + (y + 1 * w) + (x - 1) 
    v: _getIntValue idx 1
    sum: sum + v
    idx: p + (y - 1 * w) + (x + 1) 
    v: _getIntValue idx 1
    sum: sum - v
    idx: p + (y  * w) + (x + 1)
    v: _getIntValue idx 1 
    sum: sum - (v * 2)
    idx: p + (y + 1 * w) + (x + 1) 
    v: _getIntValue idx 1
    sum: sum - v
    sum 
]


;Computes the x component of the gradient vector
; at a given point in a matrix.
;returns gradient in the y direction

_ySMGradient: routine [
	p		[integer!]
	mSize	[pair!]
	x		[integer!]
	y		[integer!]
	return:	[integer!]
	/local
	h w idx sum v
][
	w: mSize/x
    h: mSize/y
    if x < 1 [x: w - 1]
    if y < 1 [y: h - 1]
    if x >= (w - 1) [x: 1]
	if y >= (h - 1) [y: 1]
    sum: 0
    idx: p + (y - 1 * w) + (x - 1)
    v: _getIntValue idx 1 
    sum: sum + v
    idx: p + (y - 1 * w) + x 
    v: _getIntValue idx 1
    sum: sum + (v * 2)
    idx: p + (y - 1 * w) + (x + 1) 
    v: _getIntValue idx 1
    sum: sum + v
    idx: p + (y + 1 * w) + (x - 1) 
    v: _getIntValue idx 1
    sum: sum - v
    idx: p + (y + 1 * w) + x 
    v: _getIntValue idx 1
    sum: sum - (v * 2)
    idx: p + (y + 1 * w) + (x + 1) 
    v: _getIntValue idx 1
    sum: sum - v
    sum
]


; Sobel Edges detector
_rcvSobelMat: routine [
    src  	[vector!]
    dst  	[vector!]
    mSize	[pair!]
    /local
        h w x y
        svalue dvalue idx 
        gX gY v f 
        sum
        unit
][
    ;get mat size will be improved in future with matrix! type
    w: mSize/x
    h: mSize/y
	svalue: vector/rs-head src   ; get byte pointer address of the source matrix first value
	dvalue: vector/rs-head dst	; a byte ptr
	;vector/rs-clear dst 		; clears destination matrix
	unit: _rcvGetMatBitSize src
    x: 0
    y: 0
    gX: 0
    gY: 0
    sum: 0
    while [y < h] [	
       	while [x < w][
    		gx: _xSMGradient as integer! svalue mSize x y
    		gy: _ySMGradient as integer! svalue mSize x y
    		sum: gX + gY ; faster approximation but requires absolute difference
    		;sum: as integer! (sqrt ((as float! gx * gx) + (as float! gy * gy)))
    		if sum < 0 [sum:  0]
    		if sum > 255 [sum: 255]
    		dvalue/value: as-byte sum
        	dvalue: dvalue + unit
        	x: x + 1
       ]
       x: 0
       y: y + 1
    ]
]


; ******************* morphological Operations**************************
; exported as functions in /libs/matrix/rcvMatrixRoutines.red
; for 8-bits matrices
_rcvMorpho: routine [
   	src  	[vector!]
    dst  	[vector!]
    mSize	[pair!]
    cols	[integer!]
    rows	[integer!]
    kernel 	[block!] 
    op		[integer!]
    /local
        svalue 	[byte-ptr!]
        dvalue 	[byte-ptr!]
        idx	 	[byte-ptr!]
        idx2	[byte-ptr!]
        idxD	[byte-ptr!]
        h w x y i j
        maxi
        k  imx imy imx2 imy2
       	radiusX radiusY
		kBase 
		kValue  
][
    w: mSize/x
    h: mSize/y
    svalue: vector/rs-head src   ; get byte pointer address of the source matrix first value
	dvalue: vector/rs-head dst	; a byte ptr
	vector/rs-clear dst 		; clears destination matrix
    idx:  svalue
    idx2: svalue
    idxD: dvalue
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
	radiusX: cols / 2
	radiusY: rows / 2
    x: radiusX
    y: radiusY
    j: 0
    i: 0
    while [y < (h - radiusY)] [
       while [x < (w - radiusX)][
       		idx: svalue + (y * w) + x  
       		kValue: kBase
        	j: 0 
        	switch op [
        		1	[maxi: as byte! 0] ; dilatation
        		2	[maxi: as byte! 255]	; erosion
        	 ]
        	
        	; process neightbour
        	while [j < rows][
        		i: 0
        		while [i < cols][
        			imx2: x + i - radiusX
        			imy2: y + j - radiusY
        			idx2: svalue + (imy2 * w) + imx2
        			k: as red-integer! kValue
        			if k/value = 1 [
        				switch op [
        					1	[if idx2/value > maxi [maxi: idx2/value]] ; dilatation
        					2	[if idx2/value < maxi [maxi: idx2/value]]	; erosion
        	 			]	
        			]
        			kValue: kBase + (j * cols + i + 1)
        			i: i + 1
        		]
        		j: j + 1
        	]
       		dValue: idxD + (y * w) + x
           	dValue/value: maxi
           	x: x + 1
       ]
       x: 0
       y: y + 1 
    ]
]

;*********************** Integral Matrices *************************
; exported as functions in /libs/matrix/rcvMatrix.red
; integer Matrices 
_rcvIntegralMat: routine [
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
    p4
    unit
    x y w h
    pindex val val2
    sum sqsum
] [
    svalue: vector/rs-head src  
	d1value: vector/rs-head dst1	
	d2value: vector/rs-head dst2
	unit: _rcvGetMatBitSize src
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
       		val: _getIntValue as integer! svalue unit 
       		sum: sum + val                             
       		sqsum: sqsum + (val * val)
       		either (x = 0) [
       					_setIntValue as integer! d1Value sum unit
       					_setIntValue as integer! d2Value sqsum unit
       					 ] 
       					 [
       					 ;sum
       					 d1value: d1value - unit
       					 val: _getIntValue as integer! d1value unit
       					 d1value: d1value + unit
       					 val2: sum + val
       					 _setIntValue as integer! d1Value val2 unit
       					 ; square sum
       					 d2value: d2value - unit
       					 val: _getIntValue as integer! d2value unit
       					 d2value: d2value + unit
       					 val2: sqsum + val
       					 _setIntValue as integer! d2Value val2 unit
       					 ]
       		y: y + 1
       	]
    x: x + 1   	
    ]
]

_rcvProcessIntegralMat: routine [
	mat 	[vector!]
	w 		[integer!] 
	h 		[integer!]
	boxW 	[integer!]
	boxH 	[integer!]
	thresh	[integer!]
	points  [block!]
	/local
	x y
	scal0 scal1 scal2 scal3
	val
	s
]
[
	s: "box"
	y: boxH 
	while [y < (h - 1)] [
		x: boxW
		while [x < (w - 1)] [
			scal0: _rcvGetInt2D mat w x y
			scal1: _rcvGetInt2D mat w (x - boxW) (y - boxH)
			scal2: _rcvGetInt2D mat w  x (y - boxH) 
			scal3: _rcvGetInt2D mat w  (x - boxW) y
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


;************** matrices alpha blending ***********************
; exported as functions in /libs/matrix/rcvMatrix.red

_rcvBlendMat: routine [
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
	unit: _rcvGetMatBitSize mat1
    while [svalue1 < tail][
		int1: vector/get-value-int as int-ptr! svalue1 unit
		int2: vector/get-value-int as int-ptr! svalue2 unit
		v: as integer! (alpha * int1 + calpha * int2)
		vector/rs-append-int dst v
		svalue1: svalue1 + unit
		svalue2: svalue2 + unit
	]
]

;******************Threshold**************************
; exported as functions in /libs/matrix/rcvMatrix.red


_rcvInRangeMat: routine [
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
	unit: _rcvGetMatBitSize mat1
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


;****************** Contour detection ********************************

; by columns
_rcvleftPixel: routine [
	mat [vector!] 
	matSize [pair!] 
	value [integer!] 
	b [block!]
	/local
	flag
	unit matHead v
	x y px py pos
	] 
[
	matHead: as integer! vector/rs-head mat ; get pointer address of the matrice
	unit: _rcvGetMatBitSize mat
	flag: false
	x: 0
	while [x < matSize/x][
		y: 0
		while [y < matSize/y] [
			pos: y * matSize/x + x * unit
			v: _getIntValue  matHead + pos unit; get mat value as integer
			if (v = value) and (not flag) [
				px: x
				py: y
				flag: true
			]
			y: y + 1
		]
		x: x + 1
	]
	pair/make-in b px py
]

; by columns
_rcvRightPixel: routine [
	mat [vector!] 
	matSize [pair!] 
	value [integer!] 
	b [block!]
	/local
	flag
	unit matHead v
	x y
	px py pos
	] 
[
	matHead: as integer!  vector/rs-head mat ; get pointer address of the matrice
	unit: _rcvGetMatBitSize mat
	flag: false
	x: matSize/x - 1
	while [x >= 0][
		y: matSize/y - 1
		while [y >= 0] [
			pos: (x + (y * matSize/x)) * unit
			v: _getIntValue matHead + pos unit; get mat value as integer
			if (v = value) and (not flag) [
				px: x
				py: y
				flag: true
			]
			y: y - 1
		]
		x: x - 1
	]
	pair/make-in b px py
]

;by lines
_rcvUpPixel: routine [
	mat [vector!] 
	matSize [pair!] 
	value [integer!] 
	b [block!]
	/local
	flag
	unit matHead v
	x y px py
	i j pos
	] 
[
	matHead: as integer!  vector/rs-head mat ; get pointer address of the matrice
	unit: _rcvGetMatBitSize mat
	flag: false
	y: 0
	while [y < matSize/y][
		x: 0
		while [x < matSize/x] [
			pos: (x + (y * matSize/x)) * unit
			v: _getIntValue matHead + pos unit; get mat value as integer
			if (v = value) and (not flag) [
				px: x
				py: y
				flag: true
			]
			x: x + 1
		]
		y: y + 1
	]
	pair/make-in b px py
]

;by lines
_rcvDownPixel: routine [
	mat [vector!] 
	matSize [pair!] 
	value [integer!] 
	b [block!]
	/local
	flag
	unit matHead v
	x y px py
	i j pos
	] 
[
	matHead: as integer! vector/rs-head mat ; get pointer address of the matrice
	unit: _rcvGetMatBitSize mat
	flag: false
	y: matSize/y - 1
	while [y >= 0][
		x: matSize/x - 1
		while [x >= 0] [
			pos: (x + (y * matSize/x)) * unit
			v: _getIntValue  matHead + pos unit; get mat value as integer
			if (v = value) and (not flag) [
				px: x
				py: y
				flag: true
			]
			x: x - 1
		]
		y: y - 1
	]
	pair/make-in b px py
]

_borderPixel: routine [
	mat [vector!] 
	matSize [pair!]
	x [integer!]
	y [integer!]
	value [integer!]
	return: [logic!]
	/local
	unit matHead v vbg
	pos
][
	
	matHead: as integer! vector/rs-head mat ; get pointer address of the matrice
	unit: _rcvGetMatBitSize mat
	;only check background pixels (white or black)
	if value = 1 	[vbg: 0]
	if value = 255	[vbg: 0]
	if value =  0 	[vbg: 1]
	;either value = 0 [vbg: 1] [vbg: 0] 
	
	pos: y * matSize/x + x * unit
	v: _getIntValue matHead + pos unit
	if (v = vbg) [return false] 
	
	;check left (west)
	if (x = 0) [return true] ; image border = shape border
	if (x > 0) [
		pos: y * matSize/x + x - 1 * unit
		v: _getIntValue  matHead + pos unit
		if (v = vbg) [return true]
	]
	
	;check up (north)
	if (y = 0) [return true]
	if (y > 0) [
		pos: y - 1 * matSize/x + x * unit
		v: _getIntValue matHead + pos unit
		if (v = vbg) [return true]
	]
	
	;check right (east)
    if (x = matSize/x) [return true]
    if (x < matSize/x) [
    	pos: y * matSize/x + x + 1 * unit
    	v: _getIntValue matHead + pos unit
    	if (v = vbg) [return true]
    ]
    
     ;check down (south)
    if (y = matSize/y) [return true]
    if (y < matSize/y) [
    	pos: y + 1 * matSize/x + x * unit
    	v: _getIntValue matHead + pos unit
    	if (v = vbg) [return true]
    ]
    
    
	;no empty pixel around = not border pixel
	return false
]


_rcvGetBorder: routine [
	mat [vector!] 
	matSize [pair!]
	value [integer!]
	border [block!]
	/local
	matHead unit pos x y v
][
	matHead: as integer! vector/rs-head mat ; get pointer address of the matrice
	unit: _rcvGetMatBitSize mat
	block/rs-clear border
	y: 0
	while [y < matSize/y][
		x: 0
		while [x < matSize/x] [
			v: _getIntValue matHead unit
			if (v = value) [
				;if a neighbor of a pixel belongs to background
				;that pixel belongs to the border of the shape 
				if _borderPixel mat matSize x y value [
					pair/make-in border x y
				]
			]
			mathead: mathead + unit
			x: x + 1
		]
		y: y + 1
	]
]


_borderNeighbors: routine [
	mat [vector!] 
	matSize [pair!]
	x [integer!]
	y [integer!]
	value [integer!]
	return:	[integer!]
	/local
	 unit matHead v
	pos
][
	
	matHead: as integer! vector/rs-head mat ; get pointer address of the matrice
	unit: _rcvGetMatBitSize mat
	
	; check east (0)
	pos: y * matSize/x + x + 1 * unit
	v: _getIntValue matHead + pos unit
	if (v = value) [return 0]
	
	;check southeast (1)
	
	pos: y + 1 * matSize/x + x + 1 * unit
	v: _getIntValue matHead + pos unit
	if (v = value) [return 1]
	
	;check south (2)
	pos: y + 1 * matSize/x + x * unit
	v: _getIntValue matHead + pos unit
	if (v = value) [return 2]
	
	;check southwest (3)
	pos: y + 1 * matSize/x + x - 1 * unit
	v: _getIntValue matHead + pos unit
	if (v = value) [return 3]
	
	;check west (4)
	pos: y * matSize/x + x - 1 * unit
	v: _getIntValue matHead + pos unit
	if (v = value) [return 4]
	
	;check northwest (5)
	pos: y - 1 * matSize/x + x - 1 * unit
	v: _getIntValue matHead + pos unit
	if (v = value) [return 5]
	
	;check north (6)
	pos: y - 1 * matSize/x + x * unit
	v: _getIntValue matHead + pos unit
	if (v = value) [return 6]
	
	;check northeast (7)
	pos: y - 1 * matSize/x + x + 1 * unit
	v: _getIntValue matHead + pos unit
	if (v = value) [return 7]
	
	return -1
]



