Red [
	Title:   "Matrix tests "
	Author:  "ldci"
	File: 	 %matLaplacian.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red

; laplacian convolution filter for sample
mask: [-1.0 0.0 -1.0 0.0 4.0 0.0 -1.0 0.0 -1.0]
{mask: [0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0]}

isize: 256x256					;--fix image size
bitSize: 32						;--for 8-bit integer matrix

img1: rcvCreateImage isize		;--create image
img2: rcvCreateImage isize		;--create image
img3: rcvCreateImage isize		;--create image

loadImage: does [
	canvas1/image/rgb: black
	canvas2/image/rgb: black
	tmp: request-file
	unless none? tmp [
		img1: rcvLoadImage tmp					;--load image
		img2: rcvCreateImage img1/size			;--update according to size
		img3: rcvCreateImage img1/size			;--update according to size
		canvas1/image: img1
		mat1: matrix/init 2 bitSize img1/size	;--create integer matrix
		mat2: matrix/init 2 bitSize img1/size	;--create integer matrix
		mat3: matrix/init 2 bitSize img1/size	;--create integer matrix
		rcvImage2Mat img1 mat1					;--Converts to 1 Channel matrix [0..255]
		rcvConvolveMat mat1 mat2 mask 1.0 0.0	;--Laplacian convolution
		rcvConvolveNormalizedMat mat1 mat3 mask 1.0 0.0	;--Laplacian normalization 
		rcvMat2Image mat2 img2					;--from matrix to red image
	 	rcvMat2Image mat3 img3					;--from matrix to red image
		canvas2/image: img2						;--show result
		canvas3/image: img3						;--show result
		rcvReleaseMat mat1						;--free matrix
		rcvReleaseMat mat2						;--free matrix
		rcvReleaseMat mat2						;--free matrix
	]
]


; ***************** Test Program ****************************
view win: layout [
		title "Laplacian convolution on matrix"
		button "Load" [loadImage]
		
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2
							Quit]
		return
		text 100 "Source" pad 166x0 
		text 120 "Standard convolution"
		pad 120x0 
		text "Normalized convolution"
		return
		canvas1: base isize img1
		canvas2: base isize img2
		canvas3: base isize img3
]
