Red [
	Title:   "Gaussian Filter tests "
	Author:  "Francois Jouen"
	File: 	 %Gaussian2.red
	Needs:	 'View
]


#include %../../../libs/redcv.red ; for redCV functions
margins: 5x5
img1: rcvCreateImage 512x512
dst:  rcvCreateImage 512x512


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
		button 65 "Source" 		[rcvCopyImage img1 dst clear f/text]	
		button 50 "3x3" 	   	[knl: rcvMakeGaussian 3x3 2.0 f/text: form knl rcvFilter2D img1 dst knl 1.0 0.0] 
		button 50 "5x5" 		[knl: rcvMakeGaussian 5x5 2.0 f/text: form knl rcvFilter2D img1 dst knl 1.0 0.0]
		button 50 "7x7"  		[knl: rcvMakeGaussian 7x7 2.0 f/text: form knl rcvFilter2D img1 dst knl 1.0 0.0]
		button 50 "9x9"  		[knl: rcvMakeGaussian 9x9 2.0 f/text: form knl rcvFilter2D img1 dst knl 1.0 0.0]
		button 60 "11x11"  		[knl: rcvMakeGaussian 11x11 2.0 f/text: form knl rcvFilter2D img1 dst knl 1.0 0.0]
		button 60 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return 
		canvas: base 512x512 black
		return
		f: field 512
]
