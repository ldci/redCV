#!/usr/local/bin/red
Red [
	Title:   "Signal Processing"
	Author:  "Francois Jouen"
	File: 	 %fourier5.red
	Needs:	 View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/timeseries/rcvFFT.red

imgSize: 532x128
img1: rcvCreateImage imgSize
img2: rcvCreateImage imgSize
img3: rcvCreateImage imgSize
plot1: copy []
plot2: copy []
plot3: copy []
n: 512
generateSignal: does [
	random/seed now/time/precise
	img1/rgb: 0.0.0
	re: make vector! reduce ['float! 64 n] ;'real
	im: make vector! reduce ['float! 64 n] ;'imaginary
	plot1: reduce ['line-width 1 'pen green 'spline] ;'
	len: length? re
	repeat i len [
		re/:i: random 128.0
		append plot1 as-pair i + 10  re/:i
	]
	canvas1/image: draw img1 plot1
]

processSignal: does [
	;FFT and Magnitude
	rcvFFT re im 1 1
	am: rcvFFTAmplitude re im
	amc: rcvFFTShift am
	img2/rgb: 0.0.0
	plot2: reduce ['line-width 1 'pen red 'line] ;'
	len: length? am
	repeat i len [
		append plot2 as-pair i + 10 am/:i * 32.0
	]
	canvas2/image: draw img2 plot2
	
	;inverse FFT
	rcvFFT re im -1 1
	img3/rgb: 0.0.0
	plot3: reduce ['line-width 1 'pen green 'spline] ;'
	len: length? re
	repeat i len [
		append plot3 as-pair i + 10 (re/:i + im/:i)
	]
	canvas3/image: draw img3 plot3
]

view win: layout [
	title "Fourier [512]"
	pad 90x0
	button 150 "Generate Signal" [
		generateSignal 
		processSignal
	]
	pad 300x0
	button "Quit" 		[Quit]
	return
	text "Signal" 		canvas1: base imgSize black img1
	return
	text "Amplitude" 	canvas2: base imgSize black img2
	return
	text "Inverse FFT" 	canvas3: base imgSize black img3
]