Red [
	Title:   "Test image operators and camera Red VID "
	Author:  "Francois Jouen"
	File: 	 %tracking.red
	Needs:	 'View
]



; all we need for computer vision with red
#include %../../libs/redcv.red ; for red functions

iSize: 320x240
rimg: rcvCreateImage iSize
src: rcvCloneImage rimg
hsv: rcvCloneImage rimg
mask: rcvCloneImage rimg

r1: rcvCloneImage rimg
r2: rcvCloneImage rimg

margins: 10x10
threshold: 32

lower:  130.50.50
upper:  170.255.255


view win: layout [
		title "Object Detection"
		origin margins space margins
		text 320 "Source" text 320 "HSV transform" text 320 "Object tracking"
		btnQuit: button "Quit" 60x24 on-click [
			rcvReleaseImage rimg
			rcvReleaseImage hsv
			rcvReleaseImage mask
			rcvReleaseImage src
			rcvReleaseImage r1
			quit]
		return
		cam: camera iSize
		
		cmask: base 320x240 mask
		
		canvas: base 320x240 rimg rate 0:0:1 on-time [
			rcvRGB2HSV src hsv
			rcvInrange hsv mask lower upper
			rcvAnd src mask r1
			
			cmask/image: hsv
			canvas/image: r1
			src: to-image cam
		]
		
		
		return
		text 100 "Select camera" 
		cam-list: drop-list 210x32 on-create [
				face/data: cam/data
			]
		onoff: button "Start/Stop" 65x24 on-click [
				either cam/selected [
					cam/selected: none
					canvas/rate: none
					canvas/image: black
					cmask/image: black
				][
					cam/selected: cam-list/selected
					canvas/rate: 0:0:0.10;  max 1/25 fps in ms			
					]
			]
		
		do [cam-list/selected: 1 canvas/rate: none]
]
	
	


