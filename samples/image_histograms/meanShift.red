Red [
	Title:   "Histogram tests"
	Author:  "ldci"
	File: 	 %meanShift.red
	Needs:	 View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/math/rcvHistogram.red	

isFile: false
margins: 5x5
nBins: 128
margins: 5x5
msize: 256x256
bitSize: 8
img1:    make image! reduce [msize black]
histor:  make vector! nBins		
histog:  make vector! nBins
histob:  make vector! nBins
matR: matrix/init 2 bitSize 256x1 
matG: matrix/init 2 bitSize 256x1 
matB: matrix/init 2 bitSize 256x1
colorBW: 1
convergenceFact: 3.0
;recycle/off

loadImage: does [
	tmp: request-file
	if not none? tmp [
		img1:  load  tmp
		img2: make image! reduce [img1/size black]
		canvas1/image: img1
		canvas2/draw: none
		canvas2/image: black
		canvas3/image: black
		isFile: true
	]
]


processMat: does [
	;--sum for density probability
	sumT: to-float (img1/size/x * img1/size/y) ; image size
	
	;--create arrays for RGB histograms according the number of bins 
	histo: copy []
	append/only histo make vector! nBins
	append/only histo make vector! nBins
	append/only histo make vector! nBins
	
	histo2: copy []
	vect1: make vector! reduce ['float! 64 nBins]
	vect2: make vector! reduce ['float! 64 nBins]
	vect3: make vector! reduce ['float! 64 nBins]
	
	;--get array histograms
	rcvRGBHistogram img1 img2 histo  ;--we don't use img2 here
	histor: histo/1		; R values
	histog: histo/2		; G Values
	histob: histo/3		; B Values
	
	;--calculate density probability
	repeat i nBins [vect1/:i: histor/:i / sumT]
	repeat i nBins [vect2/:i: histog/:i / sumT]
	repeat i nBins [vect3/:i: histob/:i / sumT]
	
	; vectors for rcvMeanShift routine
	append/only histo2 vect1
	append/only histo2 vect2
	append/only histo2 vect3

	;--we use maxi for scale conversion and plotting
	;--update and create matrices for visualisation
	matR/data: histo/1	
	matG/data: histo/2	
	matB/data: histo/3	
	matRC: rcvConvertMatIntScale matR matrix/maxi matR 200 ; change scale
	matGC: rcvConvertMatIntScale matG matrix/maxi matG 200 ; change scale
	matBC: rcvConvertMatIntScale matB matrix/maxi matB 200 ; change scale
]

showPlot: does [
	plotr: copy [line-width 1 pen red line]
	plotg: copy [line-width 1 pen green line]
	plotb: copy [line-width 1 pen blue line]
	step: 256 / nBins
	repeat i nBins [
		append plotr as-pair i * step 250 - matRC/data/:i
		append plotg as-pair i * step 250 - matGC/data/:i
		append plotb as-pair i * step 250 - matBC/data/:i
	]
	canvas2/draw: reduce [plotr plotg plotb]
]



process: does [
	processMat 
	showPlot
	rcvMeanShift img1 img2 histo2 to-float colorBW convergenceFact true
	canvas3/image: img2
]


; ***************** Test Program ****************************
view win: layout [
		title "Mean Shift"
		origin margins space margins
		button 100 "Load Image" [loadImage process]
		text 40 "Bins" 	
		
		sl0: slider 100 [
			nBins: 128 - to-integer face/data * 127 
			f0/text: form nBins
			t/text: form nBins		
			if nBins > 2 [process]
		]
		f0: field 40 "256"
		text "Color Bandwidth" 
		sl1: slider 100 [
				colorBW: 1 + to-integer face/data * 19 f1/text: form colorBW 
				if isFile [process]
		]
		f1: field 40 
		text "Convergence"
		f2: field 40 [
			if error? try [convergenceFact: to-float face/text] [convergenceFact: 3.0]
			if isFile [process]
		]
		pad 10x0
		button 60 "Quit" 		[Quit]
		return
		canvas1: base msize img1
		canvas2: base msize black
		canvas3: base msize black
		return
		text 256 center "Original image"
		text 40 "1" 
		text 170 center "© Red Foundation 2019" 
		t: text 40 right 
		text 250 center "Meanshift segmented image"
		do [t/text: form nBins f0/text: form nBins
			f1/text: form colorBW f2/text: form convergenceFact]
]
