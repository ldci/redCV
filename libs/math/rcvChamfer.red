Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvChamfer.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

; ************** Chamfer distance **********

{ Thanks to Pierre Schwartz & Xavier Philippeau
 Kernels by Verwer, Borgefors and Thiel 
 http://www.developpez.com for the java implementation
 ; in french Distance de chanfrein}


; predefined array of distances 
cheessboard: copy [1 0 1 1 1 1]
chamfer3:	 copy [1 0 3 1 1 4]
chamfer5:	 copy [1 0 5 1 1 7 2 1 11]
chamfer7:	 copy [1 0 14 1 1 20 2 1 31 3 1 44]
chamfer13:	 copy [1 0 68 1 1 96 2 1 152 3 1 215 3 2 245 4 1 280 4 3 340 5 1 346 6 1 413]
normalizer:  0
chamfer:	 copy []



rcvMakeGradient: routine [
"Makes a gradient matrix for contour detection (similar to Sobel) and returns max value"
    src  		[vector!] ;src and dst are integer matrices
    dst  		[vector!]
    size		[pair!]
    return: 	[integer!]
    /local
    sValue 		[byte-ptr!]
    dValue 		[byte-ptr!]
    idx 		[byte-ptr!]
    idx2		[byte-ptr!]
    sx 			[float!]
    sy 			[float!]			
    snorm		[float!]
    unit		[integer!]
    w			[integer!]
    h			[integer!]
    x			[integer!] 
    y			[integer!]
    v 			[integer!]
    p00 		[integer!]	
    p01 		[integer!]
    p02			[integer!]
    p10 		[integer!]
    p12 		[integer!]
    p20 		[integer!]
    p21			[integer!]
    p22			[integer!]
    maxGradient	[integer!]
][
	w: size/x
	h: size/y
	sValue: vector/rs-head src  			
	dValue: vector/rs-head dst		
    unit: rcvGetMatBitSize src 
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
        		p00: rcvGetIntValue as integer! idx unit 
        		idx: sValue + ((((y + 1) * w) + x) * unit) 
        		p01: rcvGetIntValue as integer! idx unit 
        		idx: sValue + ((((y + 2) * w) + x) * unit) 
        		p02: rcvGetIntValue as integer! idx unit 
        		idx: sValue + (((y * w) + (x + 1)) * unit) 
        		p10: rcvGetIntValue as integer! idx unit 
        		idx: sValue + ((((y + 2) * w) + (x + 1)) * unit) 
        		p12: rcvGetIntValue as integer! idx unit 
        		idx: sValue + ((((y) * w) + (x + 2)) * unit) 
        		p20: rcvGetIntValue as integer! idx unit 
        		idx: sValue + ((((y + 1) * w) + (x + 2)) * unit)
        		p21: rcvGetIntValue as integer! idx unit 
        		idx: sValue + ((((y + 2) * w) + (x + 2)) * unit)
        		p22: rcvGetIntValue as integer! idx unit 
        		sx: as float! (p20 + (2 * p21) + p22) - (p00 + (2 * p01) + p02)
        		sy: as float! (p02 + (2 * p12) + p22) - (p00 + (2 * p10) + p10)
        		snorm: sqrt  ((sx * sx) + (sy * sy))
        		v: as integer! snorm
        		maxGradient: maxInt maxGradient v
        		; update dst
        		idx2: dValue + ((((y + 1) * w) + (x + 1)) * unit)
        		rcvSetIntValue as integer! idx2 v unit
				x: x + 1
		]
		y: y + 1
	]
    maxGradient
]

;Binary [ 0 1] according to threshold value
;src and bingradient are integer matrices
 
rcvMakeBinaryGradient: routine [
"Makes a binary [0 1] matrix for contour detection"
    src  		[vector!]		;src and bingradient are integer matrices
    bingradient [vector!]
    maxG		[integer!]		; threshold
    threshold 	[integer!]
    /local
    sValue 		[byte-ptr!]	
    sTail		[byte-ptr!]
    dValue 		[byte-ptr!]	
    v 			[integer!]
    scale		[integer!]
    unit		[integer!]
][
	sValue: vector/rs-head src			; byte ptr
	sTail: vector/rs-tail src			; byte ptr
    dValue: vector/rs-head bingradient	; byte ptr
    unit: rcvGetMatBitSize src 		; bit size
    scale: threshold * maxG / 100
    while [svalue <= sTail] [
    		v: rcvGetIntValue as integer! sValue unit
    		either  (v > scale) [dValue/value: #"^(01)"] ;as byte! 1 
								[dValue/value: #"^(00)"] ;as byte! 0
    		sValue: sValue + unit
			dValue: dValue + unit
    ]  
]

; input float mat output integer mat
rcvFlowMat: routine [
"Calculates the distance map to binarized gradient"
	input 		[vector!] 	; float mat
	output 		[vector!]	; integer mat
	scale		[float!]	; float scale
	return: 	[float!]
	/local
	mvalueIN	[byte-ptr!]
	mTailIN		[byte-ptr!]
	mvalueOUT	[byte-ptr!]
	v			[integer!]
	unit1 		[integer!]
	unit2		[integer!]
	f 			[float!]
	maxf		[float!]
][
	f: 0.0
	maxf: 0.0
	v: 0
	mvalueIN: vector/rs-head input
	mTailIN: vector/rs-tail input
	mvalueOUT: vector/rs-head output
	unit1: rcvGetMatBitSize input
	unit2: rcvGetMatBitSize output
	while [mvalueIN <= mTailIN] [
		f: rcvGetFloatValue as integer! mvalueIN 
		if (f * scale)  > maxf [maxf: f * scale]
		v: as integer! (f * scale) 
		rcvSetIntValue as integer! mvalueOUT v unit2
		mvalueIN: mvalueIN + unit1
		mvalueOUT: mvalueOUT + unit2	
	]
	maxf
]


; distance to a 0.. 255 scale
; input: integer mat
rcvnormalizeFlow: routine [
"Normalizes distance into 0..255 range"
	input 		[vector!] ; integer mat
	factor		[float!]
	/local
	mvalueIN	[byte-ptr!]
	mTailIN		[byte-ptr!]
	scale		[float!]
	v			[float!]
	unit		[integer!]
	vFlow		[integer!]
][
	mvalueIN: vector/rs-head input
	mTailIN: vector/rs-tail input
	unit: rcvGetMatBitSize input
	scale: 255.0 / factor
	while [mvalueIN <= mTailIN] [
		vFlow: rcvGetIntValue as integer! mvalueIN unit
		v: scale * vFlow
		rcvSetIntValue as integer! mvalueIN as integer! v unit
		mvalueIN: mvalueIN + unit
	]
]

; 2 integer matrices and 1 image
rcvGradient&Flow: routine [
"Creates an image including flow and gradient calculation"
	input1		[vector!]
	input2		[vector!]
	dst			[image!]
	/local
	mvalueIN1	[byte-ptr!]
	mTailIN1	[byte-ptr!]
	mvalueIN2	[byte-ptr!]
	dvalue		[int-ptr!]
	unit		[integer!]
	handleD		[integer!]
	vFlow 		[integer!]
	vGrad		[integer!]
	r 			[integer!]
	g 			[integer!]
	b			[integer!]
][
	handleD: 0
	mvalueIN1: vector/rs-head input1
	mTailIN1: vector/rs-tail input1
	mvalueIN2: vector/rs-head input2
	unit: rcvGetMatBitSize input1
	dvalue: image/acquire-buffer dst :handleD
	while [mvalueIN1 <= mTailIn1] [
    	vFlow: rcvGetIntValue as integer! mvalueIN1 unit
    	vGrad: rcvGetIntValue as integer! mvalueIN2 unit
    	
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




rcvChamferNormalize: routine [
"Normalization"
	output 		[vector!]
	normalizer  [integer!]
	/local
	mvalueOUT	[byte-ptr!]
	mtailOUT	[byte-ptr!]
	unit		[integer!]
	f			[float!]
][
	mvalueOUT: vector/rs-head output
	mtailOUT: vector/rs-tail output
	unit: rcvGetMatBitSize output
	while [mvalueOUT <= mtailOUT] [
		f: (rcvGetFloatValue as integer! mvalueOUT)  / normalizer
		rcvSetFloatValue as integer! mvalueOUT f unit
		mvalueOUT: mvalueOUT + unit
	]
]



; not exported 
; initializes distance map
;inside the object distance=0.0 
;outside the object (-1.0)  distance to be computed

_initDistance: routine [
	input 		[vector!] 
	output 		[vector!]
	/local
	mvalueIN	[byte-ptr!]
	mTailIN		[byte-ptr!]
	mvalueOUT	[byte-ptr!]
	unit1 		[integer!]
	unit2		[integer!]
] [
	mvalueIN: vector/rs-head input
	mTailIN: vector/rs-tail input
	mvalueOUT: vector/rs-head output
	unit1: rcvGetMatBitSize input
	unit2: rcvGetMatBitSize output
	while [mvalueIN <= mTailIN] [
		either ((rcvGetIntValue as integer! mvalueIN unit1)  = 1) 	
					[rcvSetFloatValue as integer! mvalueOUT 0.0 unit2] 
					[rcvSetFloatValue as integer! mvalueOUT -1.0 unit2]
		mvalueIN: mvalueIN + unit1
		mvalueOUT: mvalueOUT + unit2
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
	mvalueOUT	[byte-ptr!]
	f			[float!]
	unit		[integer!]
	ptr			[integer!]		
][
	mvalueOUT: vector/rs-head output
	unit: rcvGetMatBitSize output
	if any [x < 0 x >= w] [exit]	;
	if any [y < 0 y >= h] [exit]
	ptr: as integer! mvalueOUT + (((y * w) + x) * unit)
	f: rcvGetFloatValue  ptr
	if all [f >= 0.0 f < newvalue] [exit] ; distance still processed -> exit
	rcvSetFloatValue  ptr newvalue unit
]


; Functions and Compute Routine
rcvChamferDistance: function [
"Selects a pre-defined chamfer kernel"
	chamferMask [block!] 
][
	chamfer: copy chamferMask
	normalizer: chamfer/3  ;[0][2]
	reduce [chamfer normalizer]
]

; output must be a vector of float!

rcvChamferCreateOutput: function [
"Creates a distance map (float!)" 
	mSize [pair!] 
][
	n: mSize/x * mSize/y
	make vector! reduce ['float! 64 n]
]


rcvChamferInitMap: function [
"Initializes distance map inside the object distance=0  outside the object distance to be computed"
	input 	[vector!] 
	output 	[vector!]
][
	_initDistance input output
]


; output is a vector of float!

rcvChamferCompute: routine [
"Calculates the distance map to binarized gradient"
	output 		[vector!]
	chamfer		[block!]
	size		[pair!]
	/local
	mvalueOUT	[byte-ptr!]
	idx2		[byte-ptr!]
	mvalueKNL	[red-value!]
	idx			[red-value!]
	w 			[integer!] 
	h 			[integer!] 
	x 			[integer!] 
	y			[integer!] 
	v			[red-integer!] 
	f			[float!]
	unit		[integer!] 
	n 			[integer!] 
	k			[integer!] 
	dx 			[integer!] 
	dy 			[integer!] 
	dt			[float!] 
][
	w: size/x
	h: size/y
	mvalueOUT: vector/rs-head output
	mvalueKNL: block/rs-head chamfer
	unit: rcvGetMatBitSize output
	
	; forward OK
	mvalueOUT: vector/rs-head output
	n: (block/rs-length? chamfer) / 3
	y: 0
	while [y <= (h - 1)] [
		x: 0
		while [x <= (w - 1)] [
			idx2: mvalueOUT  + (((y * w) + x) * unit) 
			f: rcvGetFloatValue as integer! idx2
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
			f: rcvGetFloatValue as integer! idx2
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
