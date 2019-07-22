Red [
	Title:   "Pyramidal test"
	Author:  "Francois Jouen"
	File: 	 %pyramidal2.red
	Needs:	 'View
]


; last Red Master required!
#include %../../libs/redcv.red ; for red functions
margins: 10x10
knl: rcvMakeGaussian 5x5 1.0
img1: rcvCreateImage 512x512
dst: rcvCreateImage 512x512
iSize: 0x0
lt: 0x0
br: 0x0
isFile: false


loadImage: does [
	canvas/image/rgb: black
	isFile: false
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: fileName
		img1: rcvLoadImage tmp
		dst:  rcvCloneImage img1
		iSize: img1/size
		br: iSize
		drawBlk: compose [image (dst) (lt) (br)]
		canvas/draw: drawBlk
		f/data: form dst/size
		isFile: true
	]
]

showPyramidal: does [
	f/data: form iSize
	dst: rcvResizeImage/gaussian dst iSize
	drawBlk/4: iSize
]

; ***************** Test Program ****************************
view win: layout [
		title "Pyramidal Sizing"
		button 80 "Load" 		[loadImage]						    					    								
		button 85 "Pyr Down"	[if isFile [iSize: iSize / 2 showPyramidal]]	
		button 80 "Pyr Up"	   	[if isFile [iSize: iSize * 2 showPyramidal]]								    
		f: field 80						
		button 80 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return
		canvas: base 512x512 dst		
]
