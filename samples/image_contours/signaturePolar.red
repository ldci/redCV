Red [
	Title:   "Polar tests "
	Author:  "Francois Jouen"
	File: 	 %signaturePolar.red
	Needs:	 'View
]


;required libs
#include %../../libs/tools/rcvTools.red
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvFreeman.red
#include %../../libs/math/rcvDistance.red
#include %../../libs/math/rcvStats.red


iSize: 512x512
mat:  rcvCreateMat 'integer! 32 iSize
bMat: rcvCreateMat 'integer! 32 iSize
img: rcvCreateImage iSize
plot:  copy [fill-pen white box 155x155 355x355]
_plot: copy [line-width 1 pen green 
			text 175x480 "Angle"
			line 5x10 5x470 5x470 375x470 375x5 5x10 
			line 190x10 190x470
			text 10x450 "0" text 178x450 "180" text 345x450 "360" 
			pen red
			line]
plot2: copy _plot
fgVal: 1
canvas: none


processImage: does [
	img: to-image canvas
	rcvImage2Mat img mat 	 
	rcvMakeBinaryMat mat bmat
	cg: rcvGetMatCentroid bmat img/size 	; get shape centroid
	border: []
	rcvMatGetBorder bmat iSize fgVal border ; get border
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
						plot: compose [fill-pen white box 155x155 355x355]
						plot2: copy _plot
						canvas/draw: reduce [plot]
						canvas2/draw: reduce [plot2]
						processImage
						]
	r2: radio "Circle" [canvas/image: none 
						canvas2/image: none
						plot: compose [fill-pen white circle 255x255 120] 
						plot2: copy _plot
						canvas/draw: reduce [plot]
						canvas2/draw: reduce [plot2]
						processImage
						]
	r3: radio "Triangle" [canvas/image: none 
						canvas2/image: none
						plot: compose [pen white fill-pen white triangle 256x128 128x300 384x400] 
						plot2: copy _plot
						canvas/draw: reduce [plot]
						canvas2/draw: reduce [plot2]
						processImage
						]
	r4: radio "Polygon" [canvas/image: none 
						canvas2/image: none
						plot: compose [pen white fill-pen white polygon 256x100 384x300 128x400 128x300 256x10] 
						plot2: copy _plot
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
