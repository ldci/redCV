Red [
	Title:   "Snake tests "
	Author:  "Francois Jouen"
	File: 	 %gradient.red
	Needs:	 'View
]

;required libs
#include %../../../libs/core/rcvCore.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/tools/rcvTools.red	
#include %../../../libs/math/rcvDistance.red
#include %../../../libs/math/rcvChamfer.red


margins: 10x10
isize: 256x256
imgSize: 0x0
bitSize: 32 ; or 16 bits


img0: rcvCreateImage isize
img1: rcvCreateImage isize
img2: rcvCreateImage isize
imgcopy: rcvCreateImage isize
binaryMat: rcvCreateMat 'integer! bitSize isize
flowMat:  rcvCreateMat 'integer! bitSize isize
lumMat: rcvCreateMat 'integer! bitSize isize
gradientMat:  rcvCreateMat 'integer! bitSize isize
distMat: rcvCreateMat 'float! 64 isize

threshold: 1
distance: 25.0
gMax: 0
lw: 1
isFile: false
chamfer*: copy []
normalizer: 0


quitApp: does [
	if isFile [
		rcvReleaseImage img0
		rcvReleaseImage img1
		rcvReleaseImage img2
		rcvReleaseImage imgcopy
		rcvReleaseMat binaryMat
		rcvReleaseMat flowMat
		rcvReleaseMat lumMat
		rcvReleaseMat gradientMat
		rcvReleaseMat distMat
	]
	Quit
]


loadImage: does [
	canvas0/image: none
	canvas1/image: none
	canvas2/image: none
	isFile: false
	tmp: request-file
	if not none? tmp [
		img0: rcvLoadImage tmp
		imgSize: img0/size
		img1: rcvCreateImage imgSize
		img2: rcvCreateImage imgSize
		imgcopy: rcvCreateImage imgSize
		rcvCopyImage img0 imgcopy
		canvas0/image: imgcopy
		; we need a grayscale image
		rcv2Gray/luminosity img0 img1
		canvas1/image: img1
		flowMat: rcvCreateMat 'integer! bitSize imgSize
		distMat: rcvCreateMat 'float! 64 imgSize
		; GrayLevelScale (Luminance) mat
		lumMat: rcvCreateMat 'integer! bitSize imgSize 
		rcvImage2Mat img1 lumMat
		canvas1/image: img1
		; Gradient (Sobel-like) mat		
		gradientMat: rcvCreateMat 'integer! bitSize imgSize 
		; chamfer default
		chamfer*: first rcvChamferDistance chamfer5
		normalizer: second rcvChamferDistance chamfer5
		fSize/text: form imgSize
		lw: 1
		if imgSize > 1024x768 [lw: 5]
		win/text: rejoin [ "Gradient and Flow: " to-string tmp]
		sl0/data: 50%
		sl1/data: 0.1%
		distance: 25.0
		threshold: 1
		gMax: 0
		isFile: true
		if to-string system/platform = "macOS" [canvas3/draw: reduce [grad]]
	]
]



computeFlow: does [	
	; binary thresholding
	gMax: rcvMakeGradient lumMat gradientMat imgSize	
	; for binary gradient [0/1]	
	binaryMat: rcvCreateMat 'integer! bitSize imgSize 
	rcvMakeBinaryGradient gradientMat binaryMat gMax threshold imgSize
	; Chamfer distance map
	distMat: rcvChamferCreateOutput imgSize;
	rcvChamferInitMap binaryMat distMat
	rcvChamferCompute distMat chamfer* imgSize 
	rcvChamferNormalize distMat normalizer
	
	; for flow in image
	flowMat: rcvCreateMat 'integer! bitSize imgSize 
	
	;distance map to binarized gradient
	maxf: rcvFlowMat distMat flowMat distance
	if cb/data [rcvnormalizeFlow flowMat maxf]
	rcvMat2Image flowMat img1
	
	; flow and gradient
	rcvGradient&Flow flowMat binaryMat img2	
	canvas1/image: img1
	canvas2/image: img2
]

; for distance scale (should be improved)
grad: compose [
				pen red
				fill-pen linear 0x0
			    0 512 90
				1.0 1.0 
				red
				black 
				black
				scale 1.0 1.0
				translate 0x0
				;rotate 0 10x128
				box 0x0 20x256
]

view win: layout [
	title "Gradient and Flow"
	origin margins space margins
	button "Load image" [loadImage computeFlow]
	fsize: field 120 center
	text "Chamfer Distance"
	drop-down 
	data ["cheessboard" "Chamfer 3" "Chamfer 5" "Chamfer 7" "Chamfer 13"] 
	select 3 
	on-change [
		switch face/selected [
			1 [	chamfer*: first rcvChamferDistance cheessboard
				normalizer: second rcvChamferDistance cheessboard]
			2 [	chamfer*: first rcvChamferDistance chamfer3
				normalizer: second rcvChamferDistance chamfer3]
			3 [	chamfer*: first rcvChamferDistance chamfer5
				normalizer: second rcvChamferDistance chamfer5]
			4 [ chamfer*: first rcvChamferDistance chamfer7
				normalizer: second rcvChamferDistance chamfer7]
			5  [ chamfer*: first rcvChamferDistance chamfer13
				normalizer: second rcvChamferDistance chamfer13]
		]
		if isFile [computeFlow]
	]
	
	button "Quit" [quitApp]
	return
	canvas0: base 128x128 
	return
	text 256 "Flow"
	text 256 "Flow + Gradient"
	pad 4x0 
	text bold 15 "0"
	return
	canvas1: base isize 
	canvas2: base isize 
	canvas3: base 20x256 
	return
	text 110 "Distance"
	sl0: slider 85 [
		if isFile [
			distance: 0.05 + to-float (face/data * 49.95)
			fnz/text: form distance
			computeFlow 
		]
	]
	fnz: field 40 "10.0"
	
	text 110 "Gradient Threshold"
	sl1: slider 85 [
		if isFile [
			threshold: 1 + (to-integer face/data * 99)
			fgt/text: form threshold
			computeFlow 
		]
	]
	fgt: field 40 "0" 
	pad 4x0
	text 15 bold "N"
	
	return
	cb: check "Flow Scale [0..255]" [computeFlow]
	do [cb/data: false]
]