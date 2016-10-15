Red [
	Title:   "Statitical tests "
	Author:  "Francois Jouen"
	File: 	 %ImageStats.red
	Needs:	 'View
]

; required last Red Master

#include %../../libs/redcv.red ; for red functions

margins: 5x5
img1: rcvLoadImage %../../images/lena.jpg
img2: rcvCloneImage img1
img: rcvCreateImage img1/size
p1: 0x0
; ***************** Test Program ****************************
view win: layout [
		title "Statistical Tests"
		origin margins space margins
		button 40 "NZero" 	[sbar/data: rcvCountNonZero img1 canvas/image: img1]
		button 40 "Sum" 	[sbar/data: rcvSum img1 canvas/image: img1]
		button 40 "Mean" 	[sbar/data: rcvMean/argb img1 canvas/image: img1]
		button 40 "SD"  	[sbar/data: rcvSTD/argb img1 canvas/image: img1]
		button 45 "Median"	[sbar/data: rcvMedian img1 canvas/image: img1]
		button 40 "Min"		[sbar/data: rcvMinValue img1 canvas/image: img1]
		button 50 "Min Loc"	[sbar/data: xy: rcvMinLoc img1 0x0 
							 	plot: compose [line-width 1 fill-pen green circle (xy) 10.0]
							 	img2: rcvCloneImage img1
							 	img: draw img2 plot
							 	canvas/image: img]
		button 40 "Max"		[sbar/data: rcvMaxValue img1 canvas/image: img1]
		button 50 "Max Loc"	[sbar/data: xy: rcvMaxLoc img1 0x0
								plot: compose [line-width 1 fill-pen green circle (xy) 10.0]
								img2: rcvCloneImage img1
							 	img: draw img2 plot
							 	canvas/image: img ]
		button 40 "Quit" 	[rcvReleaseImage img1 img2 img Quit]
		return 
		canvas: base 512x512 img1
		return
		sbar: field 250
]
