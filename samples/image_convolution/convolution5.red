Red [
	Title:   "Convolution tests "
	Author:  "ldci"
	File: 	 %convolution5.red
	Needs:	 'View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red

isize: 256x256
dsize: isize * 2

img1: rcvCreateImage isize
img2: rcvCreateImage isize 
img3: rcvCreateImage dsize 

;a quick laplacian mask
knl: [1.0 1.0 1.0 1.0 -8.0 1.0 1.0 1.0 1.0]

loadImage: does [
	canvas1/image: canvas2/image: canvas3/image: black
	tmp: request-file
	if not none? tmp [
		isFile: true
		;img1: rcvLoadImage/grayscale tmp
		img1: rcvLoadImage tmp
		img2: rcvCreateImage img1/size
		img3: rcvCreateImage img1/size
		canvas1/image: img1
		f/text: form knl
		convolve
	]
]

convolve: does [
	rcvConvolve img1 img2 knl 1.0 0.0
	rcvFilter2D img1 img3 knl 1.0 0.0
	canvas2/image: img2
	canvas3/image: img3
]


view win: layout [
	title "Fast Convolution tests"
	origin 10x10 space 10x10
	button 50 "Load" [loadImage]
	text "Kernel" f: text 230
	pad 330x0 
	button 50 "Quit" [Quit]
	return
	text 256 "Source" 
	text 256 "Convolution"
	text 256 "2-D Filter"
	return
	canvas1: base isize img1
	canvas2: base isize img2
	canvas3: base isize img3
]


