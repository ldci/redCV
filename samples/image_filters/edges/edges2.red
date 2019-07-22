Red [
	Title:   "Simple Canny Subtraction Filter "
	Author:  "Francois Jouen"
	File: 	 %edges2.red
	Needs:	 'View
]

;A basic edges filter by subtraction (smoothed image - original image)
;it's works because Gaussian filter + delta function Å Laplacian of Gaussian

#include %../../../libs/redcv.red ; for redCV functions
margins: 10x10
defSize: 512x512
img1: rcvCreateImage defSize
img2: rcvCreateImage defSize
dst:  rcvCreateImage defSize
gray: rcvCreateImage defSize

knl: rcvMakeGaussian 3x3 1.0 ; you can play with kernel size

delta: 0.0
isFile: false
gScale: false
gScaleLoad: false
loadImage: does [
    isFile: false
    gScaleLoad: false
	canvas/image: none
	sl/data: 0.0
	delta: 0
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: fileName
		img1: rcvLoadImage tmp
		img2: rcvCloneImage img1
		gray: rcvCloneImage img1
		dst:  rcvCloneImage img1
		if gScale [
			rcv2Gray/average img1 gray 
			rcvCopyImage gray dst
			gScaleLoad: true
		]
		canvas/image: dst
		isFile: true
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Simple Edges Detection Filter by Subtraction"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
		 
		check "Grayscale" [gScale: face/data]	
							
		sl: slider 220[ if isFile [
							delta: to float! sl/data * 255.0
							vf/data: form delta
							either gScale [
								if not gScaleLoad [rcv2Gray/average img1 gray] 
								rcvFilter2D gray img2 knl 1.0 delta
								rcvSub img2 gray dst]
								[
								rcvFilter2D img1 img2 knl 1.0 delta
								rcvSub img2 img1 dst]	 	
						]				 
		]
		
		vf: field 50 "0"						
		button 50 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage img2
								rcvReleaseImage gray
								rcvReleaseImage dst Quit]
		return 
		canvas: base 512x512 dst	
]
