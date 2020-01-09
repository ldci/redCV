Red [
	Title:   "TIFF"
	Author:  "Francois Jouen"
	File: 	 %tiffWriter.red
	Needs:	 View
]
; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/tiff/rcvTiff.red

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
		canvas2/image: none
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
	button 120 "Load Red Image" 	[loadImage]	
	button 100 "Write Tiff" 		[if isFile [writeTiff]]		
	pad 710x0
	button 70 "Quit" 				[Quit]
	return
	text dSize "Red Source Image"
	text dSize "24-bit Tiff Converted Image"
	return
	canvas1:  base gsize img
	canvas2:  base gsize black	
]
