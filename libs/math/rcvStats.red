Red [
	Title:   "Red Computer Vision: Statistics"
	Author:  "Francois Jouen"
	File: 	 %rcvSats.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

#include %../matrix/rcvMatrix.red

;***************** STATISTICAL ROUTINES ON IMAGE ***********************
rcvCount: routine [
"Returns the number of non zero values in image"
	src1 		[image!] 
	return: 	[integer!]
	/local 
		pix1	[int-ptr!]
		handle1	[integer!]
		w 		[integer!]
		h 		[integer!]
		x 		[integer!]
		y 		[integer!]
		r 		[integer!]
		g		[integer!]
		b		[integer!]
		a		[integer!]
		n		[integer!]
][
    handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    y: 0
    n: 0
    while [y < h][
    	x: 0
        while [x < w][
            a: pix1/value >>> 24
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
       		b: pix1/value and FFh 
       		if any [r > 0 g > 0 b > 0] [n: n + 1]
            pix1: pix1 + 1
            x: x + 1
        ]
        y: y + 1
    ]
    image/release-buffer src1 handle1 no
    n
]


rcvStdImg: routine [
"Returns standard deviation value of image as an integer"
	src1 	[image!] 
	return: [integer!]
	/local 
		pix1	[int-ptr!]
		pix2	[int-ptr!]
		handle1	[integer!]
		w 		[integer!]
		h 		[integer!]
		x 		[integer!]
		y 		[integer!]
		r 		[integer!]
		g		[integer!]
		b		[integer!]
		a		[integer!]
		mr		[integer!] 
		mg		[integer!]
		mb		[integer!]
		ma		[integer!]
		sr 		[integer!]
		sg		[integer!]
		sb		[integer!]
		sa		[integer!]
		fr 		[float!]
		fg		[float!]
		fb		[float!]
		fa		[float!]
		e		[integer!]
][
    handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    pix2: pix1
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0 y: 0
    sa: 0 sr: 0 sg: 0 sb: 0
    fa: 0.0 fr: 0.0 fg: 0.0 fb: 0.0
    ; Sigma X
    while [y < h][
    	x: 0
        while [x < w][
            a: pix1/value >>> 24
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
       		b: pix1/value and FFh 
            sa: sa + a
            sr: sr + r  
            sg: sg + g
            sb: sb + b
            pix1: pix1 + 1
            x: x + 1
        ]
        y: y + 1
    ]
    ; mean values
    ma: sa / (w * h)
    mr: sr / (w * h)
    mg: sg / (w * h)
    mb: sb / (w * h)
    x: 0 y: 0 e: 0
    ;pix1: image/acquire-buffer src1 :handle1 ; pbs with windows
    ; x - m 
    while [y < h][
    	x: 0
        while [x < w][
           	a: pix2/value >>> 24
       		r: pix2/value and 00FF0000h >> 16 
        	g: pix2/value and FF00h >> 8 
       		b: pix2/value and FFh 
            e: a - ma sa: sa + (e * e)
            e: r - mr sr: sr + (e * e)
            e: g - mg sg: sg + (e * e)
            e: b - mb sb: sb + (e * e)
            pix2: pix2 + 1
            x: x + 1
        ]
        y: y + 1
    ]
    ; standard deviation
    fa: 0.0; 255 xor sa / ((w * h) - 1)
    fr: sqrt as float! (sr / ((w * h) - 1))
    fg: sqrt as float! (sg / ((w * h) - 1))
    fb: sqrt as float! (sb / ((w * h) - 1))
    a: as integer! fa
    r: as integer! fr
    g: as integer! fg
    b: as integer! fb
    image/release-buffer src1 handle1 no
    (a << 24) OR (r << 16 ) OR (g << 8) OR b 
]

rcvMeanImg: routine [
"Returns mean value of image as an integer"
	src1 	[image!] 
	return: [integer!]
	/local 
		pix1	[int-ptr!]
		handle1	[integer!]
		w 		[integer!]
		h 		[integer!]
		x 		[integer!]
		y 		[integer!]
		r 		[integer!]
		g		[integer!]
		b		[integer!]
		a		[integer!]
		sr 		[integer!]
		sg		[integer!]
		sb		[integer!]
		sa		[integer!]
][
    handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
  	y: 0
    sa: 0 sr: 0 sg: 0 sb: 0
    while [y < h][
    	x: 0
        while [x < w][
            a: pix1/value >>> 24
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
       		b: pix1/value and FFh 
            sa: sa + a
            sr: sr + r 
            sg: sg + g
            sb: sb + b
            pix1: pix1 + 1
            x: x + 1
        ]
        y: y + 1
    ]
    a: sa / (w * h)
    r: sr / (w * h)
    g: sg / (w * h)
    b: sb / (w * h)
    image/release-buffer src1 handle1 no
    (a << 24) OR (r << 16 ) OR (g << 8) OR b 
]

rcvMinLocImg: routine [
"Finds global minimum location in image"
	src1 	[image!] 
	return: [pair!]
/local 
		pix1	[int-ptr!]
		handle1	[integer!]
		w 		[integer!]
		h 		[integer!]
		x 		[integer!]
		y 		[integer!]
		r 		[integer!]
		g		[integer!]
		b		[integer!]
		v		[integer!]
		mini  	[integer!]
		locmin 	[red-pair!]
] [
	handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    mini: (255 << 16) or (255 << 8) or 255
    locmin: pair/make-at stack/push* 0 0
    y: 0
    while [y < h][
    	x: 0
        while [x < w][
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
       		b: pix1/value and FFh 
            v: (r << 16 ) OR (g << 8) OR b 
            if v < mini [mini: v locmin/x: x locmin/y: y]
            pix1: pix1 + 1
            x: x + 1
        ]
        y: y + 1
    ]
    image/release-buffer src1 handle1 no
    as red-pair! stack/set-last as cell! locmin 
]


rcvMaxLocImg: routine [
"Finds global maximun location in image"
	src1 	[image!] 
	return: [pair!]
/local 
		pix1	[int-ptr!]
		handle1	[integer!]
		w 		[integer!]
		h 		[integer!]
		x 		[integer!]
		y 		[integer!]
		r 		[integer!]
		g		[integer!]
		b		[integer!]
		v		[integer!]
		maxi 	[integer!] 
		locmax	[red-pair!] 
] [
	handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    maxi: 0
    locmax: pair/make-at stack/push* 0 0
    y: 0
    while [y < h][
    	x: 0
        while [x < w][
            r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
       		b: pix1/value and FFh 
            v: (r << 16 ) OR (g << 8) OR b 
            if v > maxi [maxi: v locmax/x: x locmax/y: y]
            pix1: pix1 + 1
            x: x + 1
        ]
        y: y + 1
    ]
    image/release-buffer src1 handle1 no
    as red-pair! stack/set-last as cell! locmax 
]

; sorting images
_sortPixels: routine [
	arr 	[vector!]
	/local
	ptr		[int-ptr!]
	tmp		[integer!]
	n		[integer!]
	i 		[integer!]
	j		[integer!]
	j2		[integer!]
	
][
	n: vector/rs-length? arr
	ptr: as int-ptr! vector/rs-head arr
	i: 1
	while [i <= n] [
		j: 1
		while [j < i] [
			if ptr/i < ptr/j [
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

_sortReversePixels: routine [
	arr 	[vector!]
	/local
	ptr		[int-ptr!]	
	n		[integer!]
	i 		[integer!]
	j		[integer!]
	j2		[integer!]
	tmp		[integer!]
][
	n: vector/rs-length? arr
	ptr: as int-ptr! vector/rs-head arr
	i: 0
	while [i <= n] [
		j: 1
		while [j < i] [
			if ptr/i > ptr/j [
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


rcvSortImagebyX: routine [
"Sorts image columns"
	src1 	[image!]
	dst		[image!]
	b		[vector!]
	flag	[logic!]
	/local
	pix1 	[int-ptr!]
    pixD 	[int-ptr!]
    handle1 [integer!]
    handleD [integer!]
    h 		[integer!]
    w 		[integer!]
    x		[integer!]	 
    y		[integer!]
    n		[integer!]
    idx 	[int-ptr!]
    vBase 	[byte-ptr!]
    ptr 	[int-ptr!]
][
	handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    vBase: vector/rs-head b
    y: 0
    while [y < h] [
    	x: 0 
    	vector/rs-clear b
    	while [x < w] [
    		idx: pix1 + (y * w) + x
    		vector/rs-append-int b idx/value
    		x: x + 1
    	]
    	either flag [_sortReversePixels b] 
    				[_sortPixels b]
    	ptr: as int-ptr! vBase
    	x: 0
		while [x < w] [
			idx: pixD + (y * w) + x
			n: x + 1			; ptr/0 returns vector size
			idx/value: ptr/n
			x: x + 1
		]
    	y: y + 1
    ]
    image/release-buffer src1 handle1 no
	image/release-buffer dst handleD yes
]


rcvSortImagebyY: routine [
"Sorts image lines"
	src1 	[image!]
	dst		[image!]
	b		[vector!]
	flag	[logic!]
	/local
	pix1 	[int-ptr!]
    pixD 	[int-ptr!]
    handle1 [integer!]
    handleD [integer!]
    h 		[integer!]
    w 		[integer!]
    x		[integer!]	 
    y		[integer!]
    n		[integer!]
    idx 	[int-ptr!]
    vBase 	[byte-ptr!]
    ptr 	[int-ptr!]
][
	handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    vBase: vector/rs-head b
    x: 0
    while [x < w] [
    	y: 0 
    	vector/rs-clear b
    	while [y < h] [
    		idx: pix1 + (y * w) + x
    		vector/rs-append-int b idx/value
    		y: y + 1
    	]
    	either flag [_sortReversePixels b] 
    				[_sortPixels b]
    	ptr: as int-ptr! vBase
    	y: 0
		while [y < h] [
			idx: pixD + (y * w) + x
			n: y + 1		; ptr/0 returns vector size
			idx/value: ptr/n 
			y: y + 1
		]
    	x: x + 1
    ]
    image/release-buffer src1 handle1 no
	image/release-buffer dst handleD yes
]



;***************** STATISTICAL ROUTINES ON MATRIX ***********************

rcvCountMat: routine [
"Returns number of non zero values in matrix"
	mObj 	[object!] 
	return: [integer!]
	/local
	vec		[red-vector!]
	svalue 	[byte-ptr!]
	tail	[byte-ptr!]
	f		[float!]
	int 	[integer!] 
	unit	[integer!]  
	n		[integer!] 
	
] [
	vec: mat/get-data mObj
	unit: mat/get-unit mObj
    svalue: vector/rs-head vec ; get pointer address of the matrice
    tail: vector/rs-tail vec
	n: 0
	;integer matrix
	if  any [vec/type = TYPE_INTEGER vec/type = TYPE_CHAR][
		while [svalue < tail][
			int: vector/get-value-int as int-ptr! svalue unit
			if (int > 0) [n: n + 1] 
			svalue: svalue + unit 
		]
	]
	;float matrix
	if vec/type = TYPE_FLOAT [
		while [svalue < tail][
			f: vector/get-value-float svalue unit
			if (f > 0.0) [n: n + 1] 
			svalue: svalue + unit 
		]
	]
	n
]


;--we can also use matrix/sigma mObj (a little bit slower)  
rcvSumMat: routine [
"Returns sum value of matrix as a float"
	mObj 	[object!] 
	return: [float!]
	/local
	vec			[red-vector!]
	svalue 		[byte-ptr!]
	tail		[byte-ptr!]
	f sum		[float!] 
	int unit	[integer!]  
] [
	vec: mat/get-data mObj
	unit: mat/get-unit mObj
    svalue: vector/rs-head vec ; get pointer address of the matrice
    tail: vector/rs-tail vec
	sum: 0.0
	;integer matrix
	if  any [vec/type = TYPE_INTEGER vec/type = TYPE_CHAR] [
		while [svalue < tail][
			int: vector/get-value-int as int-ptr! svalue unit
			sum: sum + as float! int
			svalue: svalue + unit 
		]
	]
	;float matrix
	if vec/type = TYPE_FLOAT [
		while [svalue < tail][
			f: vector/get-value-float svalue unit
			sum: sum + f
			svalue: svalue + unit 
		]
	]
	sum
]

;--we can also use matrix/mean mObj
rcvMeanMat: routine [
"Returns mean value of matrix as a float"
	mObj 		[object!] 
	return: 	[float!]
	/local
	vec			[red-vector!]
	svalue 		[byte-ptr!]
	tail		[byte-ptr!]
	int unit n	[integer!] 
	sum f		[float!]
] [
	vec: mat/get-data mObj
	unit: mat/get-unit mObj
    svalue: vector/rs-head vec ; get pointer address of the matrice
    tail: vector/rs-tail vec
    n: vector/rs-length? vec
	sum: 0.0
	;integer matrix
	if  any [vec/type = TYPE_INTEGER vec/type = TYPE_CHAR][
		while [svalue < tail][
			int: vector/get-value-int as int-ptr! svalue unit
			sum: sum + (as float! int)
			svalue: svalue + unit 
		]
	]
	;float matrix
	if vec/type = TYPE_FLOAT [
		while [svalue < tail][
			f: vector/get-value-float svalue unit
			sum: sum + f
			svalue: svalue + unit 
		]
	]
	sum / (as float! n)			
]

rcvStdMat: routine [
"Returns standard deviation value of matrix as a float"
	mObj 	[object!] 
	return: [float!]
	/local
	vec				[red-vector!]
	svalue tail 	[byte-ptr!]
	n int unit		[integer!]
	sum sum2 e m f 	[float!]
	ef				[float!]
][
	vec:  mat/get-data mObj
	unit: mat/get-unit mObj
    svalue: vector/rs-head vec ; get pointer address of the matrice
    tail: vector/rs-tail vec
    n: vector/rs-length? vec
	sum: 0.0 
	sum2: 0.0
	; integer matrix
	if  any [vec/type = TYPE_INTEGER vec/type = TYPE_CHAR][
		; mean
		while [svalue < tail][
			int: vector/get-value-int as int-ptr! svalue unit
			sum: sum + (as float! int)
			svalue: svalue + unit 
		]
		m: sum / (as float! n)
		svalue: vector/rs-head vec 
		while [svalue < tail][
			int: vector/get-value-int as int-ptr! svalue unit
			e: (as float! int) - m
			sum2: sum + (e * e)
			svalue: svalue + unit 
		]
		n: n - 1
		f: sqrt (sum2 / (as float! n))	
	]
	;float matrix
	if vec/type = TYPE_FLOAT [
		; mean
		while [svalue < tail][
			f: vector/get-value-float svalue unit
			sum: sum + f
			svalue: svalue + unit 
		]
		m: sum / (as float! n)
		svalue: vector/rs-head vec 
		while [svalue < tail][
			f: vector/get-value-float svalue unit
			ef: f - m
			sum2: sum + (ef * ef)
			svalue: svalue + unit 
		]
		n: n - 1
		f: sqrt (sum2 / (as float! n))	
	]
	f
]

rcvMaxLocMat: routine [
"Finds global maximum location in matrix"
	mObj 		[object!]  
	return: 	[pair!]
	/local 
	vec			[red-vector!]
	svalue 		[byte-ptr!] 
	int 		[integer!]
	unit		[integer!]
	x 			[integer!]
	y			[integer!]
	maxi 		[integer!]
	locmax		[red-pair!]
		
] [
	vec:  mat/get-data mObj
	unit: mat/get-unit mObj
	svalue: vector/rs-head vec ; get pointer address of the matrice
    maxi: 0
    locmax: pair/make-at stack/push* 0 0
    y: 1
    while [y <= mat/get-rows mObj] [	
    	x: 1
       	while [x <= mat/get-cols mObj][
       		either vec/type = TYPE_FLOAT [
       			int: as integer! vector/get-value-float svalue unit]
       			[int: vector/get-value-int as int-ptr! svalue unit]
    		if int > maxi [maxi: int locmax/x: x locmax/y: y]
       		svalue: svalue + unit 
        	x: x + 1
       ]
       y: y + 1
    ]
    as red-pair! stack/set-last as cell! locmax 
]

rcvMinLocMat: routine [
"Finds global minimum location in matrix"
	mObj 		[object!] 
	return: 	[pair!]
	/local 
	vec			[red-vector!]
	svalue 		[byte-ptr!] 
	int 		[integer!]
	unit		[integer!]
	x y			[integer!]
	mini 		[integer!]
	locmin		[red-pair!]
		
] [
	vec:  mat/get-data mObj
	unit: mat/get-unit mObj
	svalue: vector/rs-head vec ; get pointer address of the matrice
    mini: 2147483647
    locmin: pair/make-at stack/push* 0 0
    y: 1
    while [y <= mat/get-rows mObj] [	
    	x: 1
       	while [x <= mat/get-cols mObj][
    		either vec/type = TYPE_FLOAT [
       			int: as integer! vector/get-value-float svalue unit]
       			[int: vector/get-value-int as int-ptr! svalue unit]
    		if int < mini [mini: int locmin/x: x locmin/y: y]
       		svalue: svalue + unit 
        	x: x + 1
       ]
       y: y + 1
    ]
    as red-pair! stack/set-last as cell! locmin
]

;************** STATISTICAL FUNCTIONS (images) *********************

rcvRangeImage: function [
"Range value in Image as a tuple"
	source [image!] 
][
	img: copy source
	n: to integer! (length? img/rgb) / 3 ; RGB channels only
	img/rgb: copy sort source/rgb 
	;return: [tuple!]
	pxl1: img/1
	pxl2: img/(n)
	pxl2 - pxl1
]


rcvSortImage: function [
"Ascending image sorting"
	source 	[image!] 
	dst 	[image!]
][
	dst/rgb: copy sort source/rgb 
]

rcvXSortImage: function [
"Image sorting by line"
	src 	[image!] 
	dst		[image!] 
	flag 	[logic!] ; reverse order
][
	b: make vector! src/size/x
	rcvSortImagebyX src dst b flag
]

rcvYSortImage: function [
"Image sorting by column"
	src 	[image!] 
	dst		[image!] 
	flag 	[logic!] ; reverse order
][
	b: make vector! src/size/y
	rcvSortImagebyY src dst b flag
]

;************** STATISTICAL FUNCTIONS (images or matrices) *********************

rcvCountNonZero: function [
"Returns number of non zero values in image or matrix"
	arr [image! object!]
][
	t: type? arr
	if t = image! 	[n: rcvCount arr]
	if t = object!  [n: rcvCountMat arr]
	n
]

rcvSum: function [
"Returns sum value of image or matrix as a block"
	arr [image! object!] 
	/argb
][
	t: type? arr
	if t = image! 	[	v: rcvMeanImg arr
						a: v >>> 24
    					r: v and 00FF0000h >> 16 
    					g: v and FF00h >> 8 
    					b: v and FFh
    					sz: arr/size/x * arr/size/y
    					sa: a * sz
    					sr: r * sz
    					sg: g * sz
    					sb: b * sz
    					either argb [blk: reduce [sa sr sg sb]] [blk: reduce [sr sg sb]]
					]
	if t = object!  [summ: rcvSumMat arr blk: reduce [summ]]
	blk
]

rcvMean: function [
"Returns mean value of image or matrix as a tuple"
	arr [image! object!] 
	/argb
][
	t: type? arr
	if t = object!  [m: rcvMeanMat arr tp: make tuple! reduce [m]]
	if t = image! 	[v: rcvMeanImg arr
					a: v >>> 24
    				r: v and 00FF0000h >> 16 
    				g: v and FF00h >> 8 
    				b: v and FFh
   					either argb [tp: make tuple! reduce [a r g b]] [tp: make tuple! reduce [r g b]]
	]
	tp
]

rcvSTD: function [
"Returns standard deviation value of image or matrix as a tuple"
	arr [image! object!] 
	/argb
][
t: type? arr
	if t = object!  [m: rcvStdMat arr tp: make tuple! reduce [m]]
	if t = image! 	[v: rcvStdImg arr
    				a: v >>> 24
    				r: v and 00FF0000h >> 16 
    				g: v and FF00h >> 8 
    				b: v and FFh
   					either argb [tp: make tuple! reduce [a r g b]] 
   					            [tp: make tuple! reduce [r g b]]
	]
	tp
]	


rcvMedian: function [
"Returns median value of image (tuple)  or matrix (value)"
	arr [image! object!] 
][
t: type? arr
	if t = object!  [_arr: copy arr/data
					 sort _arr
					 n: to integer! length? _arr
					 pos: to integer! ((n + 1) / 2)
					 either odd? n  [pxl: _arr/:pos] 
					 				[m1: _arr/:pos m2: _arr/(pos + 1) pxl: (m1 + m2) / 2]
	]
	if t = image! 	[img: make image! arr/size
					 img/rgb: copy sort arr/rgb 
					 n: length? img
					 pos: to integer! ((n + 1) / 2)
					 either odd? n [pxl: img/(pos)] [m1: img/(pos) m2: img/(pos + 1) pxl: (m1 + m2) / 2]
	]
	pxl
]	




rcvMinValue: function [
"Minimal value in image or matrix as a tuple"
	arr [image! object!]
][
t: type? arr
	if t = object!  [pxl: matrix/mini arr]
	if t = image! 	[img: make image! arr/size
					 img/rgb: copy sort arr/rgb 
					 pxl: img/1
	]
	pxl
]	



rcvMaxValue: function [
"Maximal value in image or matrix as a tuple"
	arr [image! object!] 
][
	t: type? arr
	if t = object!  [pxl: matrix/maxi arr]
	if t = image! 	[img: make image! arr/size
					 img/rgb: copy sort arr/rgb 
					 pxl: last img
	]
	pxl
]	

rcvMinLoc: function [
"Finds global minimum location in array"
	arr 	[image! object!] 
][
	t: type? arr
	if t = object! 	[ret: rcvMinLocMat arr]
	if t = image! 	[ret: rcvMinLocImg arr]
	ret
]

rcvMaxLoc: function [
"Finds global maximum location in array"
	arr 	[image! object!] 
][
	t: type? arr
	if t = object! 	[ret: rcvMaxLocMat arr]
	if t = image! 	[ret: rcvMaxLocImg arr]
	ret
]





