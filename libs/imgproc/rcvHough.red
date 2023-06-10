Red [
	Title:   "Red Computer Vision: Hough Transform"
	Author:  "Francois Jouen"
	File: 	 %rcvHough.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2020 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;#include %../matrix/rcvMatrix.red ;--for stand alone test
; **************** Hough Transform routines *********************

rcvHoughTransform: routine [
"Makes Hough Space transform"
	mat 		[vector!] 
	accu 		[vector!] 
	w 			[integer!] 
	h 			[integer!]
	treshold 	[integer!]
	/local
		matValue accValue accTail idx2			[byte-ptr!]
		cx cy xf yf maxRho cosAngle	sinAngle	[float!]
		deg2Rad r								[float!]
		maxTheta indexRho idx x y i ii t 		[integer!]
		unit1 unit2								[integer!] 
		s										[series!]
][
	cx: (as float! w) / 2.0
	cy: (as float! h) / 2.0
	either h > w [maxRho: ((sqrt 2.0) * as float! h) / 2.0] 
				 [maxRho: ((sqrt 2.0) * as float! w) / 2.0]			 
	maxTheta: 180
    deg2Rad:  pi / 180.0
    matValue: vector/rs-head mat ; get pointer address of the vector
    s: GET_BUFFER(mat)
    unit1: GET_UNIT(s)
    accValue: vector/rs-head accu; get pointer address of the vector
    accTail:  vector/rs-tail accu
    s: GET_BUFFER(accu)
    unit2: GET_UNIT(s)
	y: 0
	while [y < h] [
		yf: (as float! y) - cy
		x: 0
		while [x < w][
			xf: (as float! x) - cx
			idx: ((y * w) + x) * unit1
			i: rcvGetIntValue as integer! (matValue + idx) unit1
			if i > treshold [ 
				t: 0
				while [t < maxTheta] [
					cosAngle: cos (deg2Rad * as float! t); in radian
					sinAngle: sin (deg2Rad * as float! t); in radian
					r: (xf * cosAngle) + (yf * sinAngle)
					indexRho: as integer! (r + maxRho + 0.5)
					idx: ((indexRho * maxTheta) + t) * unit2
					idx2: accValue + idx
					;assert idx2 < accTail
					if (idx2 >= accValue)  and (idx2 < accTail) [
						ii: rcvGetIntValue as integer! idx2 unit2 
						rcvSetIntValue as integer! idx2 ii + 1 unit2
					]
					t: t + 1
				]
			]
			x: x + 1
		]
		y: y + 1
	]
]


rcvHough2Image: routine [
"Makes Hough space as red image"
	mat			[vector!]
	dst			[image!]
	contrast 	[float!]
	/local
		svalue stail 	[byte-ptr!] 
		pixD 			[int-ptr!]
		handle unit		[integer!]
		maxa coef ii	[float!]
		c i				[integer!]
		s				[series!]
] [
	handle: 0
    pixD: image/acquire-buffer dst :handle
    maxa: 0.0
    svalue: vector/rs-head mat 	; get pointer address of accumulator matrix
    stail:  vector/rs-tail mat	; last
    s: GET_BUFFER(mat)
    unit: GET_UNIT(s)
    ; get first max value
    while [svalue < stail][
		i: vector/get-value-int as int-ptr! svalue unit
		if i > as integer! maxa [maxa: as float! i]
		svalue: svalue + unit
	]
    coef: 255.0 / maxa * contrast
    ; update maxRho space image
    svalue: vector/rs-head mat 	; get pointer address of accumulator
    stail:  vector/rs-tail mat	; last value address
    
    while [svalue < stail][
    	i: vector/get-value-int as int-ptr! svalue unit
    	ii: (as float! i) * coef
       	either ii < 255.0 [c: as integer! ii] [c: 255]
       	pixD/value: ((255 << 24) OR ((255 - c) << 16 ) OR ((255 - c) << 8) OR (255))
       	svalue: svalue + unit
        pixD: pixD + 1
    ]
    image/release-buffer dst handle yes
]


rcvGetHoughLines: routine [
"Gets lines in the accumulator according to threshold"
	accu 		[vector!] 
	img			[image!]	
	threshold 	[integer!] 
	lines 		[block!]
	/local
		svalue				[byte-ptr!]
		cosAngle sinAngle	[float!]
		a b x1 y1 x2 y2		[float!]
		deg2Rad maxRho		[float!]
		r t v vv vMax lx ly	[integer!]
		unit idx cx cy		[integer!]		 
		accw acch imw imh	[integer!] 
		s					[series!]
][
	imw: IMAGE_WIDTH(img/size)
    imh: IMAGE_HEIGHT(img/size)
    either imh > imw [maxRho: ((sqrt 2.0) * as float! imh) / 2.0] 
				 [maxRho: ((sqrt 2.0) * as float! imw) / 2.0]
    accw: 180
	acch: as integer! (maxRho * 2.0)
	deg2Rad: pi / as float! accw
	cx:  imw / 2
	cy:  imh / 2
	block/rs-clear lines	
	svalue: vector/rs-head accu
	s: GET_BUFFER(accu)
    unit: GET_UNIT(s)
	r: 0
	while [r < acch] [
		t: 0
		while [t < accw] [
			idx: ((r * accw) + t) * unit
			v: vector/get-value-int as int-ptr! (sValue + idx) unit
			if (v >= threshold) [
				;is the point a local maxima (9x9 kernel)
				vMax: v
				ly: -4 
				while [ly <= 4] [
					lx: -4 
					while [lx <= 4] [
					 if (((ly + r >= 0) and (ly + r < acch)) and ((lx + t >= 0) and (lx + t < accw))) 
						[	idx: (((r + ly) * accw) + t + lx) * unit
							vv: vector/get-value-int as int-ptr! (sValue + idx) unit
							if vv > vMax [
								vMax: vv
								ly: 5 
								lx: 5
							]
						]
						lx: lx + 1
					]
					ly: ly + 1
				]
				if vMax > v [t: t +1] ; pbs with if vMax > v [continue] 
				if vMax <= v 
				[
					cosAngle: cos (deg2Rad * as float! t)	; in radian
					sinAngle: sin (deg2Rad * as float! t)	; in radian
					a:  0.0 + (as float! r) - maxRho
					either (t >= 45) and (t <= 135)
						[ 	;y = (r - x*cos(t)) / sin(t) ;sin t always <> 0
							x1: 0.0
							b: x1 - (as float! cx)
							y1: (a - (b * cosAngle) / sinAngle) + (as float! cy)
							x2: 0.0 + (as float! imw)
							b: x2 - (as float! cx)
							y2: (a - (b * cosAngle) / sinAngle) + (as float! cy)
						] 
						[	;x = (r - y*sin(t)) / cos(t); ;cos t always <> 0
							y1: 0.0
							b: y1 - (as float! cy)
							x1: (a - (b * sinAngle) / cosAngle) + (as float! cx)
							y2: 0.0 + (as float! imh)
							b: y2 - (as float! cy)
							x2: (a - (b * sinAngle) / cosAngle) + (as float! cx)
					]
					pair/make-in lines as integer! x1 as integer! y1
					pair/make-in lines as integer! x2 as integer! y2 
				] 
			] 
			t: t + 1
		] 
		r: r + 1
	]
]


; *************** functions and functions that call routines ***************************

rcvMakeHoughAccumulator: func [
"Creates Hough accumulator"
	w [integer!] 
	h [integer!]
][
	either h > w [maxRho: ((sqrt 2.0) * h) / 2.0] 
				 [maxRho: ((sqrt 2.0) * w) / 2.0]
	accuH: to-integer maxRho * 2 ; -r .. +r
	accuW: 180 ; for theta
	make vector! accuH * accuW
]

rcvGetAccumulatorSize: function [
"Gets Hough space accumulator size"
	acc [vector!]
][
	accuW: 180
	n: length? acc
	accuH:  n / accuW
	as-pair accuW accuH
]




