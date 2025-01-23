#!/usr/local/bin/red-view
Red [
	Title:   "Draw tests: rcvDegree2xy "
	Author:  "ldci"
	Needs:	 View
]
;-- Thanks to gurzgri for help
radius: 150
center: 200x200
freq:   64

;-- from RedCV lib
rcvdegree2xy: func [									
	"Returns XY coordinates from angle and distance between 2 points"
	radius [number!] "distance"
	angle  [number!] "degrees"
][
	as-pair radius * cosine angle radius * sine angle 
]

generate: does [
	fa/text: form angle
	fc/text: form round/to cos: cosine  angle 0.0001
	fs/text: form round/to sin: sine    angle 0.0001
	ft/text: form round/to tan: tangent angle 0.0001
	xy:  center + rcvdegree2xy radius + 6 angle			;--xy distance as pair (c: hypothenuse)
	cxy: as-pair  xy/x - cos center/y					;--cosine distance only x is changed (b: base)
	sxy: as-pair cxy/x xy/y								;--sine distance x and y are modified (a: height)
	t1:  xy + rcvdegree2xy radius + 5 angle + 90		;--tangent point 1 for drawing
	t2:  xy + rcvdegree2xy radius - 305 angle + 90		;--tangent point 2 for drawing
	;--pixel size for rectangle ABC
	a: absolute (sxy/y - center/y)
	b: absolute (cxy/x - center/x)
	c: round/to square-root ((power a 2) + (power b 2)) 0.01
	fp/text: form angle
	fpa/text: form a
	fpb/text: form b
	fpc/text: form c
	canvas/draw: compose [
		line-width 2 pen red  
		fill-pen white circle (center) 156
		pen red fill-pen blue circle (center) 3
		fill-pen ivory line (center) (xy) circle (xy) 6 
		pen blue 
		;line (center) (cxy) (sxy)
		triangle (center) (cxy) (sxy)
		pen black line (t1) (t2)
	]
	angle: angle + 1 % 360
]

view layout [
	title "Cosine Sine Animation"
	
	text "Frequency" 
	fr: field 50 [if error? try [freq: to-integer face/text] [freq: 64]]

	
	toggle 50 "Start" false [	
			either face/data [face/text: "Stop" canvas/rate: freq]
							[face/text: "Start" canvas/rate: none]	
		] 	
	
	pad 110x0
	button "Quit"  [unview]
	return
	base 400x1 blue return
	text 40 "Angle" fa: field 30
	text 30 "Cos"   fc: field 50
	text 30 "Sin"   fs: field 50
	text 30 "Tan"   ft: field 50
	return 
	text 40 "Angle" fp: field 30
	text 30 "AB"	fpc: field 50
	text 30 "AC"	fpb: field 50
	text 30 "BC" 	fpa: field 50
	return 
	base 400x1 blue return
	canvas: base 400x400 ivory on-time [generate]
	do [angle: 0 generate canvas/rate: none fr/text: form freq]
]