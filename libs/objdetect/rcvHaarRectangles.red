Red [
	Title:   "Red Computer Vision: Haar Casacade"
	Author:  "Francois Jouen"
	File: 	 %rcvHaarRectangles.red
	Tabs:	 4
	Rights:  "Copyright (C) 2020 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]
;--functions for classifcation
;--All these functions give the expected result!
;--probably to be transformed to routines, but Red is fast with vector! type

;--To be moved to rcvTools.red
rcvRoundInt: func [
	f 		[float!]
	return: [integer!]
][
    either f > 0.0 [to-integer (f + 0.5)] [to-integer (f - 0.5)] 
]

rcvPredicate: func [
"Rectangle clustering"
	eps		[float!]
	r1		[vector!]
	r2		[vector!]
	return:	[logic!]
][
	delta: eps * ((min r1/3 r2/3) + (min r1/4 r2/4)) * 0.5
	either all [
		(absolute r1/1 - r2/1) <= delta
		(absolute r1/2 - r2/2) <= delta
		(absolute r1/1 + r1/3 - r2/1 - r2/3) <= delta
		(absolute r1/2 + r1/4 - r2/2 - r2/4) <= delta
	] [return true] [return false]
]

rcvPartition: func [
"Return the number of classes"
	array	[block!] ;--array of rectangles as vector!
	labels	[block!] ;--classes label 
	eps		[float!] ;--threshold value
][
	n: 			length? array
  	rank1: 		0
  	rank2: 		0
  	nodes: 		copy []
  	;--The first pass: create N single-vertex trees
  	repeat i n [
  		blk: copy [-1 0]
  		append/only nodes blk
  	]
  	
  	;--The second pass: merge connected components
  	i: 1
  	repeat i n [
  		root1: i
  		;find root1
  		while [nodes/(root1)/1 >= 0] [root1: nodes/(root1)/1]
  		j: 1 
      	repeat j n [
      		pred: rcvPredicate eps array/(i) array/(j)
      		if any [i == j not pred ][continue]
      		root2: j
      		while [nodes/(root2)/1 >= 0] [root2: nodes/(root2)/1]
      		if root2 <> root1 [ 
      			rank1: nodes/(root1)/2
      			rank2: nodes/(root2)/2
      			either rank1 > rank2 [nodes/(root2)/1: root1][
      				nodes/(root1)/1: root2
      				if rank1 == rank2 [
      					nodes/(root2)/2: nodes/(root2)/2 + rank1
      				]
      				root1: root2
      			]
      			;--compress the path from node2 to root1 
      			k: j
      			while [(parent: nodes/(k)/1) >= 0][
      				nodes/(k)/1: root1
      				k: parent 
      			]
      			;--compress the path from node1 to root1 
	      		k: i
      			while [(parent: nodes/(k)/1) >= 0][
      				nodes/(k)/1: root1
      				k: parent 
      			]
      		];--end if
      		j: j + 1
      	];--end j loop
  		i: i + 1
  	];--end loop i
  	;--The final pass: enumerate classes in labels
  	nclasses: 0
  	i: 1 
  	repeat i n [
  		root1: i
  		while [nodes/(root1)/1 >= 0] [root1: nodes/(root1)/1]
  		;--re-use the rank1 as the class label
  		if nodes/(root1)/2 >= 0 [
  			nclasses: nclasses + 1
  			nodes/(root1)/2: complement nclasses
  		]
  		append labels complement nodes/(root1)/2
  	]
  	;--returned value: total number of classes
  	nclasses
]


rcvGroupRectangles: func [
"Group candidate by classes"
	array			[block!] 	; array of rectangles as vector!
	labels			[block!]	; for classes labels	
	groupThreshold	[integer!]
	eps				[float!]
][
	n: length? array
	if any [groupThreshold <= 0  n = 0] [return []]
	nclasses: rcvPartition array labels eps 
	nlabels: length? labels
	rrects: copy []
	loop nclasses [
		append/only rrects make vector! [0 0 0 0]
	]
	
	rweights: copy []
	loop nclasses [append rweights 0]
	
	i: 1
	repeat i nlabels [
		cls: labels/(i)						;--class number (1..nclasses)
		r1: rrects/(cls)					;--process rectangles
		r2: array/(i)						;--process rectangles
		rrects/(cls): r1 + r2				;--process rectangles
		rweights/(cls): rweights/(cls) + 1	;--class weight 
	]
	
	i: 1
	repeat i nclasses [
		r1: rrects/(i)
		s: 1.0 / rweights/(i)
		r1/1:  rcvRoundInt r1/1 * s
		r1/2:  rcvRoundInt r1/2 * s
		r1/3:  rcvRoundInt r1/3 * s
		r1/4:  rcvRoundInt r1/4 * s
		rrects/(i): r1				;--compute rectangle values as a function od weight
	]
	
	clear array						; clear orginal array and replace by new values
	i: 1
	repeat i nclasses [
		r1: rrects/(i)
		n1: rweights/(i)
		if n1 < groupThreshold [continue]
		;--filter out small face rectangles inside large rectangles
		j: 1
		repeat j nclasses [
			n2: rweights/(j)
			;--if it is the same rectangle, 
	   		;--or the number of rectangles in class j is < group threshold, 
	   		;--do nothing 
	   		
			if any [j = i n2 <= groupThreshold] [continue]
			r2: rrects/(j)
			dx: to-integer r2/3 * eps			;--calculate delta X
			dy: to-integer r2/4 * eps			;--calculate delta Y
			t: (n2 > max 3 n1) OR (n1 < 3)
			if all [
				t
				i <> j 
				r1/1 >= (r2/1 - dx)
				r1/2 >= (r2/2 - dy)
				(r1/1 + r1/3) <= (r2/1 + r2/3 + dx)
				(r1/2 + r1/4) <= (r2/2 + r2/4 + dy)
			] [break]
		]
		if j = nclasses [append array r1]		;--store the new value of class rectangle
	]
	array
]
