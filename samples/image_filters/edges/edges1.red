Red [
	Title:   "Simple Edges Detection Filters"
	Author:  "Francois Jouen"
	File: 	 %edges1.red
	Needs:	 'View
]

;A basic edges detection filter by subtraction (smoothed image - original image)
;it's works because Gaussian filter + delta function ≈ Laplacian of Gaussian



#include %../../../libs/redcv.red ; for redCV functions
margins: 10x10
isFile: false
iSize: 256x256
kSize: 3x3

loadImage: does [
	isFile: false
	canvas1/image: none
	canvas2/image: none
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		img2: rcvCreateImage img1/size
		dst:  rcvCreateImage img1/size
		gray: rcvCreateImage img1/size
		rcv2Gray/average img1 gray 
		rcvCopyImage gray dst
		canvas1/image: gray
		rcvGaussianFilter gray img2 kSize
		rcvSub img2 gray dst
		canvas2/image: dst
		isFile: true
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Simple edges detection by subtraction"
		origin margins space margins
		button 70 "Load" [loadImage]
		pad 365x0
		button 70 "Quit" 		[ if isFile [
									rcvReleaseImage img1 
									rcvReleaseImage img2
									rcvReleaseImage gray
									rcvReleaseImage dst ]
								Quit]
		return 
		canvas1: base iSize black	
		canvas2: base iSize black	
]
