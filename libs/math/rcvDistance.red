Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvDistance.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;******************* absolute distances *****************************
;general routines for distance
_rcvDotsDistance: routine [
	dx		[float!] 	; x distance between 2 dots
	dy		[float!] 	; y distance between 2 dots
	op		[integer!]	; distance function
	p		[float!]	; power for Minkowski
	return: [float!]
	/local
		x2 y2 m1 m2 s	[float!] 	
][
	if dx < 0.0 [dx: 0.0 - dx]
	if dy < 0.0 [dy: 0.0 - dy]
	x2: dx * dx
	y2: dy * dy
	; for absolute distances
	switch op [
		1	[sqrt (x2 + y2)]				; Euclidian
		2	[dx + dy]						; Manhattan
		;3	[maxFloat dx dy]				
		3	[either (dx > dy) [dx] [dy]]	; Chessboard
		4	[m1: pow dx p m2: pow dy p
			 s: m1 + m2 pow s (1.0 / p)]	; Minkowsky
		5	[either (dx > dy) [dx] [dy]]	; Chebyshev
		6	[x2 + y2]						; D2 Euclidian 
	]
]

;******************* fractional distances ******************
_rcvDotsFDistance: routine [
	dx1		[float!] 	; x1 - x2  distance
	dx2		[float!] 	; x1 + x2 distance 
	dy1		[float!] 	; y1 - y2 distance 
	dy2		[float!] 	; y1 + y2 distance 
	op		[integer!]	; distance op
	return: [float!]
	/local
		r		[float!]
] [
	switch op [
		1 [r: (dx1 / dx2) + (dy1 / dy2)]; Camberra
		2 [r: (dx1 + dy1) / (dx2 + dy2)]; Sorensen
	]
	if r < 0.0 [r: 0.0 - r]
	r
]

; distance to color 
rcvDistance2Color: routine [
"Returns tuple value modified by distance"
		dist 	[float!] 
		t 		[tuple!]
		/local
			r g b rf gf bf arr1	[integer!]
][
	r: t/array1 and FFh 
	g: t/array1 and FF00h >> 8 
	b: t/array1 and 00FF0000h >> 16 
	rf: as integer! (dist * as float! r)
	gf: as integer! (dist * as float! g)
	bf: as integer! (dist * as float! b)
	arr1: (rf << 16) or (gf << 8 ) or bf
	stack/set-last as red-value! tuple/push 3 arr1 0 0
]



;general distances functions 
; Horizontal: 0° clockwise 

rcvDegree2xy: function [
"Returns XY coordinates from angle and distance between 2 points"
	radius [number!]	; distance
	angle  [number!]	; angle in degree
][
	as-pair (radius * cosine angle) (radius * sine angle) 
]

;new 
rcvRadian2xy: function [
"Returns XY coordinates from angle and distance between 2 points"
	radius 	[number!]	; distance
	angle 	[number!]	; angle in radian
][
	as-pair (radius * cos angle) (radius * sin angle) 
]


rcvGetEuclidianDistance: function [
"Gets Euclidian distance between 2 points"
	a [pair!] 
	b [pair!]
][
	dxy: b - a
	_rcvDotsDistance to-float dxy/x to-float dxy/y 1 0.0
]

rcvGetEuclidian2Distance: function [
"Gets Squared Euclidian distance between 2 points"
	a [pair!] 
	b [pair!]
][
	dxy: b - a
	_rcvDotsDistance to-float dxy/x to-float dxy/y 6 0.0
]

rcvGetManhattanDistance: function [
"Gets Manhattan distance between 2 points"
	a [pair!] 
	b [pair!]
][
	dxy: absolute b - a
	_rcvDotsDistance to-float dxy/x to-float dxy/y 2 0.0
]

rcvGetChessboardDistance: function [
"Gets Chessboard distance between 2 points"
	a [pair!] 
	b [pair!] 
][
	dxy: absolute b - a
	_rcvDotsDistance to-float dxy/x to-float dxy/y 3 0.0
]

rcvGetMinkowskiDistance: function [
"Gets Minkowski distance between 2 points"
	a [pair!] 
	b [pair!] 
	p [float!]
][
	dxy: absolute b - a
	if p = 0.0 [p: 2.0]	; euclidian by default
	_rcvDotsDistance to-float dxy/x to-float dxy/y 4 p
]

rcvGetChebyshevDistance: function [
"Gets Chebyshev distance between 2 points"
	a [pair!] 
	b [pair!]
][
	dxy: absolute b - a
	_rcvDotsDistance to-float dxy/x to-float dxy/y 5 0.0
]

; fractional distances
rcvGetCamberraDistance: function [
"Gets Camberra distance between 2 points"
	a [pair!] 
	b [pair!]
][
	dx1: to-float a/x - to-float b/x
	dx2: to-float a/x + to-float b/x
	dy1: to-float a/y - to-float b/y
	dy2: to-float a/y + to-float b/y
	_rcvDotsFDistance dx1 dx2 dy1 dy2 1
]

; Sorensen or Bray Curtis Distance
rcvGetSorensenDistance: function [
"Gets Sorensen or Bray Curtis distance between 2 points"
	a [pair!] 
	b [pair!]
][
	dx1: to-float a/x - to-float b/x
	dx2: to-float a/x + to-float b/x
	dy1: to-float a/y - to-float b/y
	dy2: to-float a/y + to-float b/y
	_rcvDotsFDistance dx1 dx2 dy1 dy2 2
]

rcvGetAngle: function [
"Gets angle in degrees from points coordinates"
	p 	[pair!] 
	cg 	[pair!]
][		
	rho: rcvGetEuclidianDistance p cg		; rho
	uY: to-float p/y - cg/y					; uY ->
	uX: to-float p/x - cg/x					; uX ->	
	costheta: uX / rho
	sinTheta: uY / rho
	tanTheta: costheta / sinTheta 
	theta: arccosine costheta
	if p/y > cg/y [theta: 360 - theta]
	theta
]

;needs a coordinate translation p - shape centroid
; angle * 180 / pi radian -> degrees
; angle * pi / 180 degree -> radian

rcvGetAngleRadian: function [
"Gets angle in radian "
	p [pair!]
][
	atan2 p/y p/x
]


rcvRhoNormalization: function [
"Returns normalized block [0.0..1.0] of rho values" 
	b [block!] 
][
 	tmpb: copy b
 	sort tmpb
 	maxRho: last tmpb
 	normf: 1.0 / maxRho
	tmpv: make vector! reduce b
	tmpv * normf
	to block! tmpv
]

;*************** Voronoï and Distance Diagrams *********

rcvVoronoiDiagram: routine [
"Creates Voronoï diagram"
	peaks	[block!]		; block of seed coordinates
	peaksC	[block!]		; colors as tuples
	img		[image!]		; image for rendering
	param1	[logic!]		; show seeds or not
	param2	[integer!]		; kind of distance
	param3	[float!]		; p value for Minkowski distance
	/local
		pix1 idxim pt				[int-ptr!]
		n x y s w h sMin handle1	[integer!]
		d dMin						[float!]
	 	p							[red-pair!] 		
		bxy bcl	idxy idxc			[red-value!]
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

;Based on Boleslav Březovský's sample
rcvDistanceDiagram: routine [
"Creates Distance diagram"
	peaks	[block!]		; block of seed coordinates
	peaksC	[block!]		; colors as tuples
	img		[image!]		; image for rendering
	param1	[logic!]		; show seeds or not	
	param2	[integer!]		; kind of distance
	param3	[float!]		; p value for Minkowski distance
	/local
		pix1 idxim					[int-ptr!]
		n x y w h s sMin handle1	[integer!]
		d dMin 	dMax				[float!]
	 	p							[red-pair!] 		
		bxy	idxy bcl idxc			[red-value!]	
		r g b dr dg db				[integer!]
		t							[red-tuple!]
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
       		dMax: 0.1 * _rcvDotsDistance (as float! w) (as float! h) param2 param3 
       		dMin: 0.1 * _rcvDotsDistance (as float! w) (as float! h) param2 param3
       		s: 0
       		while [s < n] [
       			idxy: bxy + s
       			p: as red-pair! idxy
       			d: _rcvDotsDistance (as float! p/x - x) (as float! p/y - y) param2 param3
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
			dr: as integer! (d * as float! r)
			dg: as integer! (d * as float! g)
			db: as integer! (d * as float! b)
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




	


