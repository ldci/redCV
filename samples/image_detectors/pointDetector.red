Red [
	Title:   "Point Filter "
	Author:  "ldci"
	File: 	 %pointDetector.red
	Needs:	 'View
]


;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red
#include %../../libs/math/rcvQuickHull.red

margins: 10x10
defSize: 512x512
img1: rcvCreateImage defSize
dst:  rcvCreateImage defSize
isFile: false

multi: 1.0
bias: 0.0

loadImage: does [
    isFile: false
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: fileName
		either cb/data [img1: rcvLoadImage/grayscale tmp]
					   [img1: rcvLoadImage tmp]
		dst:  rcvLoadImage/grayscale tmp
		lumMat: matrix/init 2 32 img1/size
		either (img1/size/x = img1/size/y) [bb/size: 120x120] [bb/size: 160x120]
		bb/image: img1
		isFile: true
		compute
	]
]

compute: does [
	cPoints: copy []
	rcvPointDetector img1 dst multi bias
	rcvImage2Mat dst lumMat 
	binMat: rcvMakeBinaryMat lumMat
	rcvGetPairs binMat cPoints
	chull: rcvQuickHull/cw cPoints
	; we need 3 points or more for polygon drawing 
	n: length? chull
	if n > 2 [
		plot: copy reduce ['line-width 2 'pen red 'polygon]
		foreach p chull [append plot p]
	]
	canvas/image: draw dst plot
]

; ***************** Test Program ****************************
view win: layout [
		title "Points"
		origin margins space margins
		cb: check "Grayscale" 
		button 60 "Load" 		[loadImage]			
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage dst Quit]
		return
		bb: base 160x120 img1
		return 
		canvas: base 512x512 dst	
]
