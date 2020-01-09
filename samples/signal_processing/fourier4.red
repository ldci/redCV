Red [
	Title:   "Signal Processing"
	Author:  "Francois Jouen"
	File: 	 %fourier4.red
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

n: to-integer (t1 * t2 / dt) ; n = 120

generateSignal: does [
	t: make vector! reduce ['float! 64 n] ;'
	i: 0 
	while [i < n] [
		t/(i + 1): i * dt
		i: i + 1
	]
	re: make vector! reduce ['float! 64 n];'
	i: 0 
	while [i < n] [
		ca: cos (2.0 * pi / t1 * t/(i + 1))
		sa: sin (2.0 * pi / t1 * t/(i + 1)) ; or / t1 -> sin
		re/(i + 1): 2.0 * (ca + sa)
		i: i + 1
	]
	img1/rgb: 0.0.0
	plot1: reduce ['line-width 1 'pen yellow 'line] ;'
	i: 1
	repeat i n [
		append plot1 as-pair i * 3 64 - (re/:i * 20)
	]
	canvas1/image: draw img1 plot1
	
]	

processSignal: does [
	im: make vector! reduce ['float! 64 n];'
	rcvFFT re im 1
	fam: rcvFFTAmplitude re im		;magnitude
	freq: rcvFFTFrequency n dt		;frequency
	f1/text: form first freq
	f2/text: form freq/((n / 2))
	f3/text: form last freq
	am: rcvFFTShift fam
	amr: rcvFFTShift re
	aim: rcvFFTShift im
	img2/rgb: 0.0.0
	plot2: reduce ['line-width 2 'pen white 'line 195x0 195X128 'pen red 'line] ;'
	len: length? re
	repeat i len [
		;append plot2 reduce ['pen red 'line] 
		;append plot2 as-pair (i * 3)  120 
		append plot2 as-pair (i * 3)  120 - (am/:i * 60.0)
		;append plot2 reduce ['pen 'off] 
	]
	canvas2/image: draw img2 plot2
	
	plot3: reduce ['line-width 2 'pen white 'line 195x0 195X128  'pen green 'line] ;'
	len: length? im
	repeat i len [
		append plot3 as-pair (i * 3) 64 - (im/:i * 60.0)
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
	text 100 "Real" canvas2: base imgSize black img2
	return
	text 100 "Imaginary" canvas3: base imgSize black img3
	return
	text 100 "Frequency"
	f1: text 50
	pad 120x0
	f2: text 50 
	pad 120x0
	f3: text 30 
	do [generateSignal processSignal]
]