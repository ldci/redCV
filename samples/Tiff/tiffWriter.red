Red [
	Title:   "TIFF"
	Author:  "Francois Jouen"
	File: 	 %tiffWriter.red
	Needs:	 View
]

#include %../../libs/redcv.red ; for red functions

; **************test program variables and functions*********
dSize: 512
gsize: as-pair dSize dSize
img: make image! reduce [gSize black]
isFile: false
mode: 1 ; Intel little endian for Tiff writing


loadImage: does [
	isFile: false
	tmp: request-file
	if not none? tmp [
		img: rcvLoadImage tmp
		canvas1/image: img
		isFile: true
	]
]

writeTiff: does [
	tmp: request-file/save
	if not none? tmp [
		rcvSaveTiffImage img tmp mode
		ret: rcvLoadTiffImage tmp
		canvas2/image: rcvTiff2RedImage 
	]
]


view win: layout [
	title "Red to TIFF Image writing"
	button 100 "Load Image" 	[loadImage]	
	button 100 "Write Tiff" 	[if isFile [writeTiff]]		
	pad 730x0
	button 70 "Quit" 			[Quit]
	return
	text dSize "Red Source Image"
	text dSize "24-bit Tiff Converted Image"
	return
	canvas1:  base gsize img
	canvas2:  base gsize img	
]
