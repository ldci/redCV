Red [
	Title:   "Statitical tests "
	Author:  "Francois Jouen"
	File: 	 %ImageStats.red
	Needs:	 'View
]

; required last Red Master

#include %../../libs/redcv.red ; for redcv functions

margins: 2x5
img1: rcvLoadImage %../../images/lena.jpg
img: rcvCreateImage img1/size


; ***************** Test Program ****************************
view win: layout [
		title "RGB Statistical Tests"
		origin margins space margins
		button 80 "NZero" 	[sbar/data: rcvCountNonZero img1 canvas/image: img1]
		button 60 "Sum" 	[sbar/data: rcvSum img1 canvas/image: img1]
		button 60 "Mean" 	[sbar/data: rcvMean/argb img1 canvas/image: img1]
		button 50 "SD"  	[sbar/data: rcvSTD/argb img1 canvas/image: img1]
		button 70 "Median"	[sbar/data: rcvMedian img1 canvas/image: img1]
		button 60 "Min"		[sbar/data: rcvMinValue img1 canvas/image: img1]
		button 60 "Max"		[sbar/data: rcvMaxValue img1 canvas/image: img1]
		button 50 "Quit" 	[rcvReleaseImage img1 img Quit]
		
		return
		
		button 80 "Min Loc"	[sbar/data: xy: rcvMinLoc img1 0x0 
							 	plot: compose [line-width 1 fill-pen green circle (xy) 10.0]
							 	img2: rcvCloneImage img1
							 	img: draw img2 plot
							 	canvas/image: img]
		button 80 "Max Loc"	[sbar/data: xy: rcvMaxLoc img1 0x0
								plot: compose [line-width 1 fill-pen green circle (xy) 10.0]
								img2: rcvCloneImage img1
							 	img: draw img2 plot
							 	canvas/image: img ]
		
		return 
		canvas: base 512x512 img1
		return
		sbar: field 250
]
