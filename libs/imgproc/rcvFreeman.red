Red [
	Title:   "Red Computer Vision: Matrix functions"
	Author:  "Francois Jouen"
	File: 	 %rcvFreeman.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2020 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;#include %../matrix/matrix-as-obj/matrix-obj.red		;--for stand alone test
;#include %../matrix/matrix-as-obj/routines-obj.red 	;--for stand alone test

; by columns
rcvMatleftPixel: routine [
"Gets coordinates of first left pixel"
	mx 		[object!] 
	value 	[integer!] 
	/local
		vec				[red-vector!]
		matHead			[byte-ptr!]
		flag			[logic!]
		pixel			[red-pair!]
		unit v x y pos	[integer!]
][
	unit: mat/get-unit mx
    vec: mat/get-data mx
	matHead: vector/rs-head vec ; get pointer address of the matrice
	pixel: pair/make-at stack/push* 0 0
	flag: false
	x: 0
	while [x < mat/get-cols mx][
		y: 0
		while [y < mat/get-rows mx] [
			pos: (y * (mat/get-cols mx) + x) * unit
			v: vector/get-value-int as int-ptr! matHead + pos unit
			if (v = value) and (not flag) [
				pixel/x: x
				pixel/y: y
				flag: true
			]
			y: y + 1
		]
		x: x + 1
	]
	as red-pair! stack/set-last as cell! pixel
]


; by columns
rcvMatRightPixel: routine [
"Gets coordinates of first right pixel"
	mx 		[object!] 
	value 	[integer!] 
	/local
		vec				[red-vector!]
		matHead			[byte-ptr!]
		flag			[logic!]
		pixel			[red-pair!]
		unit v x y pos	[integer!]
][
	unit: mat/get-unit mx
    vec: mat/get-data mx
	matHead:  vector/rs-head vec ; get pointer address of the matrice
	pixel: pair/make-at stack/push* 0 0
	flag: false
	x: (mat/get-cols mx) - 1
	while [x >= 0][
		y: (mat/get-rows mx) - 1
		while [y >= 0] [
			pos: (x + (y * mat/get-cols mx)) * unit
			v: vector/get-value-int as int-ptr! matHead + pos unit
			if (v = value) and (not flag) [
				pixel/x: x
				pixel/y: y
				flag: true
			]
			y: y - 1
		]
		x: x - 1
	]
	as red-pair! stack/set-last as cell! pixel
]


;by lines
rcvMatUpPixel: routine [
"Gets coordinates of first top pixel"
	mx	 	[object!] 
	value 	[integer!] 
	/local
		vec				[red-vector!]
		matHead			[byte-ptr!]
		flag			[logic!]
		pixel			[red-pair!]
		unit v x y pos 	[integer!]
][
	unit: mat/get-unit mx
    vec: mat/get-data mx
	matHead: vector/rs-head vec ; get pointer address of the matrice
	pixel: pair/make-at stack/push* 0 0
	flag: false
	y: 0
	while [y < mat/get-rows mx][
		x: 0
		while [x < mat/get-cols mx] [
			pos: (x + (y * mat/get-cols mx)) * unit
			v: vector/get-value-int as int-ptr! matHead + pos unit
			if (v = value) and (not flag) [
				pixel/x: x
				pixel/y: y
				flag: true
			]
			x: x + 1
		]
		y: y + 1
	]
	as red-pair! stack/set-last as cell! pixel
]

;by lines
rcvMatDownPixel: routine [
"Gets coordinates of first bottom pixel"
	mx	 	[object!]  
	value 	[integer!] 
	/local
		vec				[red-vector!]
		matHead			[byte-ptr!]
		flag			[logic!]
		pixel			[red-pair!]
		unit v x y pos	[integer!]
][
	unit: mat/get-unit mx
    vec:  mat/get-data mx
	matHead: vector/rs-head vec ; get pointer address of the matrice
	pixel: pair/make-at stack/push* 0 0
	flag: false
	y: (mat/get-rows mx) - 1
	while [y >= 0][
		x: (mat/get-cols mx) - 1
		while [x >= 0] [
			pos: (x + (y * mat/get-cols mx)) * unit
			v: vector/get-value-int as int-ptr! matHead + pos unit
			if (v = value) and (not flag) [
				pixel/x: x
				pixel/y: y
				flag: true
			]
			x: x - 1
		]
	y: y - 1
	]
	as red-pair! stack/set-last as cell! pixel
]

rcvBorderPixel: routine [
	mx	 	[object!] 
	x 		[integer!]
	y 		[integer!]
	value 	[integer!]
	return: [logic!]
	/local
		vec					[red-vector!]
		matHead				[byte-ptr!]
		unit v vbg pos w h	[integer!]
][
	w:  mat/get-cols mx
	h:  mat/get-rows mx
	unit: mat/get-unit mx
    vec:  mat/get-data mx
	matHead: vector/rs-head vec ; get pointer address of the matrice
	;only check background pixels (white or black)
	if value = 1 	[vbg: 0]
	if value = 255	[vbg: 0]
	if value =  0 	[vbg: 1]
		
	pos: y * w + x * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = vbg [return false] 
	
	;check left (west)
	if x = 0 [return true] ; image border = shape border
	if x > 0 [
		pos: y * w  + x - 1 * unit
		v: vector/get-value-int as int-ptr! matHead + pos unit
		if v = vbg [return true]
	]
	
	;check up (north)
	if y = 0 [return true]
	if y > 0 [
		pos: y - 1 * w + x * unit
		v: vector/get-value-int as int-ptr! matHead + pos unit
		if v = vbg [return true]
	]
	
	;check right (east)
    if x = w [return true]
    if x < w [
    	pos: y * w + x + 1 * unit
    	v: vector/get-value-int as int-ptr! matHead + pos unit
    	if v = vbg [return true]
    ]
    
     ;check down (south)
    if y = w [return true]
    if y < w [
    	pos: y + 1 * w + x * unit
    	v: vector/get-value-int as int-ptr! matHead + pos unit
    	if v = vbg [return true]
    ]
	;no empty pixel around = not border pixel
	return false
]

rcvMatGetBorder: routine [
"Gets pixels that belong to shape border"
	mx 		[object!] 
	value 	[integer!]
	border 	[block!]
	/local
		vec					[red-vector!]
		matHead				[byte-ptr!]
		unit pos x y w h v 	[integer!]
][
	w:  mat/get-cols mx
	h:  mat/get-rows mx
	unit: mat/get-unit mx
    vec:  mat/get-data mx
	matHead:  vector/rs-head vec ; get pointer address of the matrice
	block/rs-clear border
	y: 0
	while [y < h][
		x: 0
		while [x < w] [
			v: vector/get-value-int as int-ptr! matHead unit
			if v = value [
				;if a neighbor of a pixel belongs to background
				;that pixel belongs to the border of the shape 
				if rcvBorderPixel mx x y value [
					pair/make-in border x y
				]
			]
			mathead: mathead + unit
			x: x + 1
		]
		y: y + 1
	]
]

rcvBorderNeighbors: routine [
"Gets next contour pixel direction"
	mx 		[object!] 
	x 		[integer!]
	y 		[integer!]
	value 	[integer!]
	return:	[integer!]
	/local
		vec				[red-vector!]
		matHead			[byte-ptr!]
		s				[series!]
		unit v w pos	[integer!]
][
	w:  mat/get-cols mx
	unit: mat/get-unit mx
    vec:  mat/get-data mx
	matHead: vector/rs-head vec ; get pointer address of the matrice
	
	; check east (0)
	pos: y * w + x + 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = value [return 0]
	
	;check southeast (1)
	pos: y + 1 * w + x + 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = value [return 1]
	
	;check south (2)
	pos: y + 1 * w + x * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = value [return 2]
	
	;check southwest (3)
	pos: y + 1 * w + x - 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = value [return 3]
	
	;check west (4)
	pos: y * w + x - 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = value [return 4]
	
	;check northwest (5)
	pos: y - 1 * w + x - 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = value [return 5]
	
	;check north (6)
	pos: y - 1 * w + x * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = value [return 6]
	
	;check northeast (7)
	pos: y - 1 * w + x + 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = value [return 7]
	return -1
]

rcvMatGetChainCode: routine [
"Gets next contour pixel direction"
	mx 		[object!] 
	coord	[pair!]
	value 	[integer!]
	return:	[integer!]
	/local
		vec					[red-vector!]
		matHead				[byte-ptr!]
		unit v pos x y w	[integer!]
][
	x: coord/x
	y: coord/y
	w:  mat/get-cols mx
	unit: mat/get-unit mx
    vec:  mat/get-data mx
	matHead: vector/rs-head vec ; get pointer address of the matrice
	; check east (0)
	pos: y * w + x + 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = value [return 0]
	
	;check southeast (1)
	pos: y + 1 * w + x + 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = value [return 1]
	
	;check south (2)
	pos: y + 1 * w + x * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = value [return 2]
	
	;check southwest (3)
	pos: y + 1 * w + x - 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = value [return 3]
	
	;check west (4)
	pos: y * w + x - 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = value [return 4]
	
	;check northwest (5)
	pos: y - 1 * w + x - 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = value [return 5]
	
	;check north (6)
	pos: y - 1 * w + x * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = value [return 6]
	
	;check northeast (7)
	pos: y - 1 * w + x + 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if v = value [return 7]
	;error value
	return -1	
]

rcvGetContours: routine [
"Gets next contour pixel to process"
	p 		[pair!] 
	d 		[integer!] 
	return: [pair!]
	/local
	r		[red-pair!]	
][
	r: pair/make-at stack/push* p/x p/y
	switch d [
	   -1	[r/x: p/x		r/y: p/y]		;--error or last point
		0	[r/x: p/x + 1	r/y: p/y]		;--east
		1	[r/x: p/x + 1 	r/y: p/y + 1]	;--southeast
		2	[r/x: p/x 		r/y: p/y + 1]	;--south
		3	[r/x: p/x - 1 	r/y: p/y + 1]	;--southwest
		4	[r/x: r/x - 1 	r/y: p/y]		;--west
		5	[r/x: p/x - 1 	r/y: p/y - 1]	;--northwest
		6	[r/x: p/x 		r/y: p/y - 1]	;--north
		7	[r/x: p/x + 1 	r/y: p/y - 1]	;--northeast
	]
	 as red-pair! stack/set-last as cell! r 
]

;--news TBD
rcvSetContourValue: func [
"Set contour value"
	mx		[object!]
	p		[pair!]
	value	[integer!]
	/local
	idx [integer!]
][
	idx: (p/y * mx/cols + p/x) + 1
	mx/data/:idx: value
]

rcvGetContourValue: func [
"Get contour value"
	mx		[object!]
	p		[pair!]
	return:	[integer!]
	/local
	idx [integer!]
][
	idx: (p/y * mx/cols + p/x) + 1
	mx/data/:idx
]




