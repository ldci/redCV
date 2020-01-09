Red [
	Title:   "Simple Canny Subtraction Filter "
	Author:  "Francois Jouen"
	File: 	 %canny1.red
	Needs:	 'View
]

;A basic Canny filter by subtraction (smoothed image - original image)
;it's works because Gaussian filter + delta function Å Laplacian of Gaussian

; required libs
#include %../../../libs/tools/rcvTools.red
#include %../../../libs/core/rcvCore.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/imgproc/rcvImgProc.red

margins: 10x10
defSize: 512x512
img1: rcvCreateImage defSize
img2: rcvCreateImage defSize
dst:  rcvCreateImage defSize
gray: rcvCreateImage defSize

knl: rcvMakeGaussian 3x3 1.0 ; default 
delta: 0.0
isFile: false
gScale: false

loadImage: does [
    isFile: false
    canvas1/image: none
	canvas2/image: none
	sl/data: 0%
	delta: 0.0
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: fileName
		img1: rcvLoadImage tmp
		img2: rcvCloneImage img1
		gray: rcvCloneImage img1
		dst:  rcvCloneImage img1
		rcv2Gray/average img1 gray 
		canvas1/image: img1
		process
		isFile: true
	]
]


process: does [
	either gScale [rcvFilter2D gray img2 knl 1.0 delta rcvSub img2 gray dst]
				  [rcvFilter2D img1 img2 knl 1.0 delta rcvSub img2 img1 dst]
	canvas2/image: dst	 
]


; ***************** Test Program ****************************
view win: layout [
		title "Simple Canny Filter by Subtraction"
		origin margins space margins
		button 60 "Load" 	[loadImage]	
		check "Grayscale" 	[gScale: face/data process]	
		text "Kenel size" 
		drop-down 50 data ["3x3" "5x5" "7x7" "9x9"] 
			on-change [
				case [
						face/selected = 1 [knl: rcvMakeGaussian 3x3 1.0]
						face/selected = 2 [knl: rcvMakeGaussian 5x5 1.0]
						face/selected = 3 [knl: rcvMakeGaussian 7x7 1.0]
						face/selected = 4 [knl: rcvMakeGaussian 9x9 1.0]
				]
				process
						
			]
			select 1
							
		sl: slider 330		[if isFile [
								delta: to float! sl/data * 64.0
								vf/data: form delta
								process
							]
		]
		vf: field 50 "0.0"						
		button 50 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage img2
								rcvReleaseImage gray
								rcvReleaseImage dst Quit]
		return
		canvas1: base 256x256 img1
		canvas2: base defSize dst	
]
