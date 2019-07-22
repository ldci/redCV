Red [
	Title:   "Gaussian Filter test"
	Author:  "Francois Jouen"
	File: 	 %Gaussian1.red
	Needs:	 'View
]


; last Red Master required!
#include %../../../libs/redcv.red ; for red functions
margins: 10x10
img1: rcvCreateImage 512x512
dst: rcvCreateImage 512x512
count: 0

loadImage: does [
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: fileName
		img1: rcvLoadImage tmp
		currentImage: rcvCloneImage img1
		dst:  rcvCloneImage img1
		canvas/image: dst
	]
]



	  
; ***************** Test Program ****************************
view win: layout [
		title "Gaussian 2D Filter"
		button 60 "Load" 		[loadImage]
		
		button 80 "No Filter" 	[count: 0 f/text: form count
								rcvCopyImage img1 dst 
								 rcvCopyImage img1 currentImage]						    								
		button 80 "Filter +"	[rcvGaussianFilter currentImage dst 3x3 2.0
								rcvCopyImage dst currentImage
								count: count + 1 f/text: form count
								]		
		f: field 50	"0"				
		button 80 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		
		return
		canvas: base 512x512 dst	
]
