Red [
	Title:   "Color tests "
	Author:  "Francois Jouen"
	File: 	 %testColor.red
	Needs:	 'View
]

;required libs
#include %../../libs/core/rcvCore.red

margins: 5x5

img1: rcvRandomImage/uniform 256x256 255.255.255
img2: rcvRandomImage/uniform 256x256 255.255.255 
dst: rcvCreateImage 256x256
color1: rcvGetPixel img1 127x127
color2: rcvGetPixel img2 127x127
color3: rcvGetPixel dst 127x127

view win: layout [
	title "© Red Foundation 2019: Color tests"
	origin margins space margins 
	button "+" [rcvAdd img1 img2 dst color3: rcvGetPixel dst 127x127 f3/text: form color3] 
	button "-" [rcvSub img1 img2 dst color3: rcvGetPixel dst 127x127 f3/text: form color3]
	button "*" [rcvMul img1 img2 dst color3: rcvGetPixel dst 127x127 f3/text: form color3]
	button "/" [rcvDiv img1 img2 dst color3: rcvGetPixel dst 127x127 f3/text: form color3]
	button "//"[rcvMod img1 img2 dst color3: rcvGetPixel dst 127x127 f3/text: form color3]
	button "%" [rcvRem img1 img2 dst color3: rcvGetPixel dst 127x127 f3/text: form color3]
	
	pad 180x0
	button 80 "Quit" 		[rcvReleaseImage img1 
							rcvReleaseImage img2 
							rcvReleaseImage dst 
							Quit]
	return
	button 256 "Generate Color 1" [img1: rcvRandomImage/uniform img1/size 255.255.255 
									color1: rcvGetPixel img1 127x127
									f1/text: form color1
									bb1/image: img1]
	button 256 "Generate Color 2" [img2: rcvRandomImage/uniform img1/size 255.255.255 
									color2: rcvGetPixel img2 127x127
									f2/text: form color2
									bb2/image: img2]
	return
	bb1: base 256x256 img1
	bb2: base 256x256 img2
	bb3: base 256x256 dst
	
	return
	f1: field 256
	f2: field 256
	f3: field 256
	
	do [f1/text: form color1 f2/text: form color2 f3/text: form color3]
]
	
	
	 