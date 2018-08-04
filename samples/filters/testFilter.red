Red [
	Title:   "Convolution tests "
	Author:  "Francois Jouen"
	File: 	 %testFilter.red
	Needs:	 'View
]


; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 5x10
img1: rcvCreateImage 512x512
gray: rcvCreateImage img1/size
currentImage:  rcvCreateImage img1/size
dst: rcvCreateImage img1/size

factor: 1.0

noFilter: [0.0 0.0 0.0
		  0.0 1.0 0.0 
		  0.0 0.0 0.0]

removal: [-1.0 -1.0 -1.0
		  -1.0 9.0 -1.0 
		 -1.0 -1.0 -1.0]

laplacian: [-1.0 0.0 -1.0
		    0.0 4.0 0.0 
		    -1.0 0.0 -1.0]
		    
gaussian: [0.0 0.2 0.0
		   0.2 0.2 0.2 
		   0.0 0.2 0.0]
		   
sobelH: [1.0 2.0 1.0
		 0.0 0.0 0.0      		   
		-1.0 -2.0 -1.0]   
		
embossV: [0.0 -1.0 0.0
		  0.0 0.0 0.0 
		  0.0 1.0 0.0]
		  
imgList: copy []
loadImage: does [
	imgList: copy []
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-local-file tmp
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		either cb/data [currentImage: rcvCloneImage gray]
					   [currentImage: rcvCloneImage img1]
		dst:  rcvCloneImage currentImage
		canvas/image: dst
		append append append append imgList img1 gray currentImage dst
	]
]
		  
		  
; ***************** Test Program ****************************
view win: layout [
		title "2D Filter Tests"
		origin margins space margins
		button "Load Image" [loadImage]
		cb: check "Grayscale" [
			either cb/data  [currentImage: rcvCloneImage gray]
					   		[currentImage: rcvCloneImage img1]
			dst:  rcvCloneImage currentImage
			canvas/image: dst
		]
		pad 240x0
		button 80 "Quit" 	[rcvReleaseAllImages imgList quit]	
		
		
		return
		text "Fast 2D Filter (rcvFastFilter2D)"
		return
		button 80 "No Filter" 	[rcvFastFilter2D currentImage dst noFilter]
		button 80 "Laplacian" 	[rcvFastFilter2D currentImage dst laplacian]
		button 80 "Gaussian" 	[rcvFastFilter2D currentImage dst gaussian]
		button 80 "Sobel H" 	[rcvFastFilter2D currentImage dst sobelH]
		button 60 "Mean" 		[rcvFastFilter2D currentImage dst removal]
		button 80 "Emboss"	 	[rcvFastFilter2D currentImage dst embossV]
		return 
		text "2D Filter (rcvFilter2D)"
		return
		button 80 "No Filter" 	[rcvFilter2D currentImage dst noFilter 0]
		button 80 "Laplacian" 	[rcvFilter2D currentImage dst laplacian 128]
		button 80 "Gaussian" 	[rcvFilter2D currentImage dst gaussian 0]
		button 80 "Sobel H" 	[rcvFilter2D currentImage dst sobelH 127]
		button 60 "Mean" 		[rcvFilter2D currentImage dst removal 0]
		button 80 "Emboss" 		[rcvFilter2D currentImage dst embossV 127]
		return 
		text "Convolution (rcvConvolve)" 
		text "Factor" 50
		f: field 100 "1.0" [
			if error? try [factor: to-float f/text] [factor: 1.0]
		]
		return
		button 80 "No Filter" 	[rcvConvolve currentImage dst noFilter 1.0 0.0]
		button 80 "Laplacian" 	[rcvConvolve currentImage dst laplacian  factor 128.0]
		button 80 "Gaussian" 	[rcvConvolve currentImage dst gaussian factor 0.0]
		button 80 "Sobel H" 	[rcvConvolve currentImage dst sobelH factor 127.0 ]
		button 60 "Mean" 		[rcvConvolve currentImage dst removal factor 0.0]
		button 80 "Emboss" 		[rcvConvolve currentImage dst embossV factor 127.0]
		return
		canvas: base 512x512 dst
]
