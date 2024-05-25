Red [
	Title:   "Image2PGM"
	Author:  "Francois Jouen"
	File: 	 %Image2PGM.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red

isize: 512x512							;--fix image size
img1: rcvCreateImage isize				;--create image			
isFile: false

loadImage: does [
	canvas1/image/rgb: black
	tmp: request-file
	unless none? tmp [
		img1: rcvLoadImage tmp			;--load source image
		canvas1/image: img1				;--show source image
		isFile: true
	]
]

convert: does [
	if isFile [
		tmpF: request-file/save
		unless none? tmpF [
			rcvImage2PGM img1 tmpF 255
			;call rejoin ["open " form tmpF] 	;--only macOS
			result/text: read tmpF				;--all OS
		]
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Export Image to PGM"
		button "Load" 			[loadImage]
		button "Save as PGM"	[convert] 
		button 60 "Quit" 		[rcvReleaseImage img1 Quit]
		return
		canvas1: base isize img1
		result: area isize wrap
]
