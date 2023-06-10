Red [
	Title:   "Pyramidal test"
	Author:  "Francois Jouen"
	File: 	 %resize1.red
	Needs:	 'View
]

;required libs
#include %../../libs/core/rcvCore.red


margins: 10x10
src: rcvCreateImage 512x512
dst: rcvCreateImage 512x512
iSize: 0x0
isFile: false


loadImage: does [
	isFile: false
	tmp: request-file
	if not none? tmp [
		canvas/image: none
		fileName: to string! to-file tmp
		win/text: fileName
		src: rcvLoadImage tmp
		dst: rcvLoadImage tmp
		iSize: src/size
		canvas/image: dst
		canvas/size: 256x256
		canvas/offset: 138x168
		f/text: form dst/size
		isFile: true
	]
]

showResult: func [mode [integer!]] [
	case [
		mode = 0 [canvas/size: 256x256 canvas/offset: 138x168]
		mode = 1 [canvas/size: 128x128 canvas/offset: 202x232]
		mode = 2 [canvas/size: 512x512 canvas/offset: 10x50]
	]
	canvas/image: dst
	f/text: form dst/size
]


; ***************** Test Program ****************************
view win: layout [
		title "Image Resizing"
		button 60 "Load" 		[loadImage]		    					    								
		button 80 "Size / 2"	[if isFile [dst: rcvResizeImage src src/size / 2 showResult 1]]
		button 70 "Size" 		[if isFile [dst: copy src showResult 0]]			
		button 80 "Size * 2"	[if isFile [dst: rcvResizeImage src src/size * 2  showResult 2]]								    
		f: base 80x20 white	center					
		button 60 "Quit" 		[rcvReleaseImage src rcvReleaseImage dst Quit]
		return
		canvas: base 512x512 dst		
]
