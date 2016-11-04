Red [
	Title:   "Morphological operators"
	Author:  "Francois Jouen"
	File: 	 %morpho.red
	Needs:	 'View
]

; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
img1: rcvLoadImage %../../images/lena.jpg
clone: rcvCloneImage img1
dst:  rcvCreateImage img1/size
shape: 1
knlSize: 3x3
knl: rcvCreateStructuringElement/rectangle knlSize

; ***************** Test Program ****************************
view win: layout [
		title "Morphological Operators: Morphology Extensions"
		origin margins space margins
		button 55 "Source" 		[f/text: face/text rcvCopyImage img1 dst clone: rcvCloneImage img1]									
		button 70 "Gradient" 	[f/text: face/text clone: rcvCloneImage img1 rcvMGradient clone dst knlSize knl]
		button 70 "Gradient/R" 	[f/text: face/text clone: rcvCloneImage img1 rcvMGradient/reverse clone dst knlSize knl]
		button 70 "Top Hat" 	[f/text: face/text clone: rcvCloneImage img1 rcvTopHat clone dst knlSize knl]
		button 70 "Black Hat" 	[f/text: face/text clone: rcvCloneImage img1 rcvBlackHat clone dst knlSize knl]	
		f: field 70 "Source"
		button 50 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return
		text 60 "Shape" 	
		drop-down 90x30 
			data ["Cross" "Rectangle"] 
			select 1
			on-change [shape: face/selected
			switch shape [
					1	[knl: rcvCreateStructuringElement/cross knlSize]
					2	[knl: rcvCreateStructuringElement/rectangle knlSize]
				]
			]
		text 90 "Kernel Size"
		drop-down 60x30 
			data ["3x3" "4x4" "5x5" "6x6" "7x7" "8x8" "9x9" "10x10" "11x11"]
			select 1	
			on-change [knlSize: to pair! face/text]	
		return 
		canvas: base 512x512 dst	
		do [rcvCopyImage img1 dst clone: rcvCloneImage img1]
]
