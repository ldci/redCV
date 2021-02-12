Red [
	Title:   "Roberts Filter "
	Author:  "Francois Jouen"
	File: 	 %roberts1.red
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
currentImage:  rcvCreateImage defSize
isFile: false
param: 3

loadImage: does [
    isFile: false
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: copy "Edges detection: Roberts "
		append win/text fileName
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		currentImage rcvCreateImage img1/size
		either cb/data [currentImage: rcvCloneImage gray]
					   [currentImage: rcvCloneImage img1]
		dst:  rcvCloneImage currentImage
		bb/image: img1
		canvas/image: dst
		iSize: currentImage/size
		isFile: true
		rcvRoberts currentImage dst param
		r1/data: false
		r2/data: false
		r3/data: true
		r4/data: false
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: Roberts"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
		cb: check "Grayscale"	[
								either cb/data [currentImage: rcvCloneImage gray]
					   			[currentImage: rcvCloneImage img1]
					   			rcvRoberts currentImage dst param
								]
					
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage gray
								rcvReleaseImage currentImage
								rcvReleaseImage dst Quit]
		return
		bb: base 160x120 img1
		return
		text middle 100x20 "Roberts Direction"
		r1: radio "45 " 		[param: 1 rcvRoberts currentImage dst param]
		r2: radio "135 " 		[param: 2 rcvRoberts currentImage dst param]	
		r3:	radio "Both" 		[param: 3 rcvRoberts currentImage dst param]
		r4:	radio "Magnitude" 	[param: 4 rcvRoberts currentImage dst param]
		return
		canvas: base 512x512 dst	
		do [r3/data: true]
]
