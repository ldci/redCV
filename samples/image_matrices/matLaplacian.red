Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
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

isize: 256x256
bitSize: 32

img1: rcvCreateImage isize
img2: rcvCreateImage isize
img3: rcvCreateImage isize

loadImage: does [
	canvas1/image/rgb: black
	canvas2/image/rgb: black
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		img2: rcvCreateImage img1/size
		img3: rcvCreateImage img1/size
		mat1: rcvCreateMat 'integer! bitSize img1/size
		mat2: rcvCreateMat 'integer! bitSize img1/size
		mat3: rcvCreateMat 'integer! bitSize img1/size
		canvas1/image: img1
		rcvImage2Mat img1 mat1 										; Converts to  grayscale image and to 1 Channel matrix [0..255]
		rcvConvolveMat mat1 mat2 img1/size mask 1.0 0.0				; Laplacian convolution
		rcvConvolveNormalizedMat mat1 mat3 img1/size mask 1.0 0.0	; Laplacian convolution
		rcvMat2Image mat2 img2										; from matrix to red image
		rcvMat2Image mat3 img3										; from matrix to red image
		canvas2/image: img2
		canvas3/image: img3
		rcvReleaseMat mat1
		rcvReleaseMat mat2
		rcvReleaseMat mat2
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
