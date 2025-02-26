Red [
	Title:   "Translate Image"
	Author:  "ldci"
	File: 	 %imageTranslate2.red
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
isFile: false
centerXY: iSize / 2

factor: 0x0
drawBlk: 
delta: 512
x: 0
y: 0

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
		;rot: 0.0
		drawBlk: rcvTranslateImage 0.5 factor dst
		canvas/draw: drawBlk
		isFile: true
	]
]

updateImage: does [
	x: to-integer sl1/data * delta
	y: to-integer sl2/data * delta
	factor: as-pair x y
	sx/text: form factor
	sy/text: form factor
	drawBlk/5: factor 
]

updateXY: does [
	x: to-integer sl3/data * delta
	y: to-integer sl3/data * delta
	sl1/data: to-percent x / delta
	sl2/data: to-percent Y / delta
	factor: as-pair x y
	sx/text: form factor
	sy/text: form factor
	sz/text: form factor
	drawBlk/5: factor
]


; ***************** Test Program ****************************
view win: layout [
		title "Translate Image"
		origin margins space margins
		button 60 "Load"		[loadImage]
		pad 370x0
		button 60 "Quit" 		[Quit]
		return
		text 40 "X" 
		sl1: slider 390			[if isFile [updateImage]]
		sx: field 60 "0x0"
		
		return 
		text 40 "Y"
		sl2: slider 390			[if isFile [updateImage]]
		sy: field 60 "0x0"
		
		return
		
		cb: check 40 "XY"
		sl3: slider 390			[if cb/data [updateXY]]
		sz: field 60 "0x0"
		
		return 
		canvas: base iSize black draw drawBlk
]
