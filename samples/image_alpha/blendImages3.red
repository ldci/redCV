Red [
	Title:   "Blend Operator "
	Author:  "ldci"
	File: 	 %blendImages3.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red

iSize: 1000x704					;--fix image size
iSize2: 500x352					;--divide by 2
margins: 10x10					;--cosmetics
img1: 	rcvCreateImage iSize	;--create image
img2: 	rcvCreateImage iSize	;--create image
dst:  	rcvCreateImage iSize	;--create image

loadImage: function [ 
	return: [image!]]
[
	tmp: request-file
	unless none? tmp [
		img0: rcvLoadImage tmp
		img:  rcvResizeImage img0 iSize
	]
	img
]


; ***************** Test Program ****************************
view win: layout [
		;--we need 2 images (background and foreground)
		title "Blend Operator Test"
		text "Images" 
		button 125 "Background" 
		[img1: loadImage canvas/image: img1]
		button 125 "Foreground" 
		[img2: loadImage 
		 rcvBlend img1 img2 dst 0.0 
		 canvas/image: dst
		 ]
		
		pad 70x0
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2 
							rcvReleaseImage dst 
							Quit]
		return
		canvas: base iSize2 dst
		return
		text 500 center "© Red Foundation 2020-2024"
]
