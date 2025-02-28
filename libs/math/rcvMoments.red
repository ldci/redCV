Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "ldcin"
	File: 	 %rcvMoments.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2019 ldci. All rights reserved."
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
    return:			[float!]
] [
	moment1: rcvGetMatCentralMoment mx  p q 
	moment2: rcvGetMatCentralMoment mx  0.0 0.0
	exponent: p + q / 2.0 + 1.0  
	m00: power moment2 exponent
	moment1 / m00
]




rcvGetMatHuMoments: function [
	"Return the seven invariant Hu moments of the image"
	mat  			[object!]
	return:			[block!]
] [
	n20: rcvGetNormalizedCentralMoment mat 2.0 0.0
	n02: rcvGetNormalizedCentralMoment mat 0.0 2.0
	n11: rcvGetNormalizedCentralMoment mat 1.0 1.0
	n12: rcvGetNormalizedCentralMoment mat 1.0 2.0
	n21: rcvGetNormalizedCentralMoment mat 2.0 1.0
	n30: rcvGetNormalizedCentralMoment mat 3.0 0.0
	n03: rcvGetNormalizedCentralMoment mat 0.0 3.0
	
	hu1: n20 + n02
	hu2: (n20 - n02) ** 2 + (2 * n11) ** 2
	hu3: (n30 - 3 * n12) ** 2 + (3 * n21 - n03) ** 2
	hu4: (n30 + n12) ** 2 + (n21 + n03) ** 2
	hu5: (n30 - 3 * n12) ** 2 + (n30 + n12) * ((n30 + n12) ** 2 - 3 * (n21 + n03) ** 2) +
			(3 * n21 - n03) * (n21 + n03) * (3 * (n30 + n12) ** 2 - (n21 + n03) ** 2)
	hu6: (n20 - n02) * ((n30 + n12) ** 2 - (n21 + n03) ** 2) + 4 * n11 * (n30 + n12) * (n21 + n03)
	hu7: (3 * n21 - n03) * (n30 + n12) * ((n30 + n12) ** 2 - 3 * (n21 + n03) ** 2) -
			(n30 - 3 * n12) * (n21 + n03) * (3 * (n30 + n12) ** 2 - (n21 + n03) ** 2)
	reduce [hu1 hu2 hu3 hu4 hu5 hu6 hu7]
]

