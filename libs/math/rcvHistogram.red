Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvHistogram.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2020 François Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;#include %../matrix/rcvMatrix.red ;--for stand alone test
;***************** HISTOGRAM ROUTINES ON IMAGE ***********************

_minFloat: routine [
	a 		[float!] 
	b 		[float!]
	return: [float!]
][ 
		either (a < b) [a] [b]
]

_maxFloat: routine [
	a 		[float!] 
	b 		[float!]
	return: [float!]
][ 
		either (a > b) [a] [b]
]

rcvHistoImg: routine [
"Calculates image histogram by channel"
    src  		[image!]		;red image
    op	 		[integer!]		;channel selection (argb or grayscale)
    return: 	[vector!]		;32-bit integer vector
    /local
    	histo  				[red-vector!]
        pix1 tvalue base 	[int-ptr!]	
        handle1				[integer!] 
        s					[series!] 
        h w x y	r g b a c	[integer!]
][
    handle1: 0
    pix1: image/acquire-buffer src :handle1
    histo: vector/make-at stack/push* 256 TYPE_INTEGER 4 ;--0..255 32-bit
    tvalue: as int-ptr! vector/rs-head histo
	base: tvalue
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
       		a: pix1/value >>> 24
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
        	b: pix1/value and FFh 
        	c: (r + g + b) / 3
        	switch op [
        		0 [tvalue: base + a]	;alpha Channel
            	1 [tvalue: base + r]	;Red Channel
            	2 [tvalue: base + g] 	;Green Channel 
            	3 [tvalue: base + b] 	;Blue Channel
            	4 [tvalue: base + c]	;grayscale
        	]
        	tvalue/value: tvalue/value + 1	; inc bin number 
       	 	x: x + 1
        	pix1: pix1 + 1
       ]
       y: y + 1
    ]
    image/release-buffer src handle1 no
    s: GET_BUFFER(histo)
	s/tail: as cell! (as int-ptr! s/offset) + 256
	as red-vector! stack/set-last as cell! histo
]

; Uses ARRAY (a block! of vectors!)		
rcvRGBHistogram: routine [
"Calculates Array histogram"
    src  	[image!]	; red image
    dst 	[image!]	; destination image 
    array  	[block!]	; block of vectors
    /local
        pix1 [int-ptr!]
        pixD 	[int-ptr!]
        handle1	handleD 		[integer!]
        h w	x y					[integer!]
        lines cols				[integer!]
        bsvalue bstail base		[red-value!] 
        rvalue gvalue bvalue p	[int-ptr!]
        vectBlk					[red-vector!]
        r g b a	sBins unit		[integer!] 
        s						[series!]
        
][
    handle1: 0
    pix1: image/acquire-buffer src :handle1
    handleD: 0
    pixD: image/acquire-buffer dst :handleD
    bsvalue: block/rs-head array
    bstail:  block/rs-tail array
	lines:   block/rs-length? array 	;default 3 for RGB
	vectBlk: as red-vector! bsvalue
    cols: vector/rs-length? vectBlk		; number of bins
    s: GET_BUFFER(vectBlk)
	unit: GET_UNIT(s)
   	sBins: as integer! (ceil (256.0 / as float! cols)) ; for clustering color values
    y: 1
    ;get the address of each color vector
    while [bsvalue < bstail][
    	vectBlk: as red-vector! bsvalue
    	if y = 1 [rvalue: as int-ptr! vector/rs-head vectBlk]; R bin values
    	if y = 2 [gvalue: as int-ptr! vector/rs-head vectBlk]; G bin Values
    	if y = 3 [bvalue: as int-ptr! vector/rs-head vectBlk]; B bin values
    	bsvalue: bsvalue + 1
    	y: y + 1
    ] 
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
       		a: pix1/value >>> 24
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
        	b: pix1/value and FFh 
        	; cluster rgb values according to number of bins
        	r: r / sBins 	
        	g: g / sBins 
        	b: b / sBins
        	; process r bin and inc bin
        	p: rvalue + r
        	p/value: 1 + vector/get-value-int p unit
        	; process g bin and inc bin
        	p: gvalue + g
        	p/value: 1 + vector/get-value-int p unit
        	; process b bin and inc bin
        	p: bvalue + b
        	p/value: 1 + vector/get-value-int p unit
        	pixD/value: (255 << 24) OR ( r << 16 ) OR (g << 8) OR b
        	pixD: pixD + 1
        	pix1: pix1 + 1
        	x: x + 1
       	]
       	y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]

rcvMeanShift: routine [
"Mean Shift filter on image"
	src 	[image!] 	
	dst 	[image!] 
	array 	[block!]	; array of RGB Histograms
	colorBW	[float!]	; color bandwidth
	converg	[float!]	; for mean convergence 
	op		[logic!]	; for color control
	/local
	pix1 pixD 				[int-ptr!]
    handle1	handleD 		[integer!] 
    bsvalue bstail			[red-value!]
    rvalue gvalue bvalue p	[float-ptr!]
    vectBlk	[				red-vector!]
    h w x y lines cols		[integer!]
    r g b a	binR binG binB	[float!]
    sR sG sB				[float!] 
    weightR	weightG weightB	[float!]
    dist rd gd bd			[float!]
    hr lr hg lg hb lb unit	[integer!] 
    colorR colorG colorB	[integer!]
    factor 					[float!]
    s						[series!]
    _a _r _g _b				[integer!]
    rgba dRange				[subroutine!]
][
	handle1: 0
    pix1: image/acquire-buffer src :handle1
    handleD: 0
    pixD: image/acquire-buffer dst :handleD
    bsvalue: block/rs-head array
    bstail:  block/rs-tail array
	lines:   block/rs-length? array 
	vectBlk: as red-vector! bsvalue
    cols: vector/rs-length? vectBlk
    s: GET_BUFFER(vectBlk)
	unit: GET_UNIT(s)
    factor: 256.0 / (as float! cols)
    a: r: g: b: 0.0
    _a: _r: _g: _b: 0
    binR: binG: binB: 0.0
    hr: lr: hg: lg: hb: lb: 0
    colorR: colorG: colorB: 0
    ;--subroutines
    rgba: [
    	_a: pix1/value >>> 24 a: as float! _a
    	_r: pix1/value and 00FF0000h >> 16 	r: as float! _r
    	_g: pix1/value and FF00h >> 8 g: as float! _g
    	_b: pix1/value and FFh b: as float! _b 
        binR: ceil ( r / factor)
		binG: ceil ( g / factor)
		binB: ceil ( b / factor)
    ]
    
    dRange: [
    	hr: as integer! (_minFloat (as float! cols) (binR + colorBW))
		lr: as integer! (_maxFloat 1.0 (binR - colorBW))
		hg: as integer! (_minFloat (as float! cols) (binG + colorBW))
		lg: as integer! (_maxFloat 1.0 (binG - colorBW))
		hb: as integer! (_minFloat (as float! cols) (binB + colorBW))
		lb: as integer! (_maxFloat 1.0 (binB - colorBW))
    ]
    ;--end of subroutines
    y: 1
    ;get the address of each vector
    while [bsvalue < bstail][
    	vectBlk: as red-vector! bsvalue
    	if y = 1 [rvalue: as float-ptr! vector/rs-head vectBlk]; R bin values
    	if y = 2 [gvalue: as float-ptr! vector/rs-head vectBlk]; G bin values
    	if y = 3 [bvalue: as float-ptr! vector/rs-head vectBlk]; B bin values
    	bsvalue: bsvalue + 1
    	y: y + 1
    ] 
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
       		rgba		
        	dist: converg + 1.0
        	while [dist > converg] [
        		dRange
        		sR: 0.0 
				weightR: 0.0
				while [lr <= hr] [
					p: rValue + lr
					p/value: vector/get-value-float as byte-ptr! p unit
				 	sR: sR + (1.0 * (as float! lr) * p/value)
				 	weightR: weightR + p/value
					lr: lr + 1
				]	
				sG: 0.0 
				weightG: 0.0
				while [lg <= hg] [
					p: gValue + lg
					p/value: vector/get-value-float as byte-ptr! p unit
					sG: sG + (1.0 * (as float! lg) * p/value) 
					weightG: weightG + p/value
					lg: lg + 1
				]
				sB: 0.0
				weightB: 0.0
				while [lb <= hb] [
					p: bValue + lb
					p/value: vector/get-value-float as byte-ptr! p unit
					sB: sB + (1.0 * (as float! lb) * p/value) 
					weightB: weightB + p/value
					lb: lb + 1
				]
				sR: sR / weightR 
				sG: sG / weightG
				sB: sB / weightB
				rd: sR - binR 
				gd: sG - binG 
				bd: sB - binB
				rd: rd * rd
				gd: gd * gd
				bd: bd * bd
				binR: ceil sR
				binG: ceil sG 
				binB: ceil sB 
				dist: sqrt (rd + gd + bd)
			]
			colorR: (as integer! sR * factor) 
			colorG: (as integer! sG * factor) 
			colorB: (as integer! sB * factor)
			if op = true [
				colorR: colorR and 255
				colorG: colorG and 255
				colorB: colorB and 255
			]
			pixD/value: (255 << 24) OR ( colorR << 16 ) OR (colorG << 8) OR colorB
        	pix1: pix1 + 1
        	pixD: pixD + 1
        	x: x + 1
       	]
       	y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]

;***************** HISTOGRAM ROUTINES ON MATRIX ***********************

rcvHistoMat: routine [
"Calculate matrix histogram"
	mx 				[object!]		;integer or float matrix 
	return:			[vector!]		;32-bit integer vector
	/local
	vec histo 		[red-vector!]
	svalue tail		[byte-ptr!]  
	dvalue base 	[int-ptr!]
	s 				[series!]
	unit int n		[integer!]
] [
	vec:  mat/get-data mx
	unit: mat/get-unit mx
    svalue: vector/rs-head vec ; get pointer address of the matrice data
    tail: vector/rs-tail vec
	n: vector/rs-length? vec
	histo: vector/make-at stack/push* 256 TYPE_INTEGER 4
	base: as int-ptr! vector/rs-head histo ; pointer
	dvalue: base
	while [svalue < tail][
		either vec/type = TYPE_INTEGER [int: as integer! svalue/value]
		[int: as integer! vector/get-value-float svalue unit]
		; we need int value 0..255
		if unit = 1 [int: int and FFh]
		dvalue: base + int					; position in histogram 
		dvalue/value: dvalue/value + 1  	; increment number of value occurence
		svalue: svalue + unit 				; next value in matrice
	]
	s: GET_BUFFER(histo)
	s/tail: as cell! (as int-ptr! s/offset) + 256
	as red-vector! stack/set-last as cell! histo
]


; this is the cumulative-density function for the pixel value n
rcvSumHistoMat: routine [
"Calculates the cumulative sum of histogram "
	histo 		[vector!]		;integer or float matrix  
	return:		[vector!]		;32-bit vector
	/local
	sumHisto 	[red-vector!]
	svalue		[byte-ptr!]  
	tail		[byte-ptr!]
	base 		[int-ptr!]
	s 			[series!]
	unit		[integer!]
	int			[integer!]
    sum			[integer!]
] [
    svalue: vector/rs-head histo ; get pointer address of the matrice
    tail: vector/rs-tail histo
	s: GET_BUFFER(histo)
	unit: GET_UNIT(s)
	sumHisto: vector/make-at stack/push* 256 TYPE_INTEGER 4
	sum: 0
	while [svalue < tail][
		; get value in histo/(i)
		either histo/type = TYPE_INTEGER [int: as integer! svalue/value]
		[int: as integer! vector/get-value-float svalue unit]
		; we need int value 0..255
		if unit = 1 [int: int and FFh]
		sum: sum + int										; increment sum	
		vector/rs-append-int sumHisto sum					; store cumulative sum		
		svalue: svalue + unit			    				; next value
	]
	s: GET_BUFFER(sumHisto)
	s/tail: as cell! (as int-ptr! s/offset) + 256
	as red-vector! stack/set-last as cell! sumHisto
]

rcvEqualizeHistoMat: routine [
"Histogram equalization"
	mx 			[object!] 	;integer or float matrix
	sumHisto 	[vector!] 	;32-bit matrix
	constant 	[float!]
	/local
	vec			[red-vector!]
	svalue 		[byte-ptr!] 
	tail		[byte-ptr!]
	ivalue		[int-ptr!]
	ibase 		[int-ptr!]
	s 			[series!]
	k			[float!]
	int			[integer!] 
	int2 		[integer!] 
	unit 		[integer!]
	p
] [
	vec:  mat/get-data mx
	unit: mat/get-unit mx
	svalue: vector/rs-head vec ; get pointer address of the matrice data
    tail:  	vector/rs-tail vec
    ivalue: as int-ptr! vector/rs-head sumHisto
    ibase: 	ivalue
	while [svalue < tail][
		either vec/type = TYPE_INTEGER [int: as integer! svalue/value]
		[int: as integer! vector/get-value-float svalue unit]
		ivalue: ibase + int 
		int: 	ivalue/value
		k:  	constant * as float! int
		int2: 	as integer! k
		;p: as int-ptr! svalue 
		;p/value: int2
		svalue/value: as byte! int2
		svalue: svalue + unit
	]
]
; affine transform
rcvEqualizeContrast: routine [
"Enhances image contrast with affine transform" 
	mat 		[vector!] 
	table 		[vector!]
	/local
	svalue 		[byte-ptr!] 
	tail		[byte-ptr!]
	dvalue		[int-ptr!]
	base 		[int-ptr!]
	s 			[series!]
	int			[integer!]  
	unit		[integer!]
] [
	svalue: vector/rs-head mat ; get pointer address of the matrice
    tail:  vector/rs-tail mat
    dvalue: as int-ptr! vector/rs-head table
    base: dvalue
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	while [svalue < tail][
		int: vector/get-value-int as int-ptr! svalue unit
		dvalue: base + int 
		svalue/value: as byte! dvalue/value
		svalue: svalue + unit
	]	
]

;***************** HISTOGRAM FUNCTIONS ***********************

rcvHistogram: function [
"Calculates Image or Matrix histogram"
	arr [image! object!]  
	/red /green /blue
][
	t: type? arr
	if t = object! [histo: rcvHistoMat arr]
	if t = image!  [
		case [
			red 	[histo: rcvHistoImg arr 1]
			green 	[histo: rcvHistoImg arr 2]
			blue 	[histo: rcvHistoImg arr 3]
		]	
	]
	histo
]



rcvSmoothHistogram: function [
"This function smoothes the input histogram by a 3 points mean moving average."
	arr [object!] 
][
	histo: make vector! 256 
	n: length? arr/data
	i: 2
	while [i < n] [
		histo/:i: to-integer (arr/data/(i - 1) + arr/data/(i) + arr/data/(i + 1)) / 3 
	 	i: i + 1
	]
	histo/1: histo/2
	histo/(n): histo/(n - 1)		
	arr/data: histo
	arr
]



rcvHistogramEqualization: function [  
"This function performs histogram equalization on the input array"
	arr 	[object!]   
	gLevels [integer!]
] [
	n: length? arr/data
	constant: gLevels / to float! (n)
	histo: rcvHistoMat arr			; calculates histogram (vector)
	sumH:  rcvSumHistoMat histo 	; calculates the sum of histogram
	rcvEqualizeHistoMat arr sumH constant	; transforms input mat
]	

; this function should be transformed to routine for faster access:)
rcvMakeTranscodageTable: function [
"Creates a transcoding table for affine enhancement"
	p [percent!] 
] [
	table: make vector! 256		;return: [vector!]
	p1: to integer! 256 * p
	p2: to integer! 256 - p1
	diff: to float! p2 - p1
	i: 1
	while [i < p1] 	[table/(i): 0 i: i + 1]
	while [i < p2] 	[table/(i): to integer! ((i - p1) / diff) * 255 i: i + 1]
	while [i <= 256][table/(i): 255 i: i + 1]
	table
]

rcvContrastAffine: function [
"Enhances image contrast with affine function" 
	arr [object!] 
	p 	[percent!]
] [
	range: rcvMakeTranscodageTable p
	rcvEqualizeContrast arr/data range
]

;******************** Histogram of Oriented Gradient **************************
; based on Ganesh Iyer's c++ code (https://github.com/lastlegion/hog)
_rcvHOG: routine [
"Histograms of Oriented Gradients"
    src  			[image!]
    matGx			[vector!]
    matGy			[vector!]
    nBins			[integer!]
    nDivs			[integer!]
    return: 		[vector!]
    /local
        pixS idx *matgx *matgy 		[int-ptr!]
        matHog						[red-vector!]
        *matHog						[float-ptr!]
        s							[series!]
        handleS r g b h w x y m n	[integer!]
        lx rx uy dy nthBin pixel	[integer!]
        nRow nCol nHog cellX cellY	[integer!]
        imgArea	pos					[integer!]
        posf hogPos	xRight xLeft 	[float!]
        yUp yDown vx vy theta rho	[float!]
        nRho maxi binRange			[float!]
        rgb							[subroutine!]
][
	handleS: 0
    pixS: image/acquire-buffer src :handleS
	w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    imgArea: w * h
    r: g: b: 0
    rgb: [
    	r: idx/value and 00FF0000h >> 16 
		g: idx/value and FF00h >> 8 
		b: idx/value and FFh 
    ]
    
    vector/rs-clear matGx
    vector/rs-clear matGy
   	;-- first a Sobel like edges detector on grayscale image
   	;-- Find orientation gradients in x and y directions
    y: 0
    while [y < h] [
    	x: 0
		while [x < w][
				pos: (y * w + x) % w 		; current column in matrix image
				pixel: y * w + pos			; current pixel
				rx: pixel + 1				; right pixel
				if rx >= imgArea [rx: 0]	; OK first value
				idx: pixS + rx
				rgb
				xRight: (as float! r) + (as float! g) + (as float! b) / 3.0
				
				lx: pixel - 1				; left pixel
				if lx < 0 [lx: imgArea - 1]	; OK last value	
				idx: pixS + lx
				rgb
				xLeft: (as float! r) + (as float! g) + (as float! b) / 3.0 
				
				uy: y - 1 * w + pos				; up pixel
				if uy < 0 [ uy: imgArea - pos - 1] ; OK last row
				idx: pixS + uy
				rgb
				yUp: (as float! r) + (as float! g) + (as float! b) / 3.0
				
				dy: y + 1 * w + pos			; down pixel
				if dy >= imgArea [dy: x]	; OK first row 
				idx: pixS + dy
				rgb
				yDown: (as float! r) + (as float! g) + (as float! b) / 3.0
				vx: xRight - xLeft
				vy: yUp - yDown
				vector/rs-append-int matgx as integer! vx ; x gradients
				vector/rs-append-int matgy as integer! vy ; y gradients	
				x: x + 1
		]
		y: y + 1
		
	]
	; HOG matrice
	binRange: (2.0 * pi) / (as float! nBins)
    cellX: w / nDivs
    cellY: h / nDivs 
	nHog: nDivs * nDivs * nBins								;-- matrix size
	matHog: vector/make-at stack/push* nHog TYPE_FLOAT 8    ;-- slot, size, type, unit
	*matHog: as float-ptr! vector/rs-head matHog			;-- float ptr to hog matrix 
	*matgx: as int-ptr! vector/rs-head matgx
	*matgy: as int-ptr! vector/rs-head matgy
	
	; HOG matrix initialisation with 0.0 value
	m: 1
	while [m <= nHog] [
		*matHog/m: 0.0
		m: m + 1
	]
	; HOG in cells with nDivs * nDivs size
	; line by column 
	m: 0 
	while [m < nDivs] [
		n: 0
		while [n < nDivs][
			; starting pos in HOG matrix
			hogPos: as float! ((m * nDivs + n) * nBins)
			y: 0
			while [y < cellY] [
				x: 0
				while [x < cellX] [
					nRow: (n * cellY + x + 1)
					nCol: (m * cellX + y + 1)
					pos: (nRow * w + nCol) - w
				    vx: as float! *matgx/pos
				    vy: as float! *matgy/pos 
				    ;gradient 
				    rho: sqrt ((vx * vx) + (vy * vy))
				    nRho: rho / as float! imgArea
				    ;Orientation
				    theta:  atan2 vy vx 					; radians
					if theta < 0.0 [theta: theta + (2.0 * pi)]
					;find appropriate bin for angle
					nthBin: as integer! (theta / binRange) 	; OK 0-nBins - 1
					;print[ theta  * 180.0 / pi lf]			; degrees
					; position in 1-D hog matrice
					posf: 1.0 + ceil (hogPos + theta) 
					pos: as integer! posf  
					;add magnitude of the edges in the hog matrix
					*matHog/pos: *matHog/pos + nrho
					x: x + 1
				]
				y: y + 1
			]
			n: n + 1
		]
		m: m + 1 
	]
	; normalisation for each histogram
	x: 0 
	while [x < (nDivs * nDivs)][
		maxi: 0.0 
		y: 0
		while [y < nBins][
			pos: x * nBins + y + 1
			if *matHog/pos > maxi [maxi: *matHog/pos]
			y: y + 1
		]
		y: 0
		
		while [y < nBins][
			pos: x * nBins + y + 1
			if maxi > 0.0 [*matHog/pos: *matHog/pos / maxi]	
			if maxi = 0.0 [*matHog/pos: 0.0]
			y: y + 1
		]
		x: x + 1
	]
	
	image/release-buffer src handleS no
	s: GET_BUFFER(matHog)								;-- Matrix values
    s/tail: as cell! (as float-ptr! s/offset) + nHog    ;-- set the tail properly
    as red-vector! stack/set-last as cell! matHog       ;-- return the new vector
]

rcvHOG: function [
"Histograms of Oriented Gradients"
    src  			[image!]	;--red image
    nBins			[integer!]	;--number of bins of histogram
    nDivs			[integer!]	;--image cells division
    return:			[object!]
][
	matGx: matrix/create 3 64 as-pair src/size/x 1 [] 
	matGy: matrix/create 3 64 as-pair src/size/y 1 [] 
	vec: _rcvHOG src matGx/data matGy/data nBins nDivs
	matrix/create 3 64 as-pair length? vec 1 to block! vec
]


