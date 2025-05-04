Red [
	Title:   "Blend Operator "
	Author:  "ldci"
	File: 	 %blendImages1.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red


iSize: 512x512							;--fix image size
margins: 10x10							;--cosmetics
img1: rcvCreateImage iSize				;--create image 1	
img2: rcvCreateImage iSize				;--create image 2
dst:  rcvCreateImage iSize				;--create image 3
alpha: 0.5								;--0.0 to 0.5
	
loadImage: function [ 
	return: [image!]]
[
	tmp: request-file
	unless none? tmp [
		img0: rcvLoadImage tmp			;--load original image
		img: rcvResizeImage img0 iSize	;--resize image to 512x512 size
	]
	img									;--return image
]


; ***************** Test Program ****************************
view win: layout [
		title "Blend Operator Test"
		;--you need 2 images
		;--first image
		bt1: button "Load Image 1" [img1: loadImage b1/image: img1 
									rcvBlend img1 img2 dst alpha
									canvas/image: dst
		]
		b1: base 64x64 img1
		;--second image
		bt2: button "Load Image 2" [img2: loadImage b2/image: img2
									rcvBlend img1 img2 dst alpha
									canvas/image: dst
		]
		b2: base 64x64 img2
		pad 50x0
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2 
							rcvReleaseImage dst 
							Quit
		]
		return
		pad 120x0
		f1: field 64 "0.5"
		;--play with alpha factor
		sl: slider 107 [alpha: face/data * 1.0
					f1/text: form round/to alpha 0.001
					f2/text: form round/to (1 - alpha) 0.001
					rcvBlend img1 img2 dst alpha
					canvas/image: dst
					] 
		f2: field 64  "0.5"
		
		return
		canvas: base iSize dst
		return
		text 512 center "© Red Foundation 2019-2024"
		do [sl/data: alpha ]
]
