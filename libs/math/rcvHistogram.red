Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvHistogram.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;***************** HISTOGRAM ROUTINES ON IMAGE ***********************

rcvHistoImg: routine [
"Calculates image histogram by channel"
    src  		[image!]		;red image
    op	 		[integer!]		;channel selection (argb or grayscale)
    return: 	[vector!]		;32-bit matrix
    /local
    	histo  	[red-vector!]
        pix1 	[int-ptr!]
        tvalue	[int-ptr!]
        base 	[int-ptr!]	
        handle1	[integer!] 
        s		[series!] 
        h 		[integer!]
        w 		[integer!]
        x 		[integer!]
        y		[integer!]
        r		[integer!] 
        g		[integer!] 
        b		[integer!]
        a		[integer!]
        c		[integer!]
][
    handle1: 0
    pix1: image/acquire-buffer src :handle1
    histo: vector/make-at stack/push* 256 TYPE_INTEGER 4 ; 0..255 32-bit
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
_oldrcvRGBHistogram: routine [
"Calculates Array histogram"
    src  	[image!]	; red image
    array  	[block!]	; block of vectors
    /local
        pix1 [int-ptr!]
        handle1  h w x y
        lines 	[integer!]
		cols	[integer!]
        bsvalue [red-value!] 
        bstail	[red-value!]
        base	[red-value!] 
        rvalue	[int-ptr!]
        gvalue	[int-ptr!]
        bvalue	[int-ptr!]
        p		[int-ptr!]
        vectBlk	[red-vector!]
        r		[integer!] 
        g 		[integer!]
        b 		[integer!]
        a		[integer!]
        sBins	[integer!]
        unit	[integer!]
        
][
    handle1: 0
    pix1: image/acquire-buffer src :handle1
    bsvalue: block/rs-head array
    bstail:  block/rs-tail array
	lines:   block/rs-length? array 	;default 3 for RGB
	vectBlk: as red-vector! bsvalue
    cols: vector/rs-length? vectBlk		;number of bins
    unit: rcvGetMatBitSize vectBlk
   	sBins: as integer! (ceil (256.0 / cols)) ; for clustering color values
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
        	pix1: pix1 + 1
        	x: x + 1
       	]
       	y: y + 1
    ]
    image/release-buffer src handle1 no
]

rcvRGBHistogram: routine [
"Calculates Array histogram"
    src  	[image!]	; red image
    dst 	[image!]	; destination image 
    array  	[block!]	; block of vectors
    /local
        pix1 [int-ptr!]
        pixD 	[int-ptr!]
        handle1
        handleD 
        h w x y
        lines 	[integer!]
		cols	[integer!]
        bsvalue [red-value!] 
        bstail	[red-value!]
        base	[red-value!] 
        rvalue	[int-ptr!]
        gvalue	[int-ptr!]
        bvalue	[int-ptr!]
        p		[int-ptr!]
        vectBlk	[red-vector!]
        r		[integer!] 
        g 		[integer!]
        b 		[integer!]
        a		[integer!]
        sBins	[integer!]
        unit	[integer!]
        
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
    unit: rcvGetMatBitSize vectBlk
   	sBins: as integer! (ceil (256.0 / cols)) ; for clustering color values
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
	pix1 	[int-ptr!]
	pixD 	[int-ptr!]
    handle1	[integer!]
    handleD [integer!] 
    bsvalue [red-value!] 
    bstail	[red-value!]
    rvalue	[float-ptr!]
    gvalue	[float-ptr!]
    bvalue	[float-ptr!]
    p		[float-ptr!]
    vectBlk	[red-vector!]
    h 		[integer!]
    w		[integer!]
    x		[integer!] 
    y		[integer!]
    lines 	[integer!]
	cols	[integer!]
    r 		[float!]
    g 		[float!]
    b 		[float!]
    a		[float!]
    binR	[float!]	 
    binG	[float!] 
    binB	[float!]
    sR		[float!] 
    sG		[float!]
    sB		[float!]
    weightR	[float!] 
    weightG [float!]
    weightB	[float!]
    dist	[float!]
    rd 		[float!]
    gd 		[float!]
    bd		[float!]
    hr		[integer!] 
    lr		[integer!]		 
    hg		[integer!] 
    lg 		[integer!]
    hb		[integer!] 
    lb		[integer!]
    colorR 	[integer!]
    colorG 	[integer!]
    colorB	[integer!]
    factor	[integer!]
    unit	[integer!]
   
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
    unit: rcvGetMatBitSize vectBlk
    factor: 256 / cols
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
       		a: as float! (pix1/value >>> 24)
       		r: as float! (pix1/value and 00FF0000h >> 16) 
        	g: as float! (pix1/value and FF00h >> 8)
        	b: as float! (pix1/value and FFh) 
        	binR: ceil (r / factor)
			binG: ceil (g / factor)
			binB: ceil (b / factor)
        	dist: converg + 1.0
        	while [dist > converg] [
        		hr: as integer! minFloat as float! cols (binR + colorBW)
				lr: as integer! maxFloat 1.0 (binR - colorBW)
				hg: as integer! minFloat as float! cols (binG + colorBW)
				lg: as integer! maxFloat 1.0 (binG - colorBW)
				hb: as integer! minFloat as float! cols (binB + colorBW)
				lb: as integer! maxFloat 1.0 (binB - colorBW)
				sR: 0.0 
				weightR: 0.0
				while [lr <= hr] [
					p: rValue + lr
					p/value: vector/get-value-float as byte-ptr! p unit
				 	sR: sR + (1.0 * lr * p/value)
				 	weightR: weightR + p/value
					lr: lr + 1
				]
				sG: 0.0 
				weightG: 0.0
				while [lg <= hg] [
					p: gValue + lg
					p/value: vector/get-value-float as byte-ptr! p unit
					sG: sG + (1.0 * lg * p/value) 
					weightG: weightG + p/value
					lg: lg + 1
				]
				sB: 0.0
				weightB: 0.0
				while [lb <= hb] [
					p: bValue + lb
					p/value: vector/get-value-float as byte-ptr! p unit
					sB: sB + (1.0 * lb * p/value) 
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
	mat 	[vector!]		;integer or float matrix 
	return:	[vector!]		;8-bit matrix
	/local
	histo 	[red-vector!]
	svalue	[byte-ptr!]  
	tail	[byte-ptr!]
	dvalue 	[int-ptr!]
	base 	[int-ptr!]
	s 		[series!]
	unit	[integer!]
	int		[integer!]
	
] [
    svalue: vector/rs-head mat ; get pointer address of the matrice
    tail: vector/rs-tail mat
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	histo: vector/make-at stack/push* 256 TYPE_INTEGER 4
	dvalue: as int-ptr! vector/rs-head histo
	base: dvalue
	while [svalue < tail][
		; int value 0..255
		either unit <= 4 [int: as integer! svalue/value]
		[int: as integer! vector/get-value-float svalue unit]
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
	return:		[vector!]		;8-bit matrix
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
		either unit <= 4 [int: as integer! svalue/value]
			[int: as integer! vector/get-value-float svalue unit]
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
	mat 		[vector!] 	;integer or float matrix
	sumHisto 	[vector!] 	;8-bit matrix
	constant 	[float!]
	/local
	svalue 		[byte-ptr!] 
	tail		[byte-ptr!]
	ivalue		[int-ptr!]
	ibase 		[int-ptr!]
	s 			[series!]
	k			[float!]
	int			[integer!] 
	int2 		[integer!] 
	unit 		[integer!]
] [
	svalue: vector/rs-head mat ; get pointer address of the matrice
    tail:  	vector/rs-tail mat
    ivalue: as int-ptr! vector/rs-head sumHisto
    ibase: 	ivalue
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	while [svalue < tail][
		either unit <= 4 [int: vector/get-value-int as int-ptr! svalue unit] 
						 [int: as integer! vector/get-value-float svalue unit]
		ivalue: ibase + int 
		int2: 	ivalue/value
		k:  	constant * int2 * 1.0
		int2: 	as integer! k
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
	arr [image! vector!]  
	/red /green /blue
][
	t: type? arr
	if t = vector! [histo: rcvHistoMat arr]
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
	arr [vector!] 
][
	histo: make vector! 256 
	n: length? arr
	i: 2
	while [i < n] [
					histo/(i): (arr/(i - 1) + arr/(i) + arr/(i + 1)) / 3 
	 				i: i + 1
	]
	
	histo/1: histo/2
	histo/(n): histo/(n - 1)		
	histo
]



rcvHistogramEqualization: function [  
"This function performs histogram equalization on the input image array"
	arr 	[vector!]   
	gLevels [integer!]
] [
	n: length? arr
	constant: gLevels / to float! (n)	
	histo: rcvHistoMat arr				; calculates histogram 
	sumH:  rcvSumHistoMat histo 			; calculates the sum of histogram
	rcvEqualizeHistoMat arr sumH constant	; transforms input mat to output mat
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
	arr [vector!] 
	p 	[percent!]
] [
	range: rcvMakeTranscodageTable p
	rcvEqualizeContrast arr range
]


