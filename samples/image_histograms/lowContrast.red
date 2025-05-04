Red [
	Title:   "Contrast tests "
	Author:  "ldci"
	File: 	 %lowContrast.red
	Needs:	 'View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red

margins: 5x5
msize: 256x256
img1: rcvCreateImage msize
img2: rcvCreateImage msize
f: 1
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
		mat: matrix/init 2 32 img1/size	;--32-bit matrix
		rcvImage2Mat img1 mat ; -> Grayscale image
		rcvMat2Image mat img1
		rcvMat2Image mat img2
		canvas1/image: img1
		canvas2/image: img2
		isFile: true
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Low Contrast"
		origin margins space margins
		button 120 "Load Image"  [loadImage]
		sl: slider 260 [f: 1 + to integer! (face/data * 15)
						v/data: form f 
						if isFile [
							rcvImage2Mat img1 mat 
							mat/data / f 
							rcvMat2Image mat img2
							canvas2/image: img2
						]
			 ]
		v: field 60 "1"
		button 60 "Quit" [rcvReleaseImage img1 rcvReleaseImage img2 Quit]
		return
		canvas1: base msize img1
		canvas2: base msize img2
		do [sl/data: 0.0]
]