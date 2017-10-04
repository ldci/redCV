Red [
	Title:   "Maths tests "
	Author:  "Francois Jouen"
	File: 	 %testColor.red
	Needs:	 'View
]

#include %../../libs/redcv.red ; for redCV functions
margins: 5x5

img1: rcvRandomImage/uniform 256x256 255.255.255
img2: rcvRandomImage/uniform 256x256 255.255.255 ;
dst: rcvCreateImage 256x256

view win: layout [
	title "Math Operator Tests"
	origin margins space margins
	button "+" [rcvAdd img1 img2 dst] 
	button "-" [rcvSub img1 img2 dst]
	button "*" [rcvMul img1 img2 dst]
	button "/" [rcvDiv img2 img1 dst]
	button 80 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2 
							rcvReleaseImage dst 
							Quit]
	return
	bb1: base 256x256 img1
	bb2: base 256x256 img2
	bb3: base 256x256 dst
	return
	button 251 "Generate image 1" [img1: rcvRandomImage/uniform img1/size 255.255.255 bb1/image: img1]
	button 251 "Generate image 2" [img2: rcvRandomImage/uniform img1/size 255.255.255 bb2/image: img2]
]
	
	
	 