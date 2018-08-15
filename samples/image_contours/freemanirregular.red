Red [
	Title:   "Freeman tests "
	Author:  "Francois Jouen"
	File: 	 %freemanirregular.red
	Needs:	 'View
]


#include %../../libs/redcv.red ; for redCV functions



iSize: 512x512
rSize: 300x300
img: rcvCreateImage iSize
edges: rcvCreateImage iSize
edges2: rcvCreateImage iSize

mat:  rcvCreateMat 'integer! 32 iSize
bMat: rcvCreateMat 'integer! 32 iSize
visited: rcvCreateMat 'integer! 32 iSize
plot: copy []

fgVal: 1
canvas: none
knlSize: 3x3
knl: rcvCreateStructuringElement/rectangle knlSize

factor: 1.0
delta: 0.0

canny: [-1.0 -1.0 -1.0
		-1.0 8.0 -1.0 
		-1.0 -1.0 -1.0]
		

generatePolygon: does [
	canvas/image: none
	p1: 128x128 + random rSize p2: 128x128 + random rSize  p3: 128x128 + random rSize 
	p4: 128x128 + random rSize  128x128 +  p5: 128x128 + random rSize
	plot: compose [pen white fill-pen white polygon (p1) (p2) (p3) (p4) (p5)]
	canvas/draw: reduce [plot]
	img: to-image canvas
	rcvConvolve img edges canny factor delta	; edges detection with Canny
	rcvDilate edges edges2 knlSize knl			; dilates shape to suppress 0 values if exist
	rcvImage2Mat edges2 mat 					; make first matrix 0..255
	rcvMakeBinaryMat mat bmat					; make second matrix 0..1
	lPix: rcvMatleftPixel bmat iSize fgVal
	rPix: rcvMatRightPixel bmat iSize fgVal
	uPix: rcvMatUpPixel bmat iSize fgVal
	dPix: rcvMatDownPixel bmat iSize fgVal
	luPix: as-pair lPix/x uPix/y 
	ruPix: as-pair rPix/x uPix/y 
	rdPix: as-pair rPix/x dPix/y 
	ldPix: as-pair lPix/x dPix/y
	f1/text: form luPix
	f2/text: form ruPix
	f3/text: form ldPix
	f4/text: form rdPix 
	pgb/data: 0%
]



processImage: does [
	visited: rcvCreateMat 'integer! 32 iSize			; for storing visited pixels	
	border: []											; for neighbors
	rcvMatGetBorder bmat iSize fgVal border				; get border
	foreach p border [rcvSetInt2D visited iSize p 1]	; values in matrix
	perim: (length? border) / 2 						; pre-processing multiplies number of pixels
	f0/text: form perim
	p: uPix;first border
	i: 1
	s: copy ""
	clear r/text
	append append plot 'pen 'green
	pix: 1
	; repeat until all pixels are processed
	while [pix > 0] [
		pix: rcvGetInt2D visited iSize p
		d: rcvMatGetChainCode visited iSize p 1		; get chain code
		rcvSetInt2D visited iSize p 0				; pixel processed 
		append append append plot 'circle (p) 2 
		if d > -1 [append s form d]
		do-events/no-wait; to show progression
		switch d [
			0	[p/x: p/x + 1]				; east
			1	[p/x: p/x + 1 p/y: p/y + 1]	; southeast
			2	[p/y: p/y + 1]				; south
			3	[p/x: p/x - 1 p/y: p/y + 1]	; southwest
			4	[p/x: p/x - 1]				; west
			5	[p/x: p/x - 1 p/y: p/y - 1]	; northwest
			6	[p/y: p/y - 1]				; north
			7	[p/x: p/x + 1 p/y: p/y - 1]	; northeast
		]
		pgb/data: to-percent (i / to-float perim)
		i: i + 1
	]
	r/text: s
]



; ***************** Test Program ****************************
view win: layout [
	title "Chain Code with Canny Detector"
	button "Generate Polygon" [generatePolygon]
	button "Process" [processImage]
	pgb: progress 200
	f0: field 75
	pad 135x0
	button "Quit" [
					rcvReleaseImage img
					rcvReleaseImage edges
					rcvReleaseImage edges2
					rcvReleaseMat mat
					rcvReleaseMat bmat
					rcvReleaseMat visited
					Quit]
	return
	canvas: base iSize black draw plot
	r: area 200x512
	return
	pad 120x0
	f1: field 60
	f2: field 60
	f3: field 60
	f4: field 60
	return	
]

		