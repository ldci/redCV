Red [
	Title:   "Channel tests "
	Author:  "Francois Jouen"
	File: 	 %SplitChannels.red
	Needs:	 'View
]
; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
img1: rcvLoadImage %../../images/baboon.jpg
dst: rcvCreateImage img1/size

; ***************** Test Program ****************************
view win: layout [
		title "RGB Channels Test"
		origin margins space margins
		button 60 "Source"	[_rcvChannel img1 dst 0]	; routine
		button 60 "Red"  	[rcvSplit/red img1 dst]
		button 60 "Green"	[rcvSplit/green img1 dst]
		button 60 "Blue"  	[rcvSplit/blue img1 dst]
		button 60 "Alpha"  	[rcvSplit/alpha img1 dst]
		button 60 "Quit" 	[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return 
		canvas: base 512x512 dst	
		do [_rcvChannel img1 dst 0]
]