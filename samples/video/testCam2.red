#!/usr/local/bin/red-view
Red [
	Title:   "Test image operators and camera Red VID "
	Author:  "ldci"
	File: 	 %testCam2.red
	Needs:	 'View
] 
maxSize: 	1280x720; 1920x1080	;--camera max resolution (iMac M1)
cSize: 		maxSize / 3 ;--camera max resolution / n for visualization

; required libs
#include %../../libs/core/rcvCore.red	;--for rcvResizeImage routine


mainWin: layout [ 
	title "Camera test"
	cam: camera cSize  
	canvas: base black cSize
	return
	cam-list: drop-list 220 on-create [face/data: cam/data]			;--select the camera
	toggle 90 "Start" false [	
		either cam/selected 
			[cam/selected: none face/text: "Start" canvas/draw: []]
			[cam/selected: cam-list/selected face/text: "Stop"]
	]																;--start or stop the selected camera	
	button "Take snapshot" [														
		if cam/selected [
			img: to-image cam											;--get camera image
			reducedImg: rcvResizeImage img  to pair! cSize				;--downsize camera image
			canvas/draw: reduce ['image (reducedImg) 0x0 canvas/size] 	;--show the reduced snapshot
			save/as %sample.jpg reducedImg 'jpeg						;--save reduced resolution image
			save/as %samplefull.jpg img 'jpeg							;--save full resolution image
		]
	]
	button "Quit" [quit]
	do [cam-list/selected: 1 cam/selected: none]
]
view mainWin