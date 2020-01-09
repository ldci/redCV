#! /usr/local/bin/red
Red [
	Title:   "Draw tests: rcvDegree2xy "
	Author:  "Francois Jouen"
	Needs:	 View
]

; required libs
#include %../../libs/tools/rcvTools.red
#include %../../libs/math/rcvDistance.red

center: 200x200
freq: 64
buffer: []

generate: does [
	if angle > 359 [angle: 0]
	xy: center + rcvDegree2xy 150 angle
	f/text: rejoin [form angle ": " xy]
	buffer: compose [line-width 2 pen red  
			fill-pen aqua circle (center) 156
			pen red fill-pen blue circle (center) 3] 
	repend buffer ['line center xy 'circle xy 6];
	canvas/draw: buffer
	angle: angle + 1
]

view win: layout [
	title "rcvDegree2xy test"
	text 30 bold  "On"
	sl: slider 30  	[if face/data = 0 [canvas/rate: none] 
					 if face/data = 1 [canvas/rate: freq]
					]
	f: field 90
	sl2: slider 100 [freq: 1 + to-integer face/data * 255 
					f2/text: form freq  canvas/rate: freq
					]
	
	f2: field 40 "64"
	button "Quit" 	[quit]
	return
	canvas: base 400x400 ivory 
	on-time [Generate]
	do [angle: 0 generate canvas/rate: none sl2/data: 25%]
]
