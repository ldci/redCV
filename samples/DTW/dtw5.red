Red [
	Title:   "DTW tests "
	Author:  "Francois Jouen"
	File: 	 %dtw1.red
	Needs:	 'View
]

#include %../../libs/redcv.red ; for redCV functions

bitSize: 32
matSize: 256x256
img1: rcvCreateImage 256x256
img2: rcvCreateImage 256x256

mat1:  rcvCreateMat 'integer! bitSize matSize
bmat1:  rcvCreateMat 'integer! bitSize matSize
mat2:  rcvCreateMat 'integer! bitSize matSize
bmat2:  rcvCreateMat 'integer! bitSize matSize

border1: copy []
border2: copy []
angles1: copy []
angles2: copy []
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

loadImage1: does [
	canvas1/image: none
	canvas3/image: none
	canvas4/image: none
	canvas3/draw:[]
	canvas4/draw:[]
	clear f1/text
	isLoad1: false
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		matSize1: img1/size
		mat1:  rcvCreateMat 'integer! bitSize matSize1
		bmat1:  rcvCreateMat 'integer! bitSize matSize1
		rcvImage2Mat img1 mat1 		; process image to a bytes matrix [0..255] 
		rcvMakeBinaryMat mat1 bmat1	; processImages to a binary matrix [0..1]
		cg1: rcvGetMatCentroid bmat1 matSize1
		canvas1/image: img1
		isLoad1: true
	]
]

loadImage2: does [
	canvas2/image: none
	canvas3/image: none
	canvas4/image: none
	canvas3/draw:[]
	canvas4/draw: []
	clear f2/text
	isLoad2: false
	tmp: request-file
	if not none? tmp [
		img2: rcvLoadImage tmp
		matSize2: img2/size
		mat2:  rcvCreateMat 'integer! bitSize matSize2
		bmat2:  rcvCreateMat 'integer! bitSize matSize2
		rcvImage2Mat img2 mat2 		; process image to a bytes matrix [0..255] 
		rcvMakeBinaryMat mat2 bmat2	; processImages to a binary matrix [0..1]
		cg2: rcvGetMatCentroid bmat2 matSize2
		canvas2/image: img2
		isLoad2: true
	]
]

getSignature1: does[
	border1: copy []
	rcvMatGetBorder bmat1 matSize1 fgVal border1
	angles1: copy []
	foreach p border1 [
		rho: rcvGetEuclidianDistance p cg1
		theta: rcvGetAngle p cg1
		bloc: copy []
		append append bloc theta rho
		append/only angles1 bloc
	]
	
	sort angles1 ; 0.. 359  to use with line draw command
	plot1: compose [line-width 1 pen green line]
	x: copy []
	foreach n angles1 [
		theta: first n
		append x second n
		p: as-pair first n (127 - second n)
		p: p + 10x0
		append plot1 (p)
	]
]

getSignature2: does[
	border2: copy []
	rcvMatGetBorder bmat2 matSize2 fgVal border2
	angles2: copy []
	foreach p border2 [
		rho: rcvGetEuclidianDistance p cg2
		theta: rcvGetAngle p cg2
		bloc: copy []
		append append bloc theta rho
		append/only angles2 bloc		
	]
	
	sort angles2 ; 0.. 359  to use with line draw command
	plot2: compose [line-width 1 pen red line]
	y: copy []
	foreach n angles2 [ 
		theta: first n
		append y second n
		p: as-pair first n (256 - second n) 
		p: p + 10x0
		append plot2 (p)
	]
]


calculateDTW: does [
	canvas3/image: none
	canvas4/image: none
	getSignature1
	getSignature2
	f1/text: form length? x
	f2/text: form length? y
	append plot1 plot2
	canvas3/draw: reduce [plot1]
	do-events/no-wait; to show progression
	dMatrix: rcvDTWDistances x y	
	cMatrix: rcvDTWRun x y dMatrix
	dtw: rcvDTWGetDTW cMatrix
	xPath: rcvDTWGetPath x y cMatrix 
	fDTW/text: copy "DTW x y: "
	append fDTW/text form dtw
	;optimum warping path
	img: rcvCreateImage as-pair (length? x) + 1 (length? y) + 1
	plot: compose [line-width 2 pen yellow line]
	foreach v xPath [p: as-pair first v second v append plot (p)]
	;canvas4/draw: plot
	canvas4/image: draw img plot
]


; ***************** Test Program ****************************
view win: layout [
	title "red CV: Dynamic Time Warping and Shape Signature"
	button "Load Image 1"	[loadImage1]
	button "Load Image 2"	[loadImage2]
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






