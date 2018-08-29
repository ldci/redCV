Red [
	Title:   "DTW tests "
	Author:  "Francois Jouen"
	File: 	 %dtw1.red
	Needs:	 'View
]

#include %../../libs/redcv.red ; for redCV functions

bitSize: 32
matSize: 256x256
matSize1: 256x256
matSize&: 256x256

img1: rcvCreateImage 256x256
img2: rcvCreateImage 256x256

mat1:  rcvCreateMat 'integer! bitSize matSize
bmat1:  rcvCreateMat 'integer! bitSize matSize
mat2:  rcvCreateMat 'integer! bitSize matSize
bmat2:  rcvCreateMat 'integer! bitSize matSize
visited1: rcvCreateMat 'integer! bitSize matSize
visited2: rcvCreateMat 'integer! bitSize matSize
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
		img1: rcvLoadImage tmp
		matSize1: img1/size
		mat1:  rcvCreateMat 'integer! bitSize matSize1
		bmat1:  rcvCreateMat 'integer! bitSize matSize1
		visited1: rcvCreateMat 'integer! bitSize matSize1
		rcvImage2Mat img1 mat1 		; process image to a bytes matrix [0..255] 
		rcvMakeBinaryMat mat1 bmat1	; processImages to a binary matrix [0..1]
		canvas1/image: img1
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
		matSize2: img2/size
		mat2:  rcvCreateMat 'integer! bitSize matSize2
		bmat2:  rcvCreateMat 'integer! bitSize matSize2 
		visited2: rcvCreateMat 'integer! bitSize matSize2
		rcvImage2Mat img2 mat2 		; process image to a bytes matrix [0..255] 
		rcvMakeBinaryMat mat2 bmat2	; processImages to a binary matrix [0..1]
		canvas2/image: img2
		isLoad2: true
	]
]

getCodeChain1: does [
	clear cc3/text
	clear cc4/text
	s: copy ""
	border1: copy []
	rcvMatGetBorder bmat1 matSize1 fgVal border1
	foreach p border1 [rcvSetInt2D visited1 matSize1 p 255]
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
	rcvMatGetBorder bmat2 matSize2 fgVal border2
	foreach p border2 [rcvSetInt2D visited2 matSize2 p 255]
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
	dMatrix: rcvDTWDistances x y	
	cMatrix: rcvDTWRun x y dMatrix
	dtw: rcvDTWGetDTW cMatrix
	xPath: rcvDTWGetPath x y cMatrix 
	fDTW/text: copy "DTW x y: "
	append fDTW/text form dtw
	
	; distance map
	img: rcvCreateImage as-pair (length? dMatrix) (length? dMatrix)
	mat:  make vector! [integer! 32 0]
	foreach v dMatrix [
		ct: length? v 
		i: 1
		while [i <= ct][append mat (to-integer v/:i) i: i + 1]
	]
	mx:  rcvMaxMat mat
	mat * (255 / mx)
	rcvMat2Image mat img
	canvas3/image: img 
	cc3/text: copy form mat
	
	;optimum warping path
	img: rcvCreateImage as-pair (length? x) + 1 (length? y) + 1
	plot: compose [line-width 2 pen green line]
	
	foreach v xPath [p: as-pair first v second v append plot (p)
		append s v
	]
	canvas4/image: draw img plot
	cc4/text: copy form xPath
]


; ***************** Test Program ****************************
view win: layout [
	title "red CV: Dynamic Time Warping and Freeman Code Chain"
	button "Load Image 1"	[loadImage1]
	button "Load Image 2"	[loadImage2]
	text 100 "Foreground"
	r1: radio 30 "1" [fgVal: 1 bgVal: 0]
	r2: radio 30 "0" [fgVal: 0 bgVal: 1]
	button "Compare Images"	[if all [isLoad1 isLoad2] [calculateDTW]]			
	fDTW: field 126
	pad 280x0
	button "Quit" [Quit]
	return
	text 100 "Image 1" pad 156x0
	text 100 "Image 2" pad 156x0
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






