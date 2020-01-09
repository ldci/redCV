Red [
	Title:   "Red Computer Vision: Matrix functions"
	Author:  "Francois Jouen"
	File: 	 %rcvFreeman.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]
; by columns
rcvMatleftPixel: routine [
"Gets coordinates of first left pixel"
	mat 	[vector!] 
	matSize [pair!] 
	value 	[integer!] 
	/local
	matHead	[byte-ptr!]
	s		[series!]
	flag	[logic!]
	pixel	[red-pair!]
	unit  	[integer!]
	v		[integer!]
	x 		[integer!]	
	y 		[integer!]
	pos		[integer!]
] [
	matHead: vector/rs-head mat ; get pointer address of the matrice
	s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	pixel: pair/make-at stack/push* 0 0
	flag: false
	x: 0
	while [x < matSize/x][
		y: 0
		while [y < matSize/y] [
			pos: y * matSize/x + x * unit
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
	mat 	[vector!] 
	matSize [pair!] 
	value 	[integer!] 
	/local
	matHead	[byte-ptr!]
	s		[series!]
	flag	[logic!]
	pixel	[red-pair!]
	unit  	[integer!]
	v		[integer!]
	x 		[integer!]	
	y 		[integer!]
	pos		[integer!]
][
	matHead:  vector/rs-head mat ; get pointer address of the matrice
	s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	pixel: pair/make-at stack/push* 0 0
	flag: false
	x: matSize/x - 1
	while [x >= 0][
		y: matSize/y - 1
		while [y >= 0] [
			pos: (x + (y * matSize/x)) * unit
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
	mat 	[vector!] 
	matSize [pair!] 
	value 	[integer!] 
	/local
	matHead	[byte-ptr!]
	s		[series!]
	flag	[logic!]
	pixel	[red-pair!]
	unit  	[integer!]
	v		[integer!]
	x 		[integer!]	
	y 		[integer!]
	pos		[integer!]
] [
	matHead: vector/rs-head mat ; get pointer address of the matrice
	s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	pixel: pair/make-at stack/push* 0 0
	flag: false
	y: 0
	while [y < matSize/y][
		x: 0
		while [x < matSize/x] [
			pos: (x + (y * matSize/x)) * unit
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
	mat 	[vector!] 
	matSize [pair!] 
	value 	[integer!] 
	/local
	matHead	[byte-ptr!]
	s		[series!]
	flag	[logic!]
	pixel	[red-pair!]
	unit  	[integer!]
	v		[integer!]
	x 		[integer!]	
	y 		[integer!]
	pos		[integer!]
][
	matHead: vector/rs-head mat ; get pointer address of the matrice
	s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	pixel: pair/make-at stack/push* 0 0
	flag: false
	y: matSize/y - 1
	while [y >= 0][
		x: matSize/x - 1
		while [x >= 0] [
			pos: (x + (y * matSize/x)) * unit
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
	mat 	[vector!] 
	matSize [pair!]
	x 		[integer!]
	y 		[integer!]
	value 	[integer!]
	return: [logic!]
	/local
	matHead	[byte-ptr!]
	s		[series!]
	unit  	[integer!]
	v 		[integer!]
	vbg		[integer!]
	pos		[integer!]
][
	
	matHead: vector/rs-head mat ; get pointer address of the matrice
	s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	;only check background pixels (white or black)
	if value = 1 	[vbg: 0]
	if value = 255	[vbg: 0]
	if value =  0 	[vbg: 1]
	
	pos: y * matSize/x + x * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = vbg) [return false] 
	
	;check left (west)
	if (x = 0) [return true] ; image border = shape border
	if (x > 0) [
		pos: y * matSize/x + x - 1 * unit
		v: vector/get-value-int as int-ptr! matHead + pos unit
		if (v = vbg) [return true]
	]
	
	;check up (north)
	if (y = 0) [return true]
	if (y > 0) [
		pos: y - 1 * matSize/x + x * unit
		v: vector/get-value-int as int-ptr! matHead + pos unit
		if (v = vbg) [return true]
	]
	
	;check right (east)
    if (x = matSize/x) [return true]
    if (x < matSize/x) [
    	pos: y * matSize/x + x + 1 * unit
    	v: vector/get-value-int as int-ptr! matHead + pos unit
    	if (v = vbg) [return true]
    ]
    
     ;check down (south)
    if (y = matSize/y) [return true]
    if (y < matSize/y) [
    	pos: y + 1 * matSize/x + x * unit
    	v: vector/get-value-int as int-ptr! matHead + pos unit
    	if (v = vbg) [return true]
    ]
	;no empty pixel around = not border pixel
	return false
]

rcvMatGetBorder: routine [
"Gets pixels that belong to shape border"
	mat 	[vector!] 
	matSize [pair!]
	value 	[integer!]
	border 	[block!]
	/local
	matHead	[byte-ptr!]
	s		[series!]
	unit 	[integer!]
	pos 	[integer!]
	x 		[integer!]
	y 		[integer!]
	v		[integer!]
][
	matHead:  vector/rs-head mat ; get pointer address of the matrice
	s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	block/rs-clear border
	y: 0
	while [y < matSize/y][
		x: 0
		while [x < matSize/x] [
			v: vector/get-value-int as int-ptr! matHead unit
			if (v = value) [
				;if a neighbor of a pixel belongs to background
				;that pixel belongs to the border of the shape 
				if rcvBorderPixel mat matSize x y value [
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
	mat 	[vector!] 
	matSize [pair!]
	x 		[integer!]
	y 		[integer!]
	value 	[integer!]
	return:	[integer!]
	/local
	matHead	[byte-ptr!]
	s		[series!]
	unit 	[integer!]
	v		[integer!]
	pos		[integer!]
][
	
	matHead: vector/rs-head mat ; get pointer address of the matrice
	s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	; check east (0)
	pos: y * matSize/x + x + 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = value) [return 0]
	
	;check southeast (1)
	
	pos: y + 1 * matSize/x + x + 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = value) [return 1]
	
	;check south (2)
	pos: y + 1 * matSize/x + x * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = value) [return 2]
	
	;check southwest (3)
	pos: y + 1 * matSize/x + x - 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = value) [return 3]
	
	;check west (4)
	pos: y * matSize/x + x - 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = value) [return 4]
	
	;check northwest (5)
	pos: y - 1 * matSize/x + x - 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = value) [return 5]
	
	;check north (6)
	pos: y - 1 * matSize/x + x * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = value) [return 6]
	
	;check northeast (7)
	pos: y - 1 * matSize/x + x + 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = value) [return 7]
	return -1
]


rcvMatGetChainCode: routine [
"Gets next contour pixel direction"
	mat 	[vector!] 
	matSize [pair!]
	coord	[pair!]
	value 	[integer!]
	return:	[integer!]
	/local
	matHead	[byte-ptr!]
	s		[series!]
	unit 	[integer!]
	v		[integer!]
	pos		[integer!]
	x 		[integer!]
	y 		[integer!]
][
	x: coord/x
	y: coord/y
	matHead: vector/rs-head mat ; get pointer address of the matrice
	s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	; check east (0)
	pos: y * matSize/x + x + 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = value) [return 0]
	
	;check southeast (1)
	pos: y + 1 * matSize/x + x + 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = value) [return 1]
	
	;check south (2)
	pos: y + 1 * matSize/x + x * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = value) [return 2]
	
	;check southwest (3)
	pos: y + 1 * matSize/x + x - 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = value) [return 3]
	
	;check west (4)
	pos: y * matSize/x + x - 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = value) [return 4]
	
	;check northwest (5)
	pos: y - 1 * matSize/x + x - 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = value) [return 5]
	
	;check north (6)
	pos: y - 1 * matSize/x + x * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = value) [return 6]
	
	;check northeast (7)
	pos: y - 1 * matSize/x + x + 1 * unit
	v: vector/get-value-int as int-ptr! matHead + pos unit
	if (v = value) [return 7]
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
	   -1	[r/x: p/x		r/y: p/y]		; error or last point
		0	[r/x: p/x + 1	r/y: p/y]		; east
		1	[r/x: p/x + 1 	r/y: p/y + 1]	; southeast
		2	[r/x: p/x 		r/y: p/y + 1]	; south
		3	[r/x: p/x - 1 	r/y: p/y + 1]	; southwest
		4	[r/x: r/x - 1 	r/y: p/y]		; west
		5	[r/x: p/x - 1 	r/y: p/y - 1]	; northwest
		6	[r/x: p/x 		r/y: p/y - 1]	; north
		7	[r/x: p/x + 1 	r/y: p/y - 1]	; northeast
	]
	 as red-pair! stack/set-last as cell! r 
]

