Red [
	Title:   "Morphological operators"
	Author:  "Francois Jouen"
	File: 	 %morpho.red
	Needs:	 'View
]


; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
img1: rcvLoadImage %../../images/baboon.jpg
clone: rcvCloneImage img1
dst:  rcvCreateImage img1/size
; shapes for SE
shape: 1
knlSize: 3x3
knl: rcvCreateStructuringElement/rectangle knlSize
it: 0
custom: [0 0 1 0 0
		 0 1 1 1 0
		 1 1 1 1 1
		 0 1 1 1 0
		 0 0 1 0 0]

; ***************** Test Program ****************************
view win: layout [
		title "Morphological Operators: Erosion & Dilatation"
		origin margins space margins
		button 60 "Source" 	[it: 0 iter/text: form it rcvCopyImage img1 dst clone: rcvCloneImage img1]									
		button 90 "Erode" 	[it: it + 1 iter/text: form it rcvErode clone dst knlSize knl rcvCopyImage dst clone]
		button 90 "Dilate" 	[it: it + 1 iter/text: form it rcvDilate clone dst knlSize knl rcvCopyImage dst clone]
		text "Iterations" 
		iter: field 30	"0"					
		button 60 "Quit" 	[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return
		text 60 "Shape" 	
		drop-down 90x30 
			data ["Cross" "Rectangle" "Custom"] 
			select 1
			on-change [shape: face/selected
			switch shape [
					1	[knl: rcvCreateStructuringElement/cross knlSize]
					2	[knl: rcvCreateStructuringElement/rectangle knlSize]
					3	[knl: copy custom knlSize: 5x5 dpk/selected: 3]
				]
			]
		text 90 "Kernel Size"
		dpk: drop-down 60x30 
			data ["3x3" "4x4" "5x5" "6x6" "7x7" "8x8" "9x9" "10x10" "11x11"]
			select 1	
			on-change [knlSize: to pair! face/text]	
		return 
		canvas: base 512x512 dst	
		do [rcvCopyImage img1 dst clone: rcvCloneImage img1 ]
]
