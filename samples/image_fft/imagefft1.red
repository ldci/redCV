Red [
	Title:   "FFT2D tests "
	Author:  "Francois Jouen"
	File: 	 %imageFFT1.red
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
	
isFile: false

loadImage: does [
	tmp: request-file
	if not none? tmp [
		canvas1/image/rgb: black
		canvas2/image/rgb: black
		canvas3/image/rgb: black
		img:  rcvLoadImage tmp
		img0: rcvCreateImage img/size
		rcv2Gray/luminosity img img0
		img1: rcvResizeImage img0 isize
		img2: rcvCreateImage isize
		img3: rcvCreateImage isize
		;canvas0/image: img
		canvas1/image: img0
		sb/text: ""
		fft
		isFile: true
	]
]

fft: does [

	t1: now/time/precise
	rcvImage2Mat img1 matInt			; grayscale image to matrix
	rcvMatInt2Float matInt matRe 255.0	; integer mat to float mat
	arrayR: rcvMat2Array matRe isize	; array of real
	arrayI: rcvMat2Array matIm isize	; array of imaginary
	rcvFFT2D arrayR arrayI -1			; FFT without scaling
	matR: rcvArray2Mat arrayR			; real vector
	matI: rcvArray2Mat arrayI			; imaginary vector
	mat: rcvFFTAmplitude matR matI		; FFT amplitude
	matTmp: rcvMat2Array mat isize		; we need an array	for shift	
	mat: rcvFFT2DShift matTmp isize		; centered mat
	matAm: rcvTransposeArray mat		; rotated mat
	;rcvMatFloat2Int matAm matInt 255.0	
	
	rcvLogMatFloat matAm matLog			; scale amplitude  by log is better
	rcvMatFloat2Int matLog matInt 255.0	; to integer matrix	
	
	rcvMat2Image matInt img2			; to red image
	canvas2/image: img2					; show magnitude image
	
	rcvFFT2D arrayR arrayI 1			; inverse FFT2D
	matR: rcvArray2Mat arrayR			; array to vector matrice
	matI: rcvArray2Mat arrayI			; array to vector matrice
	mat: matR + matI					; Real + Imaginary parts
	rcvLogMatFloat mat matLog			; scale amplitude  by log is better
	rcvMatFloat2Int matLog matInt 255.0 ; to integer matrix 
	rcvMat2Image matInt img3			; to red image: original image from real and imaginary			
	canvas3/image: img3					; show result image
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
							rcvReleaseImage img2
							rcvReleaseImage img3
							rcvReleaseImage img
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