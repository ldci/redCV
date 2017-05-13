Red [
	Title:   "Conversions Operators "
	Author:  "Francois Jouen"
	File: 	 %Conversion.red
	Needs:	 'View
]


; last Red Master required!

#include %../../libs/redcv.red ; for redCV functions
margins: 5x5
img1: rcvLoadImage %../../images/lena.jpg
img2: rcvRandomImage/uniform img1/size 255.255.255 ;
dst:  rcvCreateImage img1/size

seuil: 32
; ***************** Test Program ****************************
view win: layout [
		title "Conversion Tests"
		origin margins space margins
		button 80 "Source" 		[rcvCopyImage img1 dst]
		button 80 "Gray 1" 		[rcv2Gray/average img1 dst]
		button 80 "Gray 2" 		[rcv2Gray/luminosity img1 dst]
		button 80 "Gray 3" 		[rcv2Gray/lightness img1 dst]
		button 80 "BGR" 		[rcv2BGRA img1 dst]
		button 80 "RGB" 		[rcv2RGBA img1 dst ]
		button 80 "BW" 			[rcv2BW img1 dst]
		button 50 "BW Filter" 	[rcv2BWFilter img1 dst 32]
		
		button 50 "Quit" 		[
									rcvReleaseImage img1 
									rcvReleaseImage img2 
									rcvReleaseImage dst 
									Quit
								]
		return 
		button 80 "Source" 			[rcvCopyImage img1 dst]
		button 80 "RGBXYZ"			[rcvRGB2XYZ img1 dst]
		button 80 "BGRXYZ"			[rcvBGR2XYZ img1 dst]
		button 80 "RGBHSV" 			[rcvRGB2HSV img1 dst]
		button 80 "BGRHSV" 			[rcvBGR2HSV img1 dst]
		button 80 "RGBHLS"			[rcvRGB2HLS img1 dst]
		button 80 "BGRHLS"			[rcvBGR2HLS img1 dst]
		button 50 "RGBYCC"			[rcvRGB2YCrCb img1 dst]
		button 50 "BGRYCC"			[rcvBGR2YCrCb img1 dst]	
		
		return 
		button 80 "Source" 			[rcvCopyImage img1 dst]
		button 80 "RGBLab"			[rcvRGB2Lab img1 dst]
		button 80 "BGRLab"			[rcvBGR2Lab img1 dst]
		button 80 "RGBLuv"			[rcvRGB2Luv img1 dst]
		button 80 "BGRLuv"			[rcvBGR2Luv img1 dst]
		
		return 
		canvas: base 512x512 dst
		do [rcvCopyImage img1 dst]
]