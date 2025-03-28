Red [
	Title:   "Pyramidal test"
	Author:  "ldci"
	File: 	 %pyramidal.red
	Needs:	 'View
]


#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgEffect.red
#include %../../libs/imgproc/rcvGaussian.red
#include %../../libs/imgproc/rcvConvolutionImg.red

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
		;dst: rcvCloneImage src
		dst: copy src
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
		title "Pyramidal Sizing"
		button 60 "Load" 		[loadImage]		    					    								
		button 80 "Pyr Down"	[if isFile [dst: rcvPyrDown src 2 showResult 1]]
		button 70 "Source" 		[if isFile [dst: copy src showResult 0]]			
		button 80 "Pyr Up"	   	[if isFile [dst: rcvPyrUp src 2 showResult 2]]								    
		f: base 80x20 white	center					
		button 60 "Quit" 		[rcvReleaseImage src rcvReleaseImage dst Quit]
		return
		canvas: base 512x512 dst		
]
