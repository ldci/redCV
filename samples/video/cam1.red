#!/usr/local/bin/red-view
Red [
	Title:   "Test camera Red VID "
	Author:  "ldci"
	File: 	 %cam1.red
	Needs:	 'View
]

iSize: 320x240
margins: 10x10
cam: none ; 'for camera object

view win: layout [
		title "Red Camera"
		origin margins space margins
		tF: field 100 on-time [face/text: form now/time] 		
		pad 160x0 button "Quit" 50 [quit]
		return
		cam: camera iSize  
		return
		cam-list: drop-list 220 on-create [face/data: cam/data]
		toggle 90 "Start" false [	
			either cam/selected [
					cam/selected: tF/rate: none
					face/text: "Start"
				][
					cam/selected: cam-list/selected
					tF/rate: 0:0:0.04;  max 1/25 fps in ms
					face/text: "Stop"
					]	
		]
		do [cam-list/selected: 1 tF/rate: none]
]