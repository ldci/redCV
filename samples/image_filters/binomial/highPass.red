Red [
	Title:   "Laplacian Filter "
	Author:  "Francois Jouen"
	File: 	 %highpass.red
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
cImg: rcvCreateImage defSize
dst:  rcvCreateImage defSize
isFile: false
param: 1

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
		canvas/image: dst
		isFile: true
		param: 1
		r1/data: true
		r2/data: false
		r3/data: false
		process
	]
]

process: does [
	if isFile [
		if param = 1 [rcvHighPass cImg dst iSize]
		if param = 2 [rcvHighPass2 cImg dst iSize]
		if param = 3 [rcvBinomialHighPass cImg dst iSize]
		canvas/image: dst
	]
	
]



; ***************** Test Program ****************************
view win: layout [
		title "High Pass Filter"
		origin margins space margins					
		button 60 "Load" 		[loadImage]	
		cb: check "Grayscale"   [either cb/data [cImg: rcvCloneImage gray]
					   			[cImg: rcvCloneImage img1]
					   			process
		]			
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage dst Quit]
		return
		pad 128x0
		r1: radio "Filter 1" [param: 1 process]
		r2: radio "Filter 2" [param: 2 process]
		r3: radio "Binomial" [param: 3 process]
		return
		bb: base 128x128 img1
		canvas: base 512x512 dst
		
]
