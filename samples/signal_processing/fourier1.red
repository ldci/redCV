#!/usr/local/bin/red
Red [
	Title:   "Signal Processing"
	Author:  "Francois Jouen"
	File: 	 %fourier1.red
	Needs:	 View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/timeseries/rcvFFT.red


imgSize: 360x128
img1: rcvCreateImage imgSize
img2: rcvCreateImage imgSize
img3: rcvCreateImage imgSize
plot1: copy []
plot2: copy []
plot3: copy []
n: 16
idx: 1

generateSignal: does [
	re: make vector! reduce ['float! 64 n] ;'
	im: make vector! reduce ['float! 64 n] ;'
	re/(idx): 1.0
]	

showSignal: does [	
	generateSignal
	img1/rgb: 0.0.0
	plot1: reduce ['line-width 1 'pen green 'line] ;'
	len: length? re
	i: 1
	repeat i len [
		repend plot1 as-pair (i * 20) 64 - (re/:i * 60)
	]
	;for period
	append plot1 as-pair (i + 1 * 20) 64 - (re/1 * 60)
	canvas1/image: draw img1 plot1
]

processSignal: does [
	factor: 60
	;FFT
	rcvFFT re im -1
	img2/rgb: 0.0.0
	plot2: reduce ['line-width 1 'pen red 'spline] ;'
	len: length? re
	i: 1
	repeat i len [
		append plot2 as-pair (i * 20) 64 - (re/:i * factor)
	]
	;for period
	append plot2 as-pair (i + 1 * 20) 64 - (re/1 * factor)
	canvas2/image: draw img2 plot2
	
	img3/rgb: 0.0.0
	plot3: reduce ['line-width 1 'pen yellow 'spline] ;'
	len: length? im
	i: 1
	repeat i len [
		append plot3 as-pair (i * 20) 64 - (im/:i * factor)
	]
	;for period
	append plot3 as-pair (i + 1 * 20) 64 - (im/1 * factor)
	canvas3/image: draw img3 plot3
]

view win: layout [
	title "Fourier [1D]"
	text 100 "Signal Position"
	sl: slider 200 [idx: 1 + to-integer sl/data * 15 f/text: form idx
			re * 0.0
			re/(idx): 1.0
			im * 0.0
			showSignal processSignal
		]
	f: field 30 "1"
	pad 50x0
	button "Quit" [Quit]
	return
	text 100 "Signal" canvas1: base imgSize black img1
	at 100x44 text "1"
	at 100x104 text "0"
	at 100x164 text "-1"
	return
	text 100 "Real" canvas2: base imgSize black img2
	at 100x184 text "1"
	at 100x244 text "0"
	at 100x304 text "-1"
	return
	text 100 "Imaginary" canvas3: base imgSize black img3
	at 100x324 text "1"
	at 100x384 text "0"
	at 100x444 text "-1"
	do [generateSignal showSignal processSignal sl/data: 0.0]
]