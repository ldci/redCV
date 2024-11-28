#! /usr/local/bin/red
Red[
	needs: view
]

size: 100x100
map: make image! reduce [size black]

nSites: 10
sc: []
sx: []
sy: []

dot: func [x y] [sqrt (x * x) + (y * y)]

randomSites: does [
	random/seed now/time
	sx: copy []
	sy: copy []
	sc: copy []
	i: 1 
	while [i <= nSites] [
		append sx random size/x
		append sy random size/y
		append sc random white
		i: i + 1
	]
]

generateVoronoi: does [
	;map: make image! reduce [size black]
	img/image/argb: black
	; distance map
	repeat y size/y [
		repeat x size/x [
			dMin: dot size/x size/y
			repeat s nSites [
				d: dot (sx/:s - x) (sy/:s - y)
				if d < dMin [
					sMin: s
					dMin: d
				]
			]
			img/image/(as-pair x y): sc/:sMin
			do-events/no-wait
		]
	]
	;show seeds
	repeat i nSites [
		x: sx/:i
		y: sy/:i
		img/image/(as-pair x y): black
		;map/(as-pair x y): black
	]
	;img/image: map
]


view win: layout [
	title "Voronoï Diagram"
	text "Seeds Number" f: field 50 "10" [if error? try [nSites: to-integer f/text] [nSites: 10]]
	button "Create" 	 [randomSites generateVoronoi]
	button 50 "Quit"   	 [quit]
	return 
	img: base 400x400 map
]