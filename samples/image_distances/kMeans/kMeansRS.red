Red [
	Title:   "Red Computer Vision: K Means"
	Author:  "Francois Jouen"
	File: 	 %kmeans.red
	Tabs:	 4
	Rights:  "Copyright (C) 2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
	Needs:	 View
]


; ces fonctions sont dans la lib redCV
minInt: routine [
	a 		[integer!] 
	b 		[integer!]
	return: [integer!]
][ 
	either (a < b) [a] [b]
]


maxInt: routine [
	a 		[integer!] 
	b 		[integer!]
	return: [integer!]
][ 
	either (a > b) [a] [b]
]

randf: routine [m [float!]return: [float!]][
	(m * as float! _random/rand) / 2147483647.0 - 1.0
]


;Some variables we need

size: 400x400	
map1: make image! reduce [size black]
map2: make image! reduce [size black]

PTS: 5000; 100000
radius: 5.0

K: 7
points: copy []
plot: copy []
centroid: copy []


initData: function [count [integer!] return: [block!]][
	blk: copy []
	i: 0
	while [i < count] [
		append blk make vector! [float! 64 [0.0 0.0 0.0]]
		i: i + 1
	]
	blk
]

genCentroid: routine [
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
	unit: 8
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
				j = 2 [p/value: as float! i] ; [0..k -1]
			]
			vvalue: vvalue + unit
			j: j + 1
		]
    	bvalue: bvalue + 1
    	i: i + 1
    ] 
]

genXY: routine [
		array	[block!]	; array type
		radius 	[float!] 
		/local
		bvalue 	[red-value!] 
   		p		[float-ptr!]
    	vectBlk	[red-vector!]
    	vvalue	[byte-ptr!] 
    	len		[integer!]
    	i		[integer!]
    	j		[integer!]
    	unit	[integer!]
		ang		[float!] 
		r		[float!]
		
][
	;Generate random data points
	bvalue: block/rs-head array
	len:  block/rs-length? array
	vectBlk: as red-vector! bvalue
	unit: 8
	;note: this is not a really uniform 2-d distribution
	i: 0
    while [i < len][
    	vectBlk: as red-vector! bvalue	;3 values in vectBlk
    	vvalue: vector/rs-head vectBlk
    	ang: randf 2.0 * pi
		r: randf radius
		j: 0
		while [j < 3] [
			p: as float-ptr! vvalue
			case [
				j = 0 [p/value: r * cos ang]
				j = 1 [p/value: r * sin ang]
				j = 2 [p/value: 0.0]
			]
			vvalue: vvalue + unit
			j: j + 1
		]
    	bvalue: bvalue + 1
    	i: i + 1
    ] 
]


nearest: routine [
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
	unit: 8
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
		d: (x * x) + (y * y)
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

; first initialization
kpp: routine [
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
	unit: 8;_rcvGetMatBitSize pvectBlk
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
			d: nearest pvectBlk centroid 2 ; distance
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
				k: 0 
				while [k < 3] [
					ptrp: as float-ptr! pvvalue
					ptrc: as float-ptr! cvvalue
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
		; group index
		d: nearest pvectBlk centroid 1 ; index
		pvectBlk: as red-vector! bpvalue
		pvvalue: vector/rs-head pvectBlk
		k: 0 
		while [k < 3] [
			ptrp: as float-ptr! pvvalue
			if k = 2 [ptrp/value: d]
			pvvalue: pvvalue + unit
			k: k + 1
		]
		bpvalue: bpvalue + 1
		j: j + 1
	]
]


;Lloyd K-means Clustering with convergence
;group element for centroids are used as counters

lloyd: routine [
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
	cvectBlk: as red-vector! bcvalue
	nCluster: block/rs-length? centroid
	
	bpvalue: block/rs-head points
	pvectBlk: as red-vector! bpvalue
	len: block/rs-length? points
	
	unit: 8
	lenpts10: len >> 10
	changed: 0
	;Find clusters centroids
	until [
		genCentroid centroid
		bcvalue: block/rs-head centroid
		pvectBlk: as red-vector! bpvalue
		i: 0
		bpvalue: block/rs-head points
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
			
			;pg: between 0 and K - 1
			; select centroid (c: centroid/(p/group))
			idx: as integer! pg
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
			min_I: nearest pvectBlk centroid 1
			if min_I <> pg [
				changed: changed + 1
				f/value: min_I 
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


scalePoints: function [points [block!] return: [block!]][
	H: W: 400
	FLOAT_MAX: 1E100
	minX: FLOAT_MAX
	minY: FLOAT_MAX
	maxX: negate FLOAT_MAX
	maxY: negate FLOAT_MAX
	p: 0x0
	foreach v points [
		p/x: to-integer v/1
		p/y: to-integer v/2
		if (maxX < p/x) [maxX: p/x]
		if (minX > p/x) [minX: p/x]
		if (maxY < p/y) [maxY: p/y]
        if (minY > p/y) [minY: p/y]
    ]
    scale: min (W / (maxX - minX)) (H / (maxY - minY))
    cx: (maxX + minX) / 2.0
    cy: (maxY + minY) / 2.0
    reduce [cx cy scale]
]



showXY: function [points [block!]][
	H: W: 400
    pBlk: scalePoints Points
    cx: pBlk/1
    cy: pBlk/2
    scale: pBlk/3
    
    map1: make image! reduce [size black]
	color: red
	plot: compose [line-width 1 pen (color)  fill-pen (color)]
    
    p: 0x0
    foreach v points [   
    	color: random white
    	p/x: to-integer (v/1 - cx * scale + W) / 2
    	p/y: to-integer (v/2 - cy * scale + H) / 2
		append plot reduce ['pen color 'fill-pen color 'circle p 1.5] ;'
	]
	canvas/image: draw map1 plot
	canvas2/image/rgb: snow
	canvas2/text: "Processing ..."
	do-events/no-wait
]

showKmeans: function [points [block!] cent [block!]][
	H: W: 400
	nCluster: length? cent
	len: length?  points
	i: 1
	colors: copy []
	while [i <= nCluster][
		r: (3 * (i + 1) % 11) / 11.0
		g: (7 * i % 11) / 11.0
		b: (9 * i % 11) / 11.0
		t: make tuple! reduce [r * 255 g * 255 b * 255]
		append colors t
		i: i + 1
	]
    pBlk: scalePoints Points
    cx: pBlk/1
    cy: pBlk/2
    scale: pBlk/3
    
    map2: make image! reduce [size black]
    color: red
    plot: compose [line-width 1 pen (color)  fill-pen (color)]
    i: 0
    while [i < nCluster][
   		p: 0x0
    	j: 0
    	color: white
    	while [j < len] [
    		pt: points/(j + 1) 
    		p/x: to-integer (pt/1 - cx * scale + W) / 2
    		p/y: to-integer (pt/2 - cy * scale + H) / 2
    		c: to-integer pt/3 + 1 ; for 1-based access
    		color: colors/(c)
    		if c <> i [
    			append plot reduce ['pen color 'fill-pen color 'circle p 1.5] ;'
			]
			j: j + 1
		]
    	i: i + 1
    ]
    ;centroids
    i: 0
    while [i < nCluster] [
    	c: cent/(i + 1)
    	p/x: to-integer (c/1 - cx * scale + W) / 2 
    	p/y: to-integer (c/2 - cy * scale + H) / 2
    	color: yellow 
    	append plot reduce ['pen color 'fill-pen color 'circle p 3.0];'
    	if cb1/data  [
    		p/x: p/x + 3 
    		p/y: p/y - 8
    		append plot reduce ['text p form (i + 1)] ;'
    	]
    	i: i + 1
    ]
    canvas2/text: ""
    canvas2/image: draw map2 plot		
]


kMeans: does [
	random/seed now/time/precise
	clear f3/text
	points: initData  PTS					;create points
	genXY  points radius					;randomly values for points
	showXY points							;draw results
	tmpblk: copy []							;temporary block for sum calculation
	centroid: initData K					;create centroid
	t1: now/time/precise 					; time
	centroid/1: copy points/(random PTS)	;random center from points
	kpp points centroid tmpblk				;kpp init
	lloyd points centroid					;Lloyd K-means Clustering
	showKMeans points centroid 				;draw results
	t2: now/time/precise					;elapsed time
	f3/text: form t2 - t1
]


;******************** Main Program *********************************
view win: layout [
	title "K Means Red/System"
	text  "Number of points" 
	f1: field 70 	[if error? try [PTS: to-integer face/text] [PTS: 500 
					face/text: form PTS] if PTS > 1 [kMeans]]
	text "Number of clusters"
					
	f2: field 50	[if error? try [K: to-integer face/text] [K: 7 
					face/text: form K] if K > 0 [kMeans]]
	cb1: check "Show Labels" 
	button  "Compute" 	 [kMeans]
	pad 160x0
	button 50 "Quit"   	 [quit]
	return 
	canvas:  base size map1
	canvas2: base size map2 font-color red font-size 14
	return
	text 400 center "© Red Foundation 2019"
	f3: text 400 center
	
	do [f1/text: form PTS f2/text: form K cb1/data: true]
]