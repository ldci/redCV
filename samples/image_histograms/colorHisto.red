Red [
	Title:   "Histogram tests "
	Author:  "Francois Jouen"
	File: 	 %colorHisto.red
	Needs:	 'View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/math/rcvHistogram.red	


margins: 5x5
msize: 256x256
img1: make image! reduce [msize black]
bitSize: 8
histor: matrix/init 2 bitSize 256x1	
histog: matrix/init 2 bitSize 256x1	
histob: matrix/init 2 bitSize 256x1	
historgb: matrix/init 2 bitSize 256x1
smooth: false
recycle/off ; avoid GC for matrices

loadImage: does [
	canvas1/image: none
	canvas2/image: black
	canvas3/image: black
	canvas2/draw: none
	canvas3/draw: none
	tmpf: request-file
	if not none? tmpf [
		img1: rcvLoadImage  tmpf
		canvas1/image: img1
	]
]


processMat: does [
	;--update matrices data with vectors
	;--rcvHistoImg returns 32-bit vectors
	histor/data: rcvHistoImg img1 1	;R 
	histog/data: rcvHistoImg img1 2	;G
	histob/data: rcvHistoImg img1 3	;B
	historgb/data: rcvHistoImg img1 4 ;Grayscale
	
	;--we need maxi for scale conversion
	historc: rcvConvertMatIntScale histor matrix/maxi histor 200 ; change scale
	histogc: rcvConvertMatIntScale histog matrix/maxi histog 200 ; change scale
	histobc: rcvConvertMatIntScale histob matrix/maxi histob 200 ; change scale
	historgbc: rcvConvertMatIntScale historgb matrix/maxi historgb 200 ; change scale
	if smooth [
		tmp: rcvSmoothHistogram historc historc: tmp
		tmp: rcvSmoothHistogram histogc histogc: tmp
		tmp: rcvSmoothHistogram histobc histobc: tmp
		tmp: rcvSmoothHistogram historgbc historgbc: tmp
	]
]

showPlot: does [
	plotr:		copy [line-width 1 pen red line]
	plotg:		copy [line-width 1 pen green line]
	plotb:		copy [line-width 1 pen blue line]
	plotrgb:	copy [line-width 1 pen white line]
	
	repeat i 256 [
		append plotr as-pair i 250 - historc/data/:i
		append plotg as-pair i 250 - histogc/data/:i
		append plotb as-pair i 250 - histobc/data/:i
		append plotrgb as-pair i 250 - historgbc/data/:i
	]		
	canvas2/draw: reduce [plotr plotg plotb] 
	canvas3/draw: reduce [plotrgb] 
]

; ***************** Test Program ****************************
view win: layout [
		title "Color Histogram"
		origin margins space margins
		button 100 "Load Image" 		[loadImage processMat showPlot]
		check  150 "Smooth Histogram" 	[smooth: face/data processMat showPlot]
		text   256 "RGB Channels"
		text   140 "Grayscale"
		pad 40x0
		button 60 "Quit" 				[rcvReleaseImage img1 recycle/on Quit]
		return
		canvas1: base msize black
		canvas2: base msize black
		canvas3: base msize black
		return
		pad 256x0 
		text 40 "0" 
		pad 175x0 
		text 40 right "255"
		text 40 "0" 
		pad 170x0 
		text 40 right "255"
]
