Red [
	Title:   "Freeman tests "
	Author:  "ldci"
	File: 	 %freemanregular.red
	Needs:	 'View
]

;required libs
#include %../../libs/tools/rcvTools.red
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvFreeman.red

iSize: 		512x512
mat:  		matrix/init 2 32 iSize
img: 		rcvCreateImage iSize
color: 		random white
plot: 		copy [pen color fill-pen color box 128x128 384x384]
fgVal: 		1
anim: 		false
border:		[]
newShape:	true

processImage: does [
	;img: to-image canvas ; to-image: problems with GTK
	rcvZeroImage img
    canvas/image: draw img canvas/draw; reduce [plot]
	rcvImage2Mat img mat 
	bmat: rcvMakeBinaryMat mat
	lPix: rcvMatleftPixel bmat fgVal
	rPix: rcvMatRightPixel bmat fgVal
	uPix: rcvMatUpPixel bmat fgVal
	dPix: rcvMatDownPixel bmat fgVal
	f1/text: form as-pair lPix/x uPix/y
	f2/text: form as-pair rPix/x uPix/y
	f3/text: form as-pair lPix/x dPix/y
	f4/text: form as-pair rPix/x dPix/y 
	clear border
	rcvMatGetBorder bmat fgVal border
	;--set visited matrix
	visited: matrix/init/value 2 8 iSize 0
	foreach p border [rcvSetContourValue visited p 1]
	perim: length? border
	p: first border
	i: 1
	s: copy ""
	clear r/text
	append append plot 'pen 'green
	while [i <= perim] [
		d: rcvMatGetChainCode visited p 1
		idx: (p/y * visited/cols + p/x) + 1
		rcvSetContourValue visited p 0; pixel is visited
		append append append plot 'circle (p) 1 
		if d > -1 [append s form d]
		pgb/data: to-percent (i / to-float perim)
		if anim [do-events/no-wait]; to show progression
		;get the next pixel to process
		p: rcvGetContours p d
		i: i + 1
	]
	r/text: s
	newShape: false
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
		color: 	random white
		canvas/image: none
		switch face/selected [
			1 [plot: copy [pen color fill-pen color box 128x128 384x384]]
			2 [plot: copy [pen color fill-pen color circle 256x256 128]]
			3 [plot: copy [pen color fill-pen color triangle 256x128 128x300 384x300]]
			4 [plot: copy [pen color fill-pen color polygon 256x100 384x300 128x400 128x300 256x10]]
		]
		newShape: true
		canvas/draw: reduce [plot]
		processImage
	]
	pad 20x0
	cb: check "Show Anination" true [anim: face/data]
	button "Process" [if newShape [processImage]]
	pgb: progress 170
	pad 130x0
	button "Quit" [
			rcvReleaseImage img
			rcvReleaseMat mat
			rcvReleaseMat bmat
			rcvReleaseMat visited
			Quit]
	return
	canvas: base iSize black
	r: area 200x512 wrap
	return
	pad 120x0
	f1: field 60
	f2: field 60
	f3: field 60
	f4: field 60
	do [canvas/draw: reduce [plot]]
]



		