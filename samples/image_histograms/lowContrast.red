Red [
	Title:   "Contrast tests "
	Author:  "Francois Jouen"
	File: 	 %lowContrast.red
	Needs:	 'View
]

; required last Red Master

#include %../../libs/redcv.red ; for red functions

margins: 5x5
msize: 512x512
img1: rcvCreateImage msize
img2: rcvCreateImage img1/size
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
		mat: rcvCreateMat 'integer! 8 img1/size
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
		title "Contrast Tests"
		origin margins space margins
		button 120 "Load Image"  [loadImage]
		sl: slider 370 [f: to integer! (face/data * 127)
						if f = 0 [f: 1]
						v/data: form f 
						if isFile [
							rcvImage2Mat img1 mat 
							mat / f 
							rcvMat2Image mat img2
							canvas2/image: img2
						]
			 ]
		v: field 50 "1"
		pad 400x0
		button 60 "Quit" 				[rcvReleaseImage img1 rcvReleaseImage img2 Quit]
		return
		canvas1: base msize img1
		canvas2: base msize img2
		do [sl/data: 0.0]
		
]