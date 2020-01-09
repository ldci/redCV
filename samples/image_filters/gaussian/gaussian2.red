Red [
	Title:   "Gaussian Filter tests "
	Author:  "Francois Jouen"
	File: 	 %Gaussian2.red
	Needs:	 'View
]

; required libs
#include %../../../libs/tools/rcvTools.red
#include %../../../libs/core/rcvCore.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/imgproc/rcvImgProc.red

margins: 5x5
img1: rcvCreateImage 512x512
dst:  rcvCreateImage 512x512
std: 1.0
knl: []

loadImage: does [
	canvas/image: none
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		dst:  rcvCloneImage img1
		canvas/image: dst
	]
]

process: does [
	f/text: form knl 
	rcvFilter2D img1 dst knl 1.0 0.0
]


; ***************** Test Program ****************************
view win: layout [
		title "Gaussian Filter"
		origin margins space margins
		button 60 "Load" 		[loadImage]
		text 55 "Variance"  drop-down 50 data ["1.0" "2.0" "3.0" "4.0"]
			on-change [std: to-float face/selected rcvCopyImage img1 dst clear f/text]
			select 1
		button 65 "Source" 		[rcvCopyImage img1 dst clear f/text]
		text 50 "Kernel"	
		button 50 "3x3" 	   	[knl: rcvMakeGaussian 3x3 std process] 
		button 50 "5x5" 		[knl: rcvMakeGaussian 5x5 std process]
		button 50 "7x7"  		[knl: rcvMakeGaussian 7x7 std process]
		button 50 "9x9"  		[knl: rcvMakeGaussian 9x9 std process]
		button 60 "11x11"  		[knl: rcvMakeGaussian 11x11 std process]
		button 50 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return 
		canvas: base 512x512 black
		f: area 160x512
]
