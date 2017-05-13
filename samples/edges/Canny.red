Red [
	Title:   "Simple Canny Filter tests "
	Author:  "Francois Jouen"
	File: 	 %Canny.red
	Needs:	 'View
]


; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
img1: rcvLoadImage %../../images/lena.jpg
img2: rcvCreateImage img1/size
dst:  rcvCreateImage img1/size
gray: rcvCreateImage img1/size
knl: rcvMakeGaussian 5x5 

delta: 8

; ***************** Test Program ****************************
view win: layout [
		title "Simple Canny Filter by Subtraction"
		origin margins space margins
		button 70 "Source" 		[
			rcv2Gray/average img1 gray 
			rcvCopyImage gray dst
			]	
		 
									
		button 70 "Canny" 		[rcvGaussianFilter gray img2 knl delta
						     	rcvSub img2 gray dst
		]
		
							
		
		
		button 70 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage img2
								rcvReleaseImage gray
								rcvReleaseImage dst Quit]
		return 
		canvas: base 512x512 dst	
		do [rcv2Gray/average img1 gray rcvCopyImage gray dst]
]
