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

;we need some vectors
matInt: rcvCreateMat 'integer! 	32 isize	;integer
matRe: 	rcvCreateMat 'float! 	64 isize	;real
matIm: 	rcvCreateMat 'float! 	64 isize	;imaginary
matAm:  rcvCreateMat 'float! 	64 isize	;magnitude
matLog: rcvCreateMat 'float! 	64 isize	;log scale

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

fft: does [
	t1: now/time/precise
	;array: rcvImg2Array img1 6
	matIm * 0.0
	rcvImage2Mat img1 matInt			; grayscale image to matrix
	rcvMatInt2Float matInt matRe 255.0	; integer mat to 0..1 float matrix
	arrayR: rcvMat2Array matRe isize	; array of real
	arrayI: rcvMat2Array matIm isize	; array of imaginary
	rcvFFT2D arrayR arrayI 1 fscale		; FFT 
	matR: rcvArray2Mat arrayR			; real vector
	matI: rcvArray2Mat arrayI			; imaginary vector
	mat: rcvFFTAmplitude matR matI		; FFT amplitude
	arrayS: rcvMat2Array mat isize		; we need an array	for shift	
	arrayC: rcvFFT2DShift arrayS isize	; centered mat
	matAm: rcvTransposeArray arrayC		; rotated mat
	rcvLogMatFloat matAm matLog 		; scale amplitude  by log is better for FFT
	rcvMatFloat2Int matLog matInt 255.0	; to integer matrix		
	;rcvMatFloat2Int matAm matInt 255.0
	
	rcvMat2Image matInt img2			; to red image
	canvas2/image: img2					; show FFT image
	
	{plot: copy [line-width 0.25 pen yellow line 0x0 128x128 
		;pen off pen yellow line 128x0 0x128
	]
	canvas2/image: draw img2 plot}

	
	matIm * 0.0
	rcvImage2Mat img2 matInt			; grayscale image to matrix
	rcvMatInt2Float matInt matRe 255.0	; integer mat to float mat
	arrayR: rcvMat2Array matRe isize
	arrayI: rcvMat2Array matIm isize	; array of imaginary
	
	rcvFFT2D arrayR arrayI -1 0			; FFT2D without scaling
	matR: rcvArray2Mat arrayR			; array to vector matrice
	matI: rcvArray2Mat arrayI			; array to vector matrice
	mat: rcvFFTAmplitude matR matI		; FFT amplitude
	matTmp: rcvMat2Array mat isize		; we need an array	for shift	
	mat: rcvFFT2DShift matTmp isize		; centered mat
	matAm: rcvTransposeArray mat		; rotated mat
	rcvLogMatFloat matAm matLog			; scale amplitude  by log is better
	rcvMatFloat2Int matLog matInt 255.0 ; to integer matrix 
	;rcvMatFloat2Int matAm matInt 255.0	
	
	rcvMat2Image matInt img3			; to red image: original image from inverse FFT			
	canvas3/image: img3					; show result image
	t2: now/time/precise
	sb/text: rejoin ["Processed in " form to-integer (third t2 - t1) * 1000 " ms"]
]

; ***************** Test Program ****************************
view win: layout [
		title "FFT-2D on Image"
		button "Load" [loadImage]
		text "Scale" 
		r1: radio "1/N" true 	[fscale: 1 if isFile [fft]]
		r2: radio "1/sqrt(N)" 	[fscale: 2 if isFile [fft]]
		r3: radio "No scale" 	[fscale: 0 if isFile [fft]]
		pad 535x0
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
		text "FFT Inverse"
		return
		canvas1: base isize2 img1
		canvas2: base 512x512 img2
		canvas3: base isize2 img3
		return
		text 256 "© Red Foundation 2019" center
		sb: field 512
]