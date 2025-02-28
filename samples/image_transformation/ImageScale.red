Red [
	Title:   "Scale image"
	Author:  "ldci"
	File: 	 %imageSale.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/imgproc/rcvConvolutionImg.red
#include %../../libs/imgproc/rcvGaussian.red
#include %../../libs/imgproc/rcvImgEffect.red

margins: 10x10
img1: rcvCreateImage 512x512
iSize: img1/size
factor: 1.0
drawBlk: []
canvas: none


loadImage: does [
	canvas/image: none
	drawBlk: []
	tmp: request-file
	if not none? tmp [
		canvas/draw: none
		img1: rcvResizeImage rcvLoadImage tmp 512x512
		canvas/image: img1
		iSize: img1/size
		centerXY: iSize / 2
		canvas/image: none
		rot: 0.0
		drawBlk: rcvScaleImage factor img1
		canvas/draw: drawBlk
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Scale Image"
		origin margins space margins
		button 60 "Load"	[loadImage]
		text "Scale"
		sl1: slider 210		[sz/text: form face/data * 2
							factor:  0.005 + face/data * 2
							drawBlk/2: factor 
							drawBlk/3: factor]
		sz: field 50 "1.0"
		button 60 "Quit" 		[Quit]
		return 
		canvas: base iSize black draw drawBlk	
		do [sl1/data: 0.5]
]

;