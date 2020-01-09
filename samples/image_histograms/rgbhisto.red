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
img1:    make image! reduce [msize black]
img2:    make image! reduce [msize black]
histor:  make vector! nBins
histog:  make vector! nBins
histob:  make vector! nBins
historc: make vector! nBins
histogc: make vector! nBins
histobc: make vector! nBins


loadImage: does [
	canvas1/image: none
	canvas2/draw: none
	canvas2/image: black
	tmp: request-file
	if not none? tmp [
		img1:  load  tmp
		canvas1/image: img1
		img2: make image! reduce [img1/size black]
	]
]


processMat: does [
	histo: copy []
	append/only histo make vector! nBins
	append/only histo make vector! nBins
	append/only histo make vector! nBins
	
	rcvRGBHistogram img1 img2 histo
	histor: histo/1		; R values
	histog: histo/2		; G Values
	histob: histo/3		; B Values
	; we need maxi for Y scale conversion
	maxi: rcvMaxMat histor
	rcvConvertMatScale/std histor historc  maxi 200 ; change scale
	
	maxi: rcvMaxMat histog
	rcvConvertMatScale/std histog histogc  maxi 200 ; change scale
	
	maxi: rcvMaxMat histob
	rcvConvertMatScale/std histob histobc  maxi 200 ; change scale
	canvas3/image: img2
]

showPlot: does [
	plotr: copy [line-width 1 pen red line]
	plotg: copy [line-width 1 pen green line]
	plotb: copy [line-width 1 pen blue line]
	
	i: 1 
	step: 256 / nBins
	while [i < nBins] [ coord: as-pair (i * step) (250 - historc/(i))
						append plotr coord
						coord: as-pair (i * step) (250 - histogc/(i))
						append plotg coord
						coord: as-pair (i * step) (250 - histobc/(i))
						append plotb coord
						i: i + 1]				
	canvas2/draw: reduce [plotr plotg plotb] 
]


; ***************** Test Program ****************************
view win: layout [
		title "Histogram Filtering"
		origin margins space margins
		button 100 "Load Image" [loadImage processMat showPlot]
		pad 150x0
		text 60 "Bins" 	
		sl: slider 140 [nBins: 256 - to-integer face/data * 255 
			f1/text: 	form nBins
			t/text: 	form nBins
			if nBins > 2 [processMat showPlot]
		]
		f1: field 50 "256"
		
		pad 160x0
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
