Red [
	Title:   "Matrix tests "
	Author:  "ldci"
	File: 	 %addMatrices.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red

isize: 256x256
bitSize: 32
img1: rcvCreateImage isize						;--create 8-bit image
img2: rcvCreateImage isize						;--create 8-bit image
img3: rcvCreateImage isize						;--create 8-bit image

isFile: false

; loads any supported Red image 
loadImage: does [
	isFile: false
	canvas1/image/rgb: black
	canvas2/image/rgb: black
	canvas3/image/rgb: black
	tmp: request-file
	unless none? tmp [
		img1: rcvLoadImage tmp					;--read original image
		img2: rcvCreateImage img1/size			;--update img2 image according to size		
		img3: rcvCreateImage img1/size			;--update img3 image according to size
		mat1: matrix/init 2 bitSize img1/size	;--an integer matrix
		mat2: matrix/init 2 bitSize img1/size	;--an integer matrix
		mat3: matrix/init 2 bitSize img1/size	;--an integer matrix
		canvas1/image: img1						;--show original image
		rcvImage2Mat img1 mat1					;--original image to integer matrix
		isFile: true
	]
]

; generate random image
generate: does [
	if isFile [
		mat2: matrix/init/value/rand 2 bitSize img1/size 128;--a random integer matrix
		rcvMat2Image mat2 img2								;--matrix to image
		canvas2/image: img2									;--show result
		mat3: matrix/addition mat1 mat2						;--add both matrices
		rcvMat2Image mat3 img3								;--matrix to image
		canvas3/image: img3									;--show result
	]
]


; Clean App Quit
quitApp: does [
	rcvReleaseImage img1 
	rcvReleaseImage img2
	rcvReleaseImage img3
	if isFile [
		rcvReleaseMat mat1
		rcvReleaseMat mat2
		rcvReleaseMat mat3
	]
	Quit
]



; ***************** Test Program ****************************
view win: layout [
		title "Add Matrices"
		button "Load" [loadImage]
		button "Generate" [generate]
		button "Quit" [quitApp]
		return
		text 100 "Source" 
		pad 156x0 text 100 "Random image"
		pad 156x0 text "Addition"
		return
		canvas1: base isize img1
		canvas2: base isize img2
		canvas3: base isize img3
]