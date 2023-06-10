Red [
	Title:   "Channel tests "
	Author:  "Francois Jouen"
	File: 	 %SplitChannels.red
	Needs:	 'View
]
;required libs
#include %../../libs/core/rcvCore.red

margins: 10x10
img1: make image! reduce [margins black]
dst: make image! reduce [margins black]


loadImage: does [	
	isFile: false
	canvas/image: none
	tmp: request-file 
	if not none? tmp [		
		fileName: to string! to-local-file tmp	
		img1: load tmp	
		dst: rcvCreateImage img1/size
		canvas/image: img1
		isFile: true
	]
]


; ***************** Test Program ****************************
view win: layout [
		title "RGB Channels Test"
		origin margins space margins
		button 60 "load"	[loadImage]
		button 65 "Source"	[rcvChannel img1 dst 0]	; routine
		button 60 "Red"  	[rcvSplit/red img1 dst canvas/image: dst]
		button 60 "Green"	[rcvSplit/green img1 dst  canvas/image: dst]
		button 60 "Blue"  	[rcvSplit/blue img1 dst canvas/image: dst]
		button 60 "Alpha"  	[rcvSplit/alpha img1 dst canvas/image: dst]
		button 60 "Quit" 	[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return 
		canvas: base 512x512 black
]