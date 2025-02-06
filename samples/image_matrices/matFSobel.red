Red [
	Title:   "Matrix tests "
	Author:  "ldci"
	File: 	 %matFSobel.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
;#include %../../libs/imgproc/rcvImgProc.red
#include %../../libs/imgproc/rcvConvolutionMat.red ;--for mat convolution


isize: 256x256
bitSize: 8

img1: rcvCreateImage isize
img2: rcvCreateImage isize

loadImage: does [
	canvas1/image/rgb: black
	canvas2/image/rgb: black
	tmp: request-file
	unless none? tmp [
		img1: rcvLoadImage tmp
		img2: rcvCreateImage img1/size
		mat1: matrix/init 2 bitSize img1/size
        mat2: matrix/init 2 bitSize img1/size
		canvas1/image: img1
		rcvImage2Mat img1 mat1 		;--Convert to a grayscale image and to 1 Channel matrix [0..255]  
		rcvSobelMat mat1 mat2		;--Fast Sobel convolution on matrix
		rcvMat2Image mat2 img2		;--from matrix to red image
		canvas2/image: img2			;--show image
		rcvReleaseMat mat1			;--free mat1
		rcvReleaseMat mat2			;--free mat2
	]
]


; ***************** Test Program ****************************
view win: layout [
		title "Fast Sobel on matrix"
		button "Load" [loadImage]
		
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2
							Quit]
		return
		text 100 "Source" pad 156x0 
		text "Fast Sobel"
		return
		canvas1: base isize img1
		canvas2: base isize img2
]
