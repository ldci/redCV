Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %matKirsch.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red

isize: 256x256					;--fix image size
bitSize: 8						;--8-bit for matrix

img1: rcvCreateImage isize		;--create image
img2: rcvCreateImage isize		;--create image
img3: rcvCreateImage isize		;--create image
img4: rcvCreateImage isize		;--create image


loadImage: does [
	canvas1/image/rgb: black
	canvas2/image/rgb: black
	canvas3/image/rgb: black
	canvas4/image/rgb: black
	tmp: request-file
	unless none? tmp [
		img1: rcvLoadImage tmp					;--load image
		img2: rcvCreateImage img1/size			;--create image
		img3: rcvCreateImage img1/size			;--create image
		img4: rcvCreateImage img1/size			;--create image
		mat1: matrix/init 2 bitSize img1/size	;--create integer matrix
		mat2: matrix/init 2 bitSize img1/size	;--create integer matrix
		mat3: matrix/init 2 bitSize img1/size	;--create integer matrix
		mat4: matrix/init 2 bitSize img1/size	;--create integer matrix
		
		rcvImage2Mat img1 mat1	;--Converts to  grayscale image and to 1 Channel matrix [0..255]  
		rcvKirsch mat1 mat2 1 1	;--Kirsch convolution x
		rcvKirsch mat1 mat3 2 1	;--Kirsch convolution y
		rcvKirsch mat1 mat4 3 1	;--Kirsch convolution x and y
		
		
		rcvMat2Image mat2 img2	;--from matrix to red image
		rcvMat2Image mat3 img3	;--from matrix to red image
		rcvMat2Image mat4 img4	;--from matrix to red image
		canvas1/image: img1		;--show result
		canvas2/image: img2		;--show result
		canvas3/image: img3		;--show result
		canvas4/image: img4		;--show result
		rcvReleaseMat mat1		;--free memory
		rcvReleaseMat mat2		;--free memory
		rcvReleaseMat mat3		;--free memory
		rcvReleaseMat mat4		;--free memory
	]
]


; ***************** Test Program ****************************
view win: layout [
		title "Kirsch Operator on matrix"
		button "Load" [loadImage]
		
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2
							rcvReleaseImage img3
							rcvReleaseImage img4
							Quit]
		return
		text "Source" 100 pad 156x0 
		text "X"
		pad 176x0 
		text "Y"
		pad 176x0 
		text "X + Y"
		return
		canvas1: base isize img1
		canvas2: base isize img2
		canvas3: base isize img3
		canvas4: base isize img4
]
