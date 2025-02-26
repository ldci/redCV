Red [
	Title:   "Conversions Operators "
	Author:  "ldci"
	File: 	 %Conversion.red
	Needs:	 'View
]


;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/imgproc/rcvColorSpace.red

kernel: make vector! [
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
	unless none? tmp [
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
		button  "Load Image"		[loadImage]
		f: base 100x22 white
		button 80 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return
		canvas: base 512x512 dst
		below
		;from core
		button 80 "Gray 1" 		[rcv2Gray/average img1 dst f/text: "Gray 1"]	;--OK
		button 80 "Gray 2" 		[rcv2Gray/luminosity img1 dst f/text: "Gray 2"]	;--OK
		button 80 "Gray 3" 		[rcv2Gray/lightness img1 dst f/text: "Gray 3"]	;--OK
		button 80 "BGR" 		[rcv2BGRA img1 dst f/text: "BGR"]				;--OK
		button 80 "RGB" 		[rcv2RGBA img1 dst f/text: "RGB"]				;--OK
		button 80 "BW" 			[rcv2BW img1 dst f/text: "BW"]					;--OK
		button 80 "BW Filter" 	[rcv2BWFilter img1 dst 64 f/text: "BW Filter"]	;--OK
		;from colorspace
		button 80 "RGB2XYZ"		[rcvRGB2XYZ img1 dst f/text: "RGB2XYZ"]			;--OK
		button 80 "BGR2XYZ"		[rcvBGR2XYZ img1 dst f/text: "GBR2XYZ"]			;--OK
		button 80 "RGB2HSV" 	[rcvRGB2HSV img1 dst f/text: "RGB2HSV"]			;--TBI
		button 80 "BGR2HSV" 	[rcvBGR2HSV img1 dst f/text: "BGR2HSV"]			;--TBI
		return 
		pad 0x33
		button 80 "RGB2HLS"		[rcvRGB2HLS img1 dst f/text: "RGB2HSL"]			;--OK
		button 80 "BGR2HLS"		[rcvBGR2HLS img1 dst f/text: "BGR2HSL"]			;--OK
		button 80 "RGB2YCC"		[rcvRGB2YCrCb img1 dst f/text: "RGB2YCC"]		;--OK
		button 80 "BGR2YCC"		[rcvBGR2YCrCb img1 dst f/text: "BGR2YCC"]		;--OK
		
		button 80 "RGB2Lab"		[rcvRGB2Lab img1 dst f/text: "RGB2Lab"]			;--OK
		button 80 "BGR2Lab"		[rcvBGR2Lab img1 dst f/text: "BGR2Lab"]			;--OK
		button 80 "RGB2Luv"		[rcvRGB2Luv img1 dst f/text: "RGB2Luv"]			;--OK
		button 80 "BGR2Luv"		[rcvBGR2Luv img1 dst f/text: "BGR2Luv"]			;--OK
		button 80 "IR2GBY"		[rcvIRgBy 	img1 dst 1 f/text: "IR2GBY"]		;--OK
		button 80 "IR2RGB"		[rcvIR2RGB 	img1 dst kernel 1 f/text: "IR2RGB"]	;--OK
		button 80 "Source" 		[rcvCopyImage img1 dst f/text: "Source" ]
]