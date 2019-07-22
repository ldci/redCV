Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvTSRoutines.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

_rcvTSStatSignal: routine [
	 signal 		[vector!]
     blk	 	 	[block!]
     op				[integer!]
     /local
     length
     sum sum2 a b num
     mean sd
     mini maxi
     val
     headS tailS unit
     f s 
][
	 block/rs-clear blk
	 sum: 0.0
	 sum2: 0.0
	 mean: 0.0
	 sd: 0.0
	 maxi: 0.0
	 mini: 10000.00
	 length: as float! vector/rs-length? signal
	 headS: vector/rs-head signal
	 tailS: vector/rs-tail signal
	 s: GET_BUFFER(signal)
	 unit: GET_UNIT(s)
	 while [headS < tailS][
	 	switch op [
	 		0 [val: as float! vector/get-value-int as int-ptr! headS unit]
	 		1 [val: vector/get-value-float headS unit]
	 	]
	 	either val >= maxi [maxi: val] [maxi: maxi]
	 	either val < mini [mini: val] [mini: mini]
		sum: sum + val
		sum2: sum2 + (val * val)
		headS: headS + unit
	]
	mean: sum / length
	a: Sum * Sum
	b: a / length
    num: (sum2 - b);
    if num < 0.0 [num: 0.0 - num]
    sd: sqrt  (Num / (length - 1))
    f: float/box mean
    block/rs-append blk as red-value! f 
    f: float/box sd
    block/rs-append blk as red-value! f
    f: float/box mini
    block/rs-append blk as red-value! f
    f: float/box maxi
    block/rs-append blk as red-value! f
]


_rcvTSSDetrendSignal: routine [
	signal 	[vector!]
	filter 	[vector!]
	mean	[float!]
	op		[integer!]
	/local headS headF tailS unit1 unit2 s
	val val2 pt64 p4
][ 
	headS: vector/rs-head signal
	tailS: vector/rs-tail signal
	headF: vector/rs-head filter
	
	s: GET_BUFFER(signal)
	unit1: GET_UNIT(s)
	
	s: GET_BUFFER(filter)
	unit2: GET_UNIT(s)
	
	while [headS < tailS][
		switch op [
	 		0 [val: as float! vector/get-value-int as int-ptr! headS unit1
	 			 val2: as integer! (val - mean)
	 			 p4: as int-ptr! headF
	 			 p4/value: switch unit2 [
					1 [val2 and FFh or (p4/value and FFFFFF00h)]
					2 [val2 and FFFFh or (p4/value and FFFF0000h)]
					4 [val2]
				]
	 		]
	 		1 [val: vector/get-value-float headS unit1
	 			pt64: as float-ptr! headF
				pt64/value: val - mean]
	 	]
		headS: headS + unit1
		headF: headF + unit2
	]
]


_rcvTSSNormalizeSignal: routine [
	signal 	[vector!]
	filter 	[vector!]
	mean	[float!]
	sd		[float!]
	op		[integer!]
	/local headS headF tailS unit1 unit2 s
	val val2 pt64 p4
][ 
	headS: vector/rs-head signal
	tailS: vector/rs-tail signal
	headF: vector/rs-head filter
	
	s: GET_BUFFER(signal)
	unit1: GET_UNIT(s)
	
	s: GET_BUFFER(filter)
	unit2: GET_UNIT(s)
	
	while [headS < tailS][
		switch op [
	 		0 [val: as float! vector/get-value-int as int-ptr! headS unit1
	 			 val2: as integer! ((val - mean) / sd)
	 			 p4: as int-ptr! headF
	 			 p4/value: switch unit2 [
					1 [val2 and FFh or (p4/value and FFFFFF00h)]
					2 [val2 and FFFFh or (p4/value and FFFF0000h)]
					4 [val2]
				]
	 		]
	 		1 [val: vector/get-value-float headS unit1
	 			pt64: as float-ptr! headF
				pt64/value: (val - mean) / sd]
	 	]
		headS: headS + unit1
		headF: headF + unit2
	]
]


_rcvTSMMFilter: routine [
	signal 	[vector!]
	filter 	[vector!]
	filterSize	[integer!]
	op		[integer!]
	/local headS headF tailS tailF unit1 unit2 s
	n val val2 pt64 p4
	idx
	sum
	mm
][ 
	headS: vector/rs-head signal
	tailS: vector/rs-tail signal
	headF: vector/rs-head filter
	tailF: vector/rs-tail filter
	
	s: GET_BUFFER(signal)
	unit1: GET_UNIT(s)
	
	s: GET_BUFFER(filter)
	unit2: GET_UNIT(s)
	
	while [headS < (tailS - filterSize)] [
		n: 0
		sum: 0.0
		while [n < filterSize] [
			idx: headS + (n * unit1)
			switch op [
	 			0 [val: as float! vector/get-value-int as int-ptr! idx unit1]
	 			1 [val: vector/get-value-float idx unit1]
	 		]
			sum: sum + val
			n: n + 1
		]
		mm: sum / as float! filterSize
		switch op [
	 		0	[p4: as int-ptr! headF
	 			p4/value: switch unit2[
					1 [(as integer! mm) and FFh or (p4/value and FFFFFF00h)]
					2 [(as integer! mm) and FFFFh or (p4/value and FFFF0000h)]
					4 [as integer! mm]
				]
	 			 
			]
	 		1	[pt64: as float-ptr! headF
				pt64/value: mm]
		]
		headS: headS + unit1
		headF: headF + unit2
	]
	
	;calculates mean for the last values (filterSize)
	sum: 0.0
	while [headS < tailS] [
		switch op [
	 			0 [val: as float! vector/get-value-int as int-ptr! headS unit1]
	 			1 [val: vector/get-value-float headS unit1]
	 		]
	 	sum: sum + val
	 	headS: headS + unit1
	]
	mm: sum / as float! filterSize
	
	while [headF < tailF] [
		switch op [
	 		0	[p4: as int-ptr! headF
	 			p4/value: switch unit2[
					1 [(as integer! mm) and FFh or (p4/value and FFFFFF00h)]
					2 [(as integer! mm) and FFFFh or (p4/value and FFFF0000h)]
					4 [as integer! mm]
				]
	 			 
			]
	 		1	[pt64: as float-ptr! headF
				pt64/value: mm]
		]
		headF: headF + unit2
	]
]


_rcvSGFilter: routine [
	signal 		[vector!]
	filter 		[vector!]
	kernel		[block!]
	/local headS headBS headF  unit1 unit2 s 
	kBase kValue kLength
	sg i n nl nr length sglength offset
	val val2 pt64
	sum coef sumCoef fcoef fsumCoef
][
	headS: vector/rs-head signal
	headBS: vector/rs-head signal
	headF: vector/rs-head filter
	kBase: block/rs-head kernel
	kLength: (block/rs-length? kernel) - 2
	s: GET_BUFFER(signal)
	unit1: GET_UNIT(s)
	s: GET_BUFFER(filter)
	unit2: GET_UNIT(s)
	length: vector/rs-length? signal
	
	nl: kLength / 2
	nr: kLength / 2
	sglength: nl + nr + 1
	;skip nl values 
	i: 0
	sum: 0.0
	while [i < nl] [
	 	headS: headS + unit1
		headF: headF + unit2 
    	i: i + 1 
    ]
    ;start filter
    while [i < (length - nr)] [
    	sg: 0.0
    	sum: 0.0
    	n: 0
    	while [n < sglength][
    		offset: (i - nl + n - 1) * unit1
    		val: vector/get-value-float headBS + offset  unit1
    		kValue: KBase + n 
    		coef: as red-integer! kValue
    		fcoef: as float! coef/value
    		sum: sum + (val * fcoef)
    		n: n + 1
    	]
    	kValue: kValue + 1
    	sumCoef: as red-integer! kValue
    	fsumCoef: as float! sumCoef/value
    	sg: sum / fsumCoef
    	if i = nl [val2: sg] ; for replacing first nl values
    	pt64: as float-ptr! headF
		pt64/value: sg
    	headS: headS + unit1
		headF: headF + unit2 
    	i: i + 1
    ]
    while [i < length] [
    	val: vector/get-value-float headS unit1
	 	pt64: as float-ptr! headF
		pt64/value: sg
    	headS: headS + unit1
		headF: headF + unit2 
    	i: i + 1 
    ]
    
    ; update first nl values
    headS: vector/rs-head signal
	headF: vector/rs-head filter
	i: 0
	while [i < nl] [
	 	pt64: as float-ptr! headF
		pt64/value: val2
	 	headS: headS + unit1
		headF: headF + unit2 
    	i: i + 1 
    ]
]




;********************* DTW Dynamic Time Warping ****************************
_rcvDTWMin: routine [
	x [float!] 
	y [float!] 
	z [float!] 
	return: [float!]
	/local 
	r
][
	if all [x <= y x <= z] [r: x]
	if all [y <= x y <= z] [r: y]
	if all [z <= x z <= y] [r: z]
	r
]


_rcvDTWDistances: routine [
	x		[block!]
	y		[block!]
	dmat	[vector!]
	op		[integer!]
	/local
	dist
	headD
	xLength xHead vxi vyi vxf vyf fvx fvy
	yLength yHead
	i j idxx idxy idxD
	p
][
	fvx: 0.0
	fvy: 0.0
	dist: 0.0
	xHead: block/rs-head x
	yHead: block/rs-head y
	xLength:  block/rs-length? x
	yLength:  block/rs-length? y
	headD: vector/rs-head dMat
	i: 0
	while [i < yLength] [
		j: 0
		while [j < xLength][
			idxx: xHead + j
			idxy: yHead + i
			idxD: headD + ((i * xLength + j) * 8)
			switch op [
				0 [ vxi: as red-integer! idxx vyi: as red-integer! idxy
					fvx: as float! vxi/value
					fvy: as float! vyi/value	
					]
				1 [ vxf: as red-float! idxx vyf: as red-float! idxy
					fvx: as float! vxf/value
					fvy: as float! vyf/value]
			]
			
			dist: (sqrt ((fvx - fvy) * (fvx - fvy)))
			p: as float-ptr! idxD
			p/value: dist
			j: j + 1
		]
		i: i + 1
	]
]

_rcvDTWRun: routine [
	w 		[integer!] 
	h 		[integer!] 
	dMat 	[vector!] 
	cMat 	[vector!]
	/local
	headD headC idxD idxC  v u
	v1 v2 v3
	i j 
	p

][
	
	headD: vector/rs-head dMat
	headC: vector/rs-head cMat

	i: 0
	while [i < h] [
		j: 0
		while [j < w][
			idxD: headD + ((i * w + j) * 8)
			idxC: headC + ((i * w + j) * 8)
			p: as float-ptr! idxC
			v: vector/get-value-float  idxD 8
			; first value
			if all [i = 0 j = 0] [p/value: v]
			; first line
			if (i = 0) and (j > 0) [
				idxC: headC + ((i * w + j - 1) * 8)
				u: vector/get-value-float idxC 8
				idxC: headC + ((i * w + j) * 8)
				p: as float-ptr! idxC
				p/value: v + u
			]
			; first column
			if (i > 0) and (j = 0) [
				idxC: headC + ((i - 1 * w + j) * 8)
				u: vector/get-value-float idxC 8
				idxC: headC + ((i * w + j) * 8)
				p: as float-ptr! idxC
				p/value: v + u
			]
			; other values
			if (i > 0) and (j > 0) [
				idxC: headC + ((i - 1 * w + j - 1) * 8)
				v1: vector/get-value-float idxC 8
				idxC: headC + ((i - 1 * w + j) * 8)
				v2: vector/get-value-float  idxC 8
				idxC: headC + ((i * w + j - 1) * 8)
				v3: vector/get-value-float  idxC 8
				idxC: headC + ((i * w + j) * 8)
				p: as float-ptr! idxC
				p/value: v  + _rcvDTWMin v1 v2 V3
			]
			j: j + 1
		]
		i: i + 1
	]
]

_rcvDTWGetPath: routine [
	x 		[block!] 
	y 		[block!] 
	cMat	[vector!] 
	xPath 	[block!]
	/local
	i j w
	minD v1 v2 v3
	headC idxC idx1 idx2
][
	i: (block/rs-length? y) - 1
	j: (block/rs-length? x) - 1
	w: block/rs-length? x 
	headC: vector/rs-head cMat
	block/rs-clear xPath
	pair/make-in xPath j i
	while [all [i > 0 j > 0]] [
		if i = 0 [j: j - 1] 
		if j = 0 [print ["yes" lf] i: i - 1]	
		idxC: headC + ((i - 1 * w + j - 1) * 8)
		v1: vector/get-value-float idxC 8
		
		idxC: headC + ((i - 1 * w + j) * 8)
		v2: vector/get-value-float  idxC 8
		
		idxC: headC + ((i * w + j - 1) * 8)
		v3: vector/get-value-float  idxC 8
		
		minD: _rcvDTWMin v1 v2 v3
		
		idx1: headC + ((i - 1 * w + j) * 8)
		v1: vector/get-value-float idx1 8
		
		idx2: headC + ((i * w + j - 1) * 8)
		v2: vector/get-value-float idx2 8
		
		either  any [v1 = minD v2 = minD][
			if v1 = minD [i: i - 1]
			if v2 = minD [j: j - 1]
		] [i: i - 1 j: j - 1]
		
		pair/make-in xPath j i
	]
	pair/make-in xPath 0 0
]

