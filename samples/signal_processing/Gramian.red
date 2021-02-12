
Red [
	Title:   "Gramian Angular Field"
	Author:  "Francois Jouen"
	File: 	 %Gramian.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red


imgSize: 360x180
img2Size: 360x360
sSize: imgSize/x
img: rcvCreateImage imgSize
signal: none
op: 1

generateSignal: function [op [integer!] return: [vector!] ] [
	random/seed now/time/precise
	img: rcvCreateImage imgSize
	plot: compose [line-width 1 pen green line]
	x: make vector! reduce ['float! 64 sSize]
	i: 0
	case [
		op = 0 [forall x [x/1: random 180.0   append plot as-pair i  x/1 i: i + 1]]
		op = 1 [forall x [x/1: 64.0 * sine i  append plot as-pair i  90 - x/1 i: i + 1]]
	]
	canvas1/image: draw img plot
	x
]


normalizeSignal: function [signal [vector!] return: [vector!]
][
	tmp: copy signal
	sort tmp
	minVal: first tmp
	maxVal: last tmp
	x: copy []
	;[ -1.0 .. 1.0]
	foreach val signal [
		xn: (2 * val - maxVal - minVal) / (maxVal - minVal)
		; Floating point inaccuracy!
		if xn >= 1.0 [xn: 1.0]
		if xn <= -1.0 [xn: -1.0]
		append x xn
	]
	make vector! reduce x
]



polarizeSignal: function [signal [vector!] return: [block!]
][
	n: to float! length? signal
	polar: copy []
	i: 1
	foreach val signal [
		theta: arccosine/radians val
		rho: i / n
		blk: copy []
		append blk theta 
		append blk rho
		append/only polar blk
		i: i + 1
	]
 	polar
]


makeGramianMat: function [signal [block!] return: [object!]][
	lg: length? signal
	blk: copy []
	i: 1
	while [i <= lg] [
		j: 1
		while [j <= lg ] [
			v: cosine/radians ((first signal/:i) + (first signal/:j))
			append blk FFh AND to integer! (v * 255)
			;append blk 255 - to integer! (v * 255)
			j: j + 1
		]
		i: i + 1
	]
	matrix/create 2 32 as-pair lg lg blk
]

processSignal: does [
	signal: generateSignal op
	scaled: normalizeSignal signal
	polar:  polarizeSignal scaled
	gMat: 	makeGramianMat polar
	img: 	rcvCreateImage as-pair sSize sSize
	rcvMat2Image gMat img
	canvas2/image: img
]



view win: layout [
	title "Gramian Angular Field"
	button 150 "Generate Serie" [processSignal]
	cb: check "Random" 			[either face/data [op: 0] [op: 1]]
	pad 40x0
	button "Quit" 				[Quit]
	return
	canvas1: base imgSize black img
	return
	canvas2: base img2Size  black
]

