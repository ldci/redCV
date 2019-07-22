Red [
	Title:   "Faces Processing"
	Author:  "Francois Jouen"
	File: 	 %sgFilter.red
	Needs:	 'View
]
; lib for data filtering
; signal is a vector of numerical values eg [0.05 0.07 0.1.....]
; filter is a vector that contains the result of numerical processing


#include %../../libs/redcv.red ; for redCV functions
imgSize: 512x128
sSize: imgSize/x
sgFilter1: 1
sgFilter2: 12
img: rcvCreateImage imgSize
signal: none

generateSignal: function [return: [vector!]] [
	random/seed now/time/precise
	img: rcvCreateImage imgSize
	canvas2/image: none
	canvas3/image: none
	clear f/text
	plot: compose [line-width 1 pen green line]
	x: make vector! reduce ['float! 64 sSize]
	i: 0
	forall x [x/1: random 128.0  append plot as-pair i  x/1 i: i + 1]
	;forall x [x/1: 64.0 + ((sine i) * 64.0 + random 15.0)  append plot as-pair i  x/1 i: i + 1]
	canvas1/image: draw img plot
	rcvTSCopySignal x
]

SGfilterSignal: function [serie [vector!] sgFilter [integer!] canvas color ] [
	canvas/image: none
	img: rcvCreateImage imgSize
	filter: make vector! reduce ['float! 64 (length? serie)]
	rcvSGFilter serie filter sgFilter
	plot: compose [line-width 1 pen (color) line]
	i: 0
	forall filter [append plot as-pair  i filter/1  i: i + 1]
	canvas/image: draw img plot
	filter
]



view win: layout [
	title "Time Series [Savitzky-Golay 512]"
	
	button 150 "Generate Serie" [
		t1: now/time/precise
		signal: generateSignal
		SGfilterSignal signal sgFilter1 canvas2 red
		SGfilterSignal signal sgFilter2 canvas3 yellow
		t2: now/time/precise
		f/text: form t2 - t1
	]
	pad 280x0
	button "Quit" [Quit]
	return
	canvas1: base imgSize black img
	return
	text 150 "quadratic and cubic" 
	dp1: drop-down 100x24 data ["5 points" "7 points" "9 points" "11 points" "13 points" "15 points" "17 points" "19 points" "21 points" "23 points" "25 points"] 
		on-change [sgFilter1: face/selected SGfilterSignal signal sgFilter1 canvas2 red ]
	return
	canvas2: base imgSize black img
	
	return
	text 150 "quartic and quintic " 
	dp2: drop-down 100x24 data ["7 points" "9 points" "11 points" "13 points" "15 points" "17 points" "19 points" "21 points" "23 points" "25 points"] 
		on-change [sgFilter2: 11 + face/selected SGfilterSignal signal sgFilter2 canvas3 yellow]
	return
	canvas3: base imgSize black img
	return
	
	text 155 "Rendered in " f: field 250
	do [dp1/selected: dp2/selected: 1]	
]
