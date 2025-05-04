Red [
	Title:   "Histogram of Oriented Gradients "
	Author:  "ldci"
	File: 	 %hog3.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/math/rcvHistogram.red
#include %../../libs/imgproc/rcvImgProc.red
#include %../../libs/timeseries/rcvDTW.red

margins: 10x5
knl: [1.0 1.0 1.0 1.0 -8.0 1.0 1.0 1.0 1.0]

gSize: 256x256
nBins: 8
nDivs: 3
nHog: nDivs * nDivs * nBins	
dMin: 0
cellX: gSize/x / nDivs
cellY: gSize/y / nDivs

isFile1: false
isFile2: false


img10: rcvCreateImage gSize
img11: rcvCreateImage gSize
img12: rcvCreateImage gSize

img20: rcvCreateImage gSize
img21: rcvCreateImage gSize
img22: rcvCreateImage gSize

matInt1: make vector! []
matInt2: make vector! []

loadImage: func [n [integer!]][
	tmp: request-file
	if not none? tmp [
		if n = 1 [
			img1: rcvLoadImage tmp
			img10: rcvLoadImage/grayscale tmp
			img11: rcvResizeImage img10 gSize
			img12: rcvCreateImage img11/size
			rcvFilter2D img11 img12 knl 1.0 0.0
			canvas1/image: img12
			isFile1: true
		]
		if n = 2 [
			img2: rcvLoadImage tmp
			img20: rcvLoadImage/grayscale tmp
			img21: rcvResizeImage img20 gSize
			img22: rcvCreateImage img21/size
			rcvFilter2D img21 img22 knl 1.0 0.0
			canvas2/image: img22
			isFile2: true
		]
	]
	if all [isFile1 isFile2] [process compareHistograms]
]

drawGrid: func [n [integer!]] [
	nHog: nDivs * nDivs * nBins
	cellX: gSize/x / nDivs
    cellY: gSize/y / nDivs
    either nDivs > 1 [nRow: nCol: nDivs - 1][nRow: nCol: 1]
	plotGrid: copy [line-width 2 pen yellow]
	
	step: 256 / nDivs
	repeat i nRow [
		p1: as-pair 0 step * i
		p2: as-pair 256 step * i
		d: compose [line (p1) (p2)]
		append plotGrid d
	]
	repeat i nCol [
		p1: as-pair step * i 0
		p2: as-pair step * i 256
		d: compose [line (p1) (p2)]
		append plotGrid d
	]
	if n = 1 [canvas1/draw: reduce [plotGrid]]
	if n = 2 [canvas2/draw: reduce [plotGrid]]
]

compareHistograms: does [
	f5/text: "0"
	f6/text: "0"
	f7/text: ""
	v: rcvDTWCompute to-block matInt1/data to-block matInt2/data
	d: round/to getEuclidianDistance matInt1/data matInt2/data 0.01
	f5/text: form d
	f6/text: form v
	if v <= dMin [f7/text: "Similar" ]
	if v >  dMin [f7/text: "Different" ]
]

getEuclidianDistance: function [
	x 		[vector!] 
	y 		[vector!]
	return: [float!]
][
	sigma: 0.0
	n: length? x
	repeat i n [
		d: (x/:i - y/:i) * (x/:i - y/:i)
		sigma: sigma + d
	]
	sqrt sigma
]


drawHistograms: does [
	nHog: nDivs * nDivs * nBins	
	plot1: 	compose [line-width 1 pen red line]
	step: 576 / nHog
	x: 600 - (step * nhog ) / 2
	foreach v matInt1/data [
		append plot1 as-pair (x) 125 - v
			x: x + step
	]
	
	x: 600 - (step * nhog ) / 2
	plot2: 	compose [line-width 1 pen green line]
	foreach v matInt2/data [
		append plot2 as-pair (x) 250 - v
			x: x + step
	]
	canvas3/draw: reduce [plot1 plot2]
]



process: does [
	if all [isFile1 isFile2] [
		if error? try [nDivs: to-integer f1/text] [nDivs: 3]
		if error? try [nBins: to-integer f3/text] [nBins: 8]
		nHog: nDivs * nDivs * nBins
		drawGrid 1
		drawGrid 2
		cellX: gSize/x / nDivs
		cellY: gSize/y / nDivs
    	f2/text: form as-pair cellX cellY
    	;--calculate both histograms
    	matHog1: rcvHOG img12 nBins nDivs
    	matHog2: rcvHOG img22 nBins nDivs
		;--just 1D float matrices
		matInt1: rcvMatFloat2Int matHog1 32 100.0		; to integer matrix
		matInt2: rcvMatFloat2Int matHog2 32 100.0		; to integer matrix
		drawHistograms
	]
]




win: layout [
	title "Histogram of Oriented Gradients [3]" 
	origin margins space margins
	button "Image 1"		[loadImage 1]
	button "Image 2"		[loadImage 2]
	text 50 "Dividor"  	
	f1: field 40		[if error? try [nDivs: to-integer f1/text] [nDivs: 3]
						process compareHistograms
						]
	f2: Field 60		[if error? try [nBins: to-integer f3/text] [nBins: 8]
						process compareHistograms
	]
	text 40  "Bins" 
	f3: field 40
	button 70 "Update"		[process compareHistograms]
	button "Quit"			[Quit]
	return
	text 55 "Euclidian"
	f5: field 50
	text 35 "DTW"
	f6: field 50
	sl: slider 200			[dMin: to-integer sl/data * 1023 f4/text: form dMin
							 if all [isFile1 isFile2] [compareHistograms]
							]
	f4: field 45 "0"
	
	
	f7: field 100
	return
	canvas1: base gSize black
	pad 75x0
	canvas2: base gSize black
	return
	canvas3: base 600x256 black
	return
	do [f1/text: form nDivs
		f3/text: form nBins
		f4/text: form dMin
		f2/text: form as-pair cellX cellY
		f5/text: f6/text: f7/text: ""
		
	]
]

view win