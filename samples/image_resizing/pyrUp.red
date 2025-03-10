Red [
	Title:   "Pyramidal test"
	Author:  "ldci"
	File: 	 %pyrUp.red
	Needs:	 'View
]

#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgEffect.red

margins: 5x5
iSize: 512x512					 
src: rcvCreateImage iSize
dst: rcvCreateImage iSize
cpi: rcvCreateImage iSize
isFile?: false

loadImage: does [
	isFile?: false
	tmp: request-file
	unless none? tmp [
		canvas/image: none
		src: rcvLoadImage tmp
		src: rcvResizeImage src 128x128 ;--we force 128x128 image/size for tests
		cpi: copy src
		dst: copy src
		iSize: src/size
		canvas/size: iSize
		canvas/image: dst
		f/text: form dst/size
		isFile?: true
	]
]

showResult: does [
	;--no size limit
	canvas/image: dst
	canvas/size: dst/size
	f/text: form dst/size
	src: copy dst
]

showSource: does [
	canvas/size: cpi/size
	f/text: form cpi/size
	canvas/image: cpi
	src: copy cpi
]

; ***************** Test Program ****************************
view win: layout [
		title "Pyramidal Upsizing"
		button 80 "Load" 		[loadImage]		    					    								
		button 80 "Pyr Up"		[if isFile? [dst: rcvPyrUp src 2 showResult]]	
		button 80 "Source" 		[if isFile? [showSource]]									    
		f: base 80x20 white	center	
		pad 70x0				
		button 60 "Quit" 		[rcvReleaseImage src rcvReleaseImage dst rcvReleaseImage cpi Quit]
		return
		canvas: base iSize dst		
]