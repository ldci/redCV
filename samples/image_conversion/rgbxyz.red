Red [
	Title:   "Conversions Operators "
	Author:  "ldci"
	File: 	 %rgbxyz.red
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
	if not none? tmp [
		img1: rcvLoadImage tmp
		img2: rcvCloneImage img1
		dst:  rcvCloneImage img1
		canvas/image: dst
		f/text: rejoin ["Image Size: "  form img1/size]
	]
]
	


; ***************** Test Program ****************************
view win: layout [
		title "RGB <-> XYZ"
		origin margins space margins
		across
		button 80 "Load RGB"		[loadImage]
		button 100 "RGB -> XYZ"		[
			tt: dt[rcvRGB2XYZ img1 dst]
			msec:  (round/to third tt 0.01) * 1000
			f/text: rejoin ["Image Size: "  form img1/size " in: " msec " msec"]
		]
		
		button 100 "XYZ -> RGB"		[
			tt: dt [
				rcvRGB2XYZ img1 dst 
				rcvCopyImage dst img2
				rcvXYZ2RGB img2 dst
			]
			msec:  (round/to third tt 0.01) * 1000
			f/text: rejoin ["Image Size: "  form img2/size " in: " msec " msec"]
		]
		button 120 "XYZ -> Adobe"	[
			tt: dt  [
				rcvRGB2XYZ img1 dst 
				rcvCopyImage dst img2
				rcvXYZ2AdobeRGB img2 dst
			]
			msec:  (round/to third tt 0.01) * 1000
			f/text: rejoin ["Image Size: "  form img2/size " in: " msec " msec"]
		]
		
		button 70 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return
		canvas: base 512x512 dst
		return
		f: field 512
]