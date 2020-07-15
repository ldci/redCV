Red [
	Title:   "Blend Operator "
	Author:  "Francois Jouen"
	File: 	 %mask.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red

iSize: 1000x704; 
iSize2: iSize / 4

margins: 10x10
img1:	rcvCreateImage iSize
img2: 	rcvCreateImage iSize
img3:  	rcvCreateImage iSize
img4:  	rcvCreateImage iSize


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
		title "Mask Operator Test" 
		button 125 "Load" 
		[	img1: loadImage 
			canvas1/image: img1
			blk: rcvSplit2 img1
			rcvMerge blk/1 blk/1 blk/1 img2 ;--red channel only
			canvas2/image: img2
			rcv2BWFilter img2 img3 128		;--B&W filter
			canvas3/image: img3
			rcvAnd img1 img3 img4			;--result  
			canvas4/image: img4
		]
		
		pad 820x0
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2
							rcvReleaseImage img3 
							rcvReleaseImage img4
							Quit]
		return
		text 250 "Source"
		text 250 "Red channel"
		text 250 "B&W Filter"
		text 250 "Result"
		return
		canvas1: base iSize2 img1
		canvas2: base iSize2 img2
		canvas3: base iSize2 img3
		canvas4: base iSize2 img4
		return
		text 1030 center "© Red Foundation 2020"
]
