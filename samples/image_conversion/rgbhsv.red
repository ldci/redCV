Red [
	Title:   "Conversions Operators "
	Author:  "ldci"
	File: 	 %rgbhsv.red
	Needs:	 'View
]


;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/imgproc/rcvColorSpace2.red

margins: 5x5
img1: rcvCreateImage 512x512
img2: rcvCreateImage 512x512
dst:  rcvCreateImage img1/size

loadImage: does [
	canvas/image/rgb: black
	tmp: request-file
	unless none? tmp [
		img1: rcvLoadImage tmp
		img2: rcvCloneImage img1
		dst:  rcvCloneImage img1
		canvas/image: dst
	]
]
	


; ***************** Test Program ****************************
view win: layout [
		title "RGB <-> HSV"
		origin margins space margins
		across
		button 100 "Load RGB"		[loadImage]
		button 100 "Source"			[rcvCopyImage img1 dst]
		button 100 "RGB -> HSV"		[rcvRGB2HSV img1 dst]
		button 100 "HSV -> RGB"		[rcvRGB2HSV img1 dst rcvCopyImage dst img2
									 rcvHSV2RGB img2 dst ;--incorrect conversion
									 ]
		;pad 80x0
		button 70 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return
		canvas: base 512x512 dst
]