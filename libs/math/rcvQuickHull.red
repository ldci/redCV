Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvQuickHull.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

#include %../../libs/tools/rcvTools.red

{Quick Hull implementation
Based on Alexander Hristov's Java code
http://www.ahristov.com/tutorial/geometry-games/convex-hull.html}


{Vectors cross product: 3 points are a counter-clockwise turn if rcvCross > 0, 
clockwise if rcvCross < 0, and collinear if rcvCross = 0 because rcvCross is a determinant that
gives the signed area of the triangle formed by p1, p2 and p3}

rcvCross: routine [
	A 		[pair!] 
	B 		[pair!] 
	C 		[pair!]
	return: [integer!]
	/local
	cp1		[integer!]
][
	cp1: ((B/x - A/x) * (C/y - A/y)) - ((B/y - A/y) * (C/x - A/x))
	either (cp1 > 0) [1] [-1]
]


; Computes the square of the distance of point C to the segment defined by points AB
rcvPointDistance: routine [
"Square of the distance of point C to the segment defined by points AB"
	A 		[pair!] 
	B 		[pair!] 
	C 		[pair!] 
	return:	[integer!]
	/local
	ABx
	ABy
	num		[integer!]
][
	ABx: B/x - A/x
	ABy: B/Y - A/Y
	num: (ABx * (A/y - C/y)) - (ABy * (A/x - C/x))
	if num < 0 [num: 0 - num]
	num
]

; to be transformed into routines

rcvFindExtrema: function [
"Finds minimal and maximal coordinates"
	points [block!] 
][
	minPoint: 0x0
	maxPoint: 0x0
	minX: 32767
	maxX: 0
	n: length? points
	i: 1
	while [i <= n] [
		p: points/(i)
		if p/x < minX [minX: p/x minPoint: p]
		if p/x > maxX [maxX: p/x maxPoint: p]
		i: i + 1
	]
	make block! reduce [minPoint maxPoint]
]

rcvSeparateSets: function [
"Separates left and right set" 
	ptsBlock [block!]
][
	sBlock: copy ptsBlock
	nPoints: length? sBlock
	tmp: rcvFindExtrema ptsBlock
	leftSet: copy []
	rightSet: copy []
	i: 1
	while [i <= nPoints] [
		p: sBlock/(i)
		v: rcvCross tmp/1 tmp/2 p
		either (v = -1 ) [append leftSet p] [append rightSet p]
		i: i + 1
	]
	result: copy []
	append/only result leftSet
	append/only result rightSet
	result
] 

rcvHullSet: function [ 
	A 		[pair!] 
	B 		[pair!] 
	aSet 	[block!] 
	hull 	[block!]
][
	insertPos: index? find hull B
	n: length? aSet
	if n = 0 [exit]
	if n = 1 [
		p: aSet/1
		insert at hull insertPos p
		exit
	]
	dist: furthestPoint: 0
	i: 1
	while [i <= n ] [
		p: aSet/(i)
		distance: rcvPointDistance A B p
		if (distance > dist) [
			dist: distance
			furthestPoint: i
		]
		i: i + 1
	]
	p: aSet/(furthestPoint)
	insert at hull insertPos p
	
	n: length? aSet
	
	;Determine who's to the left of AP
	leftSetAP: copy []
	i: 1 
	while [i <= n] [
		m: aSet/(i)
		if ((rcvCross A p m) = 1) [
			append leftSetAP m
		]
		i: i + 1
	]
	;Determine who's to the left of PB
	leftSetPB: copy []
	i: 1
	while [i <= n] [
		m: aSet/(i)
		if ( (rcvCross p B m) = 1) [
			append leftSetPB m
		]
		i: i + 1
	]
	rcvHullSet A P leftSetAP hull
    rcvHullSet P B leftSetPB hull	
]

rcvQuickHull: function [
"Finds the convex hull of a point set. Uses flag for orientation (cw/ccw) of convex hull"
	points [block!] 
	/cw/ccw
][
	convexHull: copy []
	extrema: rcvFindExtrema points
	minP: first extrema
	maxP: second extrema
	append convexHull minP
	append convexHull maxP
	sets: rcvSeparateSets points
	left: first sets
	right: second sets
	; some pbs if set = 0 TBC
	if error? try [
			rcvHullSet minP maxP right convexHull
			rcvHullSet maxP minP left  convexHull] 
		[remove at convexHull 1] 
 	 either cw [reverse convexHull] [convexHull]
]

rcvContourArea: function [
"Calculates the area of convex polygon"
	hull [block!] 
	/signed
] [
	b: copy hull
	n: length? b
	firstCoord: first b
	append b firstCoord
	sum1: 0
	sum2: 0
	i: 1
	while [i <= n] [
		sum1: sum1 + (b/(i)/x * b/(i + 1)/y)
		sum2: sum2 + (b/(i)/y * b/(i + 1)/x)
	i: i + 1
	]
	either signed [(sum1 - sum2) / 2.0] [absolute (sum1 - sum2) / 2.0]
]

;--new

rcvRayTracing: routine [
"Determine if a point is inside a given polygon or not"
	poly 	[block!] ;--block of pair 
	coord	[pair!]	 ;--tested point
	return: [logic!]
	/local
	i n x y	xinters	[integer!] 	
	p1x p1y p2x p2y [integer!]
	bxy	idxy		[red-value!]
	p				[red-pair!] 
	inside			[logic!]
		
][
	n: block/rs-length? poly
	bxy: block/rs-head poly
	p: as red-pair! bxy
	p1x: p/x p1y: p/y
	x: coord/x
	y: coord/y
	inside: false
	i: 1
	while [i < n] [
		idxy: bxy + i
		p: as red-pair! idxy
		p2x: p/x p2y: p/y
		if y > minInt  p1y p2y [
			if y <= maxInt p1y p2y [
				if x <= maxInt p1x p2x [
					if p1y <> p2y [xinters: (y - p1y) * (p2x - p1x) / (p2y - p1y) + p1x]
					if (p1x = p2x) or (x <= xinters) [inside: not inside]
				]
			]
		]
		p1x: p2x p1y: p2y
		i: i + 1
	]
	inside 
]

