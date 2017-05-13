Red [
	Title:   "Statitical tests "
	Author:  "Francois Jouen"
	File: 	 %MatStats.red
	Needs:	 'View
]

; required last Red Master

#include %../../libs/redcv.red ; for red functions

margins: 2x5
img1: rcvLoadImage %../../images/baboon.jpg
img2:  rcvCreateImage img1/size				; create image for grayscale
mat: rcvCreateMat 'integer! 8 img1/size		; a 8-bit matrix
rcvImage2Mat img1 mat 						; Converts  image to 1 Channel matrix [0..255]  
rcvMat82Image mat img2 						; from matrix to red image
img3: rcvCloneImage img2
img: rcvCreateImage img1/size

; ***************** Test Program ****************************
view win: layout [
		title "Statistical Tests"
		origin margins space margins
		button 80 "NZero" 	[sbar/data: rcvCountNonZero mat canvas/image: img2]
		button 60 "Sum" 	[sbar/data: rcvSum mat canvas/image: img2]
		button 60 "Mean" 	[sbar/data: first rcvMean mat canvas/image: img2]
		button 50 "SD"  	[sbar/data: first rcvSTD mat canvas/image: img2]
		button 70 "Median"	[sbar/data: first rcvMedian mat canvas/image: img2]
		button 60 "Min"		[sbar/data: first rcvMinValue mat canvas/image: img2]
		button 60 "Max"		[sbar/data: first rcvMaxValue mat canvas/image: img2]
		button 50 "Quit" 	[rcvReleaseImage img1 img2 img3 img Quit]
		
		return 
		button 80 "Min Loc"	[sbar/data: xy: rcvMinLoc mat img1/size
							 	plot: compose [line-width 1 fill-pen white circle (xy) 10.0]
							 	img3: rcvCloneImage img2
							 	img: draw img3 plot
							 	canvas/image: img
							]
		button 80 "Max Loc"	[sbar/data: xy: rcvMaxLoc mat img1/size
								plot: compose [line-width 1 fill-pen white circle (xy) 10.0]
								img3: rcvCloneImage img2
								img: draw img3 plot
							 	canvas/image: img
							]
		
		return 
		canvas: base 512x512 img2
		return
		sbar: field 250
]
