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

;#system-global [#include %kmeans.reds]


; ****************** Vorono• and Distances diagrams******************
;absolute distances
_rcvDotsDistance: routine [
	dx		[float!] 	; x distance between 2 dots
	dy		[float!] 	; y distance between 2 dots
	op		[integer!]	; distance function
	p		[float!]	; power for Minkowski
	return: [float!]
	/local
	x2		[float!] 
	y2		[float!]
	m1		[float!]
	m2		[float!]
	s		[float!]		
] [
	if dx < 0.0 [dx: 0.0 - dx]
	if dy < 0.0 [dy: 0.0 - dy]
	x2: dx * dx
	y2: dy * dy
	; for absolute distances
	switch op [
		1	[sqrt (x2 + y2)]				; Euclidian
		2	[dx + dy]						; Manhattan
		3	[maxFloat dx dy]				; Chessboard
		4	[m1: pow dx p m2: pow dy p
			 s: m1 + m2 pow s (1.0 / p)]	; Minkowsky
		5	[either (dx > dy) [dx] [dy]]	; Chebyshev
		6	[x2 + y2]						; D2 Euclidian
		 
	]
]

; fractional distances
_rcvDotsFDistance: routine [
	dx1		[float!] 	; x1 - x2  distance
	dx2		[float!] 	; x1 + x2 distance 
	dy1		[float!] 	; y1 - y2 distance 
	dy2		[float!] 	; y1 + y2 distance 
	op		[integer!]	; distance op
	return: [float!]
	/local
	r
] [
	switch op [
		1 [r: (dx1 / dx2) + (dy1 / dy2)]; Camberra
		2 [r: (dx1 + dy1) / (dx2 + dy2)]; Sorensen
	]
	if r < 0.0 [r: 0.0 - r]
	r
]


_rcvDistance2Color: routine [
		dist 	[float!] 
		t 		[tuple!]
		/local
		r g b
		rf gf bf
		arr1
][
	r: t/array1 and FFh 
	g: t/array1 and FF00h >> 8 
	b: t/array1 and 00FF0000h >> 16 
	rf: as integer! (dist * r)
	gf: as integer! (dist * g)
	bf: as integer! (dist * b)
	arr1: (bf << 16) or (gf << 8 ) or rf
	stack/set-last as red-value! tuple/push 3 arr1 0 0
]

_rcvVoronoiDiagram: routine [
	peaks	[block!]
	peaksC	[block!]
	img		[image!]
	param1	[logic!]
	param2	[integer!]
	param3	[float!]
	/local
	pix1 	[int-ptr!]
	idxim	[int-ptr!]
	pt		[int-ptr!]
	n 		[integer!]
	x 		[integer!]
	y 		[integer!]
	s		[integer!] 
	w		[integer!] 
	h		[integer!] 
	sMin	[integer!]
	handle1 [integer!]
	d 		[float!]
	dMin 	[float!]
	p		[red-pair!] 		
	bxy		[red-value!]
	bcl 	[red-value!]
	idxy	[red-value!]
	idxc	[red-value!]
][
	handle1: 0
	n: block/rs-length? peaks
	bxy: block/rs-head peaks
	bcl: block/rs-head peaksC
	pix1: image/acquire-buffer img :handle1
	w: IMAGE_WIDTH(img/size)
    h: IMAGE_HEIGHT(img/size)
	y: 0
	 while [y < h] [
    	x: 0
       	while [x < w ][
       		dMin: _rcvDotsDistance as float! w as float! h param2 param3
       		s: 0
       		;calculate distance 
       		while [s < n] [
       			idxy: bxy + s
       			p: as red-pair! idxy
       			d: _rcvDotsDistance as float! p/x - x  as float! p/y - y param2 param3
       			if d < dMin [
					sMin: s
					dMin: d
				]
				s: s + 1
       		]
       		idxc: bcl + sMin
			pt: as int-ptr! idxc		; get seed color (a tuple)
			idxim: pix1 + (y * w) + x
			idxim/value: (255 << 24) OR pt/1 OR pt/2 OR pt/3
       		x: x + 1
       	]
    y: y + 1
    ]
    
    if param1 = true [
    	s: 0 
    	while [s < n] [
    		idxy: bxy + s
       		p: as red-pair! idxy
       		;make a cross for better seed visualization
       		if all [p/x > 1 p/y > 1 p/x < (w - 1) p/y < (h - 1)][
       			idxim: pix1 + (p/y * w) + p/x
       			idxim/value: (255 << 24) OR (0 << 16 ) OR (0 << 8) OR 0
       			idxim: pix1 + (p/y * w) + p/x - 1
       			idxim/value: (255 << 24) OR (0 << 16 ) OR (0 << 8) OR 0
       			idxim: pix1 + (p/y * w) + p/x + 1
       			idxim/value: (255 << 24) OR (0 << 16 ) OR (0 << 8) OR 0
       			idxim: pix1 + (p/y - 1 * w) + p/x
       			idxim/value: (255 << 24) OR (0 << 16 ) OR (0 << 8) OR 0
       			idxim: pix1 + (p/y + 1 * w) + p/x
       			idxim/value: (255 << 24) OR (0 << 16 ) OR (0 << 8) OR 0
       		]
       		s: s + 1
    	]
    ]
	image/release-buffer img handle1 yes
]



_rcvDistanceDiagram: routine [
	peaks	[block!]
	peaksC	[block!]
	img		[image!]
	param1	[logic!]
	param2	[integer!]
	param3	[float!]
	/local
	pix1 	[int-ptr!]
	idxim	[int-ptr!]
	n 		[integer!]
	x 		[integer!]
	y 		[integer!]
	s		[integer!] 
	w		[integer!] 
	h		[integer!] 
	sMin	[integer!]
	handle1 [integer!]
	d 		[float!]
	dMin 	[float!]
	dMax	[float!]
	p		[red-pair!] 		
	bxy		[red-value!]
	idxy	[red-value!]
	bcl 	[red-value!]
	idxc	[red-value!]	
	r 		[integer!]
	g 		[integer!]
	b		[integer!]
	dr 		[integer!]
	dg 		[integer!]
	db		[integer!]
	t		[red-tuple!]
][
	handle1: 0
	n: block/rs-length? peaks
	bxy: block/rs-head peaks
	bcl: block/rs-head peaksC
	pix1: image/acquire-buffer img :handle1
	w: IMAGE_WIDTH(img/size)
    h: IMAGE_HEIGHT(img/size)
	y: 0
	 while [y < h] [
    	x: 0
       	while [x < w ][
       		;calculate distance 
       		dMax: 0.1 * _rcvDotsDistance as float! w as float! h param2 param3 
       		dMin: 0.1 * _rcvDotsDistance as float! w as float!  h param2 param3
       		s: 0
       		while [s < n] [
       			idxy: bxy + s
       			p: as red-pair! idxy
       			d: _rcvDotsDistance as float! p/x - x  as float! p/y - y param2 param3
       			d: d / dMax
       			if d < dMin [
					sMin: s
					dMin: d
				]
				s: s + 1
       		]
       		d: 1.0 - dMin * 0.75
       		if d < 0.0 [d: 0.0]
       		idxc: bcl + sMin		
			t: as red-tuple! idxc		; get seed color (a tuple)
			r: t/array1 and 00FF0000h >> 16
			g: t/array1 and FF00h >> 8 
			b: t/array1 and FFh 
			dr: as integer! (d * r)
			dg: as integer! (d * g)
			db: as integer! (d * b)
			idxim: pix1 + (y * w) + x
			idxim/value: (255 << 24) OR (dr << 16 ) OR (dg << 8) OR db
       		x: x + 1
       	]
    y: y + 1
    ]
    ; show seeds if required
    if param1 [
    	s: 0 
    	while [s < n] [
    		idxy: bxy + s
       		p: as red-pair! idxy
       		;make a cross for better seed visualization
       		if all [p/x > 1 p/y > 1 p/x < (w - 1) p/y < (h - 1)][
       			idxim: pix1 + (p/y * w) + p/x
       			idxim/value: (255 << 24) OR (255 << 16 ) OR (255 << 8) OR 255
       			idxim: pix1 + (p/y * w) + p/x - 1
       			idxim/value: (255 << 24) OR (255 << 16 ) OR (255 << 8) OR 255
       			idxim: pix1 + (p/y * w) + p/x + 1
       			idxim/value: (255 << 24) OR (255 << 16 ) OR (255 << 8) OR 255
       			idxim: pix1 + (p/y - 1 * w) + p/x
       			idxim/value: (255 << 24) OR (255 << 16 ) OR (255 << 8) OR 255
       			idxim: pix1 + (p/y + 1 * w) + p/x
       			idxim/value: (255 << 24) OR (255 << 16 ) OR (255 << 8) OR 255
       		]
       		s: s + 1
    	]
    ]
    
	image/release-buffer img handle1 yes
]

; ****************** KMeans alogorithm ******************

_genCentroid: routine [
	array		[block!]	; array type
	/local
	bvalue 		[red-value!] 	
   	p			[float-ptr!]
    vectBlk		[red-vector!]
    vvalue		[byte-ptr!] 
    i			[integer!]
    j			[integer!]
    nCluster	[integer!]
    unit		[integer!]
][
	;Generate centroids initial values
	bvalue: block/rs-head array
	nCluster:  block/rs-length? array
	vectBlk: as red-vector! bvalue
	unit: _rcvGetMatBitSize vectBlk
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

; ****************** Vorono• and Distances diagrams******************
;absolute distances
_rcvDotsDistance: routine [
	dx		[integer!] 	; x distance between 2 dots
	dy		[integer!] 	; y distance between 2 dots
	op		[integer!]	; distance function
	p		[float!]	; power for Minkowski
	return: [float!]
	/local
	x1		[float!] 
	y1		[float!]
	x2		[float!] 
	y2		[float!]
	m1		[float!]
	m2		[float!]
	s		[float!]		
] [
	x1: as float! dx
	y1: as float! dy
	if x1 < 0.0 [x1: 0.0 - x1]
	if y1 < 0.0 [y1: 0.0 - y1]
	x2: x1 * x1
	y2: y1 * y1
	; for absolute distances
	switch op [
		1	[sqrt (x2 + y2)]				; euclidian
		2	[x1 + y1]						; manhattan
		3	[either (x1 > y1) [x1] [y1]]	; Chebyshev
		4	[m1: pow x1 p m2: pow y1 p
			 s: m1 + m2 pow s (1.0 / p)]	; Minkowsky
	]
]

; fractional distances
_rcvDotsFDistance: routine [
	dx1		[float!] 	; x1 - x2  distance
	dx2		[float!] 	; x1 + x2 distance 
	dy1		[float!] 	; y1 - y2 distance 
	dy2		[float!] 	; y1 + y2 distance 
	op		[integer!]	; distance op
	return: [float!]
	/local
	r
] [
	switch op [
		1 [r: (dx1 / dx2) + (dy1 / dy2)]; Camberra
		2 [r: (dx1 + dy1) / (dx2 + dy2)]; Sorensen
	]
	if r < 0.0 [r: 0.0 - r]
	r
]


_rcvDistance2Color: routine [
		dist 	[float!] 
		t 		[tuple!]
		/local
		r g b
		rf gf bf
		arr1
][
	r: t/array1 and FFh 
	g: t/array1 and FF00h >> 8 
	b: t/array1 and 00FF0000h >> 16 
	rf: as integer! (dist * r)
	gf: as integer! (dist * g)
	bf: as integer! (dist * b)
	arr1: (bf << 16) or (gf << 8 ) or rf
	stack/set-last as red-value! tuple/push 3 arr1 0 0
]

_rcvVoronoiDiagram: routine [
	peaks	[block!]
	peaksC	[block!]
	img		[image!]
	param1	[logic!]
	param2	[integer!]
	param3	[float!]
	/local
	pix1 	[int-ptr!]
	idxim	[int-ptr!]
	pt		[int-ptr!]
	n 		[integer!]
	x 		[integer!]
	y 		[integer!]
	s		[integer!] 
	w		[integer!] 
	h		[integer!] 
	sMin	[integer!]
	handle1 [integer!]
	d 		[float!]
	dMin 	[float!]
	p		[red-pair!] 		
	bxy		[red-value!]
	bcl 	[red-value!]
	idxy	[red-value!]
	idxc	[red-value!]
][
	handle1: 0
	n: block/rs-length? peaks
	bxy: block/rs-head peaks
	bcl: block/rs-head peaksC
	pix1: image/acquire-buffer img :handle1
	w: IMAGE_WIDTH(img/size)
    h: IMAGE_HEIGHT(img/size)
	y: 0
	 while [y < h] [
    	x: 0
       	while [x < w ][
       		dMin: _rcvDotsDistance w h param2 param3
       		s: 0
       		;calculate distance 
       		while [s < n] [
       			idxy: bxy + s
       			p: as red-pair! idxy
       			d: _rcvDotsDistance p/x - x  p/y - y param2 param3
       			if d < dMin [
					sMin: s
					dMin: d
				]
				s: s + 1
       		]
       		idxc: bcl + sMin
			pt: as int-ptr! idxc		; get seed color (a tuple)
			idxim: pix1 + (y * w) + x
			idxim/value: (255 << 24) OR pt/1 OR pt/2 OR pt/3
       		x: x + 1
       	]
    y: y + 1
    ]
    
    if param1 = true [
    	s: 0 
    	while [s < n] [
    		idxy: bxy + s
       		p: as red-pair! idxy
       		;make a cross for better seed visualization
       		if all [p/x > 1 p/y > 1 p/x < (w - 1) p/y < (h - 1)][
       			idxim: pix1 + (p/y * w) + p/x
       			idxim/value: (255 << 24) OR (0 << 16 ) OR (0 << 8) OR 0
       			idxim: pix1 + (p/y * w) + p/x - 1
       			idxim/value: (255 << 24) OR (0 << 16 ) OR (0 << 8) OR 0
       			idxim: pix1 + (p/y * w) + p/x + 1
       			idxim/value: (255 << 24) OR (0 << 16 ) OR (0 << 8) OR 0
       			idxim: pix1 + (p/y - 1 * w) + p/x
       			idxim/value: (255 << 24) OR (0 << 16 ) OR (0 << 8) OR 0
       			idxim: pix1 + (p/y + 1 * w) + p/x
       			idxim/value: (255 << 24) OR (0 << 16 ) OR (0 << 8) OR 0
       		]
       		s: s + 1
    	]
    ]
	image/release-buffer img handle1 yes
]



_rcvDistanceDiagram: routine [
	peaks	[block!]
	peaksC	[block!]
	img		[image!]
	param1	[logic!]
	param2	[integer!]
	param3	[float!]
	/local
	pix1 	[int-ptr!]
	idxim	[int-ptr!]
	n 		[integer!]
	x 		[integer!]
	y 		[integer!]
	s		[integer!] 
	w		[integer!] 
	h		[integer!] 
	sMin	[integer!]
	handle1 [integer!]
	d 		[float!]
	dMin 	[float!]
	dMax	[float!]
	p		[red-pair!] 		
	bxy		[red-value!]
	idxy	[red-value!]
	bcl 	[red-value!]
	idxc	[red-value!]	
	r 		[integer!]
	g 		[integer!]
	b		[integer!]
	dr 		[integer!]
	dg 		[integer!]
	db		[integer!]
	t		[red-tuple!]
][
	handle1: 0
	n: block/rs-length? peaks
	bxy: block/rs-head peaks
	bcl: block/rs-head peaksC
	pix1: image/acquire-buffer img :handle1
	w: IMAGE_WIDTH(img/size)
    h: IMAGE_HEIGHT(img/size)
	y: 0
	 while [y < h] [
    	x: 0
       	while [x < w ][
       		;calculate distance 
       		dMax: 0.1 * _rcvDotsDistance w h param2 param3 
       		dMin: 0.1 * _rcvDotsDistance w h param2 param3
       		s: 0
       		while [s < n] [
       			idxy: bxy + s
       			p: as red-pair! idxy
       			d: (_rcvDotsDistance p/x - x  p/y - y param2 param3) / dMax
       			if d < dMin [
					sMin: s
					dMin: d
				]
				s: s + 1
       		]
       		d: 1.0 - dMin * 0.75
       		if d < 0.0 [d: 0.0]
       		idxc: bcl + sMin		
			t: as red-tuple! idxc		; get seed color (a tuple)
			r: t/array1 and 00FF0000h >> 16
			g: t/array1 and FF00h >> 8 
			b: t/array1 and FFh 
			dr: as integer! (d * r)
			dg: as integer! (d * g)
			db: as integer! (d * b)
			idxim: pix1 + (y * w) + x
			idxim/value: (255 << 24) OR (dr << 16 ) OR (dg << 8) OR db
       		x: x + 1
       	]
    y: y + 1
    ]
    ; show seeds if required
    if param1 [
    	s: 0 
    	while [s < n] [
    		idxy: bxy + s
       		p: as red-pair! idxy
       		;make a cross for better seed visualization
       		if all [p/x > 1 p/y > 1 p/x < (w - 1) p/y < (h - 1)][
       			idxim: pix1 + (p/y * w) + p/x
       			idxim/value: (255 << 24) OR (255 << 16 ) OR (255 << 8) OR 255
       			idxim: pix1 + (p/y * w) + p/x - 1
       			idxim/value: (255 << 24) OR (255 << 16 ) OR (255 << 8) OR 255
       			idxim: pix1 + (p/y * w) + p/x + 1
       			idxim/value: (255 << 24) OR (255 << 16 ) OR (255 << 8) OR 255
       			idxim: pix1 + (p/y - 1 * w) + p/x
       			idxim/value: (255 << 24) OR (255 << 16 ) OR (255 << 8) OR 255
       			idxim: pix1 + (p/y + 1 * w) + p/x
       			idxim/value: (255 << 24) OR (255 << 16 ) OR (255 << 8) OR 255
       		]
       		s: s + 1
    	]
    ]
    
	image/release-buffer img handle1 yes
]


_nearest: routine [
	pt	 		[vector!] 
	centroid 	[block!] 
	op			[integer!] 
	return: 	[float!]
	/local
	bcvalue		[red-value!]
	vvalue		[byte-ptr!]
	pvalue		[byte-ptr!]
	vectBlk		[red-vector!]
	nCluster	[integer!]
	unit		[integer!]
    i			[integer!]
    j			[integer!]
    min_d		[float!]
    min_i		[float!]
    cx 			[float!]
    cy 			[float!]
    cg			[float!]
    px			[float!] 
    py 			[float!]
    pg			[float!]
    x			[float!]
    y			[float!] 
    d			[float!]
    r			[float!]
] [
"Distance and index of the closest cluster center."
	min_d: 1E100
	min_i: 0.0
	bcvalue: block/rs-head centroid
	nCluster: block/rs-length? centroid
	vectBlk: as red-vector! bcvalue
	pvalue: vector/rs-head pt 
	unit: _rcvGetMatBitSize vectBlk
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
	    d: _rcvDotsDistance x y 6 0.0 ; Squared Euclidian
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
_kpp: routine [
	points 		[block!] ;array
	centroid 	[block!] ;array
	tmpblk		[block!] ;simple block for sum
	/local
	bcvalue		[red-value!]
	bpvalue		[red-value!]
	btvalue		[red-value!]
	cvectBlk	[red-vector!]
	pvectBlk	[red-vector!]
	cvvalue		[byte-ptr!]
	pvvalue		[byte-ptr!]	
	p			[int-ptr!]
	ptrc		[float-ptr!]
	ptrp		[float-ptr!]
	unit		[integer!]
	d			[float!]
	sum			[float!]
	i			[integer!]
	j			[integer!]
	k			[integer!]
	nCluster	[integer!]
	len			[integer!]
	dd
][
	bcvalue: block/rs-head centroid
	bpvalue: block/rs-head points
	btvalue: block/rs-head tmpblk
	cvectBlk: as red-vector! bcvalue
	pvectBlk: as red-vector! bpvalue
	unit: _rcvGetMatBitSize pvectBlk
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
			d:  _nearest pvectBlk centroid 2 ; distance
			dd: as int64! :d
			sum: sum + d
			;integer/make-in tmpblk as integer! sum
			float/make-in tmpblk dd/int1 dd/int2
			bpvalue: bpvalue + 1
			j: j + 1
		]
		sum: randf(sum)
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
				;d:  _nearest pvectBlk centroid 1 ; index
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
		d:  _nearest pvectBlk centroid 1 ; index
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

_lloyd: routine [
	points 		[block!] 
	centroid 	[block!]
	/local
	bcvalue		[red-value!]
	bpvalue		[red-value!]
	cvectBlk	[red-vector!]
	pvectBlk	[red-vector!]
	cvvalue		[byte-ptr!]
	pvvalue		[byte-ptr!]	
	f			[float-ptr!]
	lenpts10	[integer!]
	changed		[integer!]
	i			[integer!]
	j			[integer!]
	idx			[integer!]
	unit		[integer!]
	len			[integer!]
	nCluster	[integer!]
	cx 			[float!]
    cy 			[float!]
    cg			[float!]
    px			[float!] 
    py 			[float!]
    pg			[float!]
    min_I
][
	bcvalue: block/rs-head centroid
	nCluster: block/rs-length? centroid
	bpvalue: block/rs-head points
	pvectBlk: as red-vector! bpvalue
	len: block/rs-length? points
	unit: _rcvGetMatBitSize pvectBlk
	
	lenpts10: len >> 10
	changed: 0
	;Find clusters centroids
	until [
		_genCentroid centroid
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
			
			min_I: _nearest pvectBlk centroid 1
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



