Red [
	Title:   "Signal Processing"
	Author:  "Francois Jouen"
	File: 	 %timeSeries.red
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

imgSize: 1024x128
sSize: imgSize/x
mfilter: 4
sgFilter: 1
img: rcvCreateImage imgSize
signal: none


generateSignal: function [return: [vector!]] [
	random/seed now/time/precise
	img: rcvCreateImage imgSize
	canvas2/image: none
	canvas3/image: none
	canvas4/image: none
	canvas5/image: none
	clear f/text
	plot: compose [line-width 1 pen green line]
	x: make vector! reduce ['float! 64 sSize]
	i: 0
	forall x [x/1: random 128.0  append plot as-pair  10 + i  x/1 i: i + 1]
	canvas1/image: draw img plot
	rcvTSCopySignal x
]

detrendSignal: function [serie [vector!] return: [vector!]] [
	img: rcvCreateImage imgSize
	filter: make vector! reduce ['float! 64 (length? serie)]
	rcvTSSDetrendSignal serie filter
	plot: compose [line-width 1 pen yellow line]
	i: 0
	forall filter [append plot as-pair 10 + i 64 + filter/1 i: i + 1]
	canvas2/image: draw img plot
	filter
]

normalizeSignal: function [serie [vector!] return: [vector!]] [
	img: rcvCreateImage imgSize
	filter: make vector! reduce ['float! 64 (length? serie)]
	rcvTSSNormalizeSignal serie filter
	plot: compose [line-width 1 pen red line]
	i: 0
	forall filter [append plot as-pair 10 + i  64 + ((filter/1) * 5.0) i: i + 1]
	canvas3/image: draw img plot
	filter
]

filterSignal: function [serie [vector!] return: [vector!]] [
	img: rcvCreateImage imgSize
	filter: make vector! reduce ['float! 64 (length? serie)]
	rcvTSMMFilter serie filter mfilter
	plot: compose [line-width 1 pen cyan line]
	i: 0
	forall filter [append plot as-pair 10 + i filter/1  i: i + 1]
	canvas4/image: draw img plot
	filter
]

SGfilterSignal: function [serie [vector!] return: [vector!]] [
	img: rcvCreateImage imgSize
	filter: make vector! reduce ['float! 64 (length? serie)]
	rcvSGFilter serie filter sgFilter
	plot: compose [line-width 1 pen blue line]
	i: 0
	forall filter [append plot as-pair 10 + i filter/1  i: i + 1]
	canvas5/image: draw img plot
	filter
]
 
 

view win: layout [
	title "Time Series [1024]"
	pad 1100x0
	button "Quit" [Quit]
	return
	button 150 "Generate Serie" [
		t1: now/time/precise
		signal: generateSignal
		signal2: detrendSignal signal
		signal3: normalizeSignal signal
		signal4: filterSignal signal
		signal5: SGfilterSignal signal
		t2: now/time/precise
		f/text: rejoin [rcvElapsed t1 t2 " ms"]
	]
	canvas1: base imgSize black img
	return
	text 155 "Detrended" canvas2: base imgSize black img
	return
	text 155 "Normalized" canvas3: base imgSize black img
	return
	text 115 "Filtered" ff: field 30 "4" [
		if error? try [mfilter: to-integer face/text] [mFilter: 4]
		signal4: filterSignal signal
	]
	canvas4: base imgSize black img
	return
	text 115 "Savitzky-Golay"
	fsg: field 30 "1" [
		if error? try [sgFilter: to-integer face/text] [sgFilter: 1]
		if all [sgFilter > 0 sgFilter <= 21] [ 
		signal5: SGfilterSignal signal]
	]
	
	canvas5: base imgSize black img
	return
	text 155 "Rendered in " f: field sSize	
]


