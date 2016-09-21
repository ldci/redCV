Red [
	Title:   "Statitical tests "
	Author:  "Francois Jouen"
	File: 	 %MatStats.red
	Needs:	 'View
]

; required last Red Master

#include %../../libs/redcv.red ; for red functions

margins: 5x5
img1: rcvLoadImage %../../images/baboon.jpg
img2:  rcvCreateImage img1/size				; create image for grayscale
mat: rcvCreateMat 'integer! 8 img1/size
rcvImage2Mat img1 mat 				; Converts  image to 1 Channel matrix [0..255]  
rcvMat82Image mat img2 				; from matrix to red image


; ***************** Test Program ****************************
view win: layout [
		title "Statistical Tests"
		origin margins space margins
		button 40 "NZero" 	[sbar/data: rcvCountNonZero mat]
		button 40 "Sum" 	[sbar/data: rcvSum mat]
		button 40 "Mean" 	[sbar/data: first rcvMean mat]
		button 40 "SD"  	[sbar/data: first rcvSTD mat]
		button 45 "Median"	[sbar/data: first rcvMedian mat]
		button 40 "Min"		[sbar/data: first rcvMinValue mat]
		button 50 "Min Loc"	[sbar/data: rcvMinLoc mat img1/size]
		button 40 "Max"		[sbar/data: first rcvMaxValue mat]
		button 50 "Max Loc"	[sbar/data: rcvMaxLoc mat img1/size]
		button 40 "Quit" 	[rcvReleaseImage img1 Quit]
		return 
		canvas: base 512x512 img2
		return
		sbar: field 250
]
