Red [
	Title:   "Sobel Filter "
	Author:  "ldci"
	File: 	 %sobel1.red
	Needs:	 'View
]


; required libs
#include %../../../libs/tools/rcvTools.red
#include %../../../libs/core/rcvCore.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/imgproc/rcvImgProc.red

margins: 10x10
defSize: 512x512
iSize: 0x0
img1: rcvCreateImage defSize
dst:  rcvCreateImage defSize
gray: rcvCreateImage defSize
cImg: rcvCreateImage defSize
isFile: false
param: 1
op: 1

loadImage: does [
    isFile: false
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: "Edges detection: Sobel "
		append win/text fileName
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		cImg rcvCreateImage img1/size
		either cb/data [cImg: rcvCloneImage gray]
					   [cImg: rcvCloneImage img1]
		dst:  rcvCloneImage cImg
		bb/image: img1
		canvas/image: dst
		isFile: true
		param: 1
		iSize: cImg/size
		rcvSobel cImg dst param op
		r1/data: true
		r2/data: false
		r3/data: false
		r4/data: false
		r5/data: false
		r6/data: false
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: Sobel"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
								
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage gray
								rcvReleaseImage cImg
								rcvReleaseImage dst Quit]
		
		return
		cb: check "Grayscale"	[either cb/data [cImg: rcvCloneImage gray]
					   			[cImg: rcvCloneImage img1]
					   			if isFile [rcvSobel cImg dst param op]
								]
		check "Inverse Kernel"		[either face/data [op: 2] [op: 1]
									if isFile [rcvSobel cImg dst param op]
									]
		return
		text 130x20 "Sobel Direction"
		r1: radio  "Horizontal" [param: 1 if isFile [rcvSobel cImg dst param op]]
		r2: radio  "Vertical" 	[param: 2 if isFile [rcvSobel cImg dst param op]]		
		r3:	radio  50 "X+Y" 	[param: 3 if isFile [rcvSobel cImg dst param op]]
		r4:	radio "Magnitude" 	[param: 4 if isFile [rcvSobel cImg dst param op]]
		r5: radio 60 "Angles"	[param: 5 if isFile [rcvSobel cImg dst param op]]
		r6: radio "Product"		[param: 6 if isFile [rcvSobel cImg dst param op]]
		return
		bb: base 128x128 img1
		canvas: base defSize dst	
		do [r1/data: true]
]
