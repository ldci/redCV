Red [
	Title:   "Convolution tests "
	Author:  "Francois Jouen"
	File: 	 %threshold1.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red

margins: 3x10
;--I do not understand why this code must be executed in terminal mode
img1: rcvLoadImage %../../images/baboon.jpg
dst:  rcvCreateImage img1/size
thresh: 127
maxValue: 255
	  
; ***************** Test Program ****************************
view win: layout [
		title "BW thresholding Tests"
		origin margins space margins
		button 65 "Source" 		[rcvCopyImage img1 dst]
		button 60 "Binary" 		[rcvThreshold/binary img1 dst thresh maxValue]
		button 80 "Binary Inv" 	[rcvThreshold/binaryInv img1 dst thresh maxValue]
		button 80 "Truncate" 	[rcvThreshold/trunc img1 dst thresh maxValue]
		button 50 "To 0" 		[rcvThreshold/toZero img1 dst thresh maxValue]
		button 75 "To 0 Inv" 	[rcvThreshold/toZeroInv img1 dst thresh maxValue]
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
