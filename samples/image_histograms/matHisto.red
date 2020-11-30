Red [
	Title:   "Histogram tests "
	Author:  "Francois Jouen"
	File: 	 %MatHisto.red
	Needs:	 'View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/math/rcvHistogram.red	

margins: 5x5
mSize: 262x256
bitSize: 8
img1: rcvCreateImage mSize

processMat: does [
	mx: matrix/init/value/rand 2 bitSize mSize 255
	color: random white
	rcvMat2Image mx img1
	vHisto: copy rcvHistoMat mx ;--or vHisto: rcvHistogram mx;
	tmp: copy vHisto
	sort tmp
	maxi: last tmp
	canvas1/image: img1
]

showPlot: does [
	plot: compose [line-width 1 pen (color) line]
	repeat i 256 [
		append plot as-pair i + 2 256
		v: to-integer (vHisto/:i / maxi) * 180
		append plot as-pair i + 2 256 - v
	]
	canvas2/draw: reduce [plot] 
]



; ***************** Test Program ****************************
view win: layout [
		title "Histogram Tests: 8-bit"
		origin margins space margins
		button 120 "Generate Matrix"	[processMat showPlot]
		button 60 "Quit" 				[rcvReleaseImage img1 Quit]
		return
		canvas1: base msize img1
		canvas2: base black msize
]
