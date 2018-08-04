Red [
	Title:   "Statitical tests "
	Author:  "Francois Jouen"
	File: 	 %MatStats.red
	Needs:	 'View
]

; required last Red Master

#include %../../libs/redcv.red ; for red functions

margins: 5x5
img1: rcvCreateImage 512x512
img2: rcvCreateImage 512x512


loadImage: does [
	canvas/image: none
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		img2:  rcvCreateImage img1/size				; create image for grayscale
		mat: rcvCreateMat 'integer! 32 img1/size	; a 32-bit matrix
	rcvImage2Mat img1 mat 							; Converts  image to 1 Channel matrix [0..255]  
	rcvMat2Image mat img2 							; from matrix to red image
	img3: rcvCloneImage img2
	img: rcvCreateImage img1/size
	canvas/image: img2	
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Statistical Tests"
		origin margins space margins
		button 80 "Load"	[loadImage]
		return
		button 80 "NZero" 	[sbar/data: rcvCountNonZero mat canvas/image: img2]
		button 80 "Sum" 	[sbar/data: rcvSum mat canvas/image: img2]
		button 80 "Mean" 	[sbar/data: first rcvMean mat canvas/image: img2]
		button 80 "SD"  	[sbar/data: first rcvSTD mat canvas/image: img2]
		button 80 "Median"	[sbar/data: first rcvMedian mat canvas/image: img2]
		
		button 50 "Quit" 	[rcvReleaseImage img1 img2 img3 img Quit]
		
		return 
		button 80 "Min"		[sbar/data: first rcvMinValue mat canvas/image: img2]
		button 80 "Max"		[sbar/data: first rcvMaxValue mat canvas/image: img2]
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