#! /usr/local/bin/red
Red [
	Title:   "Red Computer Vision: Distance Mapping"
	Author:  "Francois Jouen"
	File: 	 %map7.red
	Tabs:	 4
	Rights:  "Copyright (C) 2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
	Needs:	 View
]


; Based on Boleslav Březovský's sample
;it first creates some random points - peaks and 
;then it calculates distance from nearest peak from each point in image. 
;The shorter the distance is, the brighter the pixel is.
;This vesrsion includes Red/System code for a laster rendering

;'Some variables we need

size: 320x240		
map: make image! reduce [size black]

nSeeds: 30			; number of sites
param: true			; show seeds
dparam: 1			; euclidian distance 
mparam: 3.0			; p value for Minkowski distance
color: 	true

;******************* Red/System Routines *******************
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
		3	[m1: pow x1 p m2: pow y1 p
			 s: m1 + m2 pow s (1.0 / p)]	; Minkowsky
		4	[either (x1 > y1) [x1] [y1]]	; Chebyshev
	]
]


_makeMap: routine [
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

;*********************** Red Functions ******************************
makeSeeds: func [n isize] [collect [loop n [keep random isize]]]
randomSeedsColor: func [n] [collect [loop n [keep random white]]]
randomSeedsMono: func [n] [collect [loop n [keep white]]]

makeMap: function [peaks [block!] peaksC [block!] img [image!] param1 [logic!]
param2 [integer!] param3 [float!]
"Creates Distance diagram"
][
	_makeMap peaks peaksC img param1 param2 param3
]

peaks: []
img: none
nSeeds: 50

process: does [
	random/seed now/time
	map/argb: black 
	peaks: makeSeeds nSeeds size
	either color [sc: randomSeedsColor nSeeds]
			     [sc: randomSeedsMono nSeeds]
	t1: now/time/precise
	makeMap peaks sc map param dparam mparam 
	img/image: map
	t2: now/time/precise
	f/text: rejoin ["Rendered in: " t2 - t1]
]

;******************** Main Program *********************************
view win: layout [
	title "Distance Map"
	text  "Number of seeds" 
	f1: field 50 	[if error? try [nSeeds: to-integer f1/text] [nSeeds: 30 
					f1/text: form nSeeds] process]
	text 60 "Distance"
	dp: drop-down 85 data ["Euclidian" "Manhattan" "Minkowski" "Chebyshev"]
		select 	1 
		on-change [
			dparam: face/selected
			either dparam = 3 [f2/visible?: true] [f2/visible?: false]
			process
		]
	f2: field 40 "3.0" [if error? try [mparam: to-float f2/text] [mparam: 3.0 
						f2/text: form mparam] process]
	check  60 "Seeds" param [param: face/data]
	check  60 "Color" color [color: face/data]
	button 65 "Create" 	 [process]
	button 50 "Quit"   	 [quit]
	return 
	pad 16x0 img: base 640x480 map
	return
	pad 16x0
	text 150 "© Red Foundation 2019"
	f: field 480
	do [f1/text: form nSeeds f2/visible?: false]
]


