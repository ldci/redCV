Red [
	Title:   "Gaussian Filter test"
	Author:  "Francois Jouen"
	File: 	 %gaussianFilter.red
	Needs:	 'View
]


; last Red Master required!
#include %../libs/redcv.red ; for red functions
margins: 10x10
img1: rcvLoadImage %../images/baboon.jpg
currentImage: rcvCloneImage img1

dst:  rcvCreateImage img1/size
knl: rcvMakeGaussian 5x5

	  
; ***************** Test Program ****************************
view win: layout [
		title "Gaussian 2D Filter"
		
		button 60 "No Filter" 	[	rcvCopy img1 dst 
								 	rcvCopy img1 currentImage
								]						    								
		button 60 "Filter +"	[	rcvGaussianFilter currentImage dst knl 0
									rcvCopy dst currentImage
								]
								
		button 80 "Quit" 		[Quit]
		
		return
		canvas: base 512x512 dst	
		do [rcvCopy img1 dst]
]
