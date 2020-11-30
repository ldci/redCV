Red [
	Title:   "Translate Image"
	Author:  "Francois Jouen"
	File: 	 %resize.red
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

factor: 0x0
drawBlk: 
delta: 512

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
		drawBlk: rcvTranslateImage 0.5 factor dst
		canvas/draw: drawBlk
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Translate Image"
		origin margins space margins
		button 60 "Load"	[loadImage]
		text "Translate"
		sl1: slider 200		[sz/text: form as-pair to integer! face/data * delta 
							to integer! face/data * delta
							factor: as-pair face/data * delta face/data * delta drawBlk/5: factor]
		sz: field 60 "0x0"
		button 60 "Quit" 		[Quit]
		return 
		canvas: base iSize black draw drawBlk	
		do [sl1/data: 0.0]
]
