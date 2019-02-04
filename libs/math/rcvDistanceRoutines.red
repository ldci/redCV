Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvDistanceRoutines.red
	Tabs:	 4
	Rights:  "Copyright (C) 2017 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


; ******************** Tools **********************
maxInt: routine [
	a 		[integer!] 
	b 		[integer!]
	return: [integer!]
][ 
		either (a > b) [a] [b]
]

maxFloat: routine [
	a 		[float!] 
	b 		[float!]
	return: [float!]
][ 
		either (a > b) [a] [b]
]



; ******************** Chamfer distance ******************************

; we need a grayscale image: make conversion before and convert to mat
; similar to Sobel Operator (seems faster)
; src and dst are integer matrices

_makeGradient: routine [
    src  		[vector!]
    dst  		[vector!]
    w			[integer!]
    h			[integer!]
    return: 	[integer!]
    /local
    maxGradient
    sValue 	
    dValue 	
    unit
    x y
    v 
    p00 p01 p02
    p10 p12 
    p20 p21 p22
    sx sy snorm
    idx idx2
    scale
][
	sValue: vector/rs-head src  			
	dValue: vector/rs-head dst		
    unit: _rcvGetMatBitSize src 
    
	w: w - 2
    h: h - 2
    x: 0
    y: 0
    maxGradient: 0			
    idx:  svalue
    idx2: dvalue
    
    ; Similar to Sobel filter
    while [y < h] [
    	x: 0
		while [x < w][
        		idx: sValue + (((y * w) + x) * unit)       
        		p00: _getIntValue as integer! idx unit 
        		idx: sValue + ((((y + 1) * w) + x) * unit) 
        		p01: _getIntValue as integer! idx unit 
        		idx: sValue + ((((y + 2) * w) + x) * unit) 
        		p02: _getIntValue as integer! idx unit 
        		idx: sValue + (((y * w) + (x + 1)) * unit) 
        		p10: _getIntValue as integer! idx unit 
        		idx: sValue + ((((y + 2) * w) + (x + 1)) * unit) 
        		p12: _getIntValue as integer! idx unit 
        		idx: sValue + ((((y) * w) + (x + 2)) * unit) 
        		p20: _getIntValue as integer! idx unit 
        		idx: sValue + ((((y + 1) * w) + (x + 2)) * unit)
        		p21: _getIntValue as integer! idx unit 
        		idx: sValue + ((((y + 2) * w) + (x + 2)) * unit)
        		p22: _getIntValue as integer! idx unit 
        		sx: as float! (p20 + (2 * p21) + p22) - (p00 + (2 * p01) + p02)
        		sy: as float! (p02 + (2 * p12) + p22) - (p00 + (2 * p10) + p10)
        		snorm: sqrt  ((sx * sx) + (sy * sy))
        		v: as integer! snorm
        		maxGradient: maxInt maxGradient v
        		; update dst
        		idx2: dValue + ((((y + 1) * w) + (x + 1)) * unit)
        		_setIntValue as integer! idx2 v unit
				x: x + 1
		]
		y: y + 1
	]
    maxGradient
]

;Binary [ 0 1] according to threshold value
;src and bingradient are integer matrices
 
_makeBinaryGradient: routine [
    src  		[vector!]
    bingradient [vector!]
    maxG		[integer!]
    threshold 	[integer!]
    /local
    sValue 	
    sTail
    dValue 	
    v 
    scale
    unit
][
	sValue: vector/rs-head src			; byte ptr
	sTail: vector/rs-tail src			; byte ptr
    dValue: vector/rs-head bingradient	; byte ptr
    unit: _rcvGetMatBitSize src 		; bit size
    scale: threshold * maxG / 100
    while [svalue <= sTail] [
    		v: _getIntValue as integer! sValue unit
    		either  (v > scale) [dValue/value: #"^(01)"] ;as byte! 1 
								[dValue/value: #"^(00)"] ;as byte! 0
    		sValue: sValue + unit
			dValue: dValue + unit
    ]  
]


; input float mat
;output : integer mat

_rcvFlowMat: routine [
	input 	[vector!] 
	output 	[vector!]
	scale	[float!]
	return: [float!]
	/local
	v
	f 
	maxf
	unit1 unit2
	mvalueIN
	mTailIN
	mvalueOUT
][
	f: 0.0
	maxf: 0.0
	v: 0
	mvalueIN: vector/rs-head input
	mTailIN: vector/rs-tail input
	mvalueOUT: vector/rs-head output
	unit1: _rcvGetMatBitSize input
	unit2: _rcvGetMatBitSize output
	while [mvalueIN <= mTailIN] [
		f: _getFloatValue as integer! mvalueIN 
		if (f * scale)  > maxf [maxf: f * scale]
		v: as integer! (f * scale) 
		_setIntValue as integer! mvalueOUT v unit2
		mvalueIN: mvalueIN + unit1
		mvalueOUT: mvalueOUT + unit2	
	]
	maxf
]

; distance to a 0.. 255 scale
; input: integer mat
_rcvnormalizeFlow: routine [
	input 	[vector!] ; integer mat
	factor	[float!]
	/local
	unit
	mvalueIN
	mTailIN
	vFlow
	v
	scale
][
	mvalueIN: vector/rs-head input
	mTailIN: vector/rs-tail input
	unit: _rcvGetMatBitSize input
	scale: 255.0 / factor
	while [mvalueIN <= mTailIN] [
		vFlow: _getIntValue as integer! mvalueIN unit
		v: scale * vFlow
		_setIntValue as integer! mvalueIN as integer! v unit
		mvalueIN: mvalueIN + unit
	]
]



; 2 integer matrices and 1 image

_rcvGradient&Flow: routine [
	input1	[vector!]
	input2	[vector!]
	dst		[image!]
	/local
	mvalueIN1
	mTailIN1
	mvalueIN2
	dvalue
	unit
	handleD
	vFlow vGrad
	r g b
][
	handleD: 0
	mvalueIN1: vector/rs-head input1
	mTailIN1: vector/rs-tail input1
	mvalueIN2: vector/rs-head input2
	unit: _rcvGetMatBitSize input1
	dvalue: image/acquire-buffer dst :handleD
	while [mvalueIN1 <= mTailIn1] [
    	vFlow: _getIntValue as integer! mvalueIN1 unit
    	vGrad: _getIntValue as integer! mvalueIN2 unit
    	
    	either (vGrad > 0) [vGrad: 255] [vGrad: 0]
    	; distance can be > 255 so we need to recalculate vFlow
    	;f: log-2 (1.0 + vFlow) / 50.0  r: 255 * maxInt 1 as integer! f 
    	; maxInt 0 (255 - vFlow)
    	either (vGrad > 0) [r: 0 g: vGrad b: 0] [ r: maxInt 0 (255 - vFlow) g: 0 b: 0] 
    	dvalue/value: (FFh << 24) OR (r << 16 ) OR (g << 8) OR b
    	mvalueIN1: mvalueIN1 + unit
    	mvalueIN2: mvalueIN2 + unit
    	dvalue: dvalue + 1
	]
    image/release-buffer dst handleD yes
]





; input is a binary matrix
; output must be a vector of float!
; x and y are 0-based !

; not exported 

; initializes distance map
;inside the object distance=0.0 
;outside the object (-1.0)  distance to be computed

_initDistance: routine [
	input 	[vector!] 
	output 	[vector!]
	/local
	mvalueIN
	mTailIN
	mvalueOUT
	unit1 unit2
] [
	mvalueIN: vector/rs-head input
	mTailIN: vector/rs-tail input
	mvalueOUT: vector/rs-head output
	unit1: _rcvGetMatBitSize input
	unit2: _rcvGetMatBitSize output
	while [mvalueIN <= mTailIN] [
		either ((_getIntValue as integer! mvalueIN unit1)  = 1) 	
					[_setFloatValue as integer! mvalueOUT 0.0 unit2] 
					[_setFloatValue as integer! mvalueOUT -1.0 unit2]
		mvalueIN: mvalueIN + unit1
		mvalueOUT: mvalueOUT + unit2
	]
]

_Normalize: routine [
	output 		[vector!]
	normalizer  [integer!]
	/local
	mvalueOUT
	mtailOUT
	unit
	f
][
	mvalueOUT: vector/rs-head output
	mtailOUT: vector/rs-tail output
	unit: _rcvGetMatBitSize output
	while [mvalueOUT <= mtailOUT] [
		f: (_getFloatValue as integer! mvalueOUT)  / normalizer
		_setFloatValue as integer! mvalueOUT f unit
		mvalueOUT: mvalueOUT + unit
	]
]



_testAndSet: routine [
	output 		[vector!]
	w 			[integer!] 
	h 			[integer!] 
	x 			[integer!] 
	y 			[integer!] 
	newvalue 	[float!]
	/local
	mvalueOUT
	unit
	f
	ptr
][
	mvalueOUT: vector/rs-head output
	unit: _rcvGetMatBitSize output
	if any [x < 0 x >= w] [exit]	;
	if any [y < 0 y >= h] [exit]
	ptr: as integer! mvalueOUT + (((y * w) + x) * unit)
	f: _getFloatValue  ptr
	if all [f >= 0.0 f < newvalue] [exit] ; distance still processed -> exit
	_setFloatValue  ptr newvalue unit
]





; output is a vector of float!

_rcvChamferCompute: routine [
	output 	[vector!]
	chamfer	[block!]
	w 		[integer!] 
	h 		[integer!] 
	/local
	x y
	v
	f
	unit
	idx
	mvalueOUT
	mvalueKNL
	n k
	dx dy dt
	idx2
][

	mvalueOUT: vector/rs-head output
	mvalueKNL: block/rs-head chamfer
	unit: _rcvGetMatBitSize output
	
	; forward OK
	mvalueOUT: vector/rs-head output
	n: (block/rs-length? chamfer) / 3
	y: 0
	while [y <= (h - 1)] [
		x: 0
		while [x <= (w - 1)] [
			idx2: mvalueOUT  + (((y * w) + x) * unit) 
			f: _getFloatValue as integer! idx2
			if f >= 0.0 [
				k: 0
				while [k < n][
					idx: mvalueKNL + (k * 3)
					v: as red-integer! idx
					dx: v/value
					idx: idx + 1
					v: as red-integer! idx
					dy: v/value
					idx: idx + 1
					v: as red-integer! idx
					dt: as float! v/value 
					_testAndSet output w h x + dx y + dy f + dt
					if (dy <> 0) [_testAndSet output w h x - dx y + dy f + dt] 
					if (dx <> dy) [
						_testAndSet output w h x + dy y + dx f + dt
						if (dy <> 0) [_testAndSet output w h x - dy y + dx f + dt]
					]
				k: k + 1
				]
			]
			x: x + 1
		]	
		y: y + 1
	]
	
	; backward OK
	y: h - 1
	while [y >= 0] [
		x: w - 1
		while [x >= 0] [
			idx2: mvalueOUT  + (((y * w) + x) * unit)
			f: _getFloatValue as integer! idx2
			if f >= 0.0 [
				k: 0
				while [k < n][
					idx: mvalueKNL + (k	 * 3)
					v: as red-integer! idx
					dx: v/value
					idx: idx + 1
					v: as red-integer! idx
					dy: v/value
					idx: idx + 1
					v: as red-integer! idx
					dt: as float! v/value
					_testAndSet output w h  x - dx y - dy  f + dt
					if (dy <> 0) [_testAndSet output w h x + dx y - dy f + dt]
					if (dx <> dy) [
						_testAndSet output w h x - dy y - dx f + dt
						if (dy <> 0) [_testAndSet output w h x + dy y - dx f + dt]
					]
				k: k + 1
				]
			]
			x: x - 1
		]
		y: y - 1
	]
]



