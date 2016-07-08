Red [
	Title:   "Statitical tests "
	Author:  "Francois Jouen"
	File: 	 %testStat.red
	Needs:	 'View
]

; required last Red Master

#include %../libs/redcv.red ; for red functions

margins: 5x5
img1: rcvLoadImage %../images/lena.jpg

; ***************** Test Program ****************************
view win: layout [
		title "Statistical Tests"
		origin margins space margins
		button 40 "NZero" 	[sbar/data: rcvCountNonZero img1]
		button 40 "Sum" 	[sbar/data: rcvSum img1]
		button 40 "Mean" 	[sbar/data: rcvMeanImage img1]
		button 40 "SD"  	[sbar/data: rcvVarImage img1]
		button 40 "Median"	[sbar/data: rcvMedianImage img1]
		button 40 "Min"		[sbar/data: rcvMinImage img1]
		button 40 "Max"		[sbar/data: rcvMaxImage img1]
		button 80 "Quit" 	[rcvReleaseImage img1 Quit]
		return 
		canvas: base 512x512 img1
		return
		sbar: field 200
]
