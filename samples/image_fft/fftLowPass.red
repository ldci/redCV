Red [
	Title:   "FFT2D tests "
	Author:  "Francois Jouen"
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
isize2: 256x256 ; 28
radius: 1.0
fscale: 1

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
		fft
		isFile: true
	]
]

fft: does [
	t1: now/time/precise
	rcvImage2Mat img1 matInt				; grayscale image to mat
	rcvMatInt2Float matInt matRe 255.0		; integer mat to float mat
	arrayR: rcvMat2Array matRe isize		; real array for faster FFT
	arrayI: rcvMat2Array matIm isize		; imaginary for faster FFT
	rcvFFT2D arrayR arrayI -1 fscale		; FFT
	matR: rcvArray2Mat arrayR				; real vector
	matI: rcvArray2Mat arrayI				; imaginary vector
	fR: rcvFFTFilter matR radius 2			; Low-Pass Filter
	fI: rcvFFTFilter matI radius 2			; Low-Pass Filter
	arrayR: rcvMat2Array fR isize			; for the reverse FFT
	arrayI: rcvMat2Array fI isize			; for the reverse FFT
	mat: rcvFFTAmplitude fR fI				; FFT amplitude
	arrayS: rcvMat2Array mat isize			; we need an array	for shift	
	mat: rcvFFT2DShift arrayS isize			; centered mat
	matAm: rcvTransposeArray mat			; rotated mat
	rcvLogMatFloat matAm matLog				; scale amplitude  by log is better
	rcvMatFloat2Int matLog matInt 255.0  	; to integer	
	rcvMat2Image matInt img2				; red image
	canvas2/image: img2						; show result
	rcvFFT2D arrayR arrayI 1 fscale			; inverse FFT2D
	matR: rcvArray2Mat arrayR				; array to vector matrice
	matI: rcvArray2Mat arrayI				; array to vector matrice
	mat:  rcvAddMat matR matI				; Real + Imaginary parts
	rcvLogMatFloat mat matLog				; scale amplitude  by log is better
	rcvMatFloat2Int matLog matInt 255.0  	; to integer matrix
	rcvMat2Image matInt img3				; to red image
	canvas3/image: img3						; show
	t2: now/time/precise
	sb/text: rejoin ["Processed in " form to-integer (third t2 - t1) * 1000 " ms"]
]

; ***************** Test Program ****************************
view win: layout [
		title "FFT-2D on Image: Low-Pass Filtering"
		button "Load" [loadImage]
		text 100 " Radius" 
		sl: slider 200 [radius: 1.0 + (face/data * 255.0)
						f/text: form to-integer radius if isFile [fft]]
		f: field 50
		pad 540x0
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