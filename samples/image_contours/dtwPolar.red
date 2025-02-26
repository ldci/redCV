Red [
	Title:   "DTW tests "
	Author:  "ldci"
	File: 	 %dtwPolar.red
	Needs:	 'View
]

;required libs
#include %../../libs/tools/rcvTools.red
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/math/rcvDistance.red
#include %../../libs/imgproc/rcvFreeman.red
#include %../../libs/timeseries/rcvDTW.red

bitSize: 32
matSize: 256x256
img1: rcvCreateImage 256x256
img2: rcvCreateImage 256x256
mat1: matrix/init/value 2 bitSize matSize 0
mat2: matrix/init/value 2 bitSize matSize 0
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
			mat1:   matrix/init/value 2 bitSize matSize1 0
			visited1: matrix/init/value 2 bitSize matSize1 0
			rcv2WB img1 img11 
			rcvImage2Mat img11 mat1 		; process image to a bytes matrix [0..255] 
			bmat1: rcvMakeBinaryMat mat1 	; processImages to a binary matrix [0..1]
			cg1: rcvGetMatCentroid bmat1
			canvas1/image: img11
			w1: img1/size/x
			f3/text: form img1/size append f3/text " pixels"
		]
		2 [ img2: rcvLoadImage tmp
			img21: rcvCreateImage img2/size
			matSize2: img2/size
			mat2:  matrix/init/value 2 bitSize matSize2 0
			visited2: matrix/init/value 2 bitSize matSize2 0
			rcv2WB img2 img21
			rcvImage2Mat img21 mat2 		; process image to a bytes matrix [0..255] 
			bmat2: rcvMakeBinaryMat mat2 	; processImages to a binary matrix [0..1]
			cg2: rcvGetMatCentroid bmat2 
			canvas2/image: img21
			w2: img2/size/x
			f4/text: form img2/size append f4/text " pixels"
		]
	]
		isLoad: true
	]
	isLoad
]


getSignature: func [n [integer!]][
	border: copy []
	switch n [
		1 [rcvMatGetBorder bmat1 fgVal border
			foreach p border [rcvSetContourValue visited1 p fgVal]
			cg: cg1 w: w1
			color: green
		]
		2 [rcvMatGetBorder bmat2 fgVal border
		foreach p border [rcvSetContourValue visited2 p fgVal]
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
			n = 1 [d: rcvMatGetChainCode visited1  p fgVal] 
			n = 2 [d: rcvMatGetChainCode visited2  p fgVal]
		]
		if d <> -1 [append outBorder p]
		case [
			n = 1 [rcvSetContourValue visited1 p 0]
			n = 2 [rcvSetContourValue visited2 p 0]
		]
		;get the next pixel to process
		p: rcvGetContours p d
		i: i + 1
	]
	
	; get in contours with difference if necessary 
	;inBorder: difference border outBorder
	
	;--calculate polar coordinates
	polar: copy []
	maxRho: 0.0
	foreach p outBorder [
		rho: rcvGetEuclidianDistance p cg
		; x normalization [-pi +pi]
		;theta: rcvGetAngleRadian p - cg 
		; x normalization [360°] for a better visualisation
		theta: rcvGetAngle p cg
		bloc: copy []
		; calculate maxRho for y normalization
		if rho > maxRho [maxRho: rho]	
		append append bloc theta rho
		append/only polar bloc
	]
	
	; y normalization [0.0 .. 1.0] to process image size differences
	normf: 1.0 / maxRho
	; for signature visualization
	plot: compose [line-width 1 pen (color) line]
	either cb/data [scale: 100] [scale: 1]
	serie: copy []
	foreach i polar [
		theta: first i
		rho: second i 
		if cb/data [rho: rho * normf]
		append serie rho
		p: as-pair theta  (127 * n) - (rho * scale)
		p: p + 10x0
		append append append plot 'box (p) (p + 1)
	]
	;--for dtw series
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
	f1/text: form length? x append f1/text " pixels"
	f2/text: form length? y append f2/text " pixels"
	append plot1 plot2
	canvas3/draw: reduce [plot1]
	matsize: as-pair (length? x) (length? y)
	dMatrix: matrix/init 3 64 matsize
	cMatrix: matrix/init 3 64 matsize
	xPath: copy []
	rcvDTWDistances x y dMatrix
	rcvDTWCosts x y dMatrix cMatrix
	dtw: rcvDTWGetDTW cMatrix
	fDTW/text: copy "DTW x y: "
	append fDTW/text form dtw
	;optimum warping path
	rcvDTWGetPath x y cMatrix xPath
	img: rcvCreateImage matsize
	plot: compose [line-width 2 pen yellow line]
	append plot (xPath)
	canvas4/image: draw img plot
]


; ***************** Test Program ****************************
view win: layout [
	title "red CV: Dynamic Time Warping and Shape Signature"
	button "Load Image 1"		[isLoad1: loadImage 1]
	button "Load Image 2"		[isLoad2: loadImage 2]
	text 100 "Foreground"
	r1: radio 30 "1" [fgVal: 1 bgVal: 0]
	r2: radio 30 "0" [fgVal: 0 bgVal: 1]
	button "Compare Images"		[if all [isLoad1 isLoad2] [calculateDTW]]
	cb: check 100 "Normalize" true	[if all [isLoad1 isLoad2] [calculateDTW]]			
	fDTW: field 200
	pad 220x0
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
	return
	f3: field 256
	f4: field 256
	do [r1/data: true r2/data: false]
]






