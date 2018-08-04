Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %freeman.red
	Needs:	 'View
]


#include %../../libs/redcv.red ; for redCV functions

mat:  rcvCreateMat 'integer! 32 512x512

plot: copy [fill-pen white box 205x205 305x305]

iSize: 512x512
img: rcvCreateImage iSize
fgVal: 1
bMat: none
canvas: none




processImage: does [
	img: to-image canvas
	rcvImage2Mat img mat 	 
	bmat: rcvMakeBinaryMat mat
	visited: rcvCreateMat 'integer! 32 iSize
	lPix: rcvMatleftPixel bmat iSize fgVal
	rPix: rcvMatRightPixel bmat iSize fgVal
	uPix: rcvMatUpPixel bmat iSize fgVal
	dPix: rcvMatDownPixel bmat iSize fgVal
	
	w: (rPix/x - lPix/x) + 1
	h: (dPix/y - uPix/y) + 1
	
	luPix: as-pair lPix/x uPix/y 
	ruPix: as-pair rPix/x uPix/y 
	rdPix: as-pair rPix/x dPix/y 
	ldPix: as-pair lPix/x dPix/y
	f1/text: form luPix
	f2/text: form ruPix
	f3/text: form ldPix
	f4/text: form rdPix 
	
	
	border: []
	rcvMatGetBorder bmat iSize fgVal border
	foreach p border [rcvSetInt2D visited iSize p 1]
	
	perim: length? border
	
	p: first border
	i: 1
	s: ""
	clear r/text
	
	while [i < perim] [
		d: rcvMatGetChainCode visited iSize p fgVal
		idx: (p/y * iSize/x + p/x) + 1	
		visited/:idx: 0; pixel is visited
		append s form d
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
		i: i + 1
	]
	r/text: s
	
]



; ***************** Test Program ****************************
view win: layout [
	title "Chain Code"
	button "Process" [processImage]
	button "Quit" [Quit]
	return
	canvas: base iSize black draw plot
	return
	f1: field 60
	f2: field 60
	f3: field 60
	f4: field 60
	return
	r: area 512x100
]

		