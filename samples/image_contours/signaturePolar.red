Red [
	Title:   "Polar tests "
	Author:  "ldci"
	File: 	 %signaturePolar.red
	Needs:	 'View
]


;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvFreeman.red
#include %../../libs/math/rcvDistance.red


iSize: 512x512
mat:  matrix/init/value 2 32 iSize 0
img:  rcvCreateImage iSize
plot:  compose [fill-pen white box 155x155 355x355]
_plot: compose [line-width 1 pen green 
			text 175x480 "Angle"
			line 5x10 5x470 375x470 375x10 5x10 
			line 190x10 190x470
			text 10x450 "0" text 178x450 "180" text 345x450 "359" 
			pen red
			line]
plot2: copy _plot
fgVal: 1
canvas: none
canvas2: none
recycle/off

processImage: does [
	;if system/platform <> 'Linux [img: to-image canvas]
   	rcvZeroImage img
    canvas/image: draw img canvas/draw; reduce [plot]
	rcvImage2Mat img mat 	 
	bmat: rcvMakeBinaryMat mat
	cg: rcvGetMatCentroid bmat 	; get shape centroid
	border: []
	rcvMatGetBorder bmat 1 border ; get border
	angles: copy []
	foreach p border [
		; use x y coordinates and calculate rho and theta
		rho: rcvGetEuclidianDistance p cg
		theta: rcvGetAngle p cg
		bloc: copy []
		append bloc theta
		append bloc rho
		append/only angles bloc	
	]
	sort angles ; 0.. 359  to use with line draw command
	foreach n angles [
		;p: as-pair first n 384 - second n
		p: as-point2D first n 384 - second n 
		p: p + 10x0
		append plot2 (p)
	]
	canvas2/draw: reduce [plot2]
]



; ***************** Test Program ****************************
view win: layout [
	title "Contour Signature"
	base 100x25 white "Shapes" 
	r1: radio "Square" [canvas/image: none 
						canvas2/image: none
						plot: compose [fill-pen white box 155x155 355x355]
						plot2: copy _plot
						canvas/draw:  reduce [plot]
						canvas2/draw: reduce [plot2]
						processImage
						] true
	r2: radio "Circle" [canvas/image: none 
						canvas2/image: none
						plot: compose [fill-pen white circle 255x255 120] 
						plot2: copy _plot
						canvas/draw:  reduce [plot]
						canvas2/draw: reduce [plot2]
						processImage
						]
	r3: radio "Triangle" [canvas/image: none 
						canvas2/image: none
						plot: compose [pen white fill-pen white triangle 256x128 128x300 384x400] 
						plot2: copy _plot
						canvas/draw:  reduce [plot]
						canvas2/draw: reduce [plot2]
						processImage
						]
	r4: radio "Polygon" [canvas/image: none 
						canvas2/image: none
						plot: compose [pen white fill-pen white polygon 256x100 384x300 128x400 128x300 256x10] 
						plot2: copy _plot
						canvas/draw:  reduce [plot]
						canvas2/draw: reduce [plot2]
						processImage
						]
	
	pad 370x0
	button "Quit" [ recycle/on
					rcvReleaseImage img
					rcvReleaseMat mat
					rcvReleaseMat bmat
					Quit]
	return
	canvas: 	base 512x512 black draw plot
	canvas2: 	base 380x512 black draw plot2
	do [processImage]
]
