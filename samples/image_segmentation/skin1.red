#!/usr/local/bin/red
Red [
	Title:   "Red Computer Vision: K Means Segmentation"
	Author:  "Francois Jouen"
	File: 	 %skin1.red
	Tabs:	 4
	Rights:  "Copyright (C) 2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
	Needs:	 View
]


#include %../../libs/objdetect/rcvSegmentation.red
threshold: 15
iSize: 512x512

loadImage: does [
	tmp: request-file
	if not none? tmp [
		img: load tmp
		dst: make image! reduce [img/size black]
		canvas1/image: img
		rcvSkinColor img dst threshold
		canvas2/image: dst	
	]
]


;******************** Main Program *********************************
mainWin: layout [
	title "redCV: Skin Color Segmentation"
	button "Load Image" [loadImage]
	text "Threshold" 
	sl: slider 100 [threshold: 1 + to-integer face/data * 63 tF/text: form threshold 
					rcvSkinColor img dst threshold]
	tF: field 50 "15" 			
	pad 600x0		
	button "Quit" [Quit]
	return
	canvas1: base iSize black canvas2: base iSize black
	do [sl/data: 24%]
]

view mainWin