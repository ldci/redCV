Red [
	Title:   "Laplacian Filter "
	Author:  "ldci"
	File: 	 %lowPass.red
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
dst:  rcvCreateImage defSize
gray: rcvCreateImage defSize
cImg:  rcvCreateImage defSize
isFile: false


loadImage: does [
    isFile: false
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: fileName
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		either cb/data [cImg: rcvCloneImage gray]
					   [cImg: rcvCloneImage img1]
		iSize: img1/size
		dst: rcvCreateImage iSize
		bb/image: img1
		isFile: true
		param: 1
		r1/data: true
		r2/data: false
		process
	]
]

process: does [
	if isFile [
		if param = 1 [rcvLowPass cImg dst iSize]
		if param = 2 [rcvBinomialLowPass cImg dst iSize]
		canvas/image: dst
	]
]



; ***************** Test Program ****************************
view win: layout [
		title "Low Pass Filter"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
		cb: check "Grayscale"   [either cb/data [cImg: rcvCloneImage gray]
					   			[cImg: rcvCloneImage img1]
					   			process
		]					
		button 60 "Quit" 		[rcvReleaseImage img1  rcvReleaseImage gray
								rcvReleaseImage cImg rcvReleaseImage dst 
								Quit]
		return
		pad 128x0
		r1: radio "Low Pass Filter" [param: 1 process]
		r2: radio "Binomial Low Pass Filter" [param: 2 process]
		
		return
		bb: base 128x128 img1
		canvas: base defSize dst
		do [r1/data: true]	
]
