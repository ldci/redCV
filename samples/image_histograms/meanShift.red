#! /usr/local/bin/red
Red [
	Title:   "Histogram tests "
	Author:  "Francois Jouen"
	File: 	 %meanShift.red
	Needs:	 View
]

#include %../../libs/redcv.red ; for red functions

margins: 5x5
msize: 256x256
nBins: 4
margins: 5x5
msize: 256x256
img1:    make image! reduce [msize black]
histor:  make vector! nBins
histog:  make vector! nBins
histob:  make vector! nBins
historc: make vector! nBins
histogc: make vector! nBins
histobc: make vector! nBins

colorBW: 3.0
convergenceFact: 3.0

loadImage: does [
	tmp: request-file
	if not none? tmp [
		img1:  load  tmp
		canvas1/image: img1
		canvas2/draw: none
		canvas2/image: black
		canvas3/image: black
		img2: make image! reduce [img1/size black]
		do-events/no-wait
	]
]


processMat: does [
	histo: copy []
	append/only histo make vector! nBins
	append/only histo make vector! nBins
	append/only histo make vector! nBins
	
	rcvRGBHistogram img1 histo
	histor: histo/1		; R values
	histog: histo/2		; G Values
	histob: histo/3		; B Values
	; we need maxi for Y scale conversion
	
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
	
	
	; sum and  mean for density probability
	sumT: 0.0
	foreach v histor [sumT: sumT + v] 
	histo2: copy []
	vect11: make vector! reduce ['float! 64 nBins]
	vect21: make vector! reduce ['float! 64 nBins]
	vect31: make vector! reduce ['float! 64 nBins]
	;'
	i: 1
	foreach v histor [vect11/:i: v / sumT i: i + 1]
	i: 1
	foreach v histog [vect21/:i: v / sumT i: i + 1]
	i: 1
	foreach v histob [vect31/:i: v / sumT i: i + 1]
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
	;canvas3/image: img2
]



process: does [
	processMat showPlot
	rcvMeanShift img1 img2 histo2 colorBW convergenceFact
	canvas3/image: img2
]


; ***************** Test Program ****************************
view win: layout [
		title "Mean Shift"
		origin margins space margins
		button 100 "Load Image" [loadImage process]
		text 60 "Bins" 	
		dp: drop-down 60 data ["4" "6" "8" "10" "12" "14" "16" "18" "20" "22" "24" "26" "28" "30"]
		select 1
		on-change [
			nBins: to-integer face/data/(face/selected)
			t/text: form nBins
			process
		]	
		

		text "Color Bandwidth" 
		f1: field 50 [if error? try [colorBW: to-float face/text][colorBW: 3.0] process]
		text "Convergence" 
		f2: field 50 [if error? try [convergenceFact: to-float face/text][convergenceFact: 3.0] process]
		pad 160x0
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
		do [t/text: form nBins f1/text: form colorBW f2/text: form convergenceFact]
]
