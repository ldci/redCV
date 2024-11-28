#! /usr/local/bin/red
Red[
	needs: view
]
;t first creates some random points - peaks and 
;then it calculates distance from nearest peak from each point in image. 
;The shorter the distance is, the brighter the pixel is.


rcvDistance2Color: func [dist r g b][
	to tuple! reduce [dist * r dist * g dist * b]
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
		1 [sort collect [foreach p points [keep (rcvGetEuclidianDistance point p) / maximal]]]
		2 [sort collect [foreach p points [keep (rcvGetManhattanDistance point p) / maximal]]]
		3 [sort collect [foreach p points [keep (rcvGetMinkowskiDistance point p 3) / maximal]]]
		4 [sort collect [foreach p points [keep (rcvGetChebyshevDistance point p) / maximal]]]
	]
]


make-image: func [][
	peaks: collect [loop 50 [keep random size]]
	repeat y size/y [
		repeat x size/x [
			diff: first getDistances d as-pair x y peaks max-distance
			map/(as-pair x y): rcvDistance2Color max 0 1.0 - diff * 0.5 1 256 1 
			do-events/no-wait
		]
	]
	foreach v peaks [map/:v: green]
	map
] 

size: 50x50
map: make image! reduce [size black]
max-distance: 0.1 * rcvGetEuclidianDistance 0x0 size
d: 1

random/seed now/time
view win: layout [
	title "Distance 3"
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
		]
	button "Create" [map/argb: black img/image: make-image]	 
	button "Quit"   [quit]
	return 
	img: base 400x400 map
]


