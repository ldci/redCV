Red[
	Title:   "Red Computer Vision: rcvHaar Wavelet tests"
	Author:  "ldci"
	File: 	 %wavelet.red
	Tabs:	 4
	Rights:  "Copyright (C) 2021 ldci. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

#include %../../libs/timeseries/rcvWavelet.red

imgSize: 1024x128
sSize: imgSize/x
img1: make image! imgSize
img2: make image! imgSize
img3: make image! imgSize
signal: make vector! reduce ['float! 64 sSize];
m: round/down log-2  length? signal ;--we need a 2^m integer value

generateSignal: does [
	clear sb/text
	random/seed now/time/precise
	img1/rgb: 0.0.0
	canvas2/image: none
	canvas3/image: none
	tt1: now/time/precise
	;--original signal
	img1/rgb: 0.0.0
	plot1: reduce ['line-width 1 'pen green 'line] ;'
	repeat i sSize [append plot1 as-pair i + 10 signal/:i: random 128.0]
	canvas1/image: draw img1 plot1
	
	;--wavelet transform
	img2/rgb: 0.0.0
	either cb/data [rcvHaarNormalized signal m] [rcvHaar signal m]
	plot2: reduce ['line-width 1 'pen yellow 'line] ;'
	repeat i sSize [append plot2 as-pair i + 10 64 - signal/:i]
	canvas2/image: draw img2 plot2
	
	;--go back to original signal
	img3/rgb: 0.0.0 
	either cb/data [rcvHaarNormalizedInverse signal m] [rcvHaarInverse signal m]
	plot3: reduce ['line-width 1 'pen green 'line] ;'
	repeat i sSize [append plot3 as-pair i + 10 signal/:i]
	canvas3/image: draw img3 plot3
	tt2: now/time/precise
	elapsed: to-integer (third tt2 - tt1) * 1000
	sb/text: rejoin ["Signals in: " form elapsed " msec"]
]

view win: layout [
	title "Time Series [rcvHaar Wavelet]"
	cb: check "Normalized" 			[generateSignal]
	button 150 "Generate Signal" 	[generateSignal]
	pad 700x0
	button "Quit" 					[Quit]
	return
	text 300  "Original Signal" 
	return
	canvas1: base imgSize black img1
	return
	text 300 "rcvHaar Wavelet Transform " 
	return
	canvas2: base imgSize black img2
	return
	text 300 "rcvHaar Inverse -> Original Signal" 
	return 
	canvas3: base imgSize black img3
	return
	sb: field sSize
]
