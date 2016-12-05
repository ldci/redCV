Red [
	Title:   "Contrast tests "
	Author:  "Francois Jouen"
	File: 	 %contrastColor.red
	Needs:	 'View
]

; required last Red Master

#include %../../libs/redcv.red ; for red functions

margins: 5x5
msize: 512x512
img1: rcvLoadImage %../../images/baboon.jpg
img2: rcvCreateImage img1/size
mat0: rcvCreateMat 'integer! 8 img1/size
mat1: rcvCreateMat 'integer! 8 img1/size
mat2: rcvCreateMat 'integer! 8 img1/size
mat3: rcvCreateMat 'integer! 8 img1/size
p: 0%

processMat: does [
	rcvSplit2Mat img1 mat0 mat1 mat2 mat3				; split image
	rcvContrastAffine mat1 p							; R channel
	rcvContrastAffine mat2 p							; G channel
	rcvContrastAffine mat3 p							; B channel
	rcvMerge2Image mat0 mat1 mat2 mat3 img2				; and merge matrices 
	canvas2/image: img2
]

; ***************** Test Program ****************************
view win: layout [
		title "Contrast Tests"
		origin margins space margins
		sl: slider 455 [p: to percent! face/data  v/data: form face/data processMat]
		v: field 50 "0%"
		pad 472x0
		button 40 "Quit" 				[rcvReleaseImage img1 rcvReleaseImage img2 Quit]
		return
		canvas1: base msize img1
		canvas2: base msize img2
		do [sl/data: 0 processMat]
]