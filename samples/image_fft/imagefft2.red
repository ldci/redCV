Red [
	Title:   "FFT2D tests "
	Author:  "Francois Jouen"
	File: 	 %imageFFT2.red
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

img:  rcvCreateImage isize
img0: rcvCreateImage isize
img1: rcvCreateImage isize
	
loadImage: does [
	tmp: request-file
	if not none? tmp [
		canvas1/image/rgb: black
		canvas2/image: none
		canvas3/image: none
		img:  rcvLoadImage tmp
		img0: rcvCreateImage img/size
		rcv2Gray/luminosity img img0
		img1: rcvResizeImage img0 isize
		canvas1/image: img1
		sb/text: ""
		fft
	]
]

fft: does [
	t1: now/time/precise
	canvas2/image: rcvFFTImage/forward img1		; show FFT image
	canvas3/image: rcvFFTImage/backward img1	; show inverse FFT image
	t2: now/time/precise
	sb/text: rejoin ["Processed in " form to-integer (third t2 - t1) * 1000 " ms"]
]

; ***************** Test Program ****************************
view win: layout [
		title "FFT-2D on Image"
		button "Load" [loadImage]
		pad 915x0
		button 60 "Quit" [	rcvReleaseImage img0
							rcvReleaseImage img1 
							Quit]
		return
		text "Grayscale" 256
		text "FFT Transform" 512 text "FFT Inverse"
		return
		canvas1: base isize2 img1
		canvas2: base 512x512 black
		canvas3: base isize2  black
		return
		text 256 "© Red Foundation 2019" center
		sb: field 512
]