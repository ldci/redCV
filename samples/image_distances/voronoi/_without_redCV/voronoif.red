#! /usr/local/bin/red
Red[
	needs: view
]

;size: 160x120
size: 320x240
;size: 640x480

map: make image! reduce [size black]

nSeeds: 10			; number of sites
param: true			; show seeds
dparam: 1			; 

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



_rcvVoronoiFDiagram: routine [
	peaks	[block!]
	peaksC	[block!]
	img		[image!]
	param1	[logic!]
	param2	[integer!]
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
	dx1 dx2 dy1 dy2
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
       		dMin: as float! w * h
       		s: 0
       		;calculate distance 
       		while [s < n] [
       			idxy: bxy + s
       			p: as red-pair! idxy
       			dx1: as float! p/x - x
       			dx2: as float! p/x + x
       			dy1: as float! p/y - y
       			dy2: as float! p/y + y
       			d: _rcvDotsFDistance dx1 dx2 dy1 dy2 param2
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

rcvVoronoiFDiagram: function [peaks [block!] peaksC [block!] img [image!] param1 [logic!]
param2 [integer!] 
"Creates Voronoï diagram"
][
	_rcvVoronoiFDiagram peaks peaksC img param1 param2
]


randomSeeds: func [n] [collect [loop n [keep random size]]]
randomSeedsColor: func [n] [collect [loop n [keep random white]]]


process: does [
	random/seed now/time
	sxy: randomSeeds nSeeds 
	sc: randomSeedsColor nSeeds
	t1: now/time/precise
	rcvVoronoiFDiagram sxy sc map param dparam 
	t2: now/time/precise
	f3/text: rejoin ["Rendered in: " t2 - t1]
]


view win: layout [
	title "Voronoï Diagram Fractional Distances"
	text  "Number of seeds" 
	f1: field 50 		 [if error? try [nSeeds: to-integer f1/text] [nSeeds: 30 f1/text: form nSeeds] process]
	text 60 "Distance"
	dp: drop-down 85 data ["Camberra" "Sorensen" ]
		select 1
		on-change [dparam: face/selected 
		process
	]
	cb: check "Show seeds" true [param: face/data]
	button 75 "Generate" 	 	[process]
	button 45 "Quit"   	 		[quit]
	return 
	img: base 640x480 map
	return
	text 150 "© Red Foundation 2019"
	f3: field 480
	do [f1/text: form nSeeds]
]