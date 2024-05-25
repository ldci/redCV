Red [
	Title:   "Blend Operator "
	Author:  "Francois Jouen"
	File: 	 %intensity.red
	Needs:	 'View
]


#include %../../libs/core/rcvCore.red

margins: 10x10
defSize: 512x512
img1: rcvCreateImage defSize
dst:  rcvCreateImage defSize
isFile: false
alpha: 1.0


loadImage: does [
    isFile: false
	canvas/image/rgb: black
	sl/data: 50% 
	tmp: request-file
	unless none? tmp [
		fileName: to string! to-file tmp
		win/text: fileName
		img1: rcvLoadImage tmp
		dst:  rcvCloneImage img1
		isFile: true
		alpha: 1.0
		sl/data: 0.5
		rcvSetIntensity img1 dst alpha
		canvas/image: dst
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Image intensity"
		button "Load Image" [loadImage] 
		
							
		sl: slider 256 [alpha: face/data * 2.0
						f1/text: form round/to alpha 0.001
						rcvSetIntensity img1 dst alpha
					]
		f1: field 50 "1.0"
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage dst 
							Quit]
		return
		canvas: base 512x512 dst
		do [sl/data: 50%]
]
