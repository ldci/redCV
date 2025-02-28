Red [
	Title:   "Fast Convolution tests "
	Author:  "ldci"
	File: 	 %fastConvolution1.red
	Needs:	 'View
]

{ rcvFastConvolve works on an unique channel for faster calculation
 the basic idea is to transform the source into a gray scale image}
 
	   
;required libs
#include %../../libs/tools/rcvTools.red
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvImgProc.red
	
;a quick laplacian mask
mask: [-1.0 0.0 -1.0 0.0 4.0 0.0 -1.0 0.0 -1.0]

isize: 256x256
dsize: isize * 2

img1: rcvCreateImage isize
img2: rcvCreateImage isize 
img3: rcvCreateImage dsize 

isFile: false
factor: 1.0
delta: 10.00
channel: 1 ; 1, 2 or 3 since we use a grayscale image

loadImage: does [
	canvas1/image: canvas2/image: canvas3/image: black
	tmp: request-file
	if not none? tmp [
		isFile: true
		img1: rcvLoadImage tmp
		img2: rcvCreateImage img1/size
		img3: rcvCreateImage img1/size
		rcv2Gray/average img1 img2
		canvas1/image: img1
		canvas2/image: img2
		convolve
	]
]

convolve: does [
	rcvFastConvolve img2 img3 channel mask factor delta
	canvas3/image: img3
]


view win: layout [
	title "Fast Convolution tests"
	origin 10x10 space 10x10
	button 50 "Load" [loadImage]
	text 100 "Multiplier"
	sl1: slider 200 [factor: 0.5 + (face/data * 99.5) 
		f1/data: form to integer! factor
		if isFile [convolve]
	]
	f1: field 50 "1"
	text 100 "Brightness"
	sl2: slider 200 [delta: 0.0 + (face/data * 256.0) 
		f2/data: form to integer! delta
		if isFile [convolve]
	]
	f2: field 50 "10"
	pad 160x0
	button 50 "Quit" [rcvReleaseImage img1
						rcvReleaseImage img2
						rcvReleaseImage img3
						Quit]
	return
	text 100 "Source" 
	pad 156x0 text 100 "Gray Scale"
	pad 156x0 text 100 "Result"
	return
	canvas1: base isize img1
	canvas2: base isize img2
	canvas3: base dsize img3
	do [sl1/data: 0.01 sl2/data: 0.1]
]