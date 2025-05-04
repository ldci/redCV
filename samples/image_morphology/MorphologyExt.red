Red [
	Title:   "Morphological operators"
	Author:  "ldci"
	File: 	 %morphologyExt.red
	Needs:	 'View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvMorphology.red

margins: 2x5
img1: 	rcvCreateImage 512x512
clone: 	rcvCreateImage 512x512
dst:  	rcvCreateImage 512x512
shape: 1
knlSize: 3x3
knl: rcvCreateStructuringElement/rectangle knlSize


loadImage: does [
	isFile: false
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		img1: 	rcvLoadImage/grayscale tmp
		dst:  	rcvLoadImage/grayscale tmp
		clone: 	rcvCloneImage img1
		canvas/image: dst
		isFile: true
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Morphological Operators: Morphology Extensions"
		origin margins space margins
		button 60 "Load"		[loadImage]
		button 70 "Source" 		[f/text: face/text rcvCopyImage img1 dst 
								clone: rcvCloneImage img1]									
		text 60 "Shape" 	
		drop-down 90 
			data ["Cross" "Rectangle" "Vertical" "Horizontal"]
			select 1
			on-change [shape: face/selected
			switch shape [
					1	[knl: rcvCreateStructuringElement/cross knlSize]
					2	[knl: rcvCreateStructuringElement/rectangle knlSize]
					3	[knl: rcvCreateStructuringElement/vline knlSize]
					4	[knl: rcvCreateStructuringElement/hline knlSize]
				]
			]
		text 90 "Kernel Size"
		drop-down 60
			data ["3x3" "4x4" "5x5" "6x6" "7x7" "8x8" "9x9" "10x10" "11x11"]
			select 1	
			on-change [knlSize: to pair! face/text]	
		button 50 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage clone 
								rcvReleaseImage dst
								Quit]
		return
		pad 5x0
		button 120 "Gradient" 	[f/text: face/text clone: rcvCloneImage img1 
								rcvMGradient clone dst knlSize knl]
		button 120 "Gradient/Inverse" 
								[f/text: face/text clone: rcvCloneImage img1 
								rcvMGradient/reverse clone dst knlSize knl]
		button 120 "Top Hat" 	[f/text: face/text clone: rcvCloneImage img1 
								rcvTopHat clone dst knlSize knl]
		button 120 "Black Hat" 	[f/text: face/text clone: rcvCloneImage img1 
								rcvBlackHat clone dst knlSize knl]	
		return 
		canvas: base 512x512 dst	
		return 
		f: field 512 "Source"
]
