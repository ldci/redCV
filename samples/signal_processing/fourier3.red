#!/usr/local/bin/red
Red [
	Title:   "Signal Processing"
	Author:  "Francois Jouen"
	File: 	 %fourier3.red
	Needs:	 View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/timeseries/rcvFFT.red


imgSize: 390x128
img1: rcvCreateImage imgSize
img2: rcvCreateImage imgSize
img3: rcvCreateImage imgSize
plot1: copy []
plot2: copy []
plot3: copy []

dt: 0.1
t1: 2.0
t2: 6.4

n: to-integer (t1 * t2 / dt) ; n = 128

generateSignal: does [
	t: make vector! reduce ['float! 64 n] ;'
	i: 1 
	while [i <= n] [
		t/:i: (i - 1) * dt
		i: i + 1
	]
	re: make vector! reduce ['float! 64 n];'
	i: 1 
	while [i <= n] [
		ca: cos (2.0 * pi / t1 * t/:i)
		sa: sin (2.0 * pi / t2 * t/:i)
		re/:i: 2.0 * ca + sa
		i: i + 1
	]
	img1/rgb: 0.0.0
	plot1: reduce ['line-width 1 'pen green 'line] ;'
	i: 1
	repeat i n [
		append plot1 as-pair i * 3 64 - (re/:i * 20)
	]
	canvas1/image: draw img1 plot1
	
]	

processSignal: does [
	generateSignal
	im: make vector! reduce ['float! 64 n];'
	
	;FFT
	rcvFFT re im 1 1
	
	;freq: rcvFFTFrequency n dt	; frequency
	;probe freq
	
	
	am: rcvFFTAmplitude re im
	amc: rcvFFTShift am
	
	fph: rcvFFTPhase re im true
	ff: rcvFFTShift fph
	
	img2/rgb: 0.0.0
	plot2: reduce ['line-width 1 'pen red 'line] ;'
	len: length? am
	i: 1
	repeat i n [
		;append plot2 as-pair (i * 3)  64 - (am/:i * 60)
		append plot2 as-pair (i * 3)  64 - (amc/:i * 60)
	]
	canvas2/image: draw img2 plot2
	
	img3/rgb: 0.0.0
	plot3: reduce ['line-width 1 'pen yellow 'line] ;'
	i: 1
	repeat i n [
		append plot3 as-pair (i * 3)  64 - (ff/:i / 5)
	]
	canvas3/image: draw img3 plot3
]



view win: layout [
	title "Fourier [1D]"
	button "Close" [Quit]
	return
	text 100 "Signal" canvas1: base imgSize black img1
	at 100x44 text "1"
	at 100x104 text "0"
	at 100x164 text "-1"
	return
	text 100 "Magnitude" canvas2: base imgSize black img2
	at 100x184 text "1"
	at 100x244 text "0"
	at 100x304 text "-1"
	return
	text 100 "Phase" canvas3: base imgSize black img3
	at 100x324 text "1"
	at 100x384 text "0"
	at 100x444 text "-1"
	do [generateSignal processSignal]
]