#! /usr/local/bin/red
Red[
	needs: view
]
;t first creates some random points - peaks and 
;then it calculates distance from nearest peak from each point in image. 
;The shorter the distance is, the brighter the pixel is.

size: 200x200
map: make image! reduce [size black]

nSeeds: 30			; number of sites
param: true			; show seeds
dparam: 1			; euclidian distance 
mparam: 3.0			; p value for Minkowski distance
color: green

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



_makeMap: routine [
	peaks	[block!]
	img		[image!]
	param1	[logic!]
	param2	[integer!]
	param3	[float!]
	param4	[tuple!]
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
	t		[red-tuple!] 
	r g b
	rf gf bf		
][
	handle1: 0
	n: block/rs-length? peaks
	bxy: block/rs-head peaks
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
       		r: param4/array1 and FFh 
			g: param4/array1 and FF00h >> 8 
			b: param4/array1 and 00FF0000h >> 16 
			rf: as integer! (d * r)
			gf: as integer! (d * g)
			bf: as integer! (d * b)
			idxim: pix1 + (y * w) + x
			idxim/value: (255 << 24) OR (rf << 16 ) OR (gf << 8) OR bf
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

makeSeeds: func [n isize] [collect [loop n [keep random isize]]]

makeMap: function [peaks [block!] img [image!] param1 [logic!]
param2 [integer!] param3 [float!] param4 [tuple!]
"Creates Voronoï diagram"
][
	_makeMap peaks img param1 param2 param3 param4
]

peaks: []
img: none
nSeeds: 50

process: does [
	random/seed now/time
	color: random white
	map/argb: black 
	peaks: makeSeeds nSeeds size
	t1: now/time/precise
	makeMap peaks map param dparam mparam color
	img/image: map
	t2: now/time/precise
	f/text: rejoin ["Rendered in: " t2 - t1]
]


view win: layout [
	title "Distance 5"
	text "Distance"
	dp: drop-down data ["Euclidian" "Manhattan" "Minkowski 3" "Chebyshev"]
		select 	1 
		on-change [
			dparam: face/selected
			process
		]
	cb: check 60 "Seeds" param [param: face/data]
	button "Create" 	 [process]
	button 50 "Quit"   	 [quit]
	return 
	img: base 400x400 map
	return
	f: field 400
]


