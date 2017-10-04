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
img1: rcvLoadImage %../../images/lena.jpg
img2: rcvCreateImage img1/size
mat: rcvCreateMat 'integer! 8 img1/size
rcvImage2Mat img1 mat ; -> Grayscale image
rcvMat2Image mat img1
p: 0%

processMat: does [
	rcvImage2Mat img1 mat
	rcvContrastAffine mat p
	rcvMat2Image mat img2
	canvas2/image: img2
]

; ***************** Test Program ****************************
view win: layout [
		title "Contrast Tests"
		origin margins space margins
		sl: slider 200 [p: to percent! face/data  v/data: form face/data processMat]
		v: field 50 "0"
		button 80 "Quit" 				[rcvReleaseImage img1 Quit]
		return
		canvas1: base msize img1
		canvas2: base msize img2
		do [sl/data: 0 processMat]
]