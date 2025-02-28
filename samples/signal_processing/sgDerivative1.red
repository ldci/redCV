Red [
	Title:   "Signal Processing"
	Author:  "ldci"
	File: 	 %sgDerivative.red
	Needs:	 'View
]
; lib for data filtering
; signal is a vector of numerical values eg [0.05 0.07 0.1.....]
; filter is a vector that contains the result of numerical processing

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/timeseries/rcvTS.red	
#include %../../libs/timeseries/rcvSGF.red	


imgSize: 512x128
sSize: imgSize/x
sgFilter1: 1
sgFilter2: 12
sgFilter3: 23
img: rcvCreateImage imgSize
signal: none

generateSignal: function [return: [vector!]] [
	random/seed now/time/precise
	img: rcvCreateImage imgSize
	canvas2/image: none
	canvas3/image: none
	canvas4/image: none
	clear f/text
	plot: compose [line-width 1 pen green line]
	x: make vector! reduce ['float! 64 sSize]
	i: 0
	forall x [x/1: random 128.0  append plot as-pair i x/1 i: i + 1]
	canvas1/image: draw img plot
	rcvTSCopySignal x
]

SGfilterSignal: function [serie [vector!] sgFilter [integer!] canvas color ] [
	canvas/image: none
	img: rcvCreateImage imgSize
	filter: make vector! reduce ['float! 64 (length? serie)]
	rcvSGDerivative1 serie filter sgFilter
	plot: compose [line-width 1 pen (color) line]
	i: 0
	forall filter [append plot as-pair i 64 + filter/1  i: i + 1]
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
		SGfilterSignal signal sgFilter3 canvas4 blue
		t2: now/time/precise
		f/text: rejoin ["Rendered in "  rcvElapsed t1 t2 " ms"] 
	]
	pad 280x0
	button "Quit" [Quit]
	return
	canvas1: base imgSize black img
	return
	text 150 "Derivative 1 quadratic" 
	dp1: drop-down 100x24 data ["5 points" "7 points" "9 points" "11 points" "13 points" "15 points" "17 points" "19 points" "21 points" "23 points" "25 points"] 
		on-change [sgFilter1: face/selected SGfilterSignal signal sgFilter1 canvas2 red ]
	return
	canvas2: base imgSize black img
	
	return
	text 150 "Derivative 1 quartic" 
	dp2: drop-down 100x24 data ["5 points" "7 points" "9 points" "11 points" "13 points" "15 points" "17 points" "19 points" "21 points" "23 points" "25 points"] 
		on-change [sgFilter2: 11 + face/selected SGfilterSignal signal sgFilter2 canvas3 yellow]
	return
	canvas3: base imgSize black img
	return
	
	return
	text 150 "Derivative 1 quintic sextic" 
	dp3: drop-down 100x24 data ["7 points" "9 points" "11 points" "13 points" "15 points" "17 points" "19 points" "21 points" "23 points" "25 points"] 
		on-change [sgFilter3: 22 + face/selected SGfilterSignal signal sgFilter3 canvas4 blue]
	return
	canvas4: base imgSize black img
	return
	
	f: field 512
	do [dp1/selected: dp2/selected: 1 dp3/selected: 1]	
]
