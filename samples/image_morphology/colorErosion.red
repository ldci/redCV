Red [
	Title:   "ColorErosion "
	Author:  "Francois Jouen"
	File: 	 %colorErosion.red
	Needs:	 'View
]
; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvMorphology.red


knl: [0 0 1 0 0
		 0 1 1 1 0
		 1 1 1 1 1
		 0 1 1 1 0
		 0 0 1 0 0
]

margins: 5x5
msize: 256x256

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
		;better with 32-bit matrices for each channel argb
		mat0: rcvCreateMat 'integer! 32 img1/size
		mat1: rcvCreateMat 'integer! 32 img1/size
		mat2: rcvCreateMat 'integer! 32 img1/size
		mat3: rcvCreateMat 'integer! 32 img1/size
		mat4: rcvCreateMat 'integer! 32 img1/size
		mat5: rcvCreateMat 'integer! 32 img1/size
		mat6: rcvCreateMat 'integer! 32 img1/size
		mat7: rcvCreateMat 'integer! 32 img1/size
		canvas1/image: img1
		canvas2/image: imgD
	]
]

processMat: does [
	rcvSplit2Mat img1 mat0 mat1 mat2 mat3				; split image
	rcvSplit2Mat img1 mat4 mat5 mat6 mat7				; split image
	if r [rcvErodeMat mat1 mat5 img1/size 5x5 knl]		; erode r channel
	if g [rcvErodeMat mat2 mat6 img1/size 5x5 knl]		; erode g channel
	if b [rcvErodeMat mat3 mat7 img1/size 5x5 knl]		; erode b channel
	rcvMerge2Image mat0 mat5 mat6 mat7 imgD				; and merge matrices 
]

; ***************** Test Program ****************************
view win: layout [
		title "Channels Erosion"
		origin margins space margins
		button 100 "Load Image" 	[loadImage processMat]
		button 100 "Quit" 			[rcvReleaseImage img1 rcvReleaseImage imgD Quit]
		return
		text  "Channels" 
		cbR: check "Red" 	[r: face/data processMat]
		cbG: check "Green" 	[g: face/data processMat]
		cbB: check "Blue" 	[b: face/data processMat]
		return
		text 256 "Source"  text 256 "Erosion"
		return
		canvas1: base msize img1
		canvas2: base msize imgD
]