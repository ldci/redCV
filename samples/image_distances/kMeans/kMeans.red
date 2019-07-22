#! /usr/local/bin/red
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

;Some variables we need

size: 400x400	
map1: make image! reduce [size black]
map2: make image! reduce [size black]

PTS: 5000; 100000
radius: 5.0
RAND_MAX: 2147483647.0 ; 
FLOAT_MAX: 1E100
K: 7
points: copy []
plot: copy []
centroid: copy []

;we use an object
point: object [
	x: 		0
	y: 		0
	group: 	0
]

randf: function [m [float!]return: [float!]][
	(m * random RAND_MAX) / RAND_MAX - 1.0
]

genXY: function [count [integer!] radius [float!] return: [block!]][
	;Generate random data points
	random/seed now/time/precise
	i: 1
	blk: copy []
	;note: this is not a really uniform 2-d distribution
	while [i <= count] [
		pt: copy point
		ang: randf 2.0 * pi
		r: randf radius
		pt/x: r * cos ang
		pt/y: r * sin ang
		pt/group: 0
		append blk pt
		i: i + 1
	]
	blk
]

showXY: function [points [block!]][
	H: W: 400
	map1: make image! reduce [size black]
	color: red
	plot: compose [line-width 1 pen (color)  fill-pen (color)]
	minX: FLOAT_MAX
	minY: FLOAT_MAX
	maxX: negate FLOAT_MAX
	maxY: negate FLOAT_MAX
	p: 0x0
	foreach v points [
		p/x: to-integer v/x
		p/y: to-integer v/y
		if (maxX < p/x) [maxX: p/x]
		if (minX > p/x) [minX: p/x]
		if (maxY < p/y) [maxY: p/y]
        if (minY > p/y) [minY: p/y]
    ]
    scale: min (W / (maxX - minX)) (H / (maxY - minY))
    cx: (maxX + minX) / 2.0
    cy: (maxY + minY) / 2.0
    p: 0x0
    foreach v points [   
    	color: random white
    	nx: (v/x - cx * scale + W) / 2
    	ny: (v/y - cy * scale + H) / 2
    	p/x: to-integer nx
    	p/y: to-integer ny
		append append append append plot 'pen color 'fill-pen color
		append append append plot 'circle p 1.5 ;'
	]
	canvas/image: draw map1 plot
	canvas2/image/rgb: snow
	canvas2/text: "Processing ..."
]


genCentroid: function [count [integer!] return: [block!]][
	i: 1
	blk: copy []
	while [i <= count] [
		pt: copy point
		pt/x: 0.0
		pt/y: 0.0
		pt/group: 0
		append blk pt
		i: i + 1
	]
	blk
]


dist2: function [a [object!]  b [object!] return: [float!]][
"Computes the dissimilarity between points a and b"
	x: a/x - b/x
	y: a/y - b/y
	(x * x) + (y * y)
]

nearest: function [pt [object!] centroid [block!] ncluster [integer!] return: [block!]] [
"Distance and index of the closest cluster center."
	min_d: FLOAT_MAX
	min_i: pt/group
	i: 1
	while [i <= ncluster] [
		d: dist2 pt centroid/(i)
		if min_d > d [
            min_d: d
            min_i: i
        ]
		i: i + 1
	]
	reduce [min_i min_D]
]


kpp: function [points [block!] centroid [block!]][
	len: length?  points
	nCluster: length? centroid
	;take one center chosen uniformly at random from points
	centroid/1: copy points/(random len)
	d: 0.0
	i: 1
	;repeat until we have taken nClusters centers
	while [i <= nCluster] [
		blk: copy []
		sum: 0.0
		j: 1 
		while [j <= len] [
			d: second nearest points/(j) centroid i
			sum: sum + d
            append blk d
			j: j + 1
		]
		sum: randf(sum)
		j: 1
		while [j <= len] [
			sum: sum - blk/(j)
			either sum > 0.0 [
				centroid/:i: copy points/:j
				j: j + 1
			] [break]
		]
		i: i + 1
	]
	j: 1
	while [j <= len][
		p: points/(j)
		p/group: first nearest points/(j) centroid nCluster
		j: j + 1
	]
]

;Lloyd K-means Clustering with convergence
;group element for centroids are used as counters

lloyd: function [points [block!] nCluster [integer!] return: [block!]][
	len: length?  points
	centroid: genCentroid nCluster
	;call k++ init
	kpp points centroid
	lenpts10: len >> 10
	changed: 0
	until [
		;Find clusters centroids
		centroid: genCentroid nCluster
		j: 1
		while [j <= len] [
			p: points/(j)
			c: centroid/(p/group)
			c/x: c/x + p/x
			c/y: c/y + p/y
			c/group: c/group + 1
			j: j + 1
		]
		;calculate means
		j: 1
		while [j <= nCluster] [
			c: centroid/(j)
            c/x: c/x / c/group
            c/y: c/y / c/group
			j: j + 1
		]
		
		changed: 0
		;find closest centroid of each point
		j: 1 
		while [j <= len] [
			p: points/(j)
			min_I: first nearest p centroid nCluster
			if min_I <> p/group [
				changed: changed + 1
				p/group: min_I
			]
			j: j + 1
		]
		;stop when 99.9% of points are good
		changed > lenpts10
	]
	;update centroid group element
	i: 1 
	while [i <= nCluster] [
		c: centroid/(i)
		c/group: i
		i: i + 1
	]
	centroid
]

showKmeans: function [points [block!] cent [block!] nCluster [integer!]][
	H: W: 400
	len: length?  points
	i: 1
	colors: copy []
	while [i <= nCluster][
		r: (3 * (i + 1) % 11) / 11.0
		g: (7 * i % 11) / 11.0
		b: (9 * i % 11) / 11.0
		t: make tuple! reduce [r * 255 g * 255 b * 255]
		append colors t
		i: i + 1
	]
	minX: FLOAT_MAX
	minY: FLOAT_MAX
	maxX: negate FLOAT_MAX
	maxY: negate FLOAT_MAX
	p: 0x0
	foreach v points [
		p/x: to-integer v/x
		p/y: to-integer v/y
		if (maxX < p/x) [maxX: p/x]
		if (minX > p/x) [minX: p/x]
		if (maxY < p/y) [maxY: p/y]
        if (minY > p/y) [minY: p/y]
    ]
	scale: min (W / (maxX - minX)) (H / (maxY - minY))
	cx: (maxX + minX) / 2.0
    cy: (maxY + minY) / 2.0
    map2: make image! reduce [size black]
    plot: copy []
    i: 1
    while [i <= nCluster][
   		p: 0x0
    	j: 1
    	color: white
    	while [j <= len] [
    		pt: points/(j)
    		nx: (pt/x - cx * scale + W) / 2
    		ny: (pt/y - cy * scale + H) / 2
    		p/x: to-integer nx
    		p/y: to-integer ny
    		color: colors/(pt/group)
    		if pt/group <> i [
    			append append append append plot 'pen color 'fill-pen color
				append append append plot 'circle p 1.5 ;'
			]
			
		j: j + 1
		]
    	i: i + 1
    ]
    
    ;centroids
    i: 1
    while [i <= nCluster] [
    	c: cent/(i)
		nx: (c/x - cx * scale + W) / 2
    	ny: (c/y - cy * scale + H) / 2
    	p/x: to-integer nx
    	p/y: to-integer ny
    	color: yellow
    	append append append append plot 'pen color 'fill-pen color
		append append append plot 'circle p 3.0 ;'
		p/x: p/x + 3 
    	p/y: p/y - 8
    	if cb1/data  [
    	
    	append plot reduce ['text p form (i)]];'
    	i: i + 1
    ]
    
    canvas2/text: ""
    canvas2/image: draw map2 plot		
]


kMeans: does [
	clear f3/text
	random/seed now/time/precise
	points: genXY PTS radius 
	showXY points
	do-events/no-wait
	t1: now/time/precise
	centroid: lloyd points K
	showKMeans points centroid K
	t2: now/time/precise
	f3/text: form t2 - t1
]

;******************** Main Program *********************************
view win: layout [
	title "K Means Red"
	text  "Number of points" 
	f1: field 70 	[if error? try [PTS: to-integer face/text] [PTS: 500 
					face/text: form PTS]]
	text "Number of clusters"
					
	f2: field 50	[if error? try [K: to-integer face/text] [K: 2 
					face/text: form K] if K > 1 [kMeans]]
	cb1: check "Show Labels" 
	button  "Generate" 	 [kMeans]
	pad 160x0
	button 50 "Quit"   	 [quit]
	return 
	canvas:  base size map1
	canvas2: base size map2 font-color red font-size 14
	return
	text 400 center "© Red Foundation 2019"
	f3: text 400 center
	
	do [f1/text: form PTS f2/text: form K cb1/data: true]
]