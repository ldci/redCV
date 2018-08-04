Red [
	Title:   "Simple Canny Filter tests "
	Author:  "Francois Jouen"
	File: 	 %Canny.red
	Needs:	 'View
]

#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
isFile: false


loadImage: does [
	isFile: false
	canvas/image: none
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		img2: rcvCreateImage img1/size
		dst:  rcvCreateImage img1/size
		gray: rcvCreateImage img1/size
		rcv2Gray/average img1 gray 
		rcvCopyImage gray dst
		canvas/image: gray
		isFile: true
	]
	
]

makeCanny: does [
	if isFile [
		rcvGaussianFilter gray img2
		rcvSub img2 gray dst
		canvas/image: dst
	]
]

showSource: does [
	if isFile [
		rcv2Gray/average img1 gray 
		rcvCopyImage gray dst
		canvas/image: dst
	]
]




; ***************** Test Program ****************************
view win: layout [
		title "Simple Canny Filter by Subtraction"
		origin margins space margins
		button 70 "Load" [loadImage]
		
		button 70 "Source" 		[showSource]	
		button 70 "Canny" 		[makeCanny]
		pad 185x0
		button 70 "Quit" 		[ if isFile [
									rcvReleaseImage img1 
									rcvReleaseImage img2
									rcvReleaseImage gray
									rcvReleaseImage dst ]
								Quit]
		return 
		canvas: base 512x512 black	
]
