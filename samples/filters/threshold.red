Red [
	Title:   "Convolution tests "
	Author:  "Francois Jouen"
	File: 	 %threshold.red
	Needs:	 'View
]


; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
img1: rcvLoadImage %../../images/baboon.jpg
dst:  rcvCreateImage img1/size
thresh: 64
maxValue: 255


		  
; ***************** Test Program ****************************
view win: layout [
		title "BW thresholding Tests"
		origin margins space margins
		button 60 "Source" 		[rcvCopyImage img1 dst]
		button 60 "Binary" 		[rcvThreshold/binary img1 dst thresh maxValue];
		button 60 "Binary Inv" 	[rcvThreshold/binaryInv img1 dst thresh maxValue];
		button 60 "Truncate" 	[rcvThreshold/trunc img1 dst thresh maxValue];
		button 60 "To Zero" 	[rcvThreshold/toZero img1 dst thresh maxValue];
		button 60 "To Zero Inv" [rcvThreshold/toZeroInv img1 dst thresh maxValue];
		button 80 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return
		text "Threshold" 
		p1: field [if error? try [thresh: to integer! p1/data] [thresh: 64]]
		text "Max Value" 
		p2: field [if error? try [maxValue: to integer! p2/data] [maxValue: 255]]
		return
		canvas: base 512x512 dst	
		do [rcvCopyImage img1 dst p1/data: thresh p2/data: maxValue]
]
