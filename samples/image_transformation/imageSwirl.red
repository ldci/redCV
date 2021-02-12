Red [
	Title:   "Swirl test "
	Author:  "Francois Jouen"
	File: 	 %ImageSwirl.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/imgproc/rcvConvolutionImg.red
#include %../../libs/imgproc/rcvGaussian.red
#include %../../libs/imgproc/rcvImgEffect.red

margins: 5x10
img1: rcvCreateImage 512x512
dst:  rcvCreateImage 512x512
angle: 180.0

loadImage: does [
	tmp: request-file
	if not none? tmp [
		canvas/image/rgb: black
		img1: rcvLoadImage tmp
		dst:  rcvCloneImage img1
		bb/image: img1
		canvas/image: dst
	]
	process
]

process: does [
	rcvSwirl img1 dst angle
	canvas/image: dst
]


; ***************** Test Program ****************************

view win: layout [
	title "Swirl Test"
	origin margins space margins
	button 60 "Load"		[loadImage] 
	text 60 "Angle "
	sl: slider 400 			[angle: 1.0 + to-float face/data * 359.0
							 af/text: form to-integer angle process]
	
	aF: field 50 "180.0"	[if error? try [angle: to-float af/text] [angle: 180.0] process]
	button 50 "Quit" 		[rcvReleaseImage img1 dst Quit]
	return
	bb: base 128x128 img1 
	canvas: base 512x512 dst
	do [sl/data: 50%]
]

