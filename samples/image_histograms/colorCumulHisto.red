Red [
	Title:   "Histogram tests "
	Author:  "ldci"
	File: 	 %ColorCumulHisto.red
	Needs:	 'View
]

; required last Red Master

#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/math/rcvHistogram.red		

margins: 5x5
msize: 256x256
img1: make image! reduce [msize black]
histor: make vector! 256
histog: make vector! 256
histob: make vector! 256
bitSize: 32

loadImage: does [
	canvas1/image: none
	canvas2/draw: none
	canvas2/image: black
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage  tmp
		canvas1/image: img1
	]
]


processMat: does [
	;--get histograms as vectors
	histor: rcvHistogram/red img1
	histog: rcvHistogram/green img1
	histob: rcvHistogram/blue img1
	
	; make cumulative histograms
	sumR: sumG: sumB: 0
	repeat i 256 [sumR: sumR + histor/:i histor/:i: sumR]
	repeat i 256 [sumG: sumG + histog/:i histog/:i: sumG]
	repeat i 256 [sumB: sumB + histob/:i histob/:i: sumB]
	;--create matrices
	matR: matrix/create 2 bitSize 256x1 to-block histor
	matG: matrix/create 2 bitSize 256x1 to-block histog
	matB: matrix/create 2 bitSize 256x1 to-block histob
	
	;--change scale for visualization
	matRC: rcvConvertMatIntScale matR sumR 220 ; change scale
	marGC: rcvConvertMatIntScale matG sumG 220 ; change scale
	matBC: rcvConvertMatIntScale matB sumB 220 ; change scale
]

showPlot: does [
	plotr: copy [line-width 1 pen red line]
	plotg: copy [line-width 1 pen green line]
	plotb: copy [line-width 1 pen blue line]
	repeat i 256 [ 	append plotr as-pair i 250 - matRC/data/:i
					append plotg as-pair i 250 - marGC/data/:i
					append plotb as-pair i 250 - matBC/data/:i
	]	
	canvas2/draw: reduce [plotr plotg plotb] 
]



; ***************** Test Program ****************************
view win: layout [
		title "Histogram Tests"
		origin margins space margins
		button 100 "Load Image" 		[loadImage processMat showPlot]
		pad 340x0
		button 60 "Quit" 				[rcvReleaseImage img1 Quit]
		return
		canvas1: base msize img1
		canvas2: base msize black
		return
		pad 256x0 
		text 40 "0" 
		pad 175x0 
		text 40 right "255"
		
]
