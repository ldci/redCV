Red [
	Title:   "FFT2D tests "
	Author:  "Francois Jouen"
	File: 	 %imageFFT1.red
	Needs:	 'View
]


; required libs
#include %../../libs/tools/rcvTools.red
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/timeseries/rcvFFT.red	

;working with fixed size for simplicity and fast computation
; we need 2^N values 
isize: 	128x128 ; 2^7
isize2: 256x256 ; 2^8

img1: rcvCreateImage isize
img2: rcvCreateImage isize
img3: rcvCreateImage isize

loadImage: function [
	n		[integer!]
	return:	[image!]
][
	canvas3/image: none
	canvas4/image: none
	tmp: request-file
	if not none? tmp [
		_img:  rcvLoadImage tmp
		_img0: rcvCreateImage _img/size
		rcv2Gray/average _img _img0
		_img1: rcvResizeImage _img0 128x128
	]
	_img1
]

fft: does [
	t1: now/time/precise
	rcvMul rcvFFTImage/forward img1 rcvFFTImage/forward img2 img3 
	canvas3/image: img3; rcvFFTImage/forward img3
	;canvas4/image: rcvFFTImage/backward img3
	canvas4/image: rcvFFTConvolve img1 img2
	t2: now/time/precise
	sb/text: rejoin ["Processed in " form to-integer (third t2 - t1) * 1000 " ms"]
]



; ***************** Test Program ****************************
view win: layout [
		title "FFT Convolution on Images"
		button "Load 1" 	 [img1: loadImage 1 canvas1/image: img1]
		button "Load 2" 	 [img2: loadImage 2 canvas2/image: img2]
		button "Convolution" [fft]
		pad 715x0
		button 60 "Quit" [
					rcvReleaseImage img1 
					rcvReleaseImage img2 
					rcvReleaseImage img3 
					Quit]
		return
		text "Image 1" 256
		text "Image 2" 256 
		text "Convolution" 256
		text "Result" 256
		return
		canvas1: base isize2 black
		canvas2: base isize2 black
		canvas3: base isize2 black
		canvas4: base isize2 black
		return
		text 256 "© Red Foundation 2019" center
		sb: field 788
]