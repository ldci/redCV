Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvHuMoments.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;Spatial and central moments are important statistical properties of an image

; Hu Invariant Moments of 2D Matrix
; We use binary [0..1] matrix rather [0..255] integer matrix


; requires rcvMatrix.red
;#include %../matrix/rcvMatrix.red

;Returns spatial and central moment of the matrix

;p: q: 0.0 -> moment order 0 -> form area

rcvGetMatSpatialMoment: routine [
"Returns the spatial moment of the mat"
	mx  		[object!]
    p			[float!]	;p - the order of the moment
    q			[float!]	;q - the repetition of the moment
    return:		[float!]
    /local 	
    vec			[red-vector!]
    mvalue		[byte-ptr!] 		
    moment		[float!]
    xf 			[float!]
    yf			[float!]
    v			[float!]
    x			[integer!] 
    y			[integer!]
    unit		[integer!]
    width       [integer!]
    height      [integer!]
][
	width: 	mat/get-cols mx
	height: mat/get-rows mx
	vec: mat/get-data mx
	unit: mat/get-unit mx
	mvalue: vector/rs-head vec
    x: 0
    y: 0
    xf: 0.0
    xf: 0.0
    moment: 0.0
    while [y < height] [
    	x: 0
       	while [x < width][
       		v: as float! rcvGetIntValue as integer! mvalue unit
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

;--a revoir 
rcvGetMatCentralMoment: routine [
"Returns the central moment of the mat"
	mx  		[object!]
    p			[float!]	;p - the order of the moment
    q			[float!]	;q - the repetition of the moment
    return:		[float!]
    /local 
    vec			[red-vector!]
    centroid	[red-pair!]	
    moment		[float!]
    x			[integer!] 
    y			[integer!]
    xf 			[float!]
    yf			[float!]
	mvalue 		[byte-ptr!]
    unit		[integer!]
    v			[float!]
    width       [integer!]
    height		[integer!]
][
	width: 	mat/get-cols mx
	height: mat/get-rows mx
	unit: 	mat/get-unit mx
	vec: 	mat/get-data mx
	mvalue: vector/rs-head vec
    y: 0
    xf: 0.0
    xf: 0.0
    moment: 0.0
    centroid: rcvGetMatCentroid mx
    while [y < height] [
    	x: 0
       	while [x < width][
       		v: as float! rcvGetIntValue as integer! mvalue unit
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



rcvGetNormalizedCentralMoment: function [
"Return the scale invariant moment of the image"
	mx  			[object!]
    p				[float!]
    q				[float!]
] [
	moment1: rcvGetMatCentralMoment mx  p q 
	moment2: rcvGetMatCentralMoment mx  0.0 0.0
	exponent: p + q / 2.0 + 1.0  
	m00: power moment2 exponent
	moment1 / m00
]


rcvGetMatHuMoments: function [
"Returns 7 Hu moments of the image"
	mat  			[object!]
	return:			[block!]
][
	;where ηi,j are normalized central moments of 2-nd and 3-rd orders.
	n20: rcvGetNormalizedCentralMoment mx 2.0 0.0
	n02: rcvGetNormalizedCentralMoment mx 0.0 2.0
	n11: rcvGetNormalizedCentralMoment mx 1.0 1.0
	n12: rcvGetNormalizedCentralMoment mx 1.0 2.0
	n21: rcvGetNormalizedCentralMoment mx 2.0 1.0
	n30: rcvGetNormalizedCentralMoment mx 3.0 0.0
	n03: rcvGetNormalizedCentralMoment mx 0.0 3.0

	{from OpenCV
	h1=η20+η02
	h2=(η20-η02)²+4η11²
	h3=(η30-3η12)²+ (3η21-η03)²
	h4=(η30+η12)²+ (η21+η03)²
	h5=(η30-3η12)(η30+η12)[(η30+η12)²-3(η21+η03)²]+(3η21-η03)(η21+η03)[3(η30+η12)²-(η21+η03)²]
	h6=(η20-η02)[(η30+η12)²- (η21+η03)²]+4η11(η30+η12)(η21+η03)
	h7=(3η21-η03)(η21+η03)[3(η30+η12)²-(η21+η03)²]-(η30-3η12)(η21+η03)[3(η30+η12)²-(η21+η03)²]
	}
	
	hu1: n20 + n02
	hu2: power (n20 - n02) 2 +  (4 * (power n11 2))
	;hu2: (n20 - n02) ** 2 + (2 * n11) ** 2
	
	hu3: (power n30 - (3 * n12) 2) + (power 3 * n21 - n03 2)
	hu4: power (n30 + n12) 2 + power (n21 + n03) 2
	
	
	;h5=(η30-3η12)(η30+η12)[(η30+η12)²-3(η21+η03)²]+(3η21-η03)(η21+η03)[3(η30+η12)²-(η21+η03)²]
	
	
	a: n30 - (3 * n12)
	b: n30 + n12
	c: power n30 + n12 2
	d: 3 * power n21 + n03 2 
	e: 3 * n21 - n03
	f: n21 + n03
	g: 3 * power n30 + n12 2
	h: power n21 + n03 2
	
	hu5: (a * b) * (c - d) + (e * f * (g - h))
	
	
	
	;hu5: n30 - (3 * n12) * (n30 + n12) - (3 * (n21 + n03) ** 2)))) 
	;	+ (((3 * n21) - n03) * (n21 + n03)) * (3 * ((n30 + n12) ** 2) - ((n21 + n03) ** 2))
	a: n20 - n02
	b: (n30 + n12) ** 2
	c: (n21 + n03) ** 2
	d: 4 * n11
	e: n30 + n12
	f: n21 + n03
	;print (a * (b - c)) + (d * e * f)
	
	hu6: (n20 - n02) * (((n30 + n12) ** 2) - (n21 + n03) ** 2) + (4 * n11) * ((n30 + n12) * (n21 + n03))
	hu7: (3 * n21 - n03) * (n30 + n12) * ((n30 + n12) ** 2 - 3 * (n21 + n03) ** 2) -
			(n30 - 3 * n12) * (n21 + n03) * (3 * (n30 + n12) ** 2 - (n21 + n03) ** 2)
	; return: 		[block!]		
	reduce [hu1 hu2 hu3 hu4 hu5 hu6 hu7]
]
