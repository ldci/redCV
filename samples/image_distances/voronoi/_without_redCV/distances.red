Red [
]

; new routines and functions to be included in redCV

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



;=num^(1/n) pour calculer la nieme racine de num

rcvNSquareRoot: function [num [number!] nroot [number!] return: [float!]
"Returns nth root of Num"
][
	num ** (1.0 / nroot)
]

;new version
rcvGetEuclidianDistance: function [a [pair!] b [pair!] return: [float!]
"Gets Euclidian distance between 2 points"
][
	dxy: b - a
	_rcvDotsDistance dxy/x dxy/y 1 0
]

rcvGetManhattanDistance: function [a [pair!] b [pair!] return: [float!]
"Gets Manhattan distance between 2 points"
][
	dxy: absolute b - a
	_rcvDotsDistance dxy/x dxy/y 2 0
]

rcvGetChebyshevDistance: function [a [pair!] b [pair!] return: [float!]
"Gets Chebyshev distance between 2 points"
][
	dxy: absolute b - a
	_rcvDotsDistance dxy/x dxy/y 3 0
]

rcvGetMinkowskiDistance: function [a [pair!] b [pair!] p [float!] return: [float!]
"Gets Minkowski distance between 2 points"
][
	dxy: absolute b - a
	if p = 0.0 [p: 2.0]	; euclidian by default
	_rcvDotsDistance dxy/x dxy/y 4 p
]


; fractional distances
rcvGetCamberraDistance: function [a [pair!] b [pair!] return: [float!]
"Gets Camberra distance between 2 points"
][
	dx1: to-float a/x - to-float b/x
	dx2: to-float a/x + to-float b/x
	dy1: to-float a/y - to-float b/y
	dy2: to-float a/y + to-float b/y
	_rcvDotsFDistance dx1 dx2 dy1 dy2 1
]

; Sorensen or Bray Curtis Distance
rcvGetSorensenDistance: function [a [pair!] b [pair!] return: [float!]
"Gets Sorensen or Bray Curtis distance between 2 points"
][
	dx1: to-float a/x - to-float b/x
	dx2: to-float a/x + to-float b/x
	dy1: to-float a/y - to-float b/y
	dy2: to-float a/y + to-float b/y
	_rcvDotsFDistance dx1 dx2 dy1 dy2 2
]

rcvDistance2Color: function [dist [float!] t [tuple!] return: [tuple!]
"Returns tuple value modified by distance"
][
	_rcvDistance2Color dist t
]

rcvVoronoiDiagram: function [peaks [block!] peaksC [block!] img [image!] param1 [logic!]
param2 [integer!] param3 [float!]
"Creates Voronoï diagram"
][
	_rcvVoronoiDiagram peaks peaksC img param1 param2 param3
]

rcvDistanceDiagram: function [peaks [block!] peaksC [block!] img [image!] param1 [logic!]
param2 [integer!] param3 [float!]
"Creates Distance diagram"
][
	_rcvDistanceDiagram peaks peaksC img param1 param2 param3
]



;*************** TESTS *****************

p1: 1x1
p2: 5x5
d1: rcvGetEuclidianDistance  p1 p2		; OK
d2: rcvGetManhattanDistance  p1 p2		; 0K
d3: rcvGetChebyshevDistance	 p1 p2	 	; OK
d4: rcvGetMinkowskiDistance  p1 p2 1.0 	; OK same as Manhattan
d5: rcvGetMinkowskiDistance  p1 p2 2.0 	; OK same as euclidian
d6: rcvGetMinkowskiDistance  p1 p2 3.0 	; OK 
d7: rcvGetCamberraDistance 	 p1 p2	 	; OK 1.333
d8: rcvGetSorensenDistance 	 p1 p2	 	; OK 0.666
d9: rcvDistance2Color 0.1 254.210.128
print "Distance tests"
print ["A: " p1 "B: " p2]
print ["Euclidian: " d1]
print ["Manhattan: " d2]
print ["Chebyshev: " d3]
print ["Minkowski p=1: " d4]
print ["Minkowski p=1: " d5]
print ["Minkowski p=3: " d6]
print ["Camberra: " d7] 
print ["Sorensen: " d8]
print ["Distance 2 color 0.1 254.210.128 : " d9]
print [rcvNSquareRoot 2 3]



