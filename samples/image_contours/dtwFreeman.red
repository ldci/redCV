Red [
	Title:   "DTW tests "
	Author:  "Francois Jouen"
	File: 	 %dtwFreeman.red
	Needs:	 'View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvFreeman.red
#include %../../libs/timeseries/rcvDTW.red

bitSize: 32
matSize: 256x256
matSize1: 256x256
matSize&: 256x256

img1: rcvCreateImage 256x256
img2: rcvCreateImage 256x256

mat1:  		rcvCreateMat 'integer! bitSize matSize
bmat1:  	rcvCreateMat 'integer! bitSize matSize
mat2:  		rcvCreateMat 'integer! bitSize matSize
bmat2:  	rcvCreateMat 'integer! bitSize matSize
visited1: 	rcvCreateMat 'integer! bitSize matSize
visited2: 	rcvCreateMat 'integer! bitSize matSize
border1: copy []
border2: copy []
isLoad1: false
isLoad2: false
x: copy []
y: copy []
fgVal: 1 
bgVal: 0


loadImage1: does [
	canvas1/image: none
	canvas3/image: none
	canvas4/image: none
	x: copy []
	clear cc1/text
	clear cc3/text
	clear cc4/text
	canvas4/draw: []
	isLoad1: false
	tmp: request-file
	if not none? tmp [
		img1: 	rcvLoadImage tmp
		img11: 	rcvCreateImage img1/size
		clone1: rcvCreateImage img1/size
		matSize1: img1/size
		mat1:  	rcvCreateMat 'integer! bitSize matSize1
		bmat1:  rcvCreateMat 'integer! bitSize matSize1
		;visited1: rcvCreateMat 'integer! bitSize matSize1
		rcv2WB img1 img11 
		rcvImage2Mat img11 mat1 		; process image to a bytes matrix [0..255] 
		rcvMakeBinaryMat mat1 bmat1	; processImages to a binary matrix [0..1]
		canvas1/image: img11
		f1/text: form img1/size
		isLoad1: true
	]
]

loadImage2: does [
	canvas2/image: none
	canvas3/image: none
	canvas4/image: none
	canvas4/draw: []
	y: copy []
	clear cc2/text
	clear cc3/text
	clear cc4/text
	isLoad2: false
	tmp: request-file
	if not none? tmp [
		img2: rcvLoadImage tmp
		img21: rcvCreateImage img2/size
		clone2: rcvCreateImage img2/size
		matSize2: img2/size
		mat2:  rcvCreateMat 'integer! bitSize matSize2
		bmat2:  rcvCreateMat 'integer! bitSize matSize2 
		;visited2: rcvCreateMat 'integer! bitSize matSize2
		rcv2WB img2 img21
		rcvImage2Mat img21 mat2 		; process image to a bytes matrix [0..255] 
		rcvMakeBinaryMat mat2 bmat2	; processImages to a binary matrix [0..1]
		canvas2/image: img21
		f2/text: form img2/size
		isLoad2: true
	]
]

getCodeChain1: does [
	clear cc3/text
	clear cc4/text
	s: copy ""
	border1: copy []
	visited1: rcvCreateMat 'integer! bitSize matSize1
	rcvMatGetBorder bmat1 matSize1 fgVal border1
	foreach p border1 [rcvSetInt2D visited1 matSize1 p 255]
	
	rcvCopyImage img11 clone1
	plot1: compose [line-width 1 pen green]
	foreach p border1 [append append append plot1 'box (p) (p + 1)]
	canvas1/image: draw clone1 plot1
	
	count: length? border1
	p: first border1
	i: 1
	while [i < count] [
		d: rcvMatGetChainCode visited1 matSize1 p 255
		rcvSetInt2D visited1 matSize1 p 0 ; pixel is visited
		if d >= 0 [append s form d]; only external pixels -1: internal
			switch d [
				0	[p/x: p/x + 1 ]				; east
				1	[p/x: p/x + 1 p/y: p/y + 1 ]; southeast
				2	[p/y: p/y + 1 ]				; south
				3	[p/x: p/x - 1 p/y: p/y + 1 ]; southwest
				4	[p/x: p/x - 1 ]				; west
				5	[p/x: p/x - 1 p/y: p/y - 1 ]; northwest
				6	[p/y: p/y - 1 ]				; north
				7	[p/x: p/x + 1 p/y: p/y - 1 ]; northeast
			]
		i: i + 1
	]
	cc1/text: copy s
	x: copy []
	foreach v s [append x to-integer v]
]

getCodeChain2: does [
	clear cc3/text
	clear cc4/text
	s: copy ""
	border2: copy []
	visited2: rcvCreateMat 'integer! bitSize matSize2
	rcvMatGetBorder bmat2 matSize2 fgVal border2
	foreach p border2 [rcvSetInt2D visited2 matSize2 p 255]
	rcvCopyImage img21 clone2
	plot2: compose [line-width 1 pen red]
	foreach p border2 [append append append plot2 'box (p) (p + 1)]
	canvas2/image: draw clone2 plot2
	count: length? border2
	p: first border2
	i: 1
	while [i < count] [
		d: rcvMatGetChainCode visited2 matSize2 p 255
		rcvSetInt2D visited2 matSize2 p 0 ; pixel is visited
		if d >= 0 [append s form d]; only external pixels -1: internal
			switch d [
				0	[p/x: p/x + 1 ]				; east
				1	[p/x: p/x + 1 p/y: p/y + 1 ]; southeast
				2	[p/y: p/y + 1 ]				; south
				3	[p/x: p/x - 1 p/y: p/y + 1 ]; southwest
				4	[p/x: p/x - 1 ]				; west
				5	[p/x: p/x - 1 p/y: p/y - 1 ]; northwest
				6	[p/y: p/y - 1 ]				; north
				7	[p/x: p/x + 1 p/y: p/y - 1 ]; northeast
			]
		i: i + 1
	]
	cc2/text: copy s
	y: copy []
	foreach v s [append y to-integer v]
]



calculateDTW: does [
	canvas3/image: none
	canvas4/image: none
	getCodeChain1
	getCodeChain2
	clear cc3/text
	clear cc4/text
	
	matsize: (length? x) * (length? y)
	dMatrix: make vector! reduce ['float! 64 matSize]
	cMatrix: make vector! reduce ['float! 64 matSize]
	xPath: copy []
	rcvDTWDistances x y	dMatrix
	rcvDTWCosts x y dMatrix cMatrix
	dtw: rcvDTWGetDTW cMatrix
	rcvDTWGetPath x y cMatrix xPath
	fDTW/text: copy "DTW x y: "
	append fDTW/text form dtw
	
	; distance map
	img: rcvCreateImage as-pair (length? x) (length? y)
	mat:  make vector! [integer! 32 0]
	foreach v dMatrix [append mat to-integer v]
	mx:  rcvMaxMat mat
	mat * (255 / mx)
	rcvMat2Image mat img
	canvas3/image: img 
	cc3/text: copy form mat
	
	;optimum warping path
	
	img: rcvCreateImage as-pair (length? x) + 1 (length? y) + 1
	{mat:  make vector! [integer! 32 0]
	foreach v cMatrix [append mat to-integer v]
	mx:  rcvMaxMat mat
	fc:  complement (mx / 255)
	mat / fc
	rcvMat2Image mat img}
	
	plot: compose [line-width 2 pen white line]
	append plot (xPath)
	canvas4/image: draw img plot
	cc4/text: copy form xPath
]


; ***************** Test Program ****************************
view win: layout [
	title "red CV: Dynamic Time Warping and Freeman Code Chain"
	button "Load Image 1"	[loadImage1]
	button "Load Image 2"	[loadImage2]
	text 100 "Foreground Value"
	r1: radio 30 "1" [fgVal: 1 bgVal: 0]
	r2: radio 30 "0" [fgVal: 0 bgVal: 1]
	button "Compare Images"	[if all [isLoad1 isLoad2] [calculateDTW]]			
	fDTW: field 126
	pad 280x0
	button "Quit" [Quit]
	return
	text 100 "Image 1" f1: field 90 pad  56x0
	text 100 "Image 2" f2: field 90 pad  56x0
	text 100 "Distance Map" pad 156x0
	text     "Optimum Warping Path"
	return
	canvas1: base 256x256 black img1
	canvas2: base 256x256 black img2
	canvas3: base 256x256 black 
	canvas4: base 256x256 black 
	return
	cc1: area 256x60
	cc2: area 256x60
	cc3: area 256x60
	cc4: area 256x60
	do [r1/data: true r2/data: false]
]






