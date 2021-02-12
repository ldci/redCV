Red [
	Title:   "FFT2D tests "
	Author:  "Francois Jouen"
	File: 	 %imageFFT4.red
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
floatSize: 64

img:  rcvCreateImage isize
img0: rcvCreateImage isize
img1: rcvCreateImage isize
img2: rcvCreateImage isize
img3: rcvCreateImage isize


;we need some matrices
matInt: matrix/init 2 32 isize	;integer
matRe: 	matrix/init 3 floatSize isize	;real
matIm: 	matrix/init 3 floatSize isize  ;imaginary
matAm:  matrix/init 3 floatSize isize	;magnitude
matLog: matrix/init 3 floatSize isize	;log scale
	
fscale: 1
isFile: false
bias: 255.0

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
		canvas1/image: img0
		sb/text: ""
		bias: 255.0
		fft
		isFile: true
	]
]

fft: does [
	t1: now/time/precise
	;rcvImage2Mat32 img1 matInt
	rcvImage2Mat img1 matInt					; grayscale image to matrix 
	matRe: rcvMatInt2Float matInt floatSize 1.0	; integer mat to float mat
	arrayR: rcvMat2Array matRe 					; array of real
	arrayI: rcvMat2Array matIm					; array of imaginary
	rcvFFT2D arrayR arrayI 1 fscale		    	; FFT with scaling
	vecR: rcvArray2Vector arrayR				; real vector
	vecI: rcvArray2Vector arrayI				; imaginary vector
	matAm/data: rcvFFTAmplitude vecR vecI		; FFT amplitude
	arrayS: rcvMat2Array matAm					; we need an array	for shift	
	vecC: rcvFFT2DShift arrayS isize			; centered array 
	matAm/data: rcvTransposeArray vecC			; rotated mat
	;matInt: rcvMatFloat2Int matAm 32 255.0		; scale amplitude
	matLog: rcvLogMatFloat matAm 255.0			; scale amplitude  by log is better	
	matInt: rcvMatFloat2Int matLog 32 255.0		; to integer matrix	
	rcvMat2Image matInt img2					; to red image
	either cb/data [
		plot: copy [
			line-width 0.75 pen green line 0x64 128x64
			pen off pen green line 64x0 64x128
		]
		canvas2/image: draw img2 plot
	][
		canvas2/image: img2
	]
	
	rcvFFT2D arrayR arrayI -1 0					; inverse FFT2D 
	vecR: rcvArray2Vector arrayR				; array to vector matrice
	vecI: rcvArray2Vector arrayI				; array to vector matrice
	;vecC: vecR + vecI							; Real + Imaginary parts
	;matAm/data: vecC
	matAm/data: rcvFFTAmplitude vecR vecI		; FFT amplitude
	matLog: rcvLogMatFloat matAm bias			; scale amplitude  by log is better
	matInt: rcvMatFloat2Int matLog 32 255.0	 	; to integer matrix 
	rcvMat2Image matInt img3					; to red image: original image from real and imaginary			
	canvas3/image: img3							; show result image
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
		cb: check "Show Quadrants" [if isFile [fft]]
		
		pad 420x0
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