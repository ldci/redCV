#! /usr/local/bin/red
Red[
	needs: view
]

dist-to-color: func [dist][
	to tuple! reduce [dist * 256 dist * 256 dist * 256]
]

distance: func [start end /local diff][
	diff: end - start
	absolute square-root diff/x * diff/x + (diff/y * diff/y)
]

; not used
map: func ['word series code][
	; 'Leaks :word, but foreach leaks to
	collect [
		foreach :word series [
			keep do code
		]
	]
]

get-distances: func [point points maximal][
	sort collect [
		foreach p points [keep (distance point p) / maximal]
	]
]

make-image: func [][
	size: 200x200
	f/text: copy ""
	max-distance: 0.1 * distance 0x0 size
	map: make image! size
	peaks: collect [loop 10 [keep random size]]
	probe peaks
	repeat x size/x [
		repeat y size/y [
			diff: first get-distances as-pair x y peaks max-distance
			map/(as-pair x y):  dist-to-color max 0 1.0 - diff * 0.5
			f/text: form map/(as-pair x y)
			do-events/no-wait
		]
	]
	map
] 
random/seed now/time
view win: layout [
	title "Distance 1"
	button "Create" [img/image: make-image]
	f: field 100 
	button "Quit"    [quit]
	return 
	img: base 400x400
]


