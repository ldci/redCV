#! /usr/local/bin/red
Red[
	needs: view
]
;t first creates some random points - peaks and 
;then it calculates distance from nearest peak from each point in image. 
;The shorter the distance is, the brighter the pixel is.

;max dist value 1.0
rcvDistance2Color: func [dist [number!] t [tuple!]][
	t * dist
]

rcvGetEuclidianDistance: func [a b /local d][
	d: b - a
	sqrt (d/x ** 2) + (d/y ** 2)
]



rcvGetManhattanDistance: func [a b /local d ][
	d: absolute b - a
	d/x + d/y
]

rcvGetMinkowskiDistance: func [a b p /local d s ][
	d: absolute b - a
	s: (d/x ** p) + (d/y ** p)
	s ** (1.0 / p)  ; nth root 
]

rcvGetChebyshevDistance: func [a b /local d ][
	d: absolute b - a
	max d/x d/y
]

rcvGetCamberraDistance: func [a b][
	absolute ((to-float a/x - to-float b/x) / (to-float a/x + to-float b/x)) 
	+ ((to-float a/y - to-float b/y) / (to-float a/y + to-float b/y))
	
]

getDistances: func [dNorm point points maximal][
	switch dNorm [
		1 [bl: collect [foreach p points [keep (rcvGetEuclidianDistance point p) / maximal]]]
		2 [bl: collect [foreach p points [keep (rcvGetManhattanDistance point p) / maximal]]]
		3 [bl: collect [foreach p points [keep (rcvGetMinkowskiDistance point p 3) / maximal]]]
		4 [bl: collect [foreach p points [keep (rcvGetChebyshevDistance point p) / maximal]]]
	]
	sort bl
	bl/1
]


makeSeeds: func [n isize] [collect [loop n [keep random isize]]]
showSeeds: func [seeds im /local v] [foreach v seeds [im/:v: white]]


makeMap: func [img ][
	repeat y size/y [
		repeat x size/x [
			diff: getDistances d as-pair x y peaks max-distance
			img/(as-pair x y): rcvDistance2Color max 0 1.0 - diff * 0.75 color
			do-events/no-wait
		]
	]
	img
] 

size: 200x200;50x50
map: make image! reduce [size black]
cmap: make image! reduce [size black]
max-distance: 0.1 * rcvGetEuclidianDistance 0x0 size
d: 1
peaks: []
img: none
nSeeds: 50

process: does [
	color: random white
	map/argb: black 
	cmap/argb: black
	peaks: makeSeeds nSeeds size
	t1: now/time/precise
	map: makeMap map
	img/image: map
	t2: now/time/precise
	cmap: to-image img
	if cb/data [showSeeds peaks map]
	f/text: rejoin ["Rendered in: " t2 - t1]
]

random/seed now/time
view win: layout [
	title "Distance 4"
	text "Distance"
	dp: drop-down data ["Euclidian" "Manhattan" "Minkowski 3" "Chebyshev"]
		select 	1 
		on-change [
			d: face/selected
			switch d [
				1 [max-distance: 0.1 * rcvGetEuclidianDistance 0x0 size]
				2 [max-distance: 0.1 * rcvGetManhattanDistance 0x0 size]
				3 [max-distance: 0.1 * rcvGetMinkowskiDistance 0x0 size 3]
				4 [max-distance: 0.1 * rcvGetChebyshevDistance 0x0 size]
			]
		process	
		]
	button "Create" 	 [process]
	cb: check 60 "Seeds" [either cb/data [showSeeds peaks map img/image: map]
						      [img/image: cmap]]
	button 50 "Quit"   	 [quit]
	return 
	img: base 400x400 map
	return
	f: field 400
]


