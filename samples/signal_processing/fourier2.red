#!/usr/local/bin/red
Red [
	Title:   "Signal Processing"
	Author:  "Francois Jouen"
	File: 	 %fourier2.red
	Needs:	 View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/timeseries/rcvFFT.red
#include %../../libs/math/rcvRandom.red

random/seed now/time/precise
imgSize: 360x128

img1: rcvCreateImage imgSize
img2: rcvCreateImage imgSize
img3: rcvCreateImage imgSize
plot1: copy []
plot2: copy []
plot3: copy []
n: 16
op: 1

generateSignal: func [
	op	[integer!]
][
	re: make vector! reduce ['float! 64 n] ;'
	im: make vector! reduce ['float! 64 n] ;'
	len: length? re
	i: 1
	case [
		op = 1 [repeat i len [re/:i: cos (i * 1.0 - 1.0 * 2.0 * pi / n)]]
		op = 2 [repeat i len [re/:i: sin (i * 1.0 - 1.0 * 2.0 * pi / n)]]
		op = 3 [repeat i len [re/:i: randFloat]]
	]
]	

	
showSignal: does [	
	img1/rgb: 0.0.0
	plot1: reduce ['line-width 1 'pen green 'spline] ;'
	len: length? re
	i: 1
	repeat i len [
		append plot1 as-pair (i * 20) 64 - (re/:i * 60)
	]
	;for period
	append plot1 as-pair (i + 1 * 20) 64 - (re/1 * 60)
	canvas1/image: draw img1 plot1
]

processSignal: does [
	factor: 120.0
	;FFT
	rcvFFT re im 1
	img2/rgb: 0.0.0
	plot2: reduce ['line-width 1 'pen red 'line] ;'
	len: length? re
	i: 1
	repeat i len [
		append plot2 as-pair (i * 20)  64 - (re/:i * factor)
	]
	;for period
	append plot2 as-pair (i + 1 * 20) 64 - (re/1 * factor)
	canvas2/image: draw img2 plot2
	
	img3/rgb: 0.0.0
	plot3: reduce ['line-width 1 'pen yellow 'line] ;'
	len: length? im
	i: 1
	repeat i len [
		append plot3 as-pair (i * 20)  64 - (im/:i * factor)
	]
	;for period
	append plot3 as-pair (i + 1 * 20) 64 - (im/1 * factor)
	canvas3/image: draw img3 plot3
]

view win: layout [
	title "Fourier [1D]"
	text 100 "Signal" 
	drop-down data ["Cos" "Sin" "Random"]
		select 1
		on-change [
			op: face/selected
			generateSignal op showSignal processSignal
		]
	pad 190x0
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
	do [generateSignal op showSignal processSignal]
]