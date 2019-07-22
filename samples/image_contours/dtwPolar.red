Red [
	Title:   "DTW tests "
	Author:  "Francois Jouen"
	File: 	 %dtwPolar.red
	Needs:	 'View
]

#include %../../libs/redcv.red ; for redCV functions

bitSize: 32
matSize: 256x256
img1: rcvCreateImage 256x256
img2: rcvCreateImage 256x256
mat1:  	rcvCreateMat 'integer! bitSize matSize
mat2:  	rcvCreateMat 'integer! bitSize matSize

isLoad1: false
isLoad2: false
cg1: 128x128
cg2: 128x128

x: copy []
y: copy []
fgVal: 1 
bgVal: 0
plot1: []
plot2: []
W1: w2: 0



loadImage: func [n [integer!] return: [logic!]][
	canvas3/image: none
	canvas4/image: none
	canvas3/draw:[]
	canvas4/draw:[]
	isLoad: false
	switch n [
		1 [canvas1/image: none clear f1/text]
		2 [canvas2/image: none clear f2/text]
	]
	tmp: request-file
	if not none? tmp [
		switch n [
		1 [ img1: rcvLoadImage tmp
			img11: rcvCreateImage img1/size
			matSize1: img1/size
			mat1:   rcvCreateMat 'integer! bitSize matSize1
			bmat1:  rcvCreateMat 'integer! bitSize matSize1
			visited1: rcvCreateMat 'integer! bitSize matSize1
			rcv2WB img1 img11 
			rcvImage2Mat img11 mat1 		; process image to a bytes matrix [0..255] 
			rcvMakeBinaryMat mat1 bmat1	; processImages to a binary matrix [0..1]
			cg1: rcvGetMatCentroid bmat1 matSize1
			canvas1/image: img11
			w1: img1/size/x
		]
		2 [ img2: rcvLoadImage tmp
			img21: rcvCreateImage img2/size
			matSize2: img2/size
			mat2:  rcvCreateMat 'integer! bitSize matSize2
			bmat2:  rcvCreateMat 'integer! bitSize matSize2
			visited2: rcvCreateMat 'integer! bitSize matSize2
			rcv2WB img2 img21
			rcvImage2Mat img21 mat2 		; process image to a bytes matrix [0..255] 
			rcvMakeBinaryMat mat2 bmat2	; processImages to a binary matrix [0..1]
			cg2: rcvGetMatCentroid bmat2 matSize2
			canvas2/image: img21
			w2: img2/size/x
		]
	]
		isLoad: true
	]
	isLoad
]


getSignature: func [n [integer!]][
	border: copy []
	switch n [
		1 [rcvMatGetBorder bmat1 matSize1 fgVal border
			foreach p border [rcvSetInt2D visited1 matSize1 p fgVal]
			cg: cg1 w: w1
			color: green
		]
		2 [rcvMatGetBorder bmat2 matSize2 fgVal border
		foreach p border [rcvSetInt2D visited2 matSize2 p fgVal]
		cg: cg2 w: w2
		color: red
		]
	]
	inBorder: copy [] ; we don't use
	outBorder: copy []
	perim: length? border
	; freeman chain code 
	p: first border
	i: 1
	while [i <= perim] [
		case [
			n = 1 [d: rcvMatGetChainCode visited1 matSize1 p fgVal] 
			n = 2 [d: rcvMatGetChainCode visited2 matSize2 p fgVal]
		]
		if d <> -1 [append outBorder p]
		idx: (p/y * w + p/x) + 1	
		case [
			n = 1 [visited1/:idx: 0]
			n = 2 [visited2/:idx: 0]
		]
		;get the next pixel to process
		p: rcvGetContours p d
		i: i + 1
	]
	
	; get in contours with difference if necessary 
	inBorder: difference border outBorder
	
	angles: copy []
	foreach p outBorder [
		rho: rcvGetEuclidianDistance p cg
		theta: rcvGetAngle p cg
		bloc: copy []
		append append bloc theta rho
		append/only angles bloc
	]
	; for signature visualization
	plot: compose [line-width 1 pen (color) line]
	serie: copy []
	foreach i angles [
		theta: first i
		rho: second i
		append serie rho
		p: as-pair theta  (127 * n - rho)
		p: p + 10x0
		append append append plot 'box (p) (p + 1)
	]
	; for dtw series
	case [
		n = 1 [x: copy serie plot1: copy plot]
		n = 2 [y: copy serie plot2: copy plot]
	]
]


calculateDTW: does [
	canvas3/image: none
	canvas4/image: none
	getSignature 1
	getSignature 2
	f1/text: form length? x
	f2/text: form length? y
	append plot1 plot2
	canvas3/draw: reduce [plot1]
	matsize: (length? x) * (length? y)
	dMatrix: make vector! reduce ['float! 64 matSize]
	cMatrix: make vector! reduce ['float! 64 matSize]
	xPath: copy []
	rcvDTWDistances x y dMatrix
	rcvDTWCosts x y dMatrix cMatrix
	dtw: rcvDTWGetDTW cMatrix
	fDTW/text: copy "DTW x y: "
	append fDTW/text form dtw
	;optimum warping path
	rcvDTWGetPath x y cMatrix xPath
	img: rcvCreateImage as-pair (length? x) (length? y)
	plot: compose [line-width 2 pen yellow line]
	append plot (xPath)
	canvas4/image: draw img plot
]


; ***************** Test Program ****************************
view win: layout [
	title "red CV: Dynamic Time Warping and Shape Signature"
	button "Load Image 1"	[isLoad1: loadImage 1]
	button "Load Image 2"	[isLoad2: loadImage 2]
	text 100 "Foreground"
	r1: radio 30 "1" [fgVal: 1 bgVal: 0]
	r2: radio 30 "0" [fgVal: 0 bgVal: 1]
	button "Compare Images"	[if all [isLoad1 isLoad2] [calculateDTW]]			
	fDTW: field 200
	pad 320x0
	button "Quit" [Quit]
	return
	text 100 green "Image 1" f1: field 100 pad 36x0
	text 100 red  "Image 2" f2: field 100 pad 60x0
	text 100 "Shapes Signature" pad 270x0
	text     "Optimum Warping Path"
	return
	canvas1: base 256x256 black img1
	canvas2: base 256x256 black img2
	canvas3: base 380x256 black 
	canvas4: base 256x256 black
	do [r1/data: true r2/data: false]
]






