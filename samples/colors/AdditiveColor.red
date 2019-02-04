Red [
	Title:   "Color tests "
	Author:  "Francois Jouen"
	File: 	 %AdditiveColor.red
	Needs:	 'View
]

#include %../../libs/redcv.red ; for redCV functions
margins: 5x5

img1: rcvCreateImage 256x256
img2: rcvCreateImage 256x256
dst: rcvCreateImage 256x256
rcvColorImage img1 red
rcvColorImage img2 blue

view win: layout [
	title "Additive color"
	origin margins space margins
	dp1: drop-down 100
			data ["red" "green" "blue"] 
			select 1
			on-change [set 'color to-word face/text rcvColorImage img1 reduce color
			]

	pad 156x0
	dp2: drop-down 100
			data ["red" "green" "blue" ] 
			select 3
			on-change [set 'color to-word face/text  rcvColorImage img2 reduce color]
	
	pad 150x0
	button "+" [rcvAdd img1 img2 dst] 
	pad 100x0
	button 80 "Quit" [	rcvReleaseImage img1 
						rcvReleaseImage img2 
						rcvReleaseImage dst 
						Quit]
	return
	bb1: base 256x256 img1
	bb2: base 256x256 img2
	bb3: base 256x256 dst
]
	
	
	 