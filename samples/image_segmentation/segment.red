Red [
	Title:   "Red Computer Vision: K Means Segmentation"
	Author:  "ldci"
	File: 	 %segment.red
	Tabs:	 4
	Rights:  "Copyright (C) 2019 ldci. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
	Needs:	 View
]

#include %../../libs/core/rcvCore.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/matrix/rcvMatrix.red

iSize: 512x512
nK: 3
nPoints: 0
bins: copy []
maxV: 16777215; (0 << 24) OR (255 << 16 ) OR (255 << 8) OR 255
isFile: false

loadImage: does [
	tmp: request-file
	if not none? tmp [
		img: rcvLoadImage tmp
		canvas1/image: img
		canvas2/image: none
		dst: rcvCreateImage img/size
		mat:  matrix/init 2 32 img/size	;-- integer matrix
		mat2:  matrix/init 2 32 img/size
		nPoints: length? mat/data
		rcvImage2Mat32 img mat	
		isFile: true
		segmentImage
	]
]

segmentImage: does [
	i: 1
	clear bins
	repeat i (nk + 1) [append bins 0]			;--create histogram
	i: 1
	step: to-integer (maxV / nK)				;--scale step
	while [i <= nPoints][
		vf: absolute mat/data/:i / maxV			;--color position in 32-bit scale 
		v: to-integer round vf * to-float nK	;--bin class number according to nK
		v: v + 1								;--1-based 
		bins/:v: bins/:v + 1					;--increment number of bins in bin class
		idx: step * (v - 1)						;--color index in reduced scale
		mat2/data/:i: 0 - idx					;--reduced color
		i: i + 1
	]
	rcv32Mat2Image mat2 dst
	canvas2/image: dst
]


;******************** Main Program *********************************
mainWin: layout [
	title "redCV: Image Segmentation"
	button "Load Image" [loadImage]
	text  "Number of clusters" 
	sl: slider 300 [
		nk: 1 + to-integer face/data * 255	
		f1/text: form nk
	]
	
	
	f1: field 50 "3" [if error? try [nK: to-integer face/text] [nK: 3 face/text: form nK]
						if isFile [segmentImage]]
	button "Segmentation" [segmentImage]				
	button "Quit" [Quit]
	return
	canvas1: base iSize black canvas2: base iSize black
]

view mainWin