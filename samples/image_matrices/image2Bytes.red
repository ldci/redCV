Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %Image2Bytes.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red

isize: 256x256									;--fix image size
bitSize: 8										;--8-bit 

img1: rcvCreateImage isize						;--create image
img2: rcvCreateImage isize						;--create image
mat:  matrix/init 2 bitSize isize				;--create 8-bit integer matrix

loadImage: does [
	canvas1/image/rgb: black
	canvas2/image/rgb: black
	tmp: request-file
	unless none? tmp [
		img1: rcvLoadImage tmp					;--load original image
		img2: rcvCreateImage img1/size			;--create a second image
		mat: matrix/init 2 bitSize img1/size	;--update matrix according to image size
		canvas1/image: img1						;--show original image
		convert									;--conversion
	]
]

convert: does [
	f/text: rejoin [form bitSize "-bit"]
	rcvImage2Mat img1 mat 	;--Convert image to a bytes matrix [0..255] 
	rcvMat2Image mat img2	;--Convert matrix to red image
	canvas2/image: img2		;--Show converted image
]

; ***************** Test Program ****************************
view win: layout [
		title "Bytes Matrix to Image"
		button "Load" [loadImage]
		text "Matrix Bit Size" 
		f: field 60 
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2
							rcvReleaseMat mat
							Quit]
		return
		text "Source" pad 180x0 
		text "Bytes Matrix to Image"
		return
		canvas1: base isize img1
		canvas2: base isize img2
]
