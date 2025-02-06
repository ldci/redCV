Red [
	Title:   "in Range Filter "
	Author:  "ldci"
	File: 	 %inRange.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red

margins: 10x10
defSize: 512x512
img1: rcvCreateImage defSize
dst:  rcvCreateImage defSize
isFile: false
low: 64.64.64
high: 128.128.128
op: 0

loadImage: does [
    isFile: false
	canvas/image/rgb: black
	canvas/size: 0x0
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: fileName
		img1: rcvLoadImage tmp
		dst:  rcvCloneImage img1
		; update faces
		if img1/size/x >= defSize/x [
			win/size/x: img1/size/x + 20
			win/size/y: img1/size/y + 256
		] 
		either (img1/size/x = img1/size/y) [bb/size: 120x120] [bb/size: 160x120]
		canvas/size: img1/size
		canvas/offset/x: (win/size/x - img1/size/x) / 2
		bb/image: img1
		canvas/image: dst
		isFile: true
		rcvInRange img1 dst low high 0
		r1/data: true
		r2/data: False
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Range Thresholding"
		origin margins space margins
		button 60 "Load" 		[loadImage]		
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage dst Quit]
		return
		bb: base 160x120 img1
		return
		r1: radio "Binary" 	[op: 0 rcvInRange img1 dst low high op]
		r2: radio "Color" 	[op: 1 rcvInRange img1 dst low high op]
		text 50 "Lower" 
		lw: field 100 "64.64.64" [low: to tuple! face/data
			rcvInRange img1 dst low high op
		]
		text 50 "Upper" 
		up: field 100 "128.128.128" [high: to tuple! face/data
			rcvInRange img1 dst low high op 
		]
		return
		canvas: base 512x512 dst	
]
