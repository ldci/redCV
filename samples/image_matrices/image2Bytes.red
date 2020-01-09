Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %Image2Matrix.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red

isize: 256x256
bitSize: 8

img1: rcvCreateImage isize
img2: rcvCreateImage isize
mat:  rcvCreateMat 'char! bitSize isize

loadImage: does [
	canvas1/image/rgb: black
	canvas2/image/rgb: black
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		img2: rcvCreateImage img1/size
		canvas1/image: img1
		convert
	]
]

convert: does [
	mat:  rcvCreateMat 'char! bitSize img1/size
	f/text: rejoin [form bitSize "-bit"]
	rcvImage2Mat img1 mat 		; Converts image to a bytes matrix [0..255] 
	rcvMat2Image mat img2 		; Converts matrix to red image
	canvas2/image: img2			; Shows converted image
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
