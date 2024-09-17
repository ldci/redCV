Red [
	Title:   "Fast Convolution tests "
	Author:  "Francois Jouen"
	File: 	 %fastConvolution2.red
	Needs:	 'View
]

{rcvFastConvolve works on an unique channel for faster calculation
 here rcvFastConvolve is applied to each RGB channel of source image}

;required libs
#include %../../libs/tools/rcvTools.red
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvImgProc.red

;a fast laplacian mask
mask: [-1.0 0.0 -1.0 0.0 4.0 0.0 -1.0 0.0 -1.0]


isize: 256x256
isFile: false

factor: 0.5
delta: 	0.0


img1: rcvCreateImage isize
img2: rcvCreateImage isize 
img3: rcvCreateImage isize 
img4: rcvCreateImage isize 


loadImage: does [
	canvas1/image: canvas2/image: canvas3/image: canvas4/image: black
	tmp: request-file
	if not none? tmp [
		isFile: true
		img1: rcvLoadImage tmp
		img2: rcvCreateImage img1/size
		img3: rcvCreateImage img1/size
		img4: rcvCreateImage img1/size
		canvas1/image: img1
		sl1/data: 0.0 sl2/data: 0.0
		convolve
	]
]



convolve: does [
	rcvFastConvolve img1 img2 1 mask factor delta	; fast convolution on channel 1
	rcvFastConvolve img1 img3 2 mask factor delta	; fast convolution on channel 2
	rcvFastConvolve img1 img4 3 mask factor delta	; fast convolution on channel 3
	canvas2/image: img2
	canvas3/image: img3
	canvas4/image: img4
]



view win: layout [
	title "Fast Convolution tests"
	origin 10x10 space 10x10
	button 50 "Load" [loadImage]
	text 100 "Multiplier"
	sl1: slider 200 [factor: 0.5 + (face/data * 9.5) 
		f1/data: form to integer! factor
		if isFile [convolve]
	]
	f1: field 50 "0"
	text 100 "Brightness"
	sl2: slider 200 [delta: 0.0 + (face/data * 256.0) 
		f2/data: to integer! delta
		if isFile [convolve]
	]
	f2: field 50 "0"
	pad 160x0
	button 50  "Quit" [quit]
	return
	text 100 "Source"
	pad 156x0 text "Channel 1: R"
	pad 176x0 text "Channel 2: G"
	pad 176x0 text "Channel 3: B"
	return
	canvas1: base isize
	canvas2: base isize
	canvas3: base isize
	canvas4: base isize
	do [sl1/data: 0.0 sl2/data: 0.0]
]
	