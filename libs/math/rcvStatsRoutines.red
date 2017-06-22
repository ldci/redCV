Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvStatsRoutines.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;***************** STATISTICAL ROUTINES ON IMAGE ***********************
; exported as functions in /libs/math/rcvStats.red
_rcvCount: routine [src1 [image!] return: [integer!]
	/local 
		stride1 
		bmp1 
		data1 
		w 
		x 
		y 
		h 
		pos
		r 
		g
		b
		a
		n
][
    stride1: 0
    ;bmp1: OS-image/lock-bitmap as-integer src1/node no
    bmp1: OS-image/lock-bitmap src1 no;MB
    data1: OS-image/get-data bmp1 :stride1   

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    n: 0
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            r: data1/pos and 00FF0000h >> 16
            g: data1/pos and FF00h >> 8
            b: data1/pos and FFh
            if (r > 0) and (g > 0) and (b > 0) [n: n + 1]
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    ;OS-image/unlock-bitmap as-integer src1/node bmp1;
    OS-image/unlock-bitmap src1 bmp1;
    n
]

_rcvStdInt: routine [src1 [image!] return: [integer!]
	/local 
		stride1 
		bmp1 
		data1 
		w 
		x 
		y 
		h 
		pos
		r 
		g
		b
		a
		sr 
		sg
		sb
		sa
		fr 
		fg
		fb
		fa
		e
][
    stride1: 0
    ;bmp1: OS-image/lock-bitmap as-integer src1/node no
    bmp1: OS-image/lock-bitmap src1 no
    data1: OS-image/get-data bmp1 :stride1   

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    sa: 0
    sr: 0
    sg: 0
    sb: 0
    fa: 0.0
    fr: 0.0
    fg: 0.0
    fb: 0.0
    ; Sigma X
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            sa: sa + (data1/pos >>> 24)
            sr: sr + (data1/pos and 00FF0000h >> 16)  
            sg: sg + (data1/pos and FF00h >> 8)
            sb: sb + (data1/pos and FFh)
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    ; mean values
    a: sa / (w * h)
    r: sr / (w * h)
    g: sg / (w * h)
    b: sb / (w * h)
    x: 0
    y: 0
    e: 0
    ; x - m 
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            e: (data1/pos >>> 24) - a sa: sa + (e * e)
            e: (data1/pos and 00FF0000h >> 16) - r   sr: sr + (e * e)
            e: (data1/pos and FF00h >> 8) - g sg: sg + (e * e)
            e: (data1/pos and FFh) - b sb: sb + (e * e)
            x: x + 1
        ]
        x: 0
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
    ;OS-image/unlock-bitmap as-integer src1/node bmp1;
    OS-image/unlock-bitmap src1 bmp1;
    (a << 24) OR (r << 16 ) OR (g << 8) OR b 
]

_rcvMeanInt: routine [src1 [image!] return: [integer!]
	/local 
		stride1 
		bmp1 
		data1 
		w 
		x 
		y 
		h 
		pos
		r 
		g
		b
		a
		sr 
		sg
		sb
		sa
][
    stride1: 0
    ;bmp1: OS-image/lock-bitmap as-integer src1/node no
    bmp1: OS-image/lock-bitmap src1 no
    data1: OS-image/get-data bmp1 :stride1   

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    sa: 0
    sr: 0
    sg: 0
    sb: 0
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            sa: sa + (data1/pos >>> 24)
            sr: sr + (data1/pos and 00FF0000h >> 16)  
            sg: sg + (data1/pos and FF00h >> 8)
            sb: sb + (data1/pos and FFh)
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    a: sa / (w * h)
    r: sr / (w * h)
    g: sg / (w * h)
    b: sb / (w * h)
    ;OS-image/unlock-bitmap as-integer src1/node bmp1;
    OS-image/unlock-bitmap src1 bmp1;
    (a << 24) OR (r << 16 ) OR (g << 8) OR b 
]


_rcvMinLoc: routine [src [image!] minloc [pair!] return: [pair!]
/local 
		stride 
		bmp 
		data 
		w 
		x 
		y 
		h 
		pos
		r 
		g
		b
		v
		mini  
		locmin 
] [
	stride: 0
    ;bmp: OS-image/lock-bitmap as-integer src/node no
    bmp: OS-image/lock-bitmap src no
    data: OS-image/get-data bmp :stride   

    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    y: 0
    mini: (255 << 16) or (255 << 8) or 255
    locmin: as red-pair! minloc; stack/arguments
    
    while [y < h][
        while [x < w][
            pos: stride >> 2 * y + x + 1
            r: data/pos and 00FF0000h >> 16
            g: data/pos and FF00h >> 8
            b: data/pos and FFh
            v: (r << 16 ) OR (g << 8) OR b 
            if v < mini [mini: v locmin/x: x locmin/y: y]
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    ;OS-image/unlock-bitmap as-integer src/node bmp
    OS-image/unlock-bitmap src bmp
    as red-pair! stack/set-last as cell! locmin 
]

_rcvMaxLoc: routine [src [image!] maxloc [pair!] return: [pair!]
/local 
		stride 
		bmp 
		data 
		w 
		x 
		y 
		h 
		pos
		r 
		g
		b
		v
		maxi  
		locmax 
] [
	stride: 0
    ;bmp: OS-image/lock-bitmap as-integer src/node no
    bmp: OS-image/lock-bitmap src no
    data: OS-image/get-data bmp :stride   

    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    y: 0
    maxi: 0
    locmax: as red-pair! maxloc; stack/arguments
    
    while [y < h][
        while [x < w][
            pos: stride >> 2 * y + x + 1
            r: data/pos and 00FF0000h >> 16
            g: data/pos and FF00h >> 8
            b: data/pos and FFh
            v: (r << 16 ) OR (g << 8) OR b 
            if v > maxi [maxi: v locmax/x: x locmax/y: y]
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    ;OS-image/unlock-bitmap as-integer src/node bmp
    OS-image/unlock-bitmap src bmp
    as red-pair! stack/set-last as cell! locmax 
]

_rcvHisto: routine [
    src  	[image!]
    histo  	[vector!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        handle1  h w x y
        tvalue base
        r g b a
][
    handle1: 0
    pix1: image/acquire-buffer src :handle1
    tvalue: as int-ptr! vector/rs-head histo
	base: tvalue
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and 00FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh 
        switch op [
            1 [tvalue: base + r + 1 tvalue/value: tvalue/value + 1 ]	;Red Channel
            2 [tvalue: base + g + 1 tvalue/value: tvalue/value + 1] 	;Green Channel 
            3 [tvalue: base + b + 1 tvalue/value: tvalue/value + 1] 	;blue Channel
        ]
        x: x + 1
        pix1: pix1 + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
]

;***************** STATISTICAL ROUTINES ON MATRIX ***********************
; exported as functions in /libs/math/rcvStats.red

_rcvCountMat: routine [mat [vector!] return: [integer!]
	/local
	int svalue  tail unit
	s n
	
] [
    svalue: vector/rs-head mat ; get pointer address of the matrice
    tail: vector/rs-tail mat
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	n: 0
	while [svalue < tail][
		int: vector/get-value-int as int-ptr! svalue unit
		if (int > 0) [n: n + 1] 
		svalue: svalue + unit 
	]
	n
]


_rcvSumMat: routine [mat [vector!] return: [integer!]
	/local
	int svalue  tail unit
	s sum
	
] [
    svalue: vector/rs-head mat ; get pointer address of the matrice
    tail: vector/rs-tail mat
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	sum: 0
	while [svalue < tail][
		int: vector/get-value-int as int-ptr! svalue unit
		sum: sum + int
		svalue: svalue + unit 
	]
	sum
]

_rcvMeanMat: routine [mat [vector!] return: [integer!]
	/local
	int svalue  tail unit
	s sum
	n
] [
    svalue: vector/rs-head mat ; get pointer address of the matrice
    tail: vector/rs-tail mat
    n: vector/rs-length? mat
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	sum: 0
	while [svalue < tail][
		int: vector/get-value-int as int-ptr! svalue unit
		sum: sum + int
		svalue: svalue + unit 
	]
	sum / n
]


_rcvStdMat: routine [mat [vector!] return: [integer!]
	/local
	int svalue  tail unit
	s sum sum2 m e f
	n
] [
    svalue: vector/rs-head mat ; get pointer address of the matrice
    tail: vector/rs-tail mat
    n: vector/rs-length? mat
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	sum: 0 
	sum2: 0
	; mean
	while [svalue < tail][
		int: vector/get-value-int as int-ptr! svalue unit
		sum: sum + int
		svalue: svalue + unit 
	]
	m: sum / n
	svalue: vector/rs-head mat 
	while [svalue < tail][
		int: vector/get-value-int as int-ptr! svalue unit
		e: int - m
		sum2: sum + (e * e)
		svalue: svalue + unit 
	]
	; std
	f: sqrt as float! (sum2 / (n - 1))
	as integer! f
]


_rcvMaxLocMat: routine [mat [vector!] matSize [pair!] maxloc [pair!] return: [pair!]
	/local 
	int svalue  tail s unit
	w h x y
	maxi locmax
		
] [
	svalue: vector/rs-head mat ; get pointer address of the matrice
    tail: vector/rs-tail mat
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	w: matSize/x
    h: matSize/y
    x: 0
    y: 0
    maxi: 0
    locmax: as red-pair! maxloc; stack/arguments
    while [y < h] [	
       	while [x < w][
    		int: vector/get-value-int as int-ptr! svalue unit
    		if int > maxi [maxi: int locmax/x: x locmax/y: y]
       		svalue: svalue + 1 
        	x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    as red-pair! stack/set-last as cell! locmax 
]

_rcvMinLocMat: routine [mat [vector!] matSize [pair!] minloc [pair!] return: [pair!]
	/local 
	int svalue s unit
	w h x y
	mini locmin
		
] [
	svalue: vector/rs-head mat ; get pointer address of the matrice
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	w: matSize/x
    h: matSize/y
    x: 0
    y: 0
    
    switch unit [
       			1 [mini: 255 or FFh]						
       			2 [mini: 255 or FFFFh]		
       			4 [mini: 255 or FFFFFFh]	
       		]
    
    locmin: as red-pair! minloc; stack/arguments
    while [y < h] [	
       	while [x < w][
    		int: vector/get-value-int as int-ptr! svalue unit
    		if int < mini [mini: int locmin/x: x locmin/y: y]
       		svalue: svalue + 1 
        	x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    as red-pair! stack/set-last as cell! locmin
]

; Only for 8-bit matrix images 

; calculate histogram -> OK
_rcvHistoMat: routine [mat [vector!] histo [vector!]
	/local
	int svalue  tail
	dvalue base s unit
	
] [
    svalue: vector/rs-head mat ; get pointer address of the matrice
    tail: vector/rs-tail mat
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	dvalue: as int-ptr! vector/rs-head histo
	base: dvalue
	while [svalue < tail][
		;int: vector/get-value-int as int-ptr! svalue unit
		int: as integer! svalue/value  		; int value 0..255
		dvalue: base + int					; position in histogram 
		dvalue/value: dvalue/value + 1  	; increment number of value occurence
		svalue: svalue + unit 				; next value in matrice
	]
]

; calculate the cumulative sum of histogram -> OK
; this is the cumulative-density function for the pixel value n
_rcvSumHisto: routine [histo [vector!] sumHisto [vector!]
	/local
	int svalue tail
    s unit 
    sum
] [
    svalue: vector/rs-head histo ; get pointer address of the matrice
    tail: vector/rs-tail histo
	sum: 0
	s: GET_BUFFER(histo)
	unit: GET_UNIT(s)
	vector/rs-clear sumHisto 
	while [svalue < tail][
		int: vector/get-value-int as int-ptr! svalue unit	; value in histo/(i)	
		sum: sum + int										; increment sum	
		vector/rs-append-int sumHisto sum					;store cumulative sum		
		svalue: svalue + unit			    				; next value
	]
]

_rcvEqualizeHisto: routine [mat [vector!] sumHisto [vector!] constant [float!]
	/local
	int int2 svalue dvalue tail unit s base k
] [
	svalue: vector/rs-head mat ; get pointer address of the matrice
    tail:  vector/rs-tail mat
    dvalue: as int-ptr! vector/rs-head sumHisto
    base: dvalue
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	while [svalue < tail][
		int: vector/get-value-int as int-ptr! svalue unit
		dvalue: base + int 
		int2: dvalue/value
		k:  (as float! int2) * constant
		int2: as integer! k
		svalue/value: as byte! int2
		svalue: svalue + unit
	]
]
; affine transform
_rcvEqualizeContrast: routine [mat [vector!] table [vector!]
	/local
	int svalue dvalue tail unit s base
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





