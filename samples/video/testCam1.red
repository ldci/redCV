#!/usr/local/bin/red-view
Red [
	Title:   "Test camera Red VID "
	Author:  "ldci"
	File: 	 %testCam1.red
	Needs:	 'View
]

camSize: 1280x720 			;default Apple FaceTime Camera size
iSize: camSize / 4
margins: 10x10
cam: none ; for camera


view win: layout [
		title "Red Binary Camera"
		origin margins space margins
		text "Camera size " cSize: field 100
		pad 380x0
		
		btnQuit: button "Quit" 60x24 on-click [quit]
		return
		cam: camera iSize
		canvas: base iSize black on-time [ 
					tf/text: form now/time/precise
					;camImg: to-image cam 	;--OK
					camImg: cam/image		;--macOS
					canvas/image: camImg
					cam/image: none			;--required when using cam/image
				]
		return
		text 60 "Camera" 
		cam-list: drop-list 250 on-create [
				face/data: cam/data
		]
		onoff: toggle 85  "Start/Stop" false [
				either cam/selected [
					cam/selected: none
					canvas/rate: none
					canvas/image: none
				][
					cam/selected: cam-list/selected
					camImg: to-image cam
					cSize/text: form camImg/size
					canvas/rate: 0:0:0.04;  max 1/25 fps in ms
				]
		]
		tf: field 220
		do [cam-list/selected: 1 canvas/rate: none ]
]