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

; gets matrix element value
_getMatValue: routine [
	p		[integer!] ; address of mat element
	unit	[integer!] ; size of integer 8 16 32 [1 2 4]
	return:	[integer!]
] [
	vector/get-value-int as int-ptr! p unit
]


; converts Integer Matrix scale

_convertMatScale: routine [
	src			[vector!]
	dst			[vector!]
	srcScale	[float!] ; eg FFh
	dstScale	[float!] ; eg FFFFh	
	/local
	svalue tail int v 
	s	 [series!]
	unit [integer!]
][
	svalue: vector/rs-head src  ; get a byte-pointer address of the source matrix first value
	tail: vector/rs-tail src	; last
	vector/rs-clear dst 		; clears destination for append calculated value
	s: GET_BUFFER(src)
	unit: GET_UNIT(s)
	while [svalue < tail][
		int: vector/get-value-int as int-ptr! svalue unit
		v: (as float! int) / srcScale * dstScale 
		vector/rs-append-int dst as integer! v
		svalue: svalue + 2 ;?? should be 1
	]
]



; Red Image -> 1 channel 2-D matrice with a grayscale 
; conversion (only 8-bit matrices) 

_rcvImage2Mat: routine [
	src		[image!]
	mat		[vector!]
	/local
	pix1 	[int-ptr!]
	dvalue 	[byte-ptr!]
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
    dvalue: vector/rs-head mat	; a byte ptr
   ; vector/rs-clear mat 
    while [y < h] [
       while [x < w][
			a: pix1/value >>> 24
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
        	b: pix1/value and FFh 
        	; -> to Grayscale image
			dvalue/value: as-byte (r + g + b) / 3
           	x: x + 1
           	pix1: pix1 + 1
           	dValue: dValue + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
]


; 1 channel 2-D matrice (grayscale) -> Red Image 

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
       		i: _getMatValue as integer! value unit; get mat value as integer
       		switch unit [
       			1 [v: as float! i]
       			2 [v: (as float! i) / FFFFh * FFh]
       			4 [v: (as float! i) / FFFFFFh * FFh ]
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
           			v: _getMatValue as integer! idx 1; get mat value as 8-bit integer
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
    v: _getMatValue idx 1
    sum: sum + v
    idx: p + (y * w) + (x - 1) 
    v: _getMatValue idx 1
    sum: sum + (v * 2)
    idx: p + (y + 1 * w) + (x - 1) 
    v: _getMatValue idx 1
    sum: sum + v
    idx: p + (y - 1 * w) + (x + 1) 
    v: _getMatValue idx 1
    sum: sum - v
    idx: p + (y  * w) + (x + 1)
    v: _getMatValue idx 1 
    sum: sum - (v * 2)
    idx: p + (y + 1 * w) + (x + 1) 
    v: _getMatValue idx 1
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
    v: _getMatValue idx 1 
    sum: sum + v
    idx: p + (y - 1 * w) + x 
    v: _getMatValue idx 1
    sum: sum + (v * 2)
    idx: p + (y - 1 * w) + (x + 1) 
    v: _getMatValue idx 1
    sum: sum + v
    idx: p + (y + 1 * w) + (x - 1) 
    v: _getMatValue idx 1
    sum: sum - v
    idx: p + (y + 1 * w) + x 
    v: _getMatValue idx 1
    sum: sum - (v * 2)
    idx: p + (y + 1 * w) + (x + 1) 
    v: _getMatValue idx 1
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
