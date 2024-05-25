#! /usr/local/bin/red
Red [
	Title:   "Histogram tests "
	Author:  "Francois Jouen"
	File: 	 %rgbHisto.red
	Needs:	 View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/math/rcvHistogram.red	

margins: 5x5
msize: 256x256
nBins: 256
margins: 5x5
msize: 256x256
bitSize: 8
img1: make image! reduce [msize black]
img2: make image! reduce [msize black]
matR: matrix/init 2 bitSize 256x1 
matG: matrix/init 2 bitSize 256x1 
matB: matrix/init 2 bitSize 256x1 

loadImage: does [
	canvas1/image: none
	canvas2/draw: none
	canvas2/image: black
	tmp: request-file
	unless none? tmp [
		img1:  load  tmp
		canvas1/image: img1
		img2: make image! reduce [img1/size black]
	]
]


processMat: does [
	;--an array: block of vectors
	histo: copy []
	append/only histo make vector! nBins
	append/only histo make vector! nBins
	append/only histo make vector! nBins
	
	;--get histograms as vectors
	rcvRGBHistogram img1 img2 histo 
	;--make matrices
	matR/data: histo/1
	matG/data: histo/2
	matB/data: histo/3
	; we need maxi for Y scale conversion
	matRC: rcvConvertMatIntScale matR matrix/maxi matR 200
	matGC: rcvConvertMatIntScale matG matrix/maxi matG 200
	matBC: rcvConvertMatIntScale matB matrix/maxi matB 200
	canvas3/image: img2
]

showPlot: does [
	plotr: copy [line-width 1 pen red line]
	plotg: copy [line-width 1 pen green line]
	plotb: copy [line-width 1 pen blue line]
	step: 256 / nBins
	repeat i nBins[
		append plotr as-pair (i * step) (250 - matRC/data/:i) 
		append plotg as-pair (i * step) (250 - matGC/data/:i)
		append plotb as-pair (i * step) (250 - matBC/data/:i)
	]
			
	canvas2/draw: reduce [plotr plotg plotb] 
]

; ***************** Test Program ****************************
view win: layout [
		title "Histogram Filtering"
		origin margins space margins
		button 100 "Load Image" [loadImage processMat showPlot]
		pad 150x0
		text 60 "Bins" 	
		drop-down 60 data ["256" "128" "64" "32" "16"]
			on-change [nBins: to-integer face/text face/selected 
				f1/text: form nBins
				t/text:  form nBins
				processMat showPlot
			]
			select 1
		f1: field 50 "256"
		pad 265x0
		button 60 "Quit" 		[Quit]
		return
		canvas1: base msize img1
		canvas2: base msize black
		canvas3: base msize black
		return
		pad 256x0 
		text 40 "1" 
		text 170 center "© Red Foundation 2019"
		t: text 40 right 
		do [t/text: form nBins]
]
