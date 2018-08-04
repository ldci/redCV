Red [
	Title:   "Flip tests "
	Author:  "Francois Jouen"
	File: 	 %ImageFlip.red
	Needs:	 'View
]


; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
img1: rcvCreateImage 512x512
dst:  rcvCreateImage img1/size


loadImage: does [
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		dst:  rcvCloneImage img1
		canvas/image: dst
	]
]



; ***************** Test Program ****************************
view win: layout [
		title "Flip Tests"
		origin margins space margins
		button 60 "Load"		[loadImage]
		button 80 "Source" 		[rcvCopyImage img1 dst ]
		button 80 "Left/Right" 	[rcvFlip/horizontal img1 dst] 
		button 80 "Up/Down" 	[rcvFlip/vertical img1 dst]
		button 80 "Both"  		[rcvFlip/both img1 dst]
		button 50 "Quit" 		[rcvReleaseImage img1 dst Quit]
		return 
		canvas: base 512x512 dst	
		do [rcvCopyImage img1 dst]
]
