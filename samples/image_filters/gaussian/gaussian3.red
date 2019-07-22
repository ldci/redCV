Red [
	Title:   "Gaussian Filter tests "
	Author:  "Francois Jouen"
	File: 	 %Gaussian3.red
	Needs:	 'View
]


#include %../../../libs/redcv.red ; for redCV functions
margins: 5x5
img1: rcvCreateImage 512x512
dst:  rcvCreateImage 512x512
knl: [
1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 
0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0 
0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 
0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 
0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 
0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 
0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 
0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0
]

loadImage: does [
	canvas/image: none
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		dst:  rcvCloneImage img1
		canvas/image: dst
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Gaussian Filter"
		origin margins space margins
		button 60 "Load" 		[loadImage]
		button 65 "Source" 		[rcvCopyImage img1 dst]	
		cb: check "2D Filter"
		button 50 "Blur" 	   	[ either cb/data [rcvFilter2D img1 dst knl  1.0 0.0]
												 [rcvConvolve img1 dst knl  1.0 / 9.0 0.0]
		] 
		
		button 60 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return 
		canvas: base 512x512 black
]
