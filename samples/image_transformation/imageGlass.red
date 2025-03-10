Red [
	Title:   "Glass test "
	Author:  "ldci"
	File: 	 %imageGlass.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/imgproc/rcvConvolutionImg.red
#include %../../libs/imgproc/rcvGaussian.red
#include %../../libs/imgproc/rcvImgEffect.red

margins: 5x10
img1: rcvCreateImage 512x512
dst:  rcvCreateImage img1/size
grand: 0.0
op: 1

loadImage: does [
	tmp: request-file
	if not none? tmp [
		canvas/image/rgb: black
		img1: rcvLoadImage tmp
		dst:  rcvCloneImage img1
		bb/image: img1
		canvas/image: dst
		process
	]
]

process: does [
	rcvGlass img1 dst grand op
	canvas/image: dst
]

; ***************** Test Program ****************************

random/seed now/time/precise
view win: layout [
		title "Glass Test"
		origin margins space margins
		button 60 "Load"		[loadImage] 
		text 70 "Direction"
		drop-down 40 data ["1" "2" "3" "4" "5"] 
			on-change [op: face/selected process]
			select 1
		text "Glass Value"
		sl: slider 250			[grand: to-float face/data * 32.0 
								 gf/text: form grand 
								 process]
		gF: field 40 "0.0"		
		
		button 50 "Quit" 		[rcvReleaseImage img1 dst Quit]
		return
		bb: base 128x128 img1 
		canvas: base 512x512 dst
]

