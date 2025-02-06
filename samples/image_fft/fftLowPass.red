Red [
	Title:   "FFT2D tests "
	Author:  "ldci"
	File: 	 %fftLowPass.red
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
radius: 0.0


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
	
isFile: false

loadImage: does [
	tmp: request-file
	if not none? tmp [
		canvas0/image/rgb: black
		canvas1/image/rgb: black
		canvas2/image/rgb: black
		canvas3/image/rgb: black
		img0: 	rcvLoadImage tmp
		tmpImg: rcvLoadImage/grayscale tmp
		img1: 	rcvResizeImage tmpImg isize
		img2: 	rcvCreateImage isize
		img3: 	rcvCreateImage isize
		canvas0/image: img0
		canvas1/image: img1
		sb/text: ""
		radius: 0.0
		sl/data: 0%
		filter
		isFile: true
	]
]


filter: does [
	t1: now/time/precise
	matIm: 	matrix/init 3 64 isize			; imaginary matrix
	rcvImage2Mat img1 matInt				; grayscale image to matrix
	matRe: rcvMatInt2Float matInt 64 1.0	; real matrix
	;--we need 2 arrays for FFT
	arrayR: rcvMat2Array matRe 				; array of real
	arrayI: rcvMat2Array matIm 				; array of imaginary
	
	;--Forward FFT
	rcvFFT2D arrayR arrayI 1 1						
	;--Low-Pass Filter on vectors
	fR: rcvFFTFilter rcvArray2Vector arrayR radius 2			
	fI: rcvFFTFilter rcvArray2Vector arrayI radius 2	
	matRe/data: fR							
	matIm/data: fI							
	arrayR: rcvMat2Array matRe 				; for the reverse FFT
	arrayI: rcvMat2Array matIm 				; for the reverse FFT
	;--Forward FFT amplitude
	matAm/data: rcvFFTAmplitude fR fI
	;--Quadrants processing		
	b1: rcvMat2Array matAm		;--Matrix/data (vector) to block of vectors (Array)
	b2: rcvFFT2DShift b1		;--a block of vectors
	matAm/data: rcvTransposeArray b2 ;--get vector
	;matAm/data: rcvTransposeArray rcvFFT2DShift rcvMat2Array matAm
	;--scale amplitude  by log is better for FFT
	matLog: rcvLogMatFloat matAm 1.0
	matInt: rcvMatFloat2Int matLog 32 255.0	
	
	;--red image
	rcvMat2Image matInt img2				
	canvas2/image: img2
	
	;--Backward FFT
	rcvFFT2D arrayR arrayI -1 0					
	matAm/data: rcvFFTAmplitude rcvArray2Vector arrayR rcvArray2Vector arrayI	
	
	;--scale 					
	matLog: rcvLogMatFloat matAm 255.0		
	matInt: rcvMatFloat2Int matLog 32 255.0	
	
	;--red image
	rcvMat2Image matInt img3				
	canvas3/image: img3			
	t2: now/time/precise
	sb/text: rejoin ["Processed in " form to-integer (third t2 - t1) * 1000 " ms"]
]


; ***************** Test Program ****************************
view win: layout [
		title "FFT-2D on Image: Low-Pass Filtering"
		button "Load" [loadImage]
		text 100 " Radius" 
		sl: slider 200 [radius: to-float (face/data * 48.0)
						f/text: form round/to radius 0.01 if isFile [filter]]
		f: field 50
		pad 535x0
		button 60 "Quit" [	rcvReleaseImage img0
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
		text "Source Image" 200
		pad 56x0 
		text "Grayscale" 200
		pad 56x0 
		text "Low-Pass Filtering" 200
		pad 56x0 
		text "Fourier Filtered Image"
		return
		canvas0: base isize2 img0
		canvas1: base isize2 img1
		canvas2: base isize2 img2
		canvas3: base isize2 img3
		return
		text 512 "© Red Foundation 2019" center
		pad 10x0
		sb: field 522
		do [sl/data: 0.0 f/text: form radius]
]