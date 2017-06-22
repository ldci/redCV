Red [
	Title:   "Convolution tests "
	Author:  "Francois Jouen"
	File: 	 %threshold.red
	Needs:	 'View
]


; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 3x10
img1: rcvLoadImage %../../images/baboon.jpg
dst:  rcvCreateImage img1/size
thresh: 127
maxValue: 255


		  
; ***************** Test Program ****************************
view win: layout [
		title "BW thresholding Tests"
		origin margins space margins
		button 55 "Source" 		[rcvCopyImage img1 dst]
		button 50 "Binary" 		[rcvThreshold/binary img1 dst thresh maxValue];
		button 75 "Binary Inv" 	[rcvThreshold/binaryInv img1 dst thresh maxValue];
		button 75 "Truncate" 	[rcvThreshold/trunc img1 dst thresh maxValue];
		button 45 "To 0" 		[rcvThreshold/toZero img1 dst thresh maxValue];
		button 65 "To 0 Inv" 	[rcvThreshold/toZeroInv img1 dst thresh maxValue];
		button 50 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return
		text "Threshold" 
		p1: field [if error? try [thresh: to integer! p1/data] [thresh: 127]]
		text "Max Value" 
		p2: field [if error? try [maxValue: to integer! p2/data] [maxValue: 255]]
		return
		canvas: base 512x512 dst	
		do [rcvCopyImage img1 dst p1/data: thresh p2/data: maxValue]
]
