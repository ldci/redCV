Red [
	Title:   "Statitical tests "
	Author:  "ldci"
	File: 	 %imageStats.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/math/rcvStats.red	

margins: 5x5
img1: rcvCreateImage 512x512
img: rcvCreateImage img1/size

loadImage: does [
	canvas/image: none
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		canvas/image: img1
		
	]
]


; ***************** Test Program ****************************
view win: layout [
		title "RGB Statistical Tests"
		origin margins space margins
		button 80 "Load"	[loadImage]
		button 50 "Quit" 	[rcvReleaseImage img1 img Quit]
		return
		button 80 "NZero" 	[sbar/data: rcvCountNonZero img1 canvas/image: img1]
		button 80 "Sum" 	[sbar/data: rcvSum img1 canvas/image: img1]
		button 80 "Mean" 	[sbar/data: rcvMean img1 canvas/image: img1]
		button 80 "SD"  	[sbar/data: rcvSTD img1 canvas/image: img1]
		button 80 "Median"	[sbar/data: rcvMedian img1 canvas/image: img1]
		return
		button 80 "Min"		[sbar/data: rcvMinValue img1 canvas/image: img1]
		button 80 "Max"		[sbar/data: rcvMaxValue img1 canvas/image: img1]
		
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
