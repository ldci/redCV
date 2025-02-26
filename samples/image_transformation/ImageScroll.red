Red [
	Title:   "Scroll Image"
	Author:  "ldci"
	File: 	 %imageScroll.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/imgproc/rcvConvolutionImg.red
#include %../../libs/imgproc/rcvGaussian.red
#include %../../libs/imgproc/rcvImgEffect.red

xy: 0x0
margins: 10x10
isFile: false

loadImage: does [
	isFile: false
	tmp: request-file
	vSlider/data: 0.0
	hSlider/data: 0.0
	xy: 0x0
	drawBlk: compose [translate (xy) image]
	if not none? tmp [
		img1: load tmp
		append drawBlk (img1)
		canvas/draw: drawBlk
		f/text: form img1/size
		isFile: true
		either img1/size/x > 640 [hSlider/visible?: true] [hSlider/visible?: false]
		either img1/size/y > 480 [vSlider/visible?: true] [vSlider/visible?: false]
	]
]


; ***************** Test Program ****************************
view win: layout [
		title "Image Scrolling"
		origin margins space margins
		button 60 "Load" 		[loadImage]
		f: field 120 	
		button 50 "Quit" 		[Quit]
		return
		canvas: base 640x480 glass 
		vSlider: slider 16x480 [
			if isFile [xy/y: to integer! negate face/data * (max 0 img1/size/y - canvas/size/y)  
			drawBlk/2: xy]
		]
		return 
		hSlider: slider 640x16	[
			if isFile [xy/x: to integer! negate face/data * (max 0 img1/size/x - canvas/size/x) 
			drawBlk/2: xy]	
		]
]