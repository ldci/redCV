Red [
	Title:   "Red Computer Vision: K Means"
	Author:  "Francois Jouen"
	File: 	 %kmeans.red
	Tabs:	 4
	Rights:  "Copyright (C) 2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
	Needs:	 View
]

#include %../../../libs/tools/rcvTools.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/math/rcvDistance.red
#include %../../../libs/math/rcvCluster.red

;Some variables we need

size: 400x400	
map1: make image! reduce [size black]
map2: make image! reduce [size black]
map3: make image! reduce [size black]

PTS: 5000; 100000
radius: 5.0

K: 7
points: 	copy []
plot: 		copy []
centroid:	copy []
colors: 	copy []
peaks: 		copy []

font-A: make font! [
		name: "Arial"
		size: 12
		color: black
		style: [bold]
		anti-alias?: yes
]

genPoints: routine [
		array	[block!]	; redCV array type
		radius 	[float!] 
		/local
		bvalue 	[red-value!] 
   		p		[float-ptr!]
    	vectBlk	[red-vector!]
    	vvalue	[byte-ptr!] 
    	len		[integer!]
    	i		[integer!]
    	j		[integer!]
    	unit	[integer!]
		ang		[float!] 
		r		[float!]
		
][
	;Generate random data points
	bvalue: block/rs-head array
	len:  block/rs-length? array
	vectBlk: as red-vector! bvalue
	unit: rcvGetMatBitSize vectBlk
	;note: this is not a really uniform 2-d distribution
	i: 0
    while [i < len][
    	vectBlk: as red-vector! bvalue	;3 values in vectBlk
    	vvalue: vector/rs-head vectBlk
    	ang: randf 2.0 * pi
		r: randf radius
		j: 0
		while [j < 3] [
			p: as float-ptr! vvalue
			case [
				j = 0 [p/value: r * cos ang]
				j = 1 [p/value: r * sin ang]
				j = 2 [p/value: 0.0]
			]
			vvalue: vvalue + unit
			j: j + 1
		]
    	bvalue: bvalue + 1
    	i: i + 1
    ] 
]


scalePoints: function [points [block!] return: [block!]][
	H: W: 400
	FLOAT_MAX: 1E100
	minX: minY: FLOAT_MAX
	maxX: maxY: negate FLOAT_MAX
	p: 0x0
	foreach v points [
		p/x: to-integer v/1
		p/y: to-integer v/2
		if (maxX < p/x) [maxX: p/x]
		if (minX > p/x) [minX: p/x]
		if (maxY < p/y) [maxY: p/y]
        if (minY > p/y) [minY: p/y]
    ]
    scale: min (W / (maxX - minX)) (H / (maxY - minY))
    cx: (maxX + minX) / 2.0
    cy: (maxY + minY) / 2.0
    reduce [cx cy scale]
]



showPoints: function [points [block!]][
	H: W: 400
    pBlk: scalePoints Points
    cx: pBlk/1
    cy: pBlk/2
    scale: pBlk/3
    
    map1: make image! reduce [size black]
	color: red
	plot: compose [line-width 1 pen (color)  fill-pen (color)]
    
    p: 0x0
    foreach v points [   
    	color: random white
    	p/x: to-integer (v/1 - cx * scale + W) / 2
    	p/y: to-integer (v/2 - cy * scale + H) / 2
		append plot reduce ['pen color 'fill-pen color 'circle p 1.5] ;'
	]
	canvas1/image: draw map1 plot
	canvas2/image/rgb: snow
	canvas3/image/rgb: snow
	canvas2/text: "Processing ..."
	do-events/no-wait
]



showKmeans: function [points [block!] cent [block!]][
	H: W: 400
	nCluster: length? cent
	len: length?  points
	i: 1
	clear colors
	while [i <= nCluster][
		r: (3 * (i + 1) % 11) / 11.0
		g: (7 * i % 11) / 11.0
		b: (9 * i % 11) / 11.0
		t: make tuple! reduce [r * 255 g * 255 b * 255]
		append colors t
		i: i + 1
	]
    pBlk: scalePoints Points
    cx: pBlk/1
    cy: pBlk/2
    scale: pBlk/3
    
    map2: make image! reduce [size black]
    fontC: copy font-A
	fontC/size: 14
	fontC/color: yellow
	color: yellow
    plot: compose [font fontC]
    i: 0
    while [i < nCluster][
   		p: 0x0
    	j: 0
    	while [j < len] [
    		pt: points/(j + 1) 
    		p/x: to-integer (pt/1 - cx * scale + W) / 2
    		p/y: to-integer (pt/2 - cy * scale + H) / 2
    		c: to-integer pt/3 + 1 ; for 1-based access
    		color: colors/(c)
    		if c <> i [
    			append plot reduce ['pen color 'fill-pen color 'circle p 1.5] ;'
    		]
			j: j + 1
		]
    	i: i + 1
    ]
    
	
    ;centroids
    i: 0
    p: 0x0
    while [i < nCluster] [
    	c: cent/(i + 1)
    	p/x: to-integer (c/1 - cx * scale + W) / 2 
    	p/y: to-integer (c/2 - cy * scale + H) / 2
    	color: yellow
    	append plot reduce ['pen color 'fill-pen color 'circle p 3.0];'
    	if cb1/data  [
    		p/x: p/x + 4 
    		p/y: p/y - 10
    		append plot reduce ['text p form (i + 1)] ;'
    	]
    	i: i + 1
    ]
    canvas2/text: ""
    canvas2/image: draw map2 plot		
]



kMap: does [
	H: W: 400
	map3: make image! reduce [size black]
	clear peaks
	pBlk: scalePoints points
    cx: pBlk/1
    cy: pBlk/2
    scale: pBlk/3
    
    nCluster: length?  centroid
    clear colors
    j: 1
    p: 0x0
    while [j <= nCluster] [
    	pt: centroid/:j 
    	p/x: to-integer (pt/1 - cx * scale + W) / 2
    	p/y: to-integer (pt/2 - cy * scale + H) / 2
    	append peaks p
    	append colors random white
		j: j + 1
	]
	
	
	either r1/data [rcvVoronoiDiagram peaks colors map3 false 1 3.0] 
					[rcvDistanceDiagram peaks colors map3 false 1 3.0]
	
	fontC: copy font-A
	either r1/data [fontC/color: black] [fontC/color: white]
	color: font-A/color
	plot: compose [line-width 1 pen (color) font fontC]
	j: 1				
	while [j <= nCluster] [
    	pt: centroid/:j 
    	p/x: to-integer (pt/1 - cx * scale + W) / 2
    	p/y: to-integer (pt/2 - cy * scale + H) / 2
    	p/x: p/x - 3 
    	p/y: p/y - 8
    	if cb1/data  [append plot reduce ['text p form (j)]];'
		j: j + 1
	]
	
	canvas3/image: draw map3 plot
]



kMeans: does [
	random/seed now/time/precise
	clear f3/text
	clear f4/text
	points: rcvKMInitData  PTS				;create points
	genPoints  points radius				;randomly values for points
	showPoints points						;draw points
	tmpblk: copy []							;temporary block for sum calculation
	centroid: rcvKMInitData K				;create centroid
	t1: now/time/precise 					;get time
	centroid/1: copy points/(random PTS)	;random center from points
	rcvKMInit points centroid tmpblk		;K-means++ init
	rcvKMCompute points centroid			;Lloyd K-means clustering
	showKMeans points centroid 				;draw clustering
	t2: now/time/precise					;elapsed time
	t: rcvElapsed t1 t2
	f3/text: rejoin ["Rendered in: " t " ms"]
	t1: now/time/precise 					;get time
	kMap
	t2: now/time/precise					;elapsed time
	t: rcvElapsed t1 t2
	f4/text: rejoin ["Rendered in: " t " ms"]
]




;******************** Main Program *********************************
view win: layout [
	title "redCV: K Means Computation and Mapping"
	text  "Number of points" 
	f1: field 70 	[if error? try [PTS: to-integer face/text] [PTS: 500 
					face/text: form PTS] if PTS > 1 [kMeans]]
	text "Number of clusters"
					
	f2: field 50	[if error? try [K: to-integer face/text] [K: 10 
					face/text: form K] if K > 1 [kMeans]]
	cb1: check "Show Labels"
	r1: radio "Voronoï"			[kMeans]
	r2: radio "Distance Map" 	[kMeans]
	button  "Compute" 	 		[kMeans]
	pad 360x0
	button 50 "Quit"   	 [quit]
	return 
	text 400 center "Random data"
	text 400 center "K-means clustering"
	text 400 center "Distance maps"
	return
	canvas1: base size map1
	canvas2: base size map2 font-color red font-size 14
	canvas3: base size map3
	return
	text 400 center "© Red Foundation 2019"
	f3: text 400 center
	f4: text 400 center
	do [f1/text: form PTS f2/text: form K cb1/data: r1/data: true]
]