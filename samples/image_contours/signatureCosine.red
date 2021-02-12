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


iSize: 512x512
mat:  matrix/init/value 2 32 iSize 0
img: rcvCreateImage iSize
plot:  copy [fill-pen white box 155x155 355x355]
plot2: copy [line-width 1 pen green line]
fgVal: 1
canvas: none


processImage: does [
	;img: to-image canvas
	rcvZeroImage img
    canvas/image: draw img canvas/draw; reduce [plot]
	rcvImage2Mat img mat 	 
	bmat: rcvMakeBinaryMat mat
	cg: rcvGetMatCentroid bmat 
	;append append append append append plot 'fill-pen 'green 'circle (cg) 3.0
	border: []
	rcvMatGetBorder bmat 1 border
	plot2: copy [line-width 1 pen green line]
	angles: copy []
	foreach p border [
		x: (p/x - cg/x) * (p/x - cg/x)
		y: (p/y - cg/y) * (p/y - cg/y)
		c: sqrt (x + y) 						; AB
		b: to-float p/y	- cg/y					; AC 
		a: to-float p/x - cg/x					; CB	
		if a = 0 [a: 0.00001]
		if b = 0 [b: 0.00001]	
		a2: a * a
		b2: b * b
		c2: c * c
		
		;theta: arctangent to-float a / to-float b
		; cosine law for angles
		cosA:  (negate a2) + b2 + c2 / (2 * b * c)
		cosB: a2 - b2 + c2 / (2 * c * a)
		cosC: a2 + b2 - c2 / (2 * a * b)
		theta: arccosine cosA
		; to get 0..359 angle value
		if p/x > cg/x [theta: 360 - theta]
		theta: round theta
		bloc: copy []
		append bloc theta
		append bloc c
		append/only angles bloc	
	]
	
	sort angles ; 0.. 359
	
	foreach n angles [
		p: as-pair first n 384 - second n 
		p: p + 10x0
		append plot2 (p)
	]
	canvas2/draw: reduce [plot2]
]



; ***************** Test Program ****************************
view win: layout [
	title "Contour Signature"
	
	r1: radio "Square" [canvas/image: none 
						canvas2/image: none
						plot: 	copy [fill-pen white box 155x155 355x355]
						plot2: 	copy [pen green] 
						canvas/draw: reduce [plot]
						canvas2/draw: reduce [plot2]
						processImage
						]
	r2: radio "Circle" [canvas/image: none 
						canvas2/image: none
						plot: copy [fill-pen white circle 255x255 120] 
						plot2: copy [pen green]
						canvas/draw: reduce [plot]
						canvas2/draw: reduce [plot2]
						processImage
						]
	r3: radio "Triangle" [canvas/image: none 
						canvas2/image: none
						plot: copy [pen white fill-pen white triangle 256x128 128x300 384x400] 
						plot2: copy [pen green]
						canvas/draw: reduce [plot]
						canvas2/draw: reduce [plot2]
						processImage
						]
	r4: radio "Polygon" [canvas/image: none 
						canvas2/image: none
						plot: copy [pen white fill-pen white polygon 256x100 384x300 128x400 128x300 256x10] 
						plot2: copy [pen green]
						canvas/draw: reduce [plot]
						canvas2/draw: reduce [plot2]
						processImage
						]
	pad 480x0
	button "Quit" [ rcvReleaseImage img
					rcvReleaseMat mat
					rcvReleaseMat bmat
					Quit]
	return
	canvas: base 512x512 black draw plot
	canvas2: base 380x512 black draw plot2
]
