Red [
	Title:   "Blend Operator "
	Author:  "ldci"
	File: 	 %blendImages4.red
	Needs:	 'View
]

;--this version is similar to blendImages3.red but uses rcvAlphaBlend routine

; required libs
#include %../../libs/core/rcvCore.red

iSize: 1000x704; 
iSize2: 500x352
margins: 10x10
img1: 	rcvCreateImage iSize
img2: 	rcvCreateImage iSize
dst:  	rcvCreateImage iSize

loadImage: function [ 
	return: [image!]]
[
	tmp: request-file
	if not none? tmp [
		img0: rcvLoadImage tmp
		img:  rcvResizeImage img0 iSize
	]
	img
]


; ***************** Test Program ****************************
view win: layout [
		title "Blend Operator Test"
		text "Images" 
		button 125 "Background" 
		[img1: loadImage canvas/image: img1]
		button 125 "Foreground" 
		[img2: loadImage 
		 rcvAlphaBlend img1 img2 dst
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
