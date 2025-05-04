Red [
	Title:   "Histogram of Oriented Gradients "
	Author:  "ldci"
	File: 	 %hog5.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/math/rcvDistance.red
#include %../../libs/math/rcvHistogram.red
;#include %../../libs/imgproc/rcvImgProc.red

gSize: 512x512
nBins: 8
nDivs: 32
nHog: nDivs * nDivs * nBins	

plotGrid: []
plotHog: []
isFile: false

loadImage: does [
	tmp: request-file
	if not none? tmp [
		img0: rcvLoadImage tmp
		img1: rcvResizeImage img0 gSize ; force image size
		canvas1/image: img0
		canvas2/image: img1
		r: round (img0/size/x * 1.0 / img0/size/y)
		sb/text: rejoin [form img0/size " [1.0:" r "]"]
		cellX: img1/size/x / nDivs
    	cellY: img1/size/y / nDivs
    	f2/text: form as-pair cellX cellY
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
			append blk matHog/data/:pos
		]
		append/only blkH blk
	]
]

drawHOG: does [
	nHog: nDivs * nDivs * nBins
	cellX: img1/size/x / nDivs
    cellY: img1/size/y / nDivs
	plotHog: copy [line-width 1 pen red fill-pen red]
	nCells: nDivs * nDivs
	step: gSize/x / nDivs
	y: 0 
	while [y < nDivs][
		x: 0
		while [x < nDivs][
			nCol: (y * nDivs + x) % nDivs		; Cell Col position
			yCoord: x * CellX + (CellX / 2)		; y coordinate
			xCoord: y * CellY + (CellY / 2)		; x coordinate
			nCell: y * nDivs + nCol + 1			; cell number
			hog: blkH/:nCell					; bin number histogram
			p1: as-pair xCoord yCoord			; center point
			
			d: compose  [pen red fill-pen red circle (p1) 1]			; 
			dd: compose [line-width 1 pen green]
			
			repeat i nBins [
				theta: (360.0 / nBins) * i		;angle in degrees
				rho: hog/:i * cellX / 2			;magnitude
				;theta: theta * pi / 180		;radian
				;p2: rcvRadian2xy rho theta		;radian
				p2: rcvDegree2xy rho theta		;XY coordinate
				p2: p1 + p2
				append dd reduce ['line (p1) (p2) 'pen 'off]
			]
			append plotHog dd
			if cb/data [append plotHog d]		; center of cell
			x: x + 1
		]
		y: y + 1
	]
	canvas2/draw: reduce [plotHog]
	canvas2/image: img1
]




process: does [
	gx: 	make vector! []
	gy: 	make vector! []
	if error? try [nDivs: to-integer f1/text] [nDivs: 2]
	if error? try [nBins: to-integer f3/text] [nBins: 16]
	nHog: nDivs * nDivs * nBins
	cellX: img1/size/x / nDivs
    cellY: img1/size/y / nDivs
    f2/text: form as-pair cellX cellY
	sb2/text: rejoin ["HOG matrix size " form nHog]
	matHog: rcvHOG img1 nBins nDivs				;--calculate histograms
	matInt: rcvMatFloat2Int matHog 32 200.0		;-- to integer matrix
	getHistograms
	drawHOG
]

win: layout [
	title "Histogram of Oriented Gradients [5]" 
	button "Load"			[loadImage process]
	
	text 50 "Dividor"  
	f1: field 50			[if error? try [nDivs: to-integer f1/text] [nDivs: 2]
							 process ]
	f2: Field 60
	text 40 "Bins" 
	f3: field 50			[if error? try [nBins: to-integer f3/text] [nBins: 16]
							process]
	cb: check "Show Cells" 	[if isFile [process]] 
	button "Process" 		[if isFile [process]]
	pad 160x0 
	button "Quit" 			[quit]
	return
	canvas1: base 256x256 black
	canvas2: base gSize black
	return
	sb: field 256
	sb2: field 512
	do [f1/text: form nDivs
		f3/text: form nBins
		sb2/text: rejoin ["HOG matrix size " form nHog]
	]
]
view win