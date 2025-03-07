Red [
	Title:   "Contrast tests "
	Author:  "ldci"
	File: 	 %contrastColor.red
	Needs:	 'View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
;#include %../../libs/tools/rcvTools.red
#include %../../libs/math/rcvHistogram.red	

margins: 5x5
msize: 256x256
img1: rcvCreateImage msize
img2: rcvCreateImage msize
p: 0%
isFile: false

bitSize: 32
loadImage: does [
	isFile: false
	canvas1/image: none
	canvas2/draw: none
	canvas2/image: none
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage  tmp
		img2: rcvCreateImage img1/size
		canvas1/image: img1
		isFile: true
		p: 0%
		sl/data: p
		processMat
	]
]

processMat: does [
	if isFile [
		b: rcvSplit2Mat img1 bitSize					; split image
		mat0: b/1
		mat1: b/2
		mat2: b/3
		mat3: b/4
		rcvContrastAffine mat1 p						; R channel
		rcvContrastAffine mat2 p						; G channel
		rcvContrastAffine mat3 p						; B channel
		rcvMerge2Image mat0 mat1 mat2 mat3 img2			; and merge matrices 
		canvas2/image: img2
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Color Contrast"
		origin margins space margins
		button "Load Image" [loadImage]
		sl: slider 280 		[p: to percent! face/data  v/data: form round/to face/data 0.01 processMat]
		v: field 60 "0%"
		button 60 "Quit" 	[rcvReleaseImage img1 rcvReleaseImage img2 Quit]
		return
		canvas1: base msize img1
		canvas2: base msize img2
]