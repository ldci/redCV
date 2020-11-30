Red [
	Title:   "Red Computer Vision: DTW"
	Author:  "Francois Jouen"
	File: 	 %rcvDTW.red
	Tabs:	 4
	Rights:  "Copyright (C) 2018-2020 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;#include %../matrix/matrix-as-obj/matrix-obj.red		;--for stand alone test
;#include %../matrix/matrix-as-obj/routines-obj.red 	;--for stand alone test


;********************* DTW Dynamic Time Warping ****************************
; a basic DTW algorithm
; thanks to Nipun Batra (https://nipunbatra.github.io/blog/2014/dtw.html)
; ************************ routines ****************************************

rcvDTWMin: routine [
	x [float!] 
	y [float!] 
	z [float!] 
	return: [float!]
	/local 
	r		[float!]	
][
	if all [x <= y x <= z] [r: x]
	if all [y <= x y <= z] [r: y]
	if all [z <= x z <= y] [r: z]
	r
]
;--all mat are float matrices
rcvDTWDistance: routine [
	x		[block!]
	y		[block!]
	dmat	[object!]
	op		[integer!]
	/local
	vec						[red-vector!]
	xHead yHead	idxx idxy 	[red-value!]
	headD idxD				[byte-ptr!]
	p						[float-ptr!]
	vxi vyi 				[red-integer!]
	vxf vyf 				[red-float!]
	dist fvx fvy			[float!]
	xLength yLength 		[integer!]
	i j 					[integer!]
][
	fvx: 0.0
	fvy: 0.0
	dist: 0.0
	xHead: block/rs-head x
	yHead: block/rs-head y
	xLength:  block/rs-length? x
	yLength:  block/rs-length? y
	vec: mat/get-data dmat
	headD: vector/rs-head vec
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

rcvDTWRun: routine [
	w 		[integer!] 
	h 		[integer!] 
	dMat 	[object!] 
	cMat 	[object!]
	/local
	vecD vecC				[red-vector!]
	headD headC idxD idxC	[byte-ptr!]
	v u						[float!]
	v1 v2 v3				[float!]
	i j						[integer!] 
	p						[float-ptr!]
][
	vecD: mat/get-data dMat
	vecC: mat/get-data cMat
	headD: vector/rs-head vecD
	headC: vector/rs-head vecC
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
				p/value: v  + rcvDTWMin v1 v2 V3
			]
			j: j + 1
		]
		i: i + 1
	]
]

rcvDTWPath: routine [
	x 		[block!] 
	y 		[block!] 
	cMat	[object!] 
	xPath 	[block!]
	/local
	vec						[red-vector!]
	i j w					[integer!]
	minD v1 v2 v3			[float!]
	headC idxC idx1 idx2	[byte-ptr!]
][
	i: (block/rs-length? y) - 1
	j: (block/rs-length? x) - 1
	w: block/rs-length? x 
	vec: mat/get-data cMat
	headC: vector/rs-head vec
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
		minD: rcvDTWMin v1 v2 v3
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

; ************************* Functions ***********************************

rcvDTWDistances: function [x [block!] y [block!] dmat [object!]
"Making a 2d matrix to compute distances between all pairs of x and y series"
][
	t: type? first x
	if t = integer! [rcvDTWDistance x y dmat 0]
	if t = float! 	[rcvDTWDistance x y dmat 1]
]

rcvDTWCosts: function [x [block!] y [block!] dMat [object!] cMat [object!]
"Making a 2d matrix to compute minimal distance cost "
] [
	rcvDTWRun length? x length? y dMat cMat
]

rcvDTWGetPath: function [x [block!] y [block!] cMat [object!] xPath [block!]
"Gets optimal warping path"
] [
	clear xPath
	rcvDTWPath x y cMat xPath
	reverse xPath
]

rcvDTWGetDTW: function [cMat [object!] return: [number!]
"Returns DTW value"
][
	last cMat/data
]

rcvDTWCompute: function [x [block!] y [block!] return: [number!]
"Short-cut to get DTW value if you don't need distance and cost matrices"
][
	dMat: matrix/init/value 3 64 as-pair (length? x) (length? y) 0.0
	cMat: matrix/init/value 3 64 as-pair (length? x) (length? y) 0.0
	t: type? first x
	if t = integer! [rcvDTWDistance x y dmat 0]
	if t = float! 	[rcvDTWDistance x y dmat 1]
	rcvDTWRun (length? x) (length? y) dMat cMat
	last cMat/data
]




