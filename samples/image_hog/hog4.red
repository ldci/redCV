Red [
	Title:   "Histogram of Oriented Gradients "
	Author:  "Francois Jouen"
	File: 	 %hog4.red
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
nDivs: 2
nHog: nDivs * nDivs * nBins	
dMin: 0
isFile: false

loadImage: does [
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		img2: rcvLoadImage/grayscale tmp
		img3: rcvCreateImage img1/size
		;rcvSobel img2 img3 img1/size 4 1
		rcvFilter2D img2 img3 knl 1.0 0.0
		canvas1/draw: none
		canvas1/image: img1
		canvas2/image: img3
		r: round (img1/size/x * 1.0 / img1/size/y)
		sb/text: rejoin ["Image: " form img1/size " [1.0:" r "]"]
		cellX: img1/size/x / nDivs
    	cellY: img1/size/y / nDivs
    	f2/text: form as-pair cellX cellY
    	f5/text: ""
		isFile: true
	]
]

getHistograms: does [
	blkH: copy []
	n: nHog / nBins
	repeat i n [
		blk: copy []
		repeat j nBins [
			pos: (i - 1 * nBins + j - 1) + 1
			append blk matInt/:pos
		]
		append/only blkH blk
	]
]

searchObjects: does [
	f5/text: ""
	n: (nHog / nBins) 
	count: 0
	cells: copy []
	; find the first histogram with values > 0
	loop n [
		sigma: sum blkH/:n
		template: blkH/:n
		count: count + 1
		if sigma > 0 [break]
	]
	; attention column x line order
	; test candidate histograms
	nObj: 0
	i: count + 1
	repeat i n [
		v: rcvDTWCompute template blkH/:i ; test candidate
		if v <= dMin [nObj: nObj + 1 append cells i]
	]
	f5/text: rejoin ["Found " nObj " objects [" cells "]" ]
	
	; visualisation
	plotR: compose [line-width 2 pen red]
	cellX: canvas1/size/x / nDivs
    cellY: canvas1/size/y / nDivs
	;column x line order
	x: 0 
	while [x < nDivs][
		y: 0
		while [y < nDivs] [
			ct: x * nDivs + y
			if find cells ct + 1 [
				cx: x * cellX
				cy: y * cellY 
				tl: as-pair cx cy
				bR: as-pair (cx + CellX) (cY + cellY)
				d: compose [box (tl) (br)]
				append plotR d
			]
			y: y + 1
		]
		x: x + 1
	]
	canvas1/draw: reduce [plotR]
]


drawGrid: does [
	nHog: nDivs * nDivs * nBins
	cellX: img1/size/x / nDivs
    cellY: img1/size/y / nDivs
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
	canvas2/draw: reduce [plotGrid]
]

drawHistograms: does [
	plot: 	compose [line-width 2 pen red]
	step: 576 / nHog
	x: 600 - (step * nhog ) / 2
	foreach b blkH [
		color: random white
		dd: compose [fill-pen (color)]
		append plot dd
		foreach v b [
			tL: as-pair (x) 250 - v
			bR: as-pair (x + step) 250
			d: compose [box (tl) (br)]
			append plot d
			x: x + step
		]
	]
	canvas3/draw: reduce [plot]
]


process: does [
	if isFile [
		gx: 	make vector! []
		gy: 	make vector! []
		if error? try [nDivs: to-integer f1/text] [nDivs: 2]
		if error? try [nBins: to-integer f3/text] [nBins: 16]
		drawGrid
    	f2/text: form as-pair cellX cellY
		sb2/text: rejoin ["HOG Matrix Size: " form nHog]
		matHog: rcvHOG img1 gx gy nBins nDivs		; calculate histograms
		matInt: make vector! nHog 
		rcvMatFloat2Int matHog matInt 150.0			; to integer matrix
		getHistograms 
		drawHistograms
	]
]

win: layout [
	title "Histogram of Oriented Gradients [4]" 
	origin margins space margins
	button  "Load Image"		[loadImage process]
	
	
	text 50 "Dividor"  	
	f1: field 40		[if error? try [nDivs: to-integer f1/text] [nDivs: 2]
						 process ]
	f2: Field 60
	text 100 " Number of Bins" 
	f3: field 40			[if error? try [nBins: to-integer f3/text] [nBins: 16]
							process]
	
	
	button "Process" 		[process] 
	button 50 "Quit" 		[quit]
	return
	text "Distance" 
	sl: slider 100			[dMin: to-integer sl/data * 511 f4/text: form dMin
							 if isFile [searchObjects]
							]
	f4: field 50
	;pad 80x0
	button "Search" 		[if isFile [searchObjects]]
	
	f5: field 256
	return
	canvas1: base gSize black
	pad 75x0
	canvas2: base gSize black
	return 
	canvas3: base 600x256 black
	return
	sb: field 295
	sb2: field 295
	do [f1/text: form nDivs
		f3/text: form nBins
		f4/text: form dMin
	]
]
view win