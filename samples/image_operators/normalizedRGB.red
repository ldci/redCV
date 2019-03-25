Red [
	Title:   "Normalized RGB"
	Author:  "Francois Jouen"
	File: 	 %normalizedRGB.red
	Needs:	 View
]

#include %../../libs/redcv.red ; for red functions
isFile: false

loadImage: does [
	isFile: false
	canvas1/image: none
	canvas2/image: none
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		dst: rcvCreateImage img1/size
		isFile: true
		showImages
	]
]

showImages: does [
	if isFile [
		either cb/data 	[rcv2NzRGB/sumsquare img1 dst]
						[rcv2NzRGB/sum img1 dst]
		canvas1/image: img1
		canvas2/image: dst
	]
]

; ***************** Test Program ****************************
view win: layout [
	title "Normalized RGB"
	button 60 "Load" 				[loadImage]
	cb: check "Square Sum" false	[showImages]
	button 80 "Quit" 				[if isFile [rcvReleaseImage img1 rcvReleaseImage dst] 
									Quit]
	return
	canvas1: base 512x512 
	canvas2: base 512x512 	
]