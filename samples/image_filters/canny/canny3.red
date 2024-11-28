Red [
	Title:   "Canny Filter "
	Author:  "Francois Jouen"
	File: 	 %canny3.red
	Needs:	 'View
]


; required libs
#include %../../../libs/tools/rcvTools.red
#include %../../../libs/core/rcvCore.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/imgproc/rcvImgProc.red

margins: 10x10
defSize: 512x512
isFile: false

loadImage: does [
    isFile: false
	tmp: request-file
	if not none? tmp [
		bb/image: none
    	canvas1/image: none
    	canvas2/image: none
		canvas3/image: none
		f1/text: ""
		fileName: to string! to-file tmp
		win/text: copy "Edges detection: Canny "
		append win/text fileName
		img1: rcvLoadImage tmp
		;we need a grayscale image for Canny
		gray: rcvLoadImage/grayscale tmp
		bb/image: img1
		do-events/no-wait
		isFile: true
		lowThreshold:  32
		highThreshold: 64
		makeCanny gray lowThreshold highThreshold
	]
]

makeCanny: function [img [image!] lowT [integer!]  highT [integer!]] [

	cImg: 	rcvCloneImage img					;copy source image
	iSize: 	cImg/size							;image size
	dst: 	rcvCreateImage iSize				;for edges visualisation
	imgG: 	rcvCreateImage iSize				;for gradients 
	imgA: 	rcvCreateImage iSize				;for angles
	imgX: 	rcvCreateImage iSize				;Sobel X derivative
	imgY: 	rcvCreateImage iSize				;Sobel X derivative 
	matG: 	matrix/init 3 64 iSize				;Gradient matrix (float)
	matA: 	matrix/init 3 64 iSize				;Angles matrix (float)
	gradS:  matrix/init 3 64 iSize				;Non-maximum suppression matrix (float)
	doubleT:  matrix/init 2 32 iSize			;Double threshold matrix (integer)
	finalEdges: matrix/init 2 32 iSize			;Final edges matrix (integer)
	t1: now/time/precise
	; step 1: Gaussian blur: Noise reduction
	knl: rcvMakeGaussian 5x5 1.0
	rcvFilter2D cImg dst knl 1.0 0.0
	cImg: rcvCloneImage dst
	;step 2: Sobel Filter: Gradient calculation
	hx: [-1.0 0.0 1.0 -2.0 0.0 2.0 -1.0 0.0 1.0]
	hy: [1.0 2.0 1.0 0.0 0.0 0.0 -1.0 -2.0 -1.0]
	rcvConvolve cImg imgX hx 1.0 0.0
	rcvConvolve cImg imgY hy 1.0 0.0
	rcvEdgesGradient imgX imgY matG/data		;get gradient matrix as a vector

	;--pb here with rcvEdgesDirection
	;--Access Error: bad media data (corrupt image, sound, video)
	;rcvEdgesDirection imgX imgY matA/data 		;get angle matrix as a vector
	;gradient visualization
	probe 3
	gMat: rcvMatFloat2Int matG 32 255.0
	probe 4
	rcvMat2Image gMat imgG 
	canvas1/image: imgG
	;step 3 Non-maximum suppression
	rcvCopyMat matG gradS
	rcvEdgesSuppress matA/data matG/data gradS/data iSize
	; step 4 double thresholding
	weak: 128
	strong: 255
	rcvDoubleThresh gradS/data doubleT/data lowT highT weak strong
	rcvMat2Image doubleT imgA 
	canvas2/image: imgA
	;step 5 Edge tracking by hysteresis
	rcvHysteresis doubleT/data finalEdges/data iSize weak strong
	;result
	rcvMat2Image finalEdges dst 
	canvas3/image: dst
	t2: now/time/precise
	t: rcvElapsed t1 t2
	f1/text: rejoin ["Rendered in: " t " ms"]
]



; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: Canny"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
		text 150 "Red Foundation 2019"
		f1: field 552 ""
		pad 450x0			
		button 60 "Quit" 		[Quit]
		return
		text 256 "Source"
		text 256 "Gradient"
		text 256 "Double Thresholding"
		text 256 "Canny"
		return
		bb: 	 base 256x256 black
		canvas1: base 256x256 black
		canvas2: base 256x256 black
		canvas3: base 512x512 black	
]
