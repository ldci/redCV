Red [
	Title:   "Rotate image"
	Author:  "ldci"
	File: 	 %imageRotate.red
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

scale: 0.625
centerXY: iSize / 2
translation: (iSize * scale) / 2 - 8
;scale: 1.0
;translation: 90x90
;centerXY: 160x160
;rot: 0.0


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
		drawBlk: rcvRotateImage scale translation rot centerXY dst
		canvas/draw: drawBlk
	]
]



; ***************** Test Program ****************************
view win: layout [
		title "Rotate Image"
		origin margins space margins
		button 60 "Load"	[loadImage]
		sl1: slider 230		[sz/text: form to integer! face/data * 360 
							 rot: face/data * 360.0 drawBlk/7: rot]
		sz: field 30 "0"
		text 80 "Degrees"
		button 60 "Quit"	[Quit]
		return 
		canvas: base iSize black draw drawBlk	
		do [sl1/data: 0.0]
]
