Red [
	Title:   "Maths tests "
	Author:  "ldci"
	File: 	 %mathOps.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red

margins: 5x5
img1: rcvCreateImage 512x512
img2: rcvRandomImage/uniform img1/size 255.255.255

dst: rcvCreateImage img1/size

loadImage: does [
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage  tmp
		img2: rcvRandomImage/uniform img1/size 255.255.255
		dst: rcvCreateImage img1/size
		rcvCopyImage img1 dst
		canvas/image: dst
	]
]


; ***************** Test Program ****************************
view win: layout [
		title "Math Operator Tests"
		origin margins space margins
		bb: base 80x30 img2 
		button "Load" [LoadImage]
		button "Generate image 2" [img2: rcvRandomImage/uniform img1/size 255.255.255 bb/image: img2]
		button 80 "Source"  [rcvMath img1 img2 dst 0]
		button 80 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2 
							rcvReleaseImage dst 
							Quit]
		return
		text 80 "Images"
		button 35 "+" [rcvAdd img1 img2 dst] 
		button 35 "-" [rcvSub img1 img2 dst]
		button 35 "*" [rcvMul img1 img2 dst]
		button 35 "/" [rcvDiv img2 img1 dst]
		button 35 "//"[rcvMod img1 img2 dst]
		button 35 "%" [rcvRem img1 img2 dst]
		button 50 "Abs"[rcvAbsDiff img1 img2 dst]
		button 50 "Mean" [rcvMeanImages img1 img2 dst]
		return
		text 80 "LIP Model"
		button 35 "+" [rcvAddLIP img1 img2 dst]
		button 35 "-" [rcvSubLIP img1 img2 dst]
		
		return 
		text 80 "Tuple"
		button 35 "+" [rcvAddT img1 dst 128.128.128 false]
		button 35 "-" [rcvSubT img1 dst 128.128.128 false]
		button 35 "*" [rcvMulT img1 dst 2.2.2 false]
		button 35 "/" [rcvDivT img1 dst 2.2.2 false]
		button 35 "//"[rcvModT img1 dst 1.1.1 false]
		button 35 "%" [rcvRemT img1 dst  2.2.2 false]
		return
		text 80 "Scalar"
		button 35 "+" [rcvAddS img1 dst 128]
		button 35 "-" [rcvSubS img1 dst 128]
		button 35 "*" [rcvMulS img1 dst 2]
		button 35 "/" [rcvDivS img1 dst 2]
		button 35 "//"[rcvModS img1 dst 2]
		button 35 "%" [rcvRemS img1 dst 2]
		return
		text 80 "Misc"
		button 50 "Pow" [rcvPow img1 dst 0.75]
		button 50 "<<" [rcvLSH img1 dst 2]
		button 50 ">>" [rcvRSH img1 dst 2]
		button 50 "Sqr"[rcvSQR img1 dst 0.0]
		return
		canvas: base 512x512 dst
		
		do [rcvMath img1 img2 dst 0]
]

