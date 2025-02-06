Red [
	Title:   "Conversions Operators "
	Author:  "ldci"
	File: 	 %rgbhsl.red
	Needs:	 'View
]


;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/imgproc/rcvColorSpace.red

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
		title "RGB <-> HSL"
		origin margins space margins
		across
		button 100 "Load RGB"		[loadImage]
		button 100 "RGB -> HSL"		[rcvRGB2HLS img1 dst]
		button 100 "HSL -> RGB"		[rcvRGB2HLS img1 dst 
									rcvCopyImage dst img2
									rcvHLS2RGB img2 dst	;--incorrect conversion
								]
		pad 80x0
		button 100 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return
		canvas: base 512x512 dst
]