Red [
	Title:   "Gaussian Filter test"
	Author:  "Francois Jouen"
	File: 	 %Gaussian0.red
	Needs:	 'View
]


; required libs
#include %../../../libs/tools/rcvTools.red
#include %../../../libs/core/rcvCore.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/imgproc/rcvImgProc.red


margins: 10x10
img1: rcvCreateImage 512x512
dst: rcvCreateImage 512x512
knl: [0.0 0.2 0.0 0.2 0.2 0.2 0.0 0.2 0.0]
count: 0

loadImage: does [
	canvas/image/rgb: black
	;canvas/size: 0x0
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
		
		button 80 "No Filter" 	[count: 0 f/text: form count rcvCopyImage img1 dst 
								 rcvCopyImage img1 currentImage]						    								
		button 80 "Filter +"	[rcvConvolve currentImage dst knl  1.0 0.0
								rcvCopyImage dst currentImage
								count: count + 1 f/text: form count
								]	
		f: field 50	"0"			
		button 80 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		
		return
		canvas: base 512x512 dst	
]
