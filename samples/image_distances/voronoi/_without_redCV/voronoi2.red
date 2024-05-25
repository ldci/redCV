#! /usr/local/bin/red
Red[
	needs: view
]

size: 320x240
map: make image! reduce [size black]

nSeeds: 30
param: 1

rcvGetDotDistance: func [x y] [sqrt (x * x) + (y * y)]
randomSeeds: func [n] [collect [loop n [keep random size]]]
randomSeedsColor: func [n] [collect [loop n [keep random white]]]


generateVoronoi: func [ peaks peaksColor img op] [
	n: length? peaks
	;img/argb: black
	; distance map
	sMin: 1
	repeat y size/y [
		repeat x size/x [
			dMin: rcvGetDotDistance size/x size/y
			repeat s n [
				dx: first peaks/:s - x
				dy: second peaks/:s - y
				d: rcvGetDotDistance dx dy 
				if d < dMin [
					sMin: s
					dMin: d
				]
			]
			img/(as-pair x y): peaksColor/:sMin
			do-events/no-wait
		]
	]
	;show seeds
	if op = 1 [
		repeat i n [img/(peaks/:i): black]
	]
	img
]

process: does [
	random/seed now/time
	if error? try [nSeeds: to-integer f/text] [nSeeds: 30 f/text: form nSeeds]
	sxy: randomSeeds nSeeds 
	sc: randomSeedsColor nSeeds
	t1: now/time/precise
	generateVoronoi sxy sc map param
	t2: now/time/precise
	f2/text: rejoin ["Rendered in: " t2 - t1]
]



view win: layout [
	title "Voronoï Diagram 2"
	text "Seeds Number" f: field 50 "30" [if error? try [nSeeds: to-integer f/text] [nSeeds: 10 f/text: form nSeeds]]
	cb: check "Show seeds" true [either face/data [param: 1] [param: 2]]
	button "Create" 	 [process]
	button 50 "Quit"   	 [quit]
	return 
	img: base 640x480 map
	return 
	f2: field 640
]