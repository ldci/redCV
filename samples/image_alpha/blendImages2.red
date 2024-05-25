Red [
	Title:   "Blend Operator "
	Author:  "Francois Jouen"
	File: 	 %blendImages2.red
	Needs:	 'View
]

;--this version uses rcvSetIntensity and not rcvBlend
;required libs
#include %../../libs/core/rcvCore.red

iSize: 512x512						;--fix image size
margins: 10x10						;--comstetics
img1: rcvCreateImage iSize			;--create image
img2: rcvCreateImage iSize			;--create image
dst:  rcvCreateImage iSize			;--create image
tmp1: rcvCreateImage iSize			;--create image
tmp2: rcvCreateImage iSize			;--create image
alpha: 0.5

loadImage: function [
	return: [image!]]
[
	tmp: request-file
	unless none? tmp [
		img0: rcvLoadImage tmp			;--load original image
		img:  rcvResizeImage img0 iSize	;--and resize
	]
	img
]



blending: function [] [
	rcvSetIntensity img1 tmp1 alpha 		;--set intensity for the first image
	rcvSetIntensity img2 tmp2  1.0 - alpha	;--set intensity for the second image 
	rcvAdd tmp1 tmp2 dst					;--add the result
]


; ***************** Test Program ****************************
view win: layout [
		;--you need 2 images 
		
		title "Blend Operator Test"
		bt1: button "Load Image 1" [img1: loadImage b1/image: img1 
									blending
									canvas/image: dst
		]
		b1: base 64x64 img1
		bt2: button "Load Image 2" [img2: loadImage b2/image: img2
									blending
									canvas/image: dst
		]
		
		b2: base 64x64 img2
		pad 50x0
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2 
							rcvReleaseImage dst 
							rcvReleaseImage tmp1
							rcvReleaseImage tmp2
							Quit
		]
		return
		pad 120x0
		f1: field 64 "0.5"
		sl: slider 107 [alpha: face/data * 1.0
					f1/text: form round/to alpha 0.001
					f2/text: form round/to (1 - alpha) 0.001
					blending
					canvas/image: dst
					] 
		f2: field 64  "0.5"
		return
		canvas: base iSize dst
		return
		text 512 center "© Red Foundation 2019-2024"
		do [sl/data: alpha ]
]
