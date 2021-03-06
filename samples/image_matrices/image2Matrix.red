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
bitSize: 32

img1: rcvCreateImage isize
img2: rcvCreateImage isize
mat:  matrix/init 2 bitSize isize

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
	f/text: rejoin [form bitSize "-bit"]
	mat:  matrix/init 2 bitSize img1/size
	rcvImage2Mat img1 mat	; Converts image to 1 Channel matrix [0..255] 
	rcvMat2Image mat img2	; Converts matrix to red image
	canvas2/image: img2		; Shows converted image
]

; ***************** Test Program ****************************
view win: layout [
		title "Matrix to Image"
		button "Load" [loadImage]
		text 50 "Bit Size" 
		r1: radio 65 "8-bit"  [bitSize:  8  convert]
		r2: radio 65 "16-bit" [bitSize: 16  convert]
		r3: radio 65 "32-bit" [bitSize: 32  convert]
		f: field 60 
		pad 30x0
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2
							rcvReleaseMat mat
							Quit]
		return
		text "Source" pad 175x0 
		text "Matrix to Image"
		return
		canvas1: base isize img1
		canvas2: base isize img2
		do [r3/data: true]
]
