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
		rcv2Gray/average img img0
		img1: rcvResizeImage img0 isize
		img2: rcvResizeImage img0 isize
		img3: rcvResizeImage img0 isize
		
		canvas1/image: img1
		sb/text: ""
		fft
	]
]

fft: does [
	t1: now/time/precise
	matInt: matrix/init 2 32 isize
	rcvImage2Mat img1 matInt
	matR: rcvMatInt2Float matInt 64 1.0 
	matI: matrix/init 3 64 isize
	matF: rcvFFTMat/forward matR matI
	matB: rcvFFTMat/backward matR matI
	
	;--log scale and show result
	matL: rcvLogMatFloat matF 1.0	
	matInt: rcvMatFloat2Int matL 32 255.0
	rcvMat2Image matInt img2
	canvas2/image: img2
	;--log scale and show result
	matL: rcvLogMatFloat matB 255.0	
	matInt: rcvMatFloat2Int matL 32 255.0
	rcvMat2Image matInt img3
	canvas3/image: img3
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