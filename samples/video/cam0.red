#!/usr/local/bin/red-view
Red [
	Title:   "Test camera Red VID "
	Author:  "ldci"
	File: 	 %cam0.red
	Needs:	 View
]

camSize: 1280x720 			;default Apple FaceTime Camera size
iSize: camSize / 2
margins: 10x10
cam: none ; for camera object

view win: layout [
		title "Red Camera"
		origin margins space margins
		cam: camera iSize
		return
		cam-list: drop-list 220 on-create [face/data: cam/data]
		toggle 90 "Start" false [	
			either cam/selected [cam/selected: none face/text: "Start"]
								[cam/selected: cam-list/selected  face/text: "Stop"]	
		] 		
		pad 240x0 button "Quit" 50 [quit]
		do [cam-list/selected: 1 cam/selected: none]
]