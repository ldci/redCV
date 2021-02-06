Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %matrixTest.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red

;we use matrix-as-obj

isize: 256x256
bitSize: 32
dir: 1
img1: rcvCreateImage isize
img2: rcvCreateImage isize
mx:   matrix/init 2 bitSize isize

loadImage: does [
	f2/text: ""
	canvas1/image/rgb: black
	canvas2/image/rgb: black
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		img2: rcvCreateImage img1/size
		mx:   matrix/init 2 bitSize img1/size
		canvas1/image: img1
		convert
	]
]

convert: does [
	f/text: rejoin [form bitSize "-bit"]
	rcvImage2Mat32 img1 mx		; Converts image to a 32-bit matrix  
	rcv32Mat2Image mx img2 		; Converts matrix to red image
	canvas2/image: img2			; Shows converted image
]

rotate: does [
	t1: now/time/precise
	matrix/rotate mx dir
	t2: now/time/precise
	f2/text: rejoin [form round/to (third t2 - t1) * 1000 0.01 " ms"]
	rcv32Mat2Image mx img2
	canvas2/image: img2
]

transpose: does [
	t1: now/time/precise
	matrix/transpose mx
	t2: now/time/precise
	f2/text: rejoin [form round/to (third t2 - t1) * 1000 0.01 " ms"]
	rcv32Mat2Image mx img2
	canvas2/image: img2
]


; ***************** Test Program ****************************
view win: layout [
		title "Integer Matrix to Image"
		button "Load" [loadImage]
		text 50 "Bit Size" 
		f: field 50 
		button "Rotate"  [rotate]
		check "Clockwise" true [either face/data [dir: 1][dir: -1]] 
		button "Transpose" [transpose]
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2
							rcvReleaseMat   mx
							Quit]
		return
		text 256 "Source"  
		text "Matrix transform" 
		f2: field 140
		return
		canvas1: base isize img1
		canvas2: base isize img2
]
