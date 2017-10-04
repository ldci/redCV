Red [
	Title:   "Snake tests "
	Author:  "Francois Jouen"
	File: 	 %gradient.red
	Needs:	 'View
]


; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions


margins: 10x10
isize: 512x512
bitSize: 32 ; or 16 bits


img0: rcvCreateImage isize
img1: rcvCreateImage isize
img2: rcvCreateImage isize
imgcopy: rcvCreateImage isize
binaryMat: rcvCreateMat 'integer! bitSize isize
flowMat: rcvCreateMat 'integer! bitSize isize
lumMat: rcvCreateMat 'integer! bitSize isize
gradientMat: rcvCreateMat 'integer! bitSize isize
distMat: rcvChamferCreateOutput isize
threshold: 1
distance: 5.0
gMax: 0
lw: 1
isFile: false
chamfer: copy []
w: 0 h: 0

quitApp: does [
	rcvReleaseImage img0
	rcvReleaseImage img1
	rcvReleaseImage img2
	rcvReleaseImage imgcopy
	rcvReleaseMat binaryMat
	rcvReleaseMat flowMat
	rcvReleaseMat lumMat
	rcvReleaseMat gradientMat
	rcvReleaseMat distMat
	Quit
]



computeFlow: function [ ] [	
		
	; binary thresholding	
	; gradientMat and binaryMat are OK	
	rcvMakeBinaryGradient gradientMat binaryMat gMax threshold img0/size
	
	; Chamfer distance map
	rcvChamferInitMap binaryMat distMat	
	
	rcvChamferCompute distMat chamfer img0/size 
	rcvChamferNormalize distMat normalizer
	
	;	distance map to binarized gradient
	maxf: rcvFlowMat distMat flowMat distance
	if cb/data [rcvnormalizeFlow flowMat maxf]
	rcvMat2Image flowMat img0
	; flow and gradient
	rcvGradient&Flow flowMat binaryMat img2
	
]

loadImage: does [
	canvas0/image: none
	canvas1/image: none
	canvas2/image: none
	isFile: false
	clear win/text
	tmp: request-file
	if not none? tmp [
		img0: rcvLoadImage tmp
		img1: rcvCreateImage img0/size
		img2: rcvCreateImage img0/size
		imgcopy: rcvCreateImage img0/size 
		lumMat: rcvCreateMat 'integer! bitSize img0/size ; grasycale matrix
		gradientMat: rcvCreateMat 'integer! bitSize img0/size ;
		binaryMat: rcvCreateMat 'integer! bitSize img0/size ; for binary gradient [0/1]
		flowMat: rcvCreateMat 'integer! bitSize img0/size; for flow in image
		distMat: rcvChamferCreateOutput img0/size;
		; for chamfer distance
		chamfer: first rcvChamferDistance chamfer5
		normalizer: second rcvChamferDistance chamfer5
		rcvCopyImage img0 imgcopy
		canvas0/image: imgcopy
		
		; we need a grayscale image
		rcv2Gray/luminosity img0 img1
		; GrayLevelScale (Luminance) mat
		rcvImage2Mat img1 lumMat
		; Gradient (sobel) 	mat				
	    gMax: rcvMakeGradient lumMat gradientMat img0/size
		computeFlow 
		fSize/data: form img0/size
		lw: 1
		if img0/size > 1024x768 [lw: 5]
		;canvas1/size: canvas2/size: img0/size
		canvas1/image: img0
		canvas2/image: img2
		win/text: copy "Gradient and Flow: " 
		append win/text to-string tmp
		isFile: true
	]
]

; for distance scale 
grad: compose [
				anti-alias on
				pen red
				fill-pen linear 0x0
			    0 1024 90
				1.0 1.0 
				red
				black 
				black
				scale 1.0 1.0
				translate 0x0
				rotate 0 10x256 
				box 0x0 20x512
]

view win: layout [
	title "Gradient and Flow"
	origin margins space margins
	button "Load image" [loadImage]
	fsize: field 120 center
	text "Chamfer Distance"
	drop-down 
	data ["cheessboard" "Chamfer 3" "Chamfer 5" "Chamfer 7" "Chamfer 13"] 
	select 3 
	on-change [
		switch face/selected [
			1 [	chamfer: first rcvChamferDistance cheessboard
				normalizer: second rcvChamferDistance cheessboard]
			2 [	chamfer: first rcvChamferDistance chamfer3
				normalizer: second rcvChamferDistance chamfer3]
			3 [	chamfer: first rcvChamferDistance chamfer5
				normalizer: second rcvChamferDistance chamfer5]
			4 [ chamfer: first rcvChamferDistance chamfer7
				normalizer: second rcvChamferDistance chamfer7]
			5  [ chamfer: first rcvChamferDistance chamfer13
				normalizer: second rcvChamferDistance chamfer13]
		]
		if isFile [computeFlow]
	]
	
	button "Quit" [quitApp]
	return
	canvas0: base 128x128
	return
	text 100 "Flow"
	
	pad 412x0
	text 100 "Flow + Gradient"
	pad 413x0 text bold 15 "0"
	return
	canvas1: base isize img2
	canvas2: base isize img0
	canvas3: base 20x512 
	return
	text "Distance"
	sl0: slider 230 [
		if isFile [
			distance: 0.05 + to-float (face/data * 19.95)
			fnz/data: form distance
			computeFlow 
		]
	]
	fnz: field 40 "10.0"
	
	cb: check "Flow Scale [0..255]" [computeFlow]
	
	text "Gradient Threshold"
	sl1: slider 330 [
		if isFile [
			threshold: 1 + (to-integer face/data * 99)
			fgt/data: form threshold
			computeFlow 
		]
	]
	fgt: field 40 "0" 
	pad 8x0
	text 15 bold "N"
	do [sl0/data: 50% canvas3/draw: reduce [grad] cb/data: false]
	
]