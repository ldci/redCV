Red [
	Title:   "Histogram tests"
	Author:  "Francois Jouen"
	File: 	 %meanShift.red
	Needs:	 View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/math/rcvHistogram.red	

isFile: false
margins: 5x5
nBins: 128
margins: 5x5
msize: 256x256
img1:    make image! reduce [msize black]
histor:  make vector! nBins		
histog:  make vector! nBins
histob:  make vector! nBins
historc: make vector! nBins
histogc: make vector! nBins
histobc: make vector! nBins

colorBW: 1
convergenceFact: 3.0

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
	; create array for RGB histograms according the number of bins 
	histo: copy []
	append/only histo make vector! nBins
	append/only histo make vector! nBins
	append/only histo make vector! nBins
	;get array histograms
	rcvRGBHistogram img1 img2 histo  ; we don't use img2 here
	histor: histo/1		; R values
	histog: histo/2		; G Values
	histob: histo/3		; B Values

	; we need maxi for Y scale conversion and plotting
	historc: make vector! nBins
	histogc: make vector! nBins
	histobc: make vector! nBins
	tmp: copy histor
	sort tmp
	maxi: last tmp
	rcvConvertMatScale/std histor historc  maxi 200 ; change scale
	tmp: copy histog
	sort tmp
	maxi: last tmp
	rcvConvertMatScale/std histog histogc  maxi 200 ; change scale
	tmp: copy histob
	sort tmp
	maxi: last tmp
	rcvConvertMatScale/std histob histobc  maxi 200 ; change scale
	
	
	; sum and mean for density probability
	sumT: to-float (img1/size/x * img1/size/y) ; image size

	histo2: copy []
	vect11: make vector! reduce ['float! 64 nBins]
	vect21: make vector! reduce ['float! 64 nBins]
	vect31: make vector! reduce ['float! 64 nBins]
	
	i: 1
	foreach v histor [vect11/:i: v / sumT i: i + 1] ; mean R
	i: 1
	foreach v histog [vect21/:i: v / sumT i: i + 1]	; mean G
	i: 1
	foreach v histob [vect31/:i: v / sumT i: i + 1]	; mean B
	; vectors for rcvMeanShift routine
	append/only histo2 vect11
	append/only histo2 vect21
	append/only histo2 vect31
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



process: does [
	processMat showPlot
	if error? try [convergenceFact: to-float f2/text] [convergenceFact: 3.0]
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
			t/text: 	form nBins
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
		f2: field 40 
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
