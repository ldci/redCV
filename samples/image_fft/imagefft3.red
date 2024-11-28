Red [
	Title:   "FFT2D tests "
	Author:  "Francois Jouen"
	File: 	 %imageFFT3.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/timeseries/rcvFFT.red	


;working with fixed size for simplicity and fast computation
; we need 2^N values 
isize: 	128x128 ; 2^7
isize2: 256x256 ; 2^8

img:  rcvCreateImage isize
img0: rcvCreateImage isize
img1: rcvCreateImage isize
img2: rcvCreateImage isize
img3: rcvCreateImage isize

;we need some matrices
matInt: matrix/init 2 32 isize	;integer
matRe: 	matrix/init 3 64 isize	;real
matIm: 	matrix/init 3 64 isize	;imaginary
matAm:  matrix/init 3 64 isize	;magnitude
matLog: matrix/init 3 64 isize	;log scale

fscale: 1
isFile: false

loadImage: does [
	tmp: request-file
	if not none? tmp [
		canvas1/image/rgb: black
		canvas2/image/rgb: black
		canvas3/image/rgb: black
		img: rcvLoadImage tmp
		img0: rcvCreateImage img/size
		rcv2Gray/luminosity img img0
		img1: rcvResizeImage img0 isize
		img2: 	rcvCreateImage isize
		img3: 	rcvCreateImage isize
		canvas1/image: img1
		sb/text: ""
		fft
		isFile: true
	]
]

processImage: func [
	imgS	[image!]
	imgD 	[image!]
][
	matIm: 	matrix/init 3 64 isize			; imaginary matrix
	rcvImage2Mat imgS matInt				; grayscale image to matrix
	matRe: rcvMatInt2Float matInt 64 1.0	; integer mat to real matrix
	arrayR: rcvMat2Array matRe 				; array of real
	arrayI: rcvMat2Array matIm 				; array of imaginary
	rcvFFT2D arrayR arrayI 1 1				; FFT 
	vecR: rcvArray2Vector arrayR			; real vector
	vecI: rcvArray2Vector arrayI			; imaginary vector
	matAm/data: rcvFFTAmplitude vecR vecI	; FFT amplitude
	arrayS: rcvMat2Array matAm				; we need an array	for shift	
	vecC: rcvFFT2DShift arrayS isize		; centered array
	matAm/data: rcvTransposeArray vecC		; rotated mat
	matLog: rcvLogMatFloat matAm 255.0		; scale amplitude  by log is better for FFT
	matInt: rcvMatFloat2Int matLog 32 255.0	; to integer matrix		
	rcvMat2Image matInt imgD				; to red image
]

fft: does [
	t1: now/time/precise
	processImage img1 img2					;--From image to FFT image
	canvas2/image: img2						;--show FFT image
	processImage img2 img3					;--From FFT to image	
	canvas3/image: img3						;--show result image
	t2: now/time/precise
	sb/text: rejoin ["Processed in " form to-integer (third t2 - t1) * 1000 " ms"]
]

; ***************** Test Program ****************************
view win: layout [
		title "FFT-2D on Image"
		button "Load" [loadImage]
		button 60 "Quit" [	rcvReleaseImage img
							rcvReleaseImage img0
							rcvReleaseImage img1 
							rcvReleaseImage img2
							rcvReleaseImage img3
							rcvReleaseMat matInt
							rcvReleaseMat matRe
							rcvReleaseMat matIm
							rcvReleaseMat matAm
							rcvReleaseMat matLog
							Quit]
		return
		text "Grayscale Image" 256
		text "FFT Transform" 512
		text "To Red Image"
		return
		canvas1: base isize2 img1
		canvas2: base 512x512 img2
		canvas3: base isize2 img3
		return
		text 256 "© Red Foundation 2019" center
		sb: field 512
]