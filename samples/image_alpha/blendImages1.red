Red [
	Title:   "Blend Operator "
	Author:  "Francois Jouen"
	File: 	 %blendImages1.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red

iSize: 512x512
margins: 10x10
img1: rcvCreateImage iSize
img2: rcvCreateImage iSize
dst:  rcvCreateImage iSize
alpha: 0.5

loadImage: function [ 
	return: [image!]]
[
	tmp: request-file
	if not none? tmp [
		img0: rcvLoadImage tmp
		img: rcvResizeImage img0 iSize
	]
	img
]


; ***************** Test Program ****************************
view win: layout [
		title "Blend Operator Test"
		bt1: button "Load Image 1" [img1: loadImage b1/image: img1 
									rcvBlend img1 img2 dst alpha
									canvas/image: dst
									]
		b1: base 64x64 img1
		bt2: button "Load Image 2" [img2: loadImage b2/image: img2
									rcvBlend img1 img2 dst alpha
									canvas/image: dst
									]
		
		b2: base 64x64 img2
		pad 50x0
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2 
							rcvReleaseImage dst 
							Quit]
		return
		pad 120x0
		f1: field 64 "0.5"
		sl: slider 107 [alpha: face/data * 1.0
					f1/text: form alpha
					f2/text: form (1 - alpha)
					rcvBlend img1 img2 dst alpha
					canvas/image: dst
					] 
		f2: field 64  "0.5"
		
		return
		canvas: base iSize dst
		return
		text 512 center "© Red Foundation 2019"
		do [sl/data: alpha ]
]
