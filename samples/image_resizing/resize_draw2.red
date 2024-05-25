#! /usr/local/bin/red
Red [
	Title:   "Resize tests with draw dialect "
	Author:  "Francois Jouen"
	File: 	 %resize_draw.red
	Needs:	 'View
]

; This example illustrates the use of draw for resizing images without redCV

margins: 10x10
img1: make image! 512x512
iSize: img1/size
nSize: img1/size
canvas: none
lu: 0x0				;--Left Up pixel
br: 0x0				;--botton right pixel
isFile: false
maxZoom: 1000		;--Max value for zooming
zoom: to-percent (100.0 / maxZoom)

loadImage: does [
	isFile: false
	tmp: request-file
	if not none? tmp [
		img1: load tmp
		iSize: nSize: img1/size
		sl1/data:  zoom
		sz/text: "100%"
		sz2/text: form nSize
		br: nSize
		drawBlk: compose [image (img1) (lu) (br)]
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
		pad 40x0 button 50 "Quit" [Quit]
		return 
		canvas: base iSize 
		return sz2: field 512 "512x512"
		do [sl1/data: zoom]
]