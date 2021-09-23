Red [
	Title:   "Conversions Operators "
	Author:  "Francois Jouen"
	File: 	 %Conversion.red
	Needs:	 'View
]


;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/imgproc/rcvColorSpace.red

mat: make vector! [
	0.1 0.9 0.0 
	0.3 0.0 0.7
	0.1 0.1 0.8
]

margins: 5x5
img1: rcvCreateImage 512x512
dst:  rcvCreateImage img1/size

loadImage: does [
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		dst:  rcvCloneImage img1
		canvas/image: dst
	]
]
	


; ***************** Test Program ****************************
view win: layout [
		title "Conversion Tests"
		origin margins space margins
		across
		button 80 "Load"		[loadImage]
		button 80 "Source" 		[rcvCopyImage img1 dst]
		button 80 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return
		canvas: base 512x512 dst
		below
		;from core
		button 80 "Gray 1" 		[rcv2Gray/average img1 dst]
		button 80 "Gray 2" 		[rcv2Gray/luminosity img1 dst]
		button 80 "Gray 3" 		[rcv2Gray/lightness img1 dst]
		button 80 "BGR" 		[rcv2BGRA img1 dst]
		button 80 "RGB" 		[rcv2RGBA img1 dst ]
		button 80 "BW" 			[rcv2BW img1 dst]
		button 80 "BW Filter" 	[rcv2BWFilter img1 dst 32]
		;from colorspace
		button 80 "RGBXYZ"		[rcvRGB2XYZ img1 dst]
		button 80 "BGRXYZ"		[rcvBGR2XYZ img1 dst]
		button 80 "RGBHSV" 		[rcvRGB2HSV img1 dst]
		button 80 "BGRHSV" 		[rcvBGR2HSV img1 dst]
		button 80 "RGBHLS"		[rcvRGB2HLS img1 dst]
		button 80 "BGRHLS"		[rcvBGR2HLS img1 dst]
		button 80 "RGBYCC"		[rcvRGB2YCrCb img1 dst]
		button 80 "BGRYCC"		[rcvBGR2YCrCb img1 dst]	
		return 
		pad 0x35
		button 80 "RGBLab"		[rcvRGB2Lab img1 dst]
		button 80 "BGRLab"		[rcvBGR2Lab img1 dst]
		button 80 "RGBLuv"		[rcvRGB2Luv img1 dst]
		button 80 "BGRLuv"		[rcvBGR2Luv img1 dst]
		button 80 "IRgBy"		[rcvIRgBy 	img1 dst 1]	
		button 80 "IR2RGB"		[rcvIR2RGB 	img1 dst mat 1]	
]