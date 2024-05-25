#! /usr/local/bin/red
Red[
	needs: view
]

;size: 160x120
size: 320x240
;size: 640x480

map: make image! reduce [size black]

nSeeds: 50			; number of sites
param: true			; show seeds
dparam: 1			; euclidian distance 
mparam: 3.0			; p value for Minkowski distance


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
		2	[x1 + y1]						; manhatta
		3	[m1: pow x1 p m2: pow y1 p
			 s: m1 + m2 pow s (1.0 / p)]	; Minkowsky
		4	[either (x1 > y1) [x1] [y1]]	; Chebyshev
	]
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

rcvVoronoiDiagram: function [peaks [block!] peaksC [block!] img [image!] param1 [logic!]
param2 [integer!] param3 [float!]
"Creates Voronoï diagram"
][
	_rcvVoronoiDiagram peaks peaksC img param1 param2 param3
]


randomSeeds: func [n] [collect [loop n [keep random size]]]
randomSeedsColor: func [n] [collect [loop n [keep random white]]]


process: does [
	random/seed now/time
	sxy: randomSeeds nSeeds 
	sc: randomSeedsColor nSeeds
	t1: now/time/precise
	rcvVoronoiDiagram sxy sc map param dparam mparam
	t2: now/time/precise
	f3/text: rejoin ["Rendered in: " t2 - t1]
]


view win: layout [
	title "Voronoï Diagram 3"
	text  "Number of seeds" 
	f1: field 50 		 [if error? try [nSeeds: to-integer f1/text] [nSeeds: 30 f1/text: form nSeeds] process]
	text 60 "Distance"
	dp: drop-down 85 data ["Euclidian" "Manhattan" "Minkowski" "Chebyshev"]
		select 1
		on-change [dparam: face/selected 
		either dparam = 3 [f2/visible?: true] [f2/visible?: false]
		process
	]
	f2: field 40 "3.0" 			[if error? try [mparam: to-float f2/text] [mparam: 3.0 f2/text: form mparam] process]
	cb: check "Show seeds" true [param: face/data]
	button 75 "Generate" 	 	[process]
	button 45 "Quit"   	 		[quit]
	return 
	img: base 640x480 map
	return
	text 150 "© Red Foundation 2019"
	f3: field 480
	do [f1/text: form nSeeds f2/visible?: false]
]