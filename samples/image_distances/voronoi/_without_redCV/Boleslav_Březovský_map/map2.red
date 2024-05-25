#! /usr/local/bin/red
Red[
	needs: view
]
;t first creates some random points - peaks and 
;then it calculates distance from nearest peak from each point in image. 
;The shorter the distance is, the brighter the pixel is.


dist-to-color: func [dist ][
	to tuple! reduce [dist * 256 dist * 1 dist * 1]
]

; euclidian distance
distance: func [start end /local diff][
	diff: end - start
	sqrt diff/x * diff/x + (diff/y * diff/y)
]

; Manhattan distance
mdistance: func [a b /local x y ][
	x: absolute b/x - a/x
	y: absolute b/y - a/y
	x + y
]


get-distances: func [point points maximal][
	sort collect [
		foreach p points [keep (distance point p) / maximal]
	]
]

get-mdistances: func [point points maximal][
	sort collect [
		foreach p points [keep (mdistance point p) / maximal]
	]
]

make-image: func [][
	max-distance: 0.1 * distance 0x0 size
	if cb/data [max-distance: 0.1 * mdistance 0x0 size]
	;map: make image! size
	peaks: collect [loop 25 [keep random size]]
	repeat x size/x [
		repeat y size/y [
			either cb/data [diff: first get-mdistances as-pair x y peaks max-distance]
			[diff: first get-distances as-pair x y peaks max-distance]
			map/(as-pair x y):  dist-to-color max 0 1.0 - diff * 0.5
			do-events/no-wait
		]
	]
	
	foreach v peaks [map/:v: green]
	map
] 

size: 100x100
map: make image! reduce [size black]


random/seed now/time
view win: layout [
	title "Distance 2"
	button "Create" [map/argb: black img/image: make-image]
	cb: check "Manhattan" false 
	button "Quit"   [quit]
	return 
	img: base 400x400 map
]


