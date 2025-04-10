Red [
	Title:   "Rotate image"
	Author:  "ldcin"
	File: 	 %imageSkew1.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/imgproc/rcvConvolutionImg.red
#include %../../libs/imgproc/rcvGaussian.red
#include %../../libs/imgproc/rcvImgEffect.red

margins: 10x10
iSize: 	512x512
img1: 	rcvCreateImage iSize
dst: 	rcvCreateImage iSize
centerXY: iSize / 2
x: 0
y: 0
rot: 0.0
drawBlk: []
canvas: none
loadImage: does [
	canvas/image: none
	drawBlk: []
	tmp: request-file
	if not none? tmp [
		canvas/draw: none
		img1: rcvLoadImage tmp
		dst: rcvResizeImage img1 iSize ; force image in 512x512
		rot: 0.0
		drawBlk: rcvSkewImage 0.5 0x0 x y dst
		canvas/draw: drawBlk
	]
]




; ***************** Test Program ****************************
view win: layout [
		title "Skew Image"
		origin margins space margins
		button 60 "Load"	[loadImage]
		sl1: slider 230		[sz/text: form to integer! face/data * 180 
							 if cbx/data [x:  face/data * 180.0 ] [x: 0] drawBlk/7: x
							 if cby/data [y:  face/data * 180.0] [y: 0] drawBlk/8: y
							 ]
		sz: field 30 "0"
		text "Degrees"
		button 60 "Quit"	[Quit]
		return 
		cbx: check "Skew X"
	    cby: check "Skew Y"
		return 
		canvas: base iSize black draw drawBlk	
		do [ sl1/data: 0.0 cbx/data: true]
]
