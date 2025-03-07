Red [
	Title:   "Histogram Equalization "
	Author:  "ldci"
	File: 	 %equalization.red
	Needs:	 'View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/math/rcvHistogram.red	

margins: 5x5
msize: 256x256
img1: make image! reduce [msize black]
img2: make image! reduce [msize black]
img3: make image! reduce [msize black]
mat: matrix/init 2 32 img1/size	;--32-bit matrix
grayLevels: 128

processMat: does [
	rcvImage2Mat img1 mat
	rcvHistogramEqualization mat grayLevels
	mat/data * 25
	rcvMat2Image mat img3
	canvas3/image: img3
]

loadImage: does [
	canvas1/image: black
	canvas2/image: black
	canvas3/image: black
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage    tmp
		img2: rcvCreateImage  img1/size
		img3: rcvCreateImage  img1/size
		img4: rcvCreateImage  img1/size
		mat: matrix/init 2 32 img1/size	;--32-bit matrix
		rcvImage2Mat img1 mat ; -> Grayscale image
		rcvMat2Image mat img2
		canvas1/image: img1
		canvas2/image: img2
	]
]
; ***************** Test Program ****************************
view win: layout [
		title "Histogram Equalization"
		origin margins space margins
		button 100 "Load Image" 	[loadImage processMat]
		sl: slider 512 				[grayLevels: to integer! sl/data * 255
									glTxt/data: form grayLevels processMat
		]
		glTxt: field 40 "32" 
		button 100 "Quit" 			[rcvReleaseImage img1  
									rcvReleaseImage img2 
									rcvReleaseImage img3 Quit
		]
		return
		text 256 "Source" center text 256 "Grayscale" center  text 256 "Equalized" center
		return
		canvas1: base msize img1
		canvas2: base msize img2
		canvas3: base msize img3
		do [sl/data: 0.50]
]