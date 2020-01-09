Red [
	Title:   "Histogram tests "
	Author:  "Francois Jouen"
	File: 	 %colorHisto.red
	Needs:	 'View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/math/rcvHistogram.red	


margins: 5x5
msize: 256x256
img1: 		make image! reduce [msize black]
histor: 	make vector! 256	; R
histog: 	make vector! 256	; G
histob: 	make vector! 256	; B
historgb:	make vector! 256	; grayscale
historc: 	make vector! 256	; R scaled
histogc: 	make vector! 256	; G scaled
histobc: 	make vector! 256	; B scaled
historgbc: 	make vector! 256	; grayscale Scaled

smooth: false
recycle/off ; for keeping matrices alive

loadImage: does [
	canvas1/image: none
	canvas2/image: black
	canvas3/image: black
	canvas2/draw: none
	canvas3/draw: none
	tmpf: request-file
	if not none? tmpf [
		img1:  rcvLoadImage  tmpf
		canvas1/image: img1
	]
]


processMat: does [
	histor: 	rcvHistoImg img1 1	;R
	histog: 	rcvHistoImg img1 2	;G
	histob: 	rcvHistoImg img1 3	;B
	historgb: 	rcvHistoImg img1 4	;Grayscale
	
	; we need maxi for scale conversion
	maxi: rcvMaxMat histor
	rcvConvertMatScale/std histor historc  maxi 200 ; change scale
	if smooth [tmp: rcvSmoothHistogram historc  historc: tmp]
	maxi: rcvMaxMat histog
	rcvConvertMatScale/std histog histogc  maxi 200 ; change scale
	if smooth [tmp: rcvSmoothHistogram histogc histogc: tmp]
	maxi: rcvMaxMat histob
	rcvConvertMatScale/std histob histobc  maxi 200 ; change scale
	if smooth [tmp: rcvSmoothHistogram histobc histobc: tmp]
	maxi: rcvMaxMat historgb
	rcvConvertMatScale/std historgb historgbc  maxi 200 ; change scale
	if smooth [tmp: rcvSmoothHistogram historgbc historgbc: tmp]
]

showPlot: does [
	plotr: 		copy [line-width 1 pen red line]
	plotg: 		copy [line-width 1 pen green line]
	plotb: 		copy [line-width 1 pen blue line]
	plotrgb: 	copy [line-width 1 pen white line]
	
	i: 1 
	while [i <= 256] [  coord: as-pair (i) (250 - historc/(i))
						append plotr coord
						coord: as-pair (i) (250 - histogc/(i))
						append plotg coord
						coord: as-pair (i) (250 - histobc/(i))
						append plotb coord
						coord: as-pair (i) (250 - historgbc/(i))
						append plotrgb coord
						i: i + 1]			
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
