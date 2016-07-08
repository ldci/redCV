Red [
	Title:   "Conversions Operators "
	Author:  "Francois Jouen"
	File: 	 %testLogical.red
	Needs:	 'View
]


; last Red Master required!

#include %../libs/redcv.red ; for red functions
margins: 10x10
img1: rcvLoadImage %../images/lena.jpg
img2: rcvRandomImage/uniform img1/size 255.255.255 ;
dst:  rcvCreateImage img1/size


; ***************** Test Program ****************************
view win: layout [
		title "Conversion Tests"
		origin margins space margins
		button 50 "Source" [rcvConvert img1 dst 0]
		button 50 "Gray 1" [rcv2Gray/average img1 dst]
		button 50 "Gray 2" [rcv2Gray/luminosity img1 dst]
		button 50 "Gray 3" [rcv2Gray/lightness img1 dst]
		button 50 "BGR" [rcv2BGRA img1 dst]
		button 50 "RGB" [rcv2RGBA img1 dst ]
		button 50 "BW" [rcv2BW img1 dst]
		button 90 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2 
							rcvReleaseImage dst 
							Quit]
		return 
		canvas: base 512x512 dst
		do [rcvConvert img1 dst 0]
]