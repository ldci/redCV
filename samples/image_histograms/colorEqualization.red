Red [
	Title:   "Histogram Equalization "
	Author:  "ldci"
	File: 	 %ColorEqualization.red
	Needs:	 'View
]
;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/math/rcvHistogram.red	

margins: 5x5
msize: 256x256
grayLevels: 128
bitSize: 32

img1: make image! reduce [msize black]	; src
imgD: rcvCreateImage img1/size			; dst
r: g: b: false

loadImage: does [
	canvas1/image: black
	canvas2/image: black
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage  tmp
		imgD: rcvCreateImage img1/size
		;we need 8-bit matrices for each channel argb
		;mat0: matrix/init 2 bitSize img1/size
		;mat1: matrix/init 2 bitSize img1/size 
		;mat2: matrix/init 2 bitSize img1/size 
		;mat3: matrix/init 2 bitSize img1/size
		canvas1/image: img1
		canvas2/image: imgD
	]
]

processMat: does [
	b: rcvSplit2Mat img1 bitSize ; split image -> 4 matrices
	mat0: b/1 
	mat1: b/2 
	mat2: b/3 
	mat3: b/4
	if r [rcvHistogramEqualization mat1 grayLevels]		; equalize R
	if g [rcvHistogramEqualization mat2 grayLevels]		; equalize G
	if b [rcvHistogramEqualization mat3 grayLevels]		; equalize B
	mat1/data * 25
	mat2/data * 25
	mat3/data * 25
	rcvMerge2Image mat0 mat1 mat2 mat3 imgD				; and merge matrices 
]

; ***************** Test Program ****************************
view win: layout [
		title "Histogram Equalization"
		origin margins space margins
		button 100 "Load Image" 		[loadImage processMat]
		sl: slider 256 					[grayLevels: to integer! sl/data * 255 
										 glTxt/text: form grayLevels processMat]
		glTxt: field 40 "128" 
		button 100 "Quit" 				[rcvReleaseImage img1 rcvReleaseImage imgD Quit]
		return
		text 128 "Channels" 
		cbR: check "Red" 	[r: face/data processMat]
		cbG: check "Green" 	[g: face/data processMat]
		cbB: check "Blue" 	[b: face/data processMat]
		return
		text 256 "Source" center  text 256 "Equalized" center
		return
		canvas1: base msize img1
		canvas2: base msize imgD
		do [sl/data: 0.50]
]