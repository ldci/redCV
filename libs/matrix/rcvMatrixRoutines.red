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

; exported as functions in /libs/matrix/rcvMatrixRoutines.red

_rcvGetMatType: routine [
	mat  	[vector!]
	return: [integer!]
	/local
	s unit type
] [
	s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	; 1 integer/2 float
	either unit <= 4 [type: 1] [type: 2] 
	type
]

; integer matrices
_rcvCopyMat: routine [
   	src  	[vector!]
    dst1  	[vector!]
    /local
    svalue 	[byte-ptr!]
    tail 	[byte-ptr!]
    d1value [byte-ptr!]
    p4
    s unit
    val
    ] [
    svalue: vector/rs-head src  
    tail: vector/rs-tail src
	d1value: vector/rs-head dst1	
	
	s: GET_BUFFER(src)
	unit: GET_UNIT(s)
		
   	while [svalue < tail][
		val: vector/get-value-int as int-ptr! svalue unit
		p4: as int-ptr! d1Value
		p4/value: switch unit [
					1 [val and FFh or (p4/value and FFFFFF00h)]
					2 [val and FFFFh or (p4/value and FFFF0000h)]
					4 [val]
		]
		svalue: svalue + unit
		d1value: d1value + unit
    ]
]

; float matrices
_rcvCopyMatF: routine [
   	src  	[vector!]
    dst1  	[vector!]
    /local
    svalue 	[byte-ptr!]
    tail 	[byte-ptr!]
    d1value [byte-ptr!]
    p
    p32
    s unit
    val
    ] [
    svalue: vector/rs-head src  
    tail: vector/rs-tail src
	d1value: vector/rs-head dst1	
	
	s: GET_BUFFER(src)
	unit: GET_UNIT(s)
   	while [svalue < tail][
		val: vector/get-value-float svalue unit
		either unit = 8 [p: as pointer! [float!] d1Value  p/value: val]
					    [p32: as pointer! [float32!] d1Value p32/value: as float32! val]
		svalue: svalue + unit
		d1value: d1value + unit
    ]
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
	p4		[int-ptr!]
] [
	 p4: as int-ptr! p
     p4/value: switch unit [
			1 [value and FFh or (p4/value and FFFFFF00h)]
			2 [value and FFFFh or (p4/value and FFFF0000h)]
			4 [value]
	]
]


; converts Integer Matrix scale
; 8 -> 16-bits pbs
; 8 -> 32-bits OK
; 16 -> 32-bits OK

_convertMatScale: routine [
	src			[vector!]
	dst			[vector!]
	srcScale	[float!] ; eg FFh
	dstScale	[float!] ; eg FFFFh	
	/local
	svalue 		[byte-ptr!]
	tail 		[byte-ptr!]
	int 		[integer!]
	v			[float!]
	s	 		[series!]
	unit 		[integer!]
][
	svalue: vector/rs-head src  ; get a pointer address of the source matrix first value
	tail:  vector/rs-tail src	; last
	vector/rs-clear dst 		; clears destination for append calculated value
	s: GET_BUFFER(src)
	unit: GET_UNIT(s)
	while [svalue < tail][
		int: vector/get-value-int as int-ptr! svalue unit
		v: ((as float! int) / srcScale) * dstScale 
		vector/rs-append-int dst as integer! v
		svalue: svalue + unit
	]
]


; Red Image -> 1 channel 2-D matrice with a grayscale 
; conversion to 8 16 or 32-bit matrices 

_rcvImage2Mat: routine [
	src		[image!]
	mat		[vector!]
	/local
	pix1 	[int-ptr!]
	dvalue 	[byte-ptr!]
	handle1
	unit s
	h w x y 
	r g b a grv
] [
	handle1: 0
    pix1: image/acquire-buffer src :handle1
    w: IMAGE_WIDTH(src/size) 
    h: IMAGE_HEIGHT(src/size) 
    x: 0
    y: 0 
    dvalue: vector/rs-head mat	; a byte ptr
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
    ;vector/rs-clear mat 
    while [y < h] [
       while [x < w][
			a: pix1/value >>> 24
       		r: pix1/value and FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
        	b: pix1/value and FFh 
        	;OK RGBA are correct
        	; -> to Grayscale mat
        	grv: r + g + b / 3 
        	_setIntValue as integer! dvalue grv unit
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
; 8 16 and 32-bit matrices 
_rcvMat2Image: routine [
	mat		[vector!]
	dst		[image!]
	unit	[integer!] ; 1 2 or 4
	/local
	pixD 	[int-ptr!]
	handle
	i v value  
	h w x y
	
] [
	handle: 0
    pixD: image/acquire-buffer dst :handle
    w: IMAGE_WIDTH(dst/size) 
    h: IMAGE_HEIGHT(dst/size) 
    x: 0
    y: 0
    value: vector/rs-head mat ; get pointer address of the matrice
    while [y < h] [
       while [x < w][
       		i: _getIntValue as integer! value unit; get mat value as integer
       		switch unit [
       			1 [v: as float! i]						; 8-bit
       			2 [v: (as float! i) / FFFFh * FFh]		; 16-bit -> 8-bit
       			4 [v: (as float! i) / FFFFFFh * FFh ]	; 32-bit -> 8-bit
       		]
       		i: as integer! v
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
	r g b a
] [
	handle1: 0
    pix1: image/acquire-buffer src :handle1
    w: IMAGE_WIDTH(src/size) 
    h: IMAGE_HEIGHT(src/size) 
    x: 0
    y: 0 
    dvalue0: vector/rs-head mat0	; a byte ptr
    dvalue1: vector/rs-head mat1	; a byte ptr
    dvalue2: vector/rs-head mat2	; a byte ptr
    dvalue3: vector/rs-head mat3	; a byte ptr
   ; vector/rs-clear mat 
    while [y < h] [
       while [x < w][
			a: pix1/value >>> 24
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
        	b: pix1/value and FFh 
        	dvalue0/value: as-byte a
			dvalue1/value: as-byte r
			dvalue2/value: as-byte g
			dvalue3/value: as-byte b
           	x: x + 1
           	pix1: pix1 + 1
           	dValue0: dValue0 + 1
           	dValue1: dValue1 + 1
           	dValue2: dValue2 + 1
           	dValue3: dValue3 + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
]






; 1 channel 2-D matrice (grayscale) -> Red Image 

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
	
] [
	handle: 0
    pixD: image/acquire-buffer dst :handle
    w: IMAGE_WIDTH(dst/size) 
    h: IMAGE_HEIGHT(dst/size) 
    x: 0
    y: 0
    value0: vector/rs-head mat0 ; get pointer address of the matrice
    value1: vector/rs-head mat1 
    value2: vector/rs-head mat2
    value3: vector/rs-head mat3
    while [y < h] [
       while [x < w][
       		a: _getIntValue as integer! value0 1; get mat value as integer
       		r: _getIntValue as integer! value1 1; get mat value as integer
       		g: _getIntValue as integer! value2 1; get mat value as integer
       		b: _getIntValue as integer! value3 1; get mat value as integer
       		pixD/value: ((255 << 24) OR (r << 16 ) OR (g << 8) OR b)
       		value0: value0 + 1
       		value1: value1 + 1
       		value2: value2 + 1
       		value3: value3 + 1
           	pixD: pixD + 1
           	x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer dst handle yes
]


; Convolution on matrix (only 8-bit matrices)

_rcvConvolveMat: routine [
    src  	[vector!]
    dst  	[vector!]
    mSize	[pair!]
    kernel 	[block!] 
    factor 	[float!]
    delta	[float!]
    /local
        h w x y i j
        value dvalue idx 
        accV v f 
        mx my 
		kWidth 
		kHeight 
		kBase 
		kValue  
][
    ;get mat size will be improved in future
    
    w: mSize/x
    h: mSize/y
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
	value: vector/rs-head src   ; get pointer address of the source matrix first value
	dvalue: vector/rs-head dst	; a byte ptr
	vector/rs-clear dst 		; clears destination matrix
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
    	accV: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		mx:  (x + (i - (kWidth / 2)) + w ) % w 
        			my:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: value + (my * w) + mx  ; corrected pixel index
           			v: _getIntValue as integer! idx 1; get mat value as 8-bit integer
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			accV: accV + ((as float! v) * f/value)
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        
        v: as integer! (accv * factor) 						 			 
    	v: v + as integer! delta
        if v < 0 [v: 0] ; for unsigned integer 
		dvalue/value: as-byte v ; only 0..255
        value: value + 1 
        dvalue: dvalue + 2 ;?? should be 1
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
][
    ;get mat size will be improved in future with matrix! type
    w: mSize/x
    h: mSize/y
	svalue: vector/rs-head src   ; get byte pointer address of the source matrix first value
	dvalue: vector/rs-head dst	; a byte ptr
	vector/rs-clear dst 		; clears destination matrix
    x: 0
    y: 0
    gX: 0
    gY: 0
    sum: 0
    while [y < h] [	
       	while [x < w][
    		gx: _xSMGradient as integer! svalue mSize x y
    		gy: _ySMGradient as integer! svalue mSize x y
    		;sum: gX + gY ; faster approximation but requires absolute difference
    		sum: as integer! (sqrt ((as float! gx * gx) + (as float! gy * gy)))
    		if sum < 0 [sum: 0]
    		dvalue/value: as-byte sum
       		svalue: svalue + 1 
        	dvalue: dvalue + 2 ; ?? 2 should be 1
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
; exported as functions in /libs/matrix/rcvMatrixRoutines.red
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
    s unit
    x y w h
    pindex val val2
    sum sqsum
] [
    svalue: vector/rs-head src  
	d1value: vector/rs-head dst1	
	d2value: vector/rs-head dst2
	s: GET_BUFFER(src)
	unit: GET_UNIT(s)
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

;************** matrices alpha blending ***********************
; exported as functions in /libs/matrix/rcvMatrixRoutines.red

_rcvBlendMat: routine [
	mat1		[vector!]
	mat2		[vector!]
	dst			[vector!]
	alpha		[float!]
	/local
	svalue1 	[byte-ptr!]
	svalue2 	[byte-ptr!]
	tail 		[byte-ptr!]
	s	 		[series!]
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
    s: GET_BUFFER(mat1)
	unit: GET_UNIT(s)
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
; exported as functions in /libs/matrix/rcvMatrixRoutines.red


_rcvInRangeMat: routine [
	mat1		[vector!]
	dst			[vector!]
	lower		[integer!]
	upper		[integer!]
	op			[integer!]
	/local
	svalue1 	[byte-ptr!]
	tail 		[byte-ptr!]
	s	 		[series!]
	unit 		[integer!]
	int1 		[integer!]
	v			[integer!]
] [
	vector/rs-clear dst
	svalue1: vector/rs-head mat1
	tail: vector/rs-tail mat1
	s: GET_BUFFER(mat1)
	unit: GET_UNIT(s)
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

