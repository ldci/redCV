Red [
	Title:   "Smoothing filters for image  "
	Author:  "Francois Jouen"
	File: 	 %smoothing.red
	Needs:	 'View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red

kSize: 3x3
src: make image! 512x512
dst: make image! 512x512
isFile: false

loadImage: does [
	isFile: false
	tmp: request-file
	if not none? tmp [
		canvas2/image: none
		src: load tmp	
		dst: make image! src/size
		canvas1/image: src
		isFile: true
	]
]


view win: layout [
	title "Red Smoothing Filters"
	origin 10x10 space 10x10
	button "Load" 				[loadImage]
	text "Filter Size"
	field "3x3" 				[if error? try [kSize: to-pair face/text] [kSize: 3x3]]
	button "Median" 			[if isFile [rcvMedianFilter src dst kSize canvas2/image: dst]]
	button "Min"				[if isFile [rcvMinFilter src dst kSize canvas2/image: dst]]
	button "Max"				[if isFile [rcvMaxFilter src dst kSize canvas2/image: dst]]
	button "MidPoint"			[if isFile [rcvMidPointFilter src dst kSize canvas2/image: dst]]
	button "Gaussian"			[if isFile [rcvGaussianFilter src dst kSize 1.0 canvas2/image: dst]]
	button "Non Linear"			[if isFile [rcvNLFilter src dst kSize canvas2/image: dst]]
	pad 200x0
	button "Quit" 				[quit]
	return
	button "Arithmetic Mean" 	[if isFile [rcvMeanFilter src dst kSize 0 canvas2/image: dst]]
	button "Harmonic Mean" 		[if isFile [rcvMeanFilter src dst kSize 1 canvas2/image: dst]]
	button "Geometric Mean" 	[if isFile [rcvMeanFilter src dst kSize 2 canvas2/image: dst]]
	button "Quadratic Mean" 	[if isFile [rcvMeanFilter src dst kSize 3 canvas2/image: dst]]
	button "Cubic Mean" 		[if isFile [rcvMeanFilter src dst kSize 4 canvas2/image: dst]]
	button "Root Mean Square" 	[if isFile [rcvMeanFilter src dst kSize 5 canvas2/image: dst]]
	return
	canvas1: base 512x512 white
	canvas2: base 512x512 white
]





