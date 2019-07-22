Red [
	Title:   "Freeman tests "
	Author:  "Francois Jouen"
	File: 	 %freemanregular.red
	Needs:	 'View
]


#include %../../libs/redcv.red ; for redCV functions

iSize: 512x512
mat:  rcvCreateMat 'integer! 32 iSize
bMat: rcvCreateMat 'integer! 32 iSize
img: rcvCreateImage iSize
edges: rcvCreateImage iSize
plot: compose [pen white fill-pen white box 128x128 384x384]
fgVal: 1
anim: false
canvas: none



processImage: does [
	img: to-image canvas
	rcvImage2Mat img mat 	 
	rcvMakeBinaryMat mat bmat
	visited: rcvCreateMat 'integer! 32 iSize
	lPix: rcvMatleftPixel bmat iSize fgVal
	rPix: rcvMatRightPixel bmat iSize fgVal
	uPix: rcvMatUpPixel bmat iSize fgVal
	dPix: rcvMatDownPixel bmat iSize fgVal
	f1/text: form as-pair lPix/x uPix/y
	f2/text: form as-pair rPix/x uPix/y
	f3/text: form as-pair lPix/x dPix/y
	f4/text: form as-pair rPix/x dPix/y 
	border: []
	rcvMatGetBorder bmat iSize fgVal border
	foreach p border [rcvSetInt2D visited iSize p 255]
	perim: length? border
	p: first border
	i: 1
	s: copy ""
	clear r/text
	append append plot 'pen 'green
	while [i < perim] [
		d: rcvMatGetChainCode visited iSize p 255
		rcvSetInt2D visited iSize p 0	; pixel processed
		;append append append plot 'box (p) (p + 1) 
		append append append plot 'circle (p) 3 
		append s form d
		if anim [do-events/no-wait]; to show progression
		;get the next pixel to process
		p: rcvGetContours p d
		pgb/data: to-percent (i / to-float perim)
		i: i + 1
	]
	r/text: s
]



; ***************** Test Program ****************************
view win: layout [
	title "Chain Code: Regular Shapes"
	drop-down 100 
	data ["Square" "Circle" "Triangle" "Polygon"] 
	select 1 
	on-change [
		clear r/text
		clear f1/text	
		clear f2/text
		clear f3/text
		clear f4/text
		pgb/data: 0%
		switch face/selected [
			1 [plot: compose [pen white fill-pen white box 128x128 384x384]]
			2 [plot: compose [pen white fill-pen white circle (256x256) 128]]
			3 [plot: compose [pen white fill-pen white triangle 256x128 128x300 384x300]]
			4 [plot: compose [pen white fill-pen white polygon 256x100 384x300 128x400 128x300 256x10]]
		]
		canvas/draw: reduce [plot]
	]
	cb: check "Show Anination" [anim: face/data]
	button "Process" [processImage]
	pgb: progress 180
	pad 150x0
	button "Quit" [
			rcvReleaseImage img
			rcvReleaseImage edges
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
]

		