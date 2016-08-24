Red [
	Title:   "Pyramidal test"
	Author:  "Francois Jouen"
	File: 	 %pyramidal.red
	Needs:	 'View
]


; last Red Master required!
#include %../libs/redcv.red ; for red functions
margins: 10x10
knl: rcvMakeGaussian 5x5
img1: rcvCreateImage 512x512
dst: rcvCreateImage 512x512
iSize: 0x0
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
			win/size/y: img1/size/y + 70
		] 
		iSize: img1/size
		canvas/size/x: img1/size/x
		canvas/size/y: img1/size/y
		canvas/image/size: canvas/size	
		canvas/offset/x: (win/size/x - img1/size/x) / 2
		canvas/image: dst
		f/data: form dst/size
	]
]



	  
; ***************** Test Program ****************************
view win: layout [
		title "Gaussian 2D Filter"
		button 60 "Load" 		[loadImage]
		
		button 60 "Source" 			[iSize: img1/size
									rcvCopyImage img1 dst 
								    rcvCopyImage img1 currentImage
								    canvas/size: iSize
									canvas/image: dst]	
								    					    								
		button 60 "Pyr Down"	   [rcvPyrDown/gaussian currentImage dst
									iSize: iSize / 2
									f/data: form iSize
								    rcvCopyImage dst currentImage
								    canvas/size: iSize
									canvas/image: dst
								    ]	
		button 60 "Pyr Up"	   		[rcvPyrUp/gaussian currentImage dst
									iSize: iSize * 2
									f/data: form iSize
								    rcvCopyImage dst currentImage
								    canvas/size: iSize
									canvas/image: dst
								    ]				
								    
		f: field 						
		button 80 "Quit" 			[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		
		return
		canvas: base 512x512 dst
		
			
]
