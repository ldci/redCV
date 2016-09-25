Red [
	Title:   "Maths tests "
	Author:  "Francois Jouen"
	File: 	 %MathOps.red
	Needs:	 'View
]

; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 5x5
img1: rcvLoadImage %../../images/lena.jpg
img2: rcvRandomImage/uniform img1/size 255.255.255 ;
dst: rcvCreateImage img1/size

; ***************** Test Program ****************************
view win: layout [
		title "Math Operator Tests"
		origin margins space margins
		text 35 "Image"
		button 35 "+" [rcvAdd img1 img2 dst ]
		button 35 "-" [rcvSub img1 img2 dst]
		button 35 "*" [rcvMul img1 img2 dst]
		button 35 "/" [rcvDiv img2 img1 dst]
		button 35 "//"[rcvMod img1 img2 dst]
		button 35 "%" [rcvRem img1 img2 dst]
		button 35 "Abs"[rcvAbsDiff img1 img2 dst]
		return 
		text 35 "Tuple"
		button 35 "+" [rcvAddT img1 dst 128.128.128]
		button 35 "-" [rcvSubT img1 dst 128.128.128]
		button 35 "*" [rcvMulT img1 dst 2.2.2]
		button 35 "/" [rcvDivT img1 dst 2.2.2]
		button 35 "//" [rcvModT img1 dst 1.1.1]
		button 35 "%" [rcvRemT img1 dst  2.2.2]
		return
		text 35 "Scalar"
		button 35 "+" [rcvAddS img1 dst 128]
		button 35 "-" [rcvSubS img1 dst 128]
		button 35 "*" [rcvMulS img1 dst 2]
		button 35 "/" [rcvDivS img1 dst 2]
		button 35 "//"[rcvModS img1 dst 2]
		button 35 "%" [rcvRemS img1 dst 2]
		return
		text 35 "Misc"
		button 35 "^n" [rcvPow img1 dst 2]
		button 35 "<<" [rcvLSH img1 dst 2]
		button 35 ">>" [rcvRSH img1 dst 2]
		button 35 "Sqr"[rcvSQR img1 dst 0]
		return
		canvas: base 512x512 dst
		return 
		button 60 "Source"  [_rcvMath img1 img2 dst 0] ; routine
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2 
							rcvReleaseImage dst 
							Quit]
		do [_rcvMath img1 img2 dst 0]
]

