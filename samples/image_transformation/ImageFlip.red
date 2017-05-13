Red [
	Title:   "Flip tests "
	Author:  "Francois Jouen"
	File: 	 %ImageFlip.red
	Needs:	 'View
]


; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
img1: rcvLoadImage %../../images/lena.jpg
dst:  rcvCreateImage img1/size


; ***************** Test Program ****************************
view win: layout [
		title "Flip Tests"
		origin margins space margins
		button 80 "Source" 		[rcvCopyImage img1 dst ]
		button 80 "Left/Right" 	[rcvFlip/horizontal img1 dst] 
		button 80 "Up/Down" 	[rcvFlip/vertical img1 dst]
		button 80 "Both"  		[rcvFlip/both img1 dst]
		button 80 "Quit" 		[rcvReleaseImage img1 dst Quit]
		return 
		canvas: base 512x512 dst	
		do [rcvCopyImage img1 dst]
]
