Red [
	Title:   "Image2PGM"
	Author:  "Francois Jouen"
	File: 	 %Image2PGM.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red

isize: 512x512

img1: rcvCreateImage isize
isFile: false

loadImage: does [
	canvas1/image/rgb: black
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		canvas1/image: img1
		isFile: true
	]
]

convert: does [
	if isFile [
		tmpF: request-file/save
		if not none? tmpF [rcvImage2PGM img1 tmpF 255
			call rejoin ["open " form tmpF]
		]
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Export Image to PGM"
		button "Load" 			[loadImage]
		button "Save as PGM"	[convert] 
		pad 260x0	 
		button 60 "Quit" 		[rcvReleaseImage img1 Quit]
		return
		canvas1: base isize img1
]
