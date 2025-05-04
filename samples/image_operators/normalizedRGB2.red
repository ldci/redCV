Red [
	Title:   "Normalized RGB"
	Author:  "ldci"
	File: 	 %normalizedRGB2.red
	Needs:	 View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/math/rcvStats.red
#include %../../libs/matrix/rcvMatrix.red

isFile: false
meanImg: 1
stdImg:  1

loadImage: does [
	isFile: false
	canvas1/image: none
	canvas2/image: none
	canvas2/image: none
	tmp: request-file
	unless none? tmp [
		img1: rcvLoadImage tmp
		dst1: rcvCreateImage img1/size
		dst2: rcvCreateImage img1/size
		mat:  matrix/init 2 32 img1/size
		rcvImage2Mat img1 mat
		isFile: true
		showImages
	]
]

showImages: does [
	if isFile [
		canvas1/image: img1
		meanImg: to-integer rcvMeanMat mat ;or first rcvMean mat
		stdImg: to-integer rcvStdMat mat ; or first rcvSTD mat 
		;print [meanImg stdImg ]
		rcv2NzRGB img1 dst1 0 ;--Normalizes the RGB values according to sum (0) or sumsquare (1)
		canvas2/image: dst1	
		m1: matrix/scalarSubtraction mat  meanImg
		m2: matrix/scalarDivision m1  stdImg
		;rcvMat2Image m2 dst2
		rcvNormaliseImage img1 dst2  meanImg  stdImg
		canvas3/image: dst2
	]
]

; ***************** Test Program ****************************
view win: layout [
	title "Normalized RGB"
	button 60 "Load" 				[loadImage]
	pad 635x0
	button 80 "Quit" 				[if isFile [
										rcvReleaseImage img1 
										rcvReleaseImage dst1 rcvReleaseImage dst2
										] 
									Quit]
	return
	canvas1: base 256x256
	canvas2: base 256x256 
	canvas3: base 256x256	
]