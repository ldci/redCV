Red [
	Title:   "Red Computer Vision: Haar Casacade"
	Author:  "Francois Jouen"
	File: 	 %rcvHaarCascade.red
	Tabs:	 4
	Rights:  "Copyright (C) 2020 Red Foundation. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

rcvEvalWeakClassifier: routine [
"Compute each weak classifier value"
	variance			[float!]
	pOffset				[integer!]
	treeIndex			[integer!]
	wIndex				[integer!]
	rIndex				[integer!]
	return:				[float!]
	/local
	ptr	overflow				[int-ptr!]
	sigma weight t				[float!]
	idx a b c d	area			[integer!]
	hasLeft? hasRight? tt		[integer!]
	leftNode rightNode v1 v2	[float!]
][
	;--the node threshold is multiplied by the standard deviation of the image
	tt: tarray/(treeIndex)
	t: as float! tt * variance  
	
	;--for pointer error in large images
	overflow: ssum/data + (ssum/width * ssum/height)
	; srarray: array of addresses!!
	
	; compute rectangles sigma from integral image values
	;first rectangle
	idx: rIndex + 0 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [a: ptr/value] [a: overflow/value]
	idx: rIndex + 1 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [b: ptr/value] [b: overflow/value]
	idx: rIndex + 2 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [c: ptr/value] [c: overflow/value]
	idx: rIndex + 3 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [d: ptr/value] [d: overflow/value]
	weight: warray/wIndex
	area: a - b - c + d
	sigma: weight * as float! (area)
	
	; second rectangle
	idx: rIndex + 4 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [a: ptr/value] [a: overflow/value]
	idx: rIndex + 5 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [b: ptr/value] [b: overflow/value]
	idx: rIndex + 6 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [c: ptr/value] [c: overflow/value]
	idx: rIndex + 7 ptr: as int-ptr! srarray/idx
	ptr: ptr + pOffset either ptr < overflow [d: ptr/value] [d: overflow/value]
	wIndex: wIndex + 1
	weight: warray/wIndex
	area: a - b - c + d
	sigma: sigma + (weight * as float! (area))
	
	;third rectangle 
	idx: rIndex + 8
	ptr: as int-ptr! (srarray/idx)
	if (as integer! ptr) > 0 [
		idx: rIndex + 8  ptr: as int-ptr! srarray/idx 
		ptr: ptr + pOffset either ptr < overflow [a: ptr/value] [a: overflow/value]
		idx: rIndex + 9  ptr: as int-ptr! srarray/idx 
		ptr: ptr + pOffset either ptr < overflow [b: ptr/value] [b: overflow/value]
		idx: rIndex + 10 ptr: as int-ptr! srarray/idx 
		ptr: ptr + pOffset either ptr < overflow [c: ptr/value] [c: overflow/value]
		idx: rIndex + 11 ptr: as int-ptr! srarray/idx 
		ptr: ptr + pOffset either ptr < overflow [d: ptr/value] [d: overflow/value]
		wIndex: wIndex + 1
		weight: warray/wIndex
		area: a - b - c + d
		sigma: sigma + (weight * as float! (area))
	]
	
	;--go to left or  right according node threshold value
	;--and return weak classifier value according to the decision about sigma
	
	
	;--we need a default value, but in all cases v1 or v2 are returned 
	0.0
]