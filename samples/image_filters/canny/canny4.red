Red [
	Title:   "Canny Filter "
	Author:  "Francois Jouen"
	File: 	 %canny4.red
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
lowThreshold:  32
highThreshold: 64


loadImage: does [
    isFile: false
	tmp: request-file
	if not none? tmp [
		bb/image: none
    	canvas/image: none
		fileName: to string! to-file tmp
		win/text: copy "Edges detection: Canny "
		append win/text fileName
		img1: rcvLoadImage tmp
		;we need a grayscale image for Canny
		gray: rcvLoadImage/grayscale tmp
		bb/image: img1
		do-events/no-wait
		isFile: true
		createCanny gray 
		calculateCanny lowThreshold highThreshold
		showCanny
	]
]



createCanny: func [img [image!]][
	cImg: 	rcvCloneImage img					;copy source image
	iSize: 	cImg/size							;image size
	dst: 	rcvCreateImage iSize				;for edges visualisation
	imgX: 	rcvCreateImage iSize				;Sobel X derivative
	imgY: 	rcvCreateImage iSize				;Sobel X derivative 
	
	; step 1: Gaussian blur: Noise reduction
	knl: rcvMakeGaussian 5x5 1.0
	rcvFilter2D cImg dst knl 1.0 0.0
	cImg: rcvCloneImage dst
	
	;step 2: Sobel Filter: Gradient calculation
	hx: [-1.0 0.0 1.0 -2.0 0.0 2.0 -1.0 0.0 1.0]
	hy: [1.0 2.0 1.0 0.0 0.0 0.0 -1.0 -2.0 -1.0]
	
	rcvConvolve cImg imgX hx 1.0 0.0
	rcvConvolve cImg imgY hy 1.0 0.0
	;another way
	;rcvSobel cImg imgX iSize 1 1
	;rcvSobel cImg imgY iSize 2 1
]

calculateCanny: func [lowT [integer!]  highT [integer!]] [
	
	matG: 	matrix/init 3 64 iSize			;Gradient matrix (float)
	matA: 	matrix/init 3 64 iSize			;Angles matrix (float)
	gradS:  matrix/init 3 64 iSize 			;Non-maximum suppression matrix (float)
	doubleT:  matrix/init 2 32 iSize		;Double threshold matrix (integer)
	finalEdges:  matrix/init 2 32 iSize		;Final edges matrix (integer)
	rcvEdgesGradient imgX imgY matG/data	;get gradient matrix
	rcvEdgesDirection imgX imgY matA/data	;get angle matrix
	;step 3 Non-maximum suppression
	rcvCopyMat matG gradS
	rcvEdgesSuppress matA/data matG/data gradS/data iSize
	weak: 128
	strong: 255
	rcvDoubleThresh gradS/data doubleT/data lowT highT weak strong
]

showCanny: does  [
	weak: 128
	strong: 255
	rcvHysteresis doubleT/data finalEdges/data iSize weak strong
	rcvMat2Image finalEdges dst 
	canvas/image: dst
]


; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: Canny"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
		pad 640x0	
		button 60 "Quit" 		[Quit]
		return
		text 256 "Double threshold" 
		text 30 "Low"  sl1: slider 170 [lowThreshold: 1 + to-integer face/data * 254 
						fL/text: form lowThreshold
						if isFile [calculateCanny lowThreshold highThreshold showCanny]
						]
		fL: field 30 "32"
		text 30 "High" sl2: slider 170 [highThreshold: 1 + to-integer face/data * 254 
							fH/text: form highThreshold
							if isFile [calculateCanny lowThreshold highThreshold showCanny]
							]
		fH: field 30 "64"
		return
		bb: 	 base 256x256 black
		canvas:  base 512x512 black	
		do [sl1/data: 0.125 sl2/data: 0.25]
]
