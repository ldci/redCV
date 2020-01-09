Red [
	Title:   "Canny Filter "
	Author:  "Francois Jouen"
	File: 	 %cannye.red
	Needs:	 'View
]


; required libs
#include %../../../libs/tools/rcvTools.red
#include %../../../libs/core/rcvCore.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/imgproc/rcvImgProc.red

margins: 10x10
defSize: 512x512
img1: rcvCreateImage defSize
gray: rcvCreateImage defSize
dst:  rcvCreateImage defSize
cImg: rcvCreateImage defSize

isFile: false
factor: 1.0
delta: 0.0
knl: rcvMakeGaussian 3x3 1.0

; laplacian connexity 8 
canny: [-1.0 -1.0 -1.0
		-1.0 8.0 -1.0 
		-1.0 -1.0 -1.0]

loadImage: does [
    isFile: false
    bb/image/rgb: black
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: copy "Edges detection: Canny "
		append win/text fileName
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		cImg: rcvCloneImage gray
		dst:  rcvCloneImage cImg
		bb/image: img1
		canvas/image: dst
		isFile: true
		delta: 0.0
		factor: 1.0
		sl/data: 0%
		makeCanny
	]
]

makeCanny: does [
	; step 1: grayscale
	cImg: rcvCloneImage gray
	; step 2: Gaussian blur
	rcvFilter2D cImg dst knl factor 0.0
	;step 3 laplacian
	cImg: rcvCloneImage dst
	rcvConvolve cImg dst canny factor delta
]


; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: Canny"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
					
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage dst 
								rcvReleaseImage gray
								rcvReleaseImage cImg
								Quit]
		
		return
		text 128 "Source"
		sl: slider 450 [delta: to-float face/data * 64.0 
			f/text: form delta
			if isFile [makeCanny]
		]
		f: field 50
		return
		bb: base 128x128 img1
		canvas: base 512x512 dst	
]
