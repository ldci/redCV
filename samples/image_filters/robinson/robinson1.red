Red [
	Title:   "Robinson Filter "
	Author:  "ldci"
	File: 	 %robinson1.red
	Needs:	 'View
]


; required libs
#include %../../../libs/tools/rcvTools.red
#include %../../../libs/core/rcvCore.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/imgproc/rcvImgProc.red

margins: 10x10
defSize: 512x512
iSize: 512x512
img1: rcvCreateImage defSize
gray: rcvCreateImage defSize
dst:  rcvCreateImage defSize
cImg:  rcvCreateImage defSize
isFile: false

loadImage: does [
    isFile: false
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		win/text: copy "Edges detection: Robinson "
		append win/text to string! tmp
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		cImg rcvCreateImage img1/size
		either cb/data [cImg: rcvCloneImage gray]
					   [cImg: rcvCloneImage img1]
		
		dst:  rcvCloneImage cImg
		iSize: cImg/size
		bb/image: img1
		rcvRobinson cImg dst
		canvas/image: dst
		isFile: true
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: Robinson"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
		cb: check "Grayscale" 	[
					either cb/data  [cImg: rcvCloneImage gray]
					[cImg: rcvCloneImage img1]
					dst:  rcvCloneImage cImg
					rcvRobinson cImg dst
					canvas/image: dst
		]
			
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage dst 
								rcvReleaseImage gray
								rcvReleaseImage cImg
								Quit]
		return
		bb: base 128x128 img1
		return
		canvas: base 512x512 dst	
]
