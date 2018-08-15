Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %freeman.red
	Needs:	 'View
]


#include %../../libs/redcv.red ; for redCV functions

iSize: 512x512
mat:  rcvCreateMat 'integer! 32 iSize
bMat: rcvCreateMat 'integer! 32 iSize
img: rcvCreateImage iSize
plot: copy [fill-pen white box 155x155 355x355]
plot2: copy [line-width 1 pen green line]
fgVal: 1
canvas: none


processImage: does [
	img: to-image canvas
	rcvImage2Mat img mat 	 
	rcvMakeBinaryMat mat bmat
	cg: rcvGetMatCentroid bmat img/size 
	;append append append append append plot 'fill-pen 'green 'circle (cg) 3.0
	border: []
	rcvMatGetBorder bmat iSize fgVal border
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
		if (p/x >= cg/x) [theta: 180.0 + theta]
		if theta >= 180 [theta: 360.0 - theta + 180.0]
		theta: round theta
		bloc: copy []
		append bloc theta
		append bloc c
		append/only angles bloc	
	]
	
	sort angles ; 0.. 360
	
	foreach n angles [
		p: as-pair first n 384 - second n 
		p: p + 10x0
		append plot2 (p)
		;do-events/no-wait; to show progression
	]
	canvas2/draw: reduce [plot2]
	
]



; ***************** Test Program ****************************
view win: layout [
	title "Contour Signature"
	
	r1: radio "Square" [canvas/image: none 
						canvas2/image: none
						plot: compose [fill-pen white box 155x155 355x355]
						plot2: copy [pen green] 
						canvas/draw: reduce [plot]
						canvas2/draw: reduce [plot2]
						]
	r2: radio "Circle" [canvas/image: none 
						canvas2/image: none
						plot: compose [fill-pen white circle 255x255 120] 
						plot2: copy [pen green]
						canvas/draw: reduce [plot]
						canvas2/draw: reduce [plot2]
						]
	r3: radio "Triangle" [canvas/image: none 
						canvas2/image: none
						plot: compose [pen white fill-pen white triangle 256x128 128x300 384x400] 
						plot2: copy [pen green]
						canvas/draw: reduce [plot]
						canvas2/draw: reduce [plot2]
						]
	r4: radio "Polygon" [canvas/image: none 
						canvas2/image: none
						plot: compose [pen white fill-pen white polygon 256x100 384x300 128x400 128x300 256x10] 
						plot2: copy [pen green]
						canvas/draw: reduce [plot]
						canvas2/draw: reduce [plot2]
						]
	button "Process" [processImage]
	pad 395x0
	button "Quit" [ rcvReleaseImage img
					rcvReleaseMat mat
					rcvReleaseMat bmat
					Quit]
	return
	canvas: base 512x512 black draw plot
	canvas2: base 380x512 black draw plot2
	do  [r1/data: true]
]
