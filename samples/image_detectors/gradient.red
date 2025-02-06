Red [
	Title:   "Snake tests "
	Author:  "ldci"
	File: 	 %gradient.red
	Needs:	 'View
]

;--same code as in /image_distances/quickHull/gradient
; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red
#include %../../libs/math/rcvChamfer.red
#include %../../libs/math/rcvQuickHull.red

margins: 10x10
isize: 512x512
bitSize: 32

img0: rcvCreateImage isize
img1: rcvCreateImage isize
img2: rcvCreateImage isize
imgcopy: rcvCreateImage isize

binaryMat: matrix/init 2 bitSize img0/size
lumMat: matrix/init 2 bitSize img0/size
gradientMat: matrix/init 2 bitSize img0/size

cPoints: copy []
threshold: 1
gMax: 0
lw: 1
isFile: false

quitApp: does [
	rcvReleaseImage img0
	rcvReleaseImage img1
	rcvReleaseImage img2
	rcvReleaseImage imgcopy
	rcvReleaseMat binaryMat
	Quit
]


loadImage: does [
	canvas1/image: none
	canvas2/image: none
	isFile: false
	cPoints: copy []
	tmp: request-file
	if not none? tmp [
		img0: rcvLoadImage tmp
		img1: rcvCreateImage img0/size
		img2: rcvCreateImage img0/size
		img3: rcvCreateImage img0/size
		imgcopy: rcvCreateImage img0/size
		rcvCopyImage img0 imgcopy
		binaryMat: matrix/init 2 bitSize img0/size
		lumMat: matrix/init 2 bitSize img0/size
		gradientMat: matrix/init 2 bitSize img0/size
		
		; we need a grayscale image
		rcv2Gray/luminosity img0 img1
		compute
		
		fSize/data: form img0/size
		lw: 1
		if img0/size > 1024x768 [lw: 5]
		canvas1/image: img2
		canvas2/image: img0
		win/text: "Gradient and Convex Hull: " 
		append win/text to-string tmp
		isFile: true
	]
]

compute: does [
	rcvImage2Mat img1 lumMat 	
	; Gradient (sobel) 	mat		
	gMax: rcvMakeGradient lumMat gradientMat img0/size	
	; binary thresholding		
	rcvMakeBinaryGradient gradientMat binaryMat gMax threshold
	; for visualization
	binaryMat/data * 255
	rcvMat2Image binaryMat img2
	; for calculation
	binaryMat/data / 255
]


; for fun with convex hull

showHull: does [
	cPoints: copy []
	chull: copy []
	t1: now/time/precise
	rcvGetPairs binaryMat cPoints
	rcvCopyImage imgcopy img0
	chull: rcvQuickHull/cw cPoints
	; we need 3 points or more for polygon drawing 
	n: length? chull
	fNbp/text: form n append fNbp/text " points"
	if n > 2 [
		plot: copy reduce ['line-width (lw) 'pen yellow 'polygon]
		foreach p chull [append plot p]
	]
	canvas2/image: draw img0 plot
	t2: now/time/precise
	frender/text: form t2 - t1
]





view win: layout [
	title "Gradient and Convex Hull"
	origin margins space margins
	button "Load image" [loadImage]
	fsize: field 120 center
	cb: check "Automatic" 
	button "Convex" [if isFile [showHull]]
	frender: field 120
	button "Quit" [quitApp]
	return
	text 100 "Gradient"
	pad 412x0
	text 100 "Convex Hull" fNbp: field 100
	return
	canvas1: base isize img2
	canvas2: base isize img0
	return
	text "Gradient Threshold"
	sl: slider 320 [
		if isFile [
			threshold: 1 + to-integer face/data * 100
			fgt/data: form threshold
			compute
			canvas1/image: img2
			if cb/data [showHull]
		]
	]
	fgt: field 40 "0" 
]