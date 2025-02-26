#!/usr/local/bin/red
Red [
	Title:   "Signal Processing"
	Author:  "ldci"
	File: 	 %extrema.red
	Needs:	 'View
]
;'
imgSize: 1024x128
sSize: imgSize/x
img1: make image! imgSize
img2: make image! imgSize
img3: make image! imgSize
xStep: 0.1
xRound: 0.5
x2: copy []
signal: make vector! reduce ['float! 64 sSize];'

;--The differentiated values are calculated by averaging the slopes 
;--of two adjacent points for each data point
;--must be executed in terminal mode


rcvTSdifferentiate: function [
	"Calculate the derivative of function"
	signal	[vector!]	;--float vector
	deltaT	[float!]	;--x step
	factor	[float!]	;--for rounding (0.5 by default)		
][
	n: length? signal
	filter: make vector! reduce ['float! 64 n]
	i: 2
	while [i < n] [
		y-: signal/(i - 1) y: signal/:i y+: signal/(i + 1)
		x-: i * deltaT - deltaT x: i * deltaT  x+: i * deltaT + deltaT
		average: factor * (((y+ - y) / (x+ - x)) + ((y - y-) / (x - x-)))
		filter/:i: average
		i: i + 1
	]
	filter/1: filter/2		;--first point
	append filter average	;--last point
	filter
]


generateSignal: does [
	random/seed now/time/precise
	clear peaks/data
	sb/text: ""
	img1/rgb: black
	canvas2/image: none
	canvas3/image: none
	dt: xStep t1: 2.5 t2: 6.5
	t: make vector! reduce ['float! 64 sSize] ;'
	i: 1 
	while [i <= sSize] [
		t/:i: (i - 1) * dt
		i: i + 1
	]
	signal: make vector! reduce ['float! 64 sSize];'
	i: 1 
	while [i <= sSize] [
		ca: cos (2.5 * pi / t1 * t/:i)
		sa: sin (2.5 * pi / t2 * t/:i)
		either cb/data 	[signal/:i: 2.5 * sa + ca] 
						[signal/:i: 2.5 * sa]
		i: i + 1
	]
	img1/rgb: 0.0.0
	plot1: reduce ['line-width 1 'pen green 'line] ;'
	i: 1
	repeat i sSize [
		append plot1 as-pair i + 10 64 - (signal/:i * 16)
	]
	canvas1/image: draw img1 plot1
	
]	


derivate: does [
	clear peaks/data
	img2/rgb: black
	img3/rgb: black
	canvas2/image: none
	canvas3/image: none
	x2: rcvTSdifferentiate signal xStep	xRound 
	plot2: compose [line-width 1 pen green line 0x64 1024x64 pen red line]
	i: 1
	;forall x2 [append plot2 as-pair i + 10 64 - (x2/1 * 8) i: i + 1]
	foreach v x2 [append plot2 as-pair i + 10 64 - (v * 8) i: i + 1]
	canvas2/image: draw img2 plot2
]

getExtrema: does [
	sb/text: ""
	clear peaks/data
	img3/rgb: black
	plot3: compose [line-width 1 pen orange line]
	tt1: now/time/precise
	i: 1
	forall x2 [
		if (round x2/1) = 0.0 [
			y: signal/:i
			unless none? y [
				append peaks/data rejoin [i " : " round/to y 0.001]
				either (sign? y) = 1 [y: 10][y: 118]
				append plot3 as-pair i + 11 y 
			] 
		]
		i: i + 1
	]
	tt2: now/time/precise
	canvas3/image: draw img3 reduce [plot1 plot3]
	elapsed: to-integer (third tt2 - tt1) * 1000
	sb/text: rejoin ["Extrema found in: " form elapsed " msec"]
]

readFile: does [
	canvas2/image: none
	canvas3/image: none
	f: load %synchro2.txt
	n: length? f
	signal: make vector! reduce ['float! 64 n]
	repeat i n [signal/:i: to-float f/:i / 5]
	img1/rgb: 0.0.0
	plot1: reduce ['line-width 1 'pen green 'line] ;'
	i: 1
	repeat i n [
		append plot1 as-pair i + 20 64 - (signal/:i )
	]
	canvas1/image: draw img1 plot1
]

view win: layout [
	title "Time Series [Extrema]"
	button "File" [readFile ]
	button 150 "Generate Serie" [generateSignal]
	cb: check "Add Noise"  [generateSignal]
	button 150 "Differentiate Serie"  [derivate ]
	button 150 "Get Extrema" [getExtrema]
	text 50 top bold "Delta X"
	field 40 "0.1" [
		if error? try [xStep: to-float face/text][xStep: 0.1] 
		if xStep > 0.0 [generateSignal derivate getExtrema]
	]
	text 100 middle bold "Round Factor" 
	field 40 "0.5" [
		if error? try [xRound: to-float face/text][xRound: 0.5] 
		if xRound > 0.0 [generateSignal derivate getExtrema]
	]
	pad 140x0
	button "Quit" [Quit]
	return
	canvas1: base imgSize black img1
	return
	canvas2: base imgSize black img2
	return
	canvas3: base imgSize black img3
	return
	sb: field sSize
	at 1040x50 peaks: text-list 100x405 data []
]
