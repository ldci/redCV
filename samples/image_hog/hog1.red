Red [
	Title:   "Histogram of Oriented Gradients "
	Author:  "Francois Jouen"
	File: 	 %hog1.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/math/rcvHistogram.red
;#include %../../libs/imgproc/rcvImgProc.red

gSize: 256x256
nBins: 16
nDivs: 2
nHog: nDivs * nDivs * nBins	

isFile: false

loadImage: does [
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		img2: rcvLoadImage/grayscale tmp
		canvas1/image: img1
		r: round (img1/size/x * 1.0 / img1/size/y)
		sb/text: rejoin [form img1/size " [1.0:" r "]"]
		cellX: img1/size/x / nDivs
    	cellY: img1/size/y / nDivs
    	f2/text: form as-pair cellX cellY
		isFile: true
	]
]

process: does [
	if error? try [nDivs: to-integer f1/text] [nDivs: 2]
	if error? try [nBins: to-integer f3/text] [nBins: 16]
	nHog: nDivs * nDivs * nBins
	cellX: img1/size/x / nDivs
    cellY: img1/size/y / nDivs
    f2/text: form as-pair cellX cellY
	sb2/text: form nHog
	plot: 	copy [line-width 1 pen red fill-pen blue]
	matHog: rcvHOG img1 nBins nDivs
	matInt: rcvMatFloat2Int matHog 32 200.0
	x: 10
	repeat i (nHog - 2) [
		tL: as-pair (x) 240 - matInt/data/:i
		bR: as-pair (x + 4) 240
		append plot 'box
		append plot tl 
		append plot br
		x: x + 4
	]
	canvas2/draw: reduce [plot]
]

win: layout [
	title "Histogram of Oriented Gradients" 
	button "Load"		[loadImage process]
	
	text 50 "Dividor"  
	f1: field 50		[if error? try [nDivs: to-integer f1/text] [nDivs: 2]
						 process ]
	f2: Field 60
	text 100 " Number of Bins" 
	f3: field 50		[if error? try [nBins: to-integer f3/text] [nBins: 16]
						process]
	button "Process" 	[if isFile [process]] 
	pad 220x0
	button "Quit" 		[quit]
	return
	canvas1: base gSize black
	canvas2: base 600x256 black
	return
	sb: field 256
	sb2: field 600
	do [f1/text: form nDivs
		f3/text: form nBins
		sb2/text: form nHog
	]
]
view win