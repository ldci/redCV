Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %freeman.red
	Needs:	 'View
]


;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvFreeman.red

plot: []
iSize: 512x512
img: rcvCreateImage iSize
mat:  rcvCreateMat 'integer! 32 iSize
bMat: rcvCreateMat 'integer! 32 iSize
visited: rcvCreateMat 'integer! 32 iSize
fgVal: 1
canvas: none


generateImage: does [
	canvas/image: none
	p1: random 400x400
	p2: random 400x400
	color: random 255.255.255
	plot: compose [fill-pen (color) box (p1) (p2)]
	processImage
]


processImage: does [
	canvas/draw: reduce [plot]
	;img: to-image canvas		; to-image: problems with GTK
   	 rcvZeroImage img
    	canvas/image: draw img reduce [plot]
	rcvImage2Mat img mat 	 
	rcvMakeBinaryMat mat bmat
	lPix: rcvMatleftPixel bmat iSize fgVal
	rPix: rcvMatRightPixel bmat iSize fgVal
	uPix: rcvMatUpPixel bmat iSize fgVal
	dPix: rcvMatDownPixel bmat iSize fgVal
	f1/text: form as-pair lPix/x uPix/y 
	f2/text: form as-pair rPix/x uPix/y 
	f3/text: form as-pair rPix/x dPix/y 
	f4/text: form as-pair lPix/x dPix/y
	clear r/text
	visited: rcvCreateMat 'integer! 32 iSize
	border: copy []
	rcvMatGetBorder bmat iSize fgVal border
	foreach p border [rcvSetInt2D visited iSize p 1]
	perim: length? border
	p: first border
	i: 1
	s: copy ""
	while [i < perim] [
		d: rcvMatGetChainCode visited iSize p fgVal
		idx: (p/y * iSize/x + p/x) + 1	
		visited/:idx: 0; pixel is visited
		append s form d
		;get the next pixel to process
		p: rcvGetContours p d
		i: i + 1
	]
	r/text: s
]



; ***************** Test Program ****************************
view win: layout [
	title "Chain Code"
	button "Generate Shape" 	[generateImage]
	pad 580x0
	button "Quit" 				[rcvReleaseImage img
								 rcvReleaseMat mat
								 rcvReleaseMat bmat
								 rcvReleaseMat visited
								 Quit]
	return
	canvas: base iSize black draw plot
	r: area 256x512
	return
	pad 100x0
	f1: field 60
	f2: field 60
	f3: field 60
	f4: field 60
]

		