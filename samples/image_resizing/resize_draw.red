Red [
	Title:   "Resize tests with draw dialect "
	Author:  "Francois Jouen"
	File: 	 %resize_draw.red
	Needs:	 'View
]

; This example illustrates the use of draw for resizing images.

#include %../../libs/core/rcvCore.red


margins: 10x10
img1: rcvCreateImage 512x512
iSize: img1/size
nSize: img1/size
canvas: none
lt: 0x0
br: 0x0
isFile: false
maxZoom: 1000
zoom: to-percent (100.0 / maxZoom)

loadImage: does [
	isFile: false
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		iSize: img1/size
		nSize: img1/size
		sl1/data:  zoom
		sz/text: "100%"
		sz2/text: form nSize
		br: nSize
		drawBlk: compose [image (img1) (lt) (br)]
		canvas/draw: drawBlk
		isFile: true
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Resize Tests"
		origin margins space margins
		button 100 "Load Image" [loadImage]
		sl1: slider 200 		[	sz/text: form to percent! (round face/data * maxZoom / 100) 
									nSize/x: to integer! isize/x * face/data * maxZoom / 100
									nSize/y: to integer! isize/y * face/data * maxZoom / 100
								 	sz2/text: form nSize
								 	if isFile [drawBlk/4: nSize]
								 ]
		sz: field 80 "100%"
		pad 40x0
		button 50 "Quit" 		[rcvReleaseImage img1 Quit]
		return 
		canvas: base iSize 
		return sz2: field 512 "512x512"
		do [sl1/data: zoom]
]