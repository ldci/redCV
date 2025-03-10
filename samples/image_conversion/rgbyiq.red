Red [
	Title:   "Conversions Operators "
	Author:  "ldci"
	File: 	 %rgbyiq.red
	Needs:	 'View
]


;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/imgproc/rcvColorSpace.red

margins: 5x5
iSize: 512x512
img1: rcvCreateImage iSize
img2: rcvCreateImage iSize
img3: rcvCreateImage iSize
isFile?: false

loadImage: does [
	canvas/image/rgb: black
	isFile?: false
	tmp: request-file
	unless none? tmp [
		img1: rcvLoadImage tmp
		img2: rcvCloneImage img1
		img3: rcvCloneImage img1
		canvas/image: img1
		f/text: rejoin ["Image Size: "  form img1/size]
		isFile?: true
	]
]
	


; ***************** Test Program ****************************
view win: layout [
		title "RGB <-> YIQ"
		origin margins space margins
		across
		button 100 "Load RGB"		[loadImage]
		button 100 "Source"			[if isFile? [canvas/image: img1]]
		button 100 "RGB -> YIQ"		[
			if isFile? [
				tt: dt [rcvRGB2YIQ img1 img2] canvas/image: img2
				msec: (round/to third tt 0.01) * 1000
				f/text: rejoin ["Image Size: "  form img1/size " in: " msec " msec"]
			]
		]
		button 100 "YIQ -> RGB"		[
			if isFile? [
				tt: dt [rcvYIQ2RGB img2 img3] canvas/image: img3
				msec: (round/to third tt 0.01) * 1000
				f/text: rejoin ["Image Size: "  form img1/size " in: " msec " msec"]
			]
		]
		;pad 80x0
		button 70 "Quit" [rcvReleaseImage img1 rcvReleaseImage img2 rcvReleaseImage img3 Quit]
		return
		canvas: base iSize img1
		return
		f: field 512
]