Red [
	Title:   "Red Computer Vision: Clustering routines"
	Author:  "Francois Jouen"
	File: 	 %rcvCluster.red
	Tabs:	 4
	Rights:  "Copyright (C) 2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;#include %../core/rcvCore.red ;--for stand alone test
;#include %../matrix/rcvMatrix.red ;--for stand alone test
;#include %../tools/rcvTools.red ;--for stand alone test

; ****************** KMeans alogorithm routines ******************
; All routines and functions require redCV array data type [block of vector]

rcvGenCentroid: routine [
"Generates centroids initial values"
	array		[block!]	; array type
	/local
		bvalue 				[red-value!] 	
   		p					[float-ptr!]
    	vectBlk				[red-vector!]
    	vvalue				[byte-ptr!] 
    	i j nCluster unit	[integer!]
    	s					[series!]
][
	;Generate centroids initial values
	bvalue: block/rs-head array
	nCluster:  block/rs-length? array
	vectBlk: as red-vector! bvalue
	s: GET_BUFFER(vectBlk)
	unit: GET_UNIT(s)	
	i: 0
    while [i < nCluster][
    	vectBlk: as red-vector! bvalue ; 3 values in vectBlk
    	vvalue: vector/rs-head vectBlk
		j: 0
		while [j < 3] [
			p: as float-ptr! vvalue
			case [
				j = 0 [p/value: 0.0]
				j = 1 [p/value: 0.0]
				j = 2 [p/value: as float! i]
			]
			vvalue: vvalue + unit
			j: j + 1
		]
    	bvalue: bvalue + 1
    	i: i + 1
    ] 
]


rcvKNearest: routine [
"Distance and index of the closest cluster center"
	pt	 		[vector!] 
	centroid 	[block!] 
	op			[integer!] 
	return: 	[float!]
	/local
		bcvalue					[red-value!]
		vvalue  pvalue			[byte-ptr!]
		vectBlk					[red-vector!]
		nCluster unit i j		[integer!]
    	min_d min_i cx cy cg	[float!]
    	px py pg x y d r		[float!] 
    	s						[series!]
] [
	min_d: 1E100
	min_i: 0.0
	bcvalue: block/rs-head centroid
	nCluster: block/rs-length? centroid
	vectBlk: as red-vector! bcvalue
	pvalue: vector/rs-head pt 
	s: GET_BUFFER(vectBlk)
	unit: GET_UNIT(s)	
	i: 0
	;get point value as a vector
	while [i < 3][
		case [
			i = 0 [px: vector/get-value-float pvalue unit]
			i = 1 [py: vector/get-value-float pvalue unit]
			i = 2 [pg: vector/get-value-float pvalue unit]
		]
		pvalue: pvalue + unit
		i: i + 1
	]
	;get distance and index of the closest cluster center
	j: 0
	bcvalue: block/rs-head centroid
	while [j < nCluster][
		vectBlk: as red-vector! bcvalue
		vvalue: vector/rs-head vectBlk
		i: 0
		while [i < 3][
			case [
			  i = 0 [cx: vector/get-value-float vvalue unit]
			  i = 1 [cy: vector/get-value-float vvalue unit]
			  i = 2 [cg: vector/get-value-float vvalue unit]
			]
			vvalue: vvalue + unit
			i: i + 1
		]
		x: cx - px
	    y: cy - py
	    ; Squared Euclidian
	    if x < 0.0 [x: 0.0 - x]
		if y < 0.0 [y: 0.0 - y]
		x: x * x
		y: y * y
		d: x + y 
		;d: (x * x) + (y * y)
		if min_d > d [
            min_d: d
            min_i: as float! j 
        ]
        bcvalue: bcvalue + 1
        j: j + 1
    ]
	if op = 1 [r: min_i]
	if op = 2 [r: min_D]
	r
]


; first initialization with k-means++ method
rcvKMInit: routine [
"First initialization with k-means++ method"
	points 		[block!] ;array
	centroid 	[block!] ;array
	tmpblk		[block!] ;simple block for sum
	/local
		bcvalue	bpvalue	btvalue [red-value!]
		cvectBlk pvectBlk		[red-vector!]
		cvvalue	pvvalue			[byte-ptr!]
		p						[int-ptr!]
		ptrc ptrp				[float-ptr!]
		unit i j k nCluster len	[integer!]
		d sum					[float!]
		s						[series!]
		dd						; an internal structure for int64
][
	bcvalue: block/rs-head centroid
	bpvalue: block/rs-head points
	btvalue: block/rs-head tmpblk
	cvectBlk: as red-vector! bcvalue
	pvectBlk: as red-vector! bpvalue
	s: GET_BUFFER(pvectBlk)
	unit: GET_UNIT(s)	
	;unit: rcvGetMatBitSize pvectBlk
	len: block/rs-length? points
	nCluster: block/rs-length? centroid
	int64!:  alias struct! [int1 [integer!] int2 [integer!]]
	d: 0.0
	; centroid clusters
	btvalue: block/rs-head tmpblk
	block/rs-clear tmpblk
	i: 0
	while [i < nCluster] [
		sum: 0.0
		bpvalue: block/rs-head points
		cvectBlk: as red-vector! bcvalue
		cvvalue: vector/rs-head cvectBlk
		j: 0	;for each point
		while [j < len][
			pvectBlk: as red-vector! bpvalue
			d:  rcvKNearest pvectBlk centroid 2 ; distance
			dd: as int64! :d
			sum: sum + d
			;integer/make-in tmpblk as integer! sum
			;float/make-in tmpblk dd/int1 dd/int2
			float/make-in tmpblk dd/int2 dd/int1
			bpvalue: bpvalue + 1
			j: j + 1
		]
		sum: (sum * as float! _random/rand) / 2147483647.0 - 1.0 ;randf(sum)
		bpvalue: block/rs-head points
		btvalue: block/rs-head tmpblk
		j: 0
		while [j < len][
			p: as int-ptr! btvalue
			sum: sum -  as float! p/value
			if sum > 0.0 [
				pvectBlk: as red-vector! bpvalue
				pvvalue: vector/rs-head pvectBlk
				cvectBlk: as red-vector! bcvalue
				cvvalue: vector/rs-head cvectBlk
				;d:  rcvKNearest pvectBlk centroid 1 ; index
				k: 0 
				while [k < 3] [
					ptrp: as float-ptr! pvvalue
					ptrc: as float-ptr! cvvalue
					;if k = 2 [ptrp/value: d]
					ptrc/value: ptrp/value
					cvvalue: cvvalue + unit
					pvvalue: pvvalue + unit
					k: k + 1
				]
			]
			btvalue: btvalue + 1
			bpvalue: bpvalue + 1
			j: j + 1
		]
		bcvalue: bcvalue + 1
		i: i + 1
	]
	; update point group index
	bcvalue: block/rs-head centroid
	bpvalue: block/rs-head points
	j: 0
	while [j < len ][
		pvectBlk: as red-vector! bpvalue
		; group index [0..nCluster]
		d:  rcvKNearest pvectBlk centroid 1 ; index
		pvectBlk: as red-vector! bpvalue
		pvvalue: vector/rs-head pvectBlk
		k: 0 
		while [k < 3] [
			ptrp: as float-ptr! pvvalue
			if k = 2 [ptrp/value: d]	;update group
			pvvalue: pvvalue + unit
			k: k + 1
		]
		bpvalue: bpvalue + 1
		j: j + 1
	]
]

;Lloyd K-means Clustering with convergence
;group element for centroids are used as counters

rcvKMCompute: routine [
"Lloyd K-means Clustering with convergence"
	points 		[block!] 
	centroid 	[block!]
	/local
		bcvalue bpvalue				[red-value!]
		cvectBlk pvectBlk			[red-vector!]
		cvvalue	pvvalue				[byte-ptr!]
		f							[float-ptr!]
		lenpts10 changed			[integer!]
		i j idx unit len nCluster	[integer!]
		cx cy cg px py pg min_I		[float!]
    	s							[series!]
][
	bcvalue: block/rs-head centroid
	nCluster: block/rs-length? centroid
	bpvalue: block/rs-head points
	pvectBlk: as red-vector! bpvalue
	len: block/rs-length? points
	s: GET_BUFFER(pvectBlk)
	unit: GET_UNIT(s)	
	;unit: rcvGetMatBitSize pvectBlk
	lenpts10: len >> 10
	changed: 0
	;Find clusters centroids
	until [
		rcvGenCentroid centroid
		bpvalue: block/rs-head points
		bcvalue: block/rs-head centroid
		i: 0
		while [i < len] [
			; get each point values
			pvectBlk: as red-vector! bpvalue
			pvvalue: vector/rs-head pvectBlk
			j: 0
			while [j < 3] [
				case [
					j = 0 [px: vector/get-value-float pvvalue unit]
					j = 1 [py: vector/get-value-float pvvalue unit]
					j = 2 [pg: vector/get-value-float pvvalue unit]
				]
				pvvalue: pvvalue + unit
				j: j + 1
			]
			bcvalue: block/rs-head centroid
			;pg: between 0 and K - 1
			; select centroid (c: centroid/(p/group))
			idx: as integer! pg ;
			cvectBlk: as red-vector! bcvalue + idx
			cvvalue: vector/rs-head cvectBlk
			;get  and update selected centroid values
			j: 0
			while [j < 3] [
			f: as float-ptr! cvvalue
				case [
					j = 0 [cx: vector/get-value-float cvvalue unit f/value: cx + px]
					j = 1 [cy: vector/get-value-float cvvalue unit f/value: cy + py]
					j = 2 [cg: vector/get-value-float cvvalue unit f/value: cg + 1.0]
				]
				cvvalue: cvvalue + unit
				j: j + 1
			]
			bpvalue: bpvalue + 1
			i: i + 1
		]
		
		;calculate centroid means
		bcvalue: block/rs-head centroid
		cvectBlk: as red-vector! bcvalue
		i: 0
		while [i < nCluster][
			cvectBlk: as red-vector! bcvalue
			cvvalue: vector/rs-head cvectBlk
			j: 0
			while [j < 3][
				case [
					j = 0 [cx: vector/get-value-float cvvalue unit]
					j = 1 [cy: vector/get-value-float cvvalue unit]
					j = 2 [cg: vector/get-value-float cvvalue unit]
				]
				cvvalue: cvvalue + unit
				j: j + 1
			]
			;mean value
			cx: cx / cg
			cy: cy / cg
			
			cvvalue: vector/rs-head cvectBlk
			j: 0
			while [j < 3][
				f: as float-ptr! cvvalue
				case [
					j = 0 [f/value: cx]
					j = 1 [f/value: cy]
					j = 2 [f/value: cg]
				]
				cvvalue: cvvalue + unit
				j: j + 1
			]
			bcvalue: bcvalue + 1
			i: i + 1
		]
		
		;find closest centroid of each point
		bpvalue: block/rs-head points
		i: 0
		while [i < len][
			pvectBlk: as red-vector! bpvalue
			pvvalue: vector/rs-head pvectBlk
			j: 0
			; get group index
			while [j < 3 ][
				f: as float-ptr! pvvalue
				if j = 2 [pg: vector/get-value-float pvvalue unit]
				pvvalue: pvvalue + unit
				j: j + 1
			]
			
			min_I: rcvKNearest pvectBlk centroid 1
			if min_I <> pg [
				f/value: min_I 
				changed: changed + 1
			]
		
			bpvalue: bpvalue + 1
			i: i + 1
		]
		;stop when 99.9% of points are good
		changed > lenpts10
	]
	;update centroid group element OK
	bcvalue: block/rs-head centroid
	i: 0
	while [i < nCluster][
		cvectBlk: as red-vector! bcvalue
		cvvalue: vector/rs-head cvectBlk
		;update only group
		j: 0
		while [j < 3][
			f: as float-ptr! cvvalue
			if j = 2 [f/value: as float! i]
			cvvalue: cvvalue + unit
			j: j + 1
		]	
		bcvalue: bcvalue + 1
		i: i + 1
	]
	
]

;*************** kMeans Algorithm Functions ********************

rcvKMInitData: function [
"Creates data or centroid array"
	count [integer!]
][
	blk: copy []
	i: 0
	while [i < count] [
		append blk make vector! [float! 64 [0.0 0.0 0.0]]
		i: i + 1
	]
	blk
]
