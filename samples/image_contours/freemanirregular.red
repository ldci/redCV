Red [
	Title:   "Freeman tests "
	Author:  "Francois Jouen"
	File: 	 %freemanirregular.red
	Needs:	 'View
]


;required libs
#include %../../libs/tools/rcvTools.red
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvImgProc.red
#include %../../libs/imgproc/rcvMorphology.red
#include %../../libs/imgproc/rcvFreeman.red


iSize: 		512x512
rSize: 		300x300
img: 		rcvCreateImage iSize
edges: 		rcvCreateImage iSize
edges2: 	rcvCreateImage iSize
mat:		matrix/init 2 32 iSize

plot: 		copy []
fgVal: 		1
canvas: 	none
knlSize: 	3x3
knl: 		rcvCreateStructuringElement/rectangle knlSize
factor: 	1.0
delta: 		0.0
anim: 		true

filter: [-1.0 -1.0 -1.0
		-1.0 8.0 -1.0 
		-1.0 -1.0 -1.0]

color: 	random white
plot: 	compose [pen white fill-pen white box 0x0 iSize]
	
generatePolygon: does [
	random/seed now/time/precise
	canvas/image: none
	clear f0/text
	clear f1/text
	clear f2/text
	clear f3/text
	clear f4/text
	clear r/text
	p1: 128x128 + random rSize p2: 128x128 + random rSize  p3: 128x128 + random rSize 
	p4: 128x128 + random rSize  128x128 +  p5: 128x128 + random rSize
	color: 	random white
	plot: compose [pen color fill-pen color polygon (p1) (p2) (p3) (p4) (p5)]
	pgb/data: 0%
	processImage
]

processImage: does [
	canvas/draw: reduce [plot]
	;img: to-image canvas						; pbs with GTK
	rcvZeroImage img
    canvas/image: draw img canvas/draw 			; reduce [plot]
	rcvConvolve img edges filter factor delta	; edges detection with filter
	rcvDilate edges edges2 knlSize knl			; dilates shape to suppress 0 values if exist in edges
	rcvImage2Mat edges2 mat 					; make first matrix 0..255 
	bmat: rcvMakeBinaryMat mat					; make second matrix 0..1
	
	lPix: rcvMatleftPixel bmat 1
	rPix: rcvMatRightPixel bmat 1
	uPix: rcvMatUpPixel bmat 1
	dPix: rcvMatDownPixel bmat 1
	f1/text: form as-pair lPix/x uPix/y
	f2/text: form as-pair rPix/x uPix/y
	f3/text: form as-pair rPix/x dPix/y 
	f4/text: form as-pair lPix/x dPix/y 	
	border: []											; for neighbors
	rcvMatGetBorder bmat 1 border						; get border
	visited: matrix/init/value 2 8 iSize 0				; for storing visited pixels
	foreach p border [rcvSetContourValue visited p 1]	; values to 1					
	perim: to-integer (length? border) / 2 				; pre-processing 2 x number of pixels
	f0/text: form perim
	p: uPix;first border
	s: copy ""
	clear r/text
	append append plot 'pen 'green
	i: pix: 1
	; repeat until all pixels are processed
	while [pix <> 0] [
		pix: rcvGetContourValue visited p		;--get integer value  
		d: rcvMatGetChainCode visited  p 1		;--get chain code					
		rcvSetContourValue visited p 0			;--pixel is visited
		append append append plot 'circle (p) 1		 
		if d > -1 [append s form d]
		;get the next pixel to process
		pgb/data: to-percent (i / to-float perim)
		if anim [do-events/no-wait]; to show progression
		p: rcvGetContours p d
		i: i + 1
	]
	f0/text: form i
	r/text: s
]

; ***************** Test Program ****************************
view win: layout [
	title "Chain Code with Canny Detector"
	button "Generate Polygon" [generatePolygon]
	cb: check "Show Anination" true [anim: face/data]
	pgb: progress 245
	f0: field 125
	button "Quit" [
					rcvReleaseImage img
					rcvReleaseImage edges
					rcvReleaseImage edges2
					rcvReleaseMat mat
					rcvReleaseMat bmat
					rcvReleaseMat visited
					Quit]
	return
	canvas: base iSize black
	r: area 200x512
	return
	pad 120x0
	f1: field 60
	f2: field 60
	f3: field 60
	f4: field 60
	return	
]

		