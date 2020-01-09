Red [
	Title:   "Convolution tests "
	Author:  "Francois Jouen"
	File: 	 %emboss1.red
	Needs:	 'View
]


; required libs
#include %../../../libs/tools/rcvTools.red
#include %../../../libs/core/rcvCore.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/imgproc/rcvImgProc.red

margins: 5x10
img1: rcvCreateImage 512x512 ; rcvLoadImage %../../images/lena.jpg
gray: rcvCreateImage img1/size
currentImage:  rcvCreateImage img1/size
dst: rcvCreateImage img1/size
factor: 1.0
bias: 127.0


embossV: [0.0 -1.0 0.0
		  0.0 0.0 0.0 
		  0.0 1.0 0.0]



loadImage: does [
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-local-file tmp
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		either cb/data [currentImage: rcvCloneImage gray]
					   [currentImage: rcvCloneImage img1]
		
		dst:  rcvCloneImage currentImage
		canvas/image: dst
		emboss
	]
]

emboss: does [
	rcvConvolve currentImage dst embossV factor bias
]


; ***************** Test Program ****************************
view win: layout [
	title "Emboss Tests"
	origin margins space margins
	button "Load Image" [loadImage]
	cb: check "Grayscale" [
	either cb/data  [currentImage: rcvCloneImage gray]
					[currentImage: rcvCloneImage img1]
		dst:  rcvCloneImage currentImage
		canvas/image: dst
		emboss
	]
	pad 245x0
	button 80 "Quit" 		[rcvReleaseImage img1 
							rcvReleaseImage dst 
							rcvReleaseImage currentImage
							rcvReleaseImage gray
							Quit]	
	return
	text 50 "Factor" 
	sl1: slider 402 [factor: to-float face/data * 10.0 - 5.0  
					f1/text: form  Factor emboss]
	f1: field 50 "1"
	return
	text 50 "Bias" 
	sl2: slider 402 [bias: to-float face/data * 255 
					f2/text: form to-integer bias emboss]
	f2: field 50 "127"
	return
	canvas: base 512x512 dst
	do [sl1/data: 60% sl2/data: 50%]
]
		

