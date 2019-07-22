Red [
	Title:   "Contrast tests "
	Author:  "Francois Jouen"
	File: 	 %contrast.red
	Needs:	 'View
]

; required last Red Master

#include %../../libs/redcv.red ; for red functions

margins: 5x5
msize: 512x512
img1: rcvCreateImage msize
img2: rcvCreateImage img1/size
p: 0%

isFile: false

loadImage: does [
	isFile: false
	canvas1/image: none
	canvas2/draw: none
	canvas2/image: none
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage  tmp
		img2: rcvCreateImage img1/size
		mat: rcvCreateMat 'integer! 8 img1/size
		rcvImage2Mat img1 mat ; -> Grayscale image
		rcvMat2Image mat img1
		canvas1/image: img1
		isFile: true
		p: 0%
		sl/data: p
		processMat
	]
]


processMat: does [
	if isFile[
		rcvImage2Mat img1 mat
		rcvContrastAffine mat p
		rcvMat2Image mat img2
		canvas2/image: img2
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Contrast Affine Tests"
		origin margins space margins
		button "Load Image" [loadImage]
		sl: slider 260 		[p: to percent! face/data  v/data: form face/data processMat]
		v: field 50 "0"
		button 80 "Quit" 	[rcvReleaseImage img1 Quit]
		return
		canvas1: base msize img1
		canvas2: base msize img2
]