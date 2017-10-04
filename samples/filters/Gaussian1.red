Red [
	Title:   "Gaussian Filter test"
	Author:  "Francois Jouen"
	File: 	 %Gaussian1.red
	Needs:	 'View
]


; last Red Master required!
#include %../../libs/redcv.red ; for red functions
margins: 10x10
img1: rcvCreateImage 512x512
dst: rcvCreateImage 512x512

loadImage: does [
	canvas/image/rgb: black
	canvas/size: 0x0
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-local-file tmp
		win/text: fileName
		img1: rcvLoadImage tmp
		currentImage: rcvCloneImage img1
		dst:  rcvCloneImage img1
		; update faces
		if img1/size/x >= 512 [
			win/size/x: img1/size/x + 20
			win/size/y: img1/size/y + 90
		] 
		canvas/size/x: img1/size/x
		canvas/size/y: img1/size/y
		canvas/offset/x: (win/size/x - img1/size/x) / 2
		canvas/image: dst
	]
]



	  
; ***************** Test Program ****************************
view win: layout [
		title "Gaussian 2D Filter"
		button 60 "Load" 		[loadImage]
		
		button 80 "No Filter" 	[rcvCopyImage img1 dst 
								 rcvCopyImage img1 currentImage]						    								
		button 80 "Filter +"	[rcvGaussianFilter currentImage dst
								rcvCopyImage dst currentImage]					
		button 80 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		
		return
		canvas: base 512x512 dst	
]
