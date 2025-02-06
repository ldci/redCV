Red [
	Title:   "Resize tests with draw dialect "
	Author:  "ldci"
	File: 	 %resize2.red
	Needs:	 'View
]

;required libs
#include %../../libs/core/rcvCore.red

margins: 10x10
img0: rcvCreateImage 512x512
img1: rcvCreateImage 512x512
img2: rcvCreateImage 512x512
iSize: img1/size
nSize: img1/size
canvas: none
isFile: false
maxZoom: 400
zoom: to-percent (100.0 / maxZoom)

loadImage: does [
	isFile: false
	tmp: request-file
	if not none? tmp [
		img0: rcvLoadImage tmp
		img1: rcvLoadImage tmp
		iSize: img1/size
		nSize: img1/size
		sl1/data:  zoom
		sz/text: "100%"
		sz2/text: form nSize
		canvas/size: iSize
		canvas/image: img1
		isFile: true
	]
]


; ***************** Test Program ****************************
view win: layout [
		title "Resize Tests"
		origin margins space margins
		button 100 "Load Image" [loadImage]
		sl1: slider 100 		[	sz/text: form to percent! (round face/data * maxZoom / 100) 
									nSize/x: to integer! isize/x * face/data * maxZoom / 100
									nSize/y: to integer! isize/y * face/data * maxZoom / 100
								 	sz2/text: form nSize
								 	if isFile [
								 		img2: rcvResizeImage img1 nSize
								 		canvas/image: img2
								 		canvas/size: nSize
								 	]
								 ]
		sz: field 80 "100%"
		sz2: field 80 "512x512"
		pad 40x0
		button 50 "Quit" 		[rcvReleaseImage img0 rcvReleaseImage img1 rcvReleaseImage img2 
								Quit]
		return 
		canvas: image 512x512 
		do [sl1/data: zoom]
]