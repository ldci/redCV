Red [
	Title:   "Prewitt Filter "
	Author:  "Francois Jouen"
	File: 	 %prewitt1.red
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
cImg:  rcvCreateImage defSize
gray: rcvCreateImage defSize

isFile: false
op: 1
param: 3

loadImage: does [
    isFile: false
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: copy "Edges detection: Prewitt " 
		append win/text fileName
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		isize: img1/size
		cImg rcvCreateImage isize
		either cb/data [cImg: rcvCloneImage gray]
					   [cImg: rcvCloneImage img1]
		dst:  rcvCloneImage cImg
		bb/image: img1
		canvas/image: dst
		isFile: true
		rcvPrewitt cImg dst isize param op
		r1/data: false
		r2/data: false
		r3/data: true
		r4/data: false
		r5/data: false
	]
]



; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: Prewitt"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
				
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage gray
								rcvReleaseImage cImg
								rcvReleaseImage dst Quit]
		return
		bb: base 128x128 img1
		return
		cb: check "Grayscale"	[either face/data [cImg: rcvCloneImage gray]
					   			[cImg: rcvCloneImage img1]
					   			if isFile [rcvPrewitt cImg dst isize param op]]		
		check "Inverse Kernel"		[either face/data [op: 2] [op: 1]
									if isFile [rcvPrewitt cImg dst isize param op]]
		return 
		text middle 100x20 "Prewitt Detection"
		r1: radio "Horizontal" 	[param: 1 if isFile [rcvPrewitt cImg dst isize param op]]
		r2: radio "Vertical" 	[param: 2 if isFile [rcvPrewitt cImg dst isize param op]]	
		r3:	radio 50 "Both" 	[param: 3 if isFile [rcvPrewitt cImg dst isize param op]]
		r4:	radio "Magnitude"	[param: 4 if isFile [rcvPrewitt cImg dst isize param op]]
		r5: radio 60 "Angle"	[param: 5 if isFile [rcvPrewitt cImg dst isize param op]]
		return
		canvas: base 512x512 dst	
		do [r3/data: true]
]
