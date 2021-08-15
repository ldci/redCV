#!/usr/local/bin/red
Red [
	Title:   "Test camera Red VID "
	Author:  "Francois Jouen"
	File: 	 %cam2.red
	Needs:	 'View
]

iSize: 320x240
margins: 10x10
cam: none ; for camera object

view win: layout [
		title "Red Camera"
		origin margins space margins
		cam: camera 20x15 ;--non visible camera just to get back image 
		cb: check "recycle" true
		f: field 100
		pad 35x0 button "Quit" 50 [quit]
		return
		canvas: base iSize black on-time [
			canvas/text: form now/time 
			canvas/image: cam/image	
			cam/image: none	
			if cb/data [recycle]
			f/text: form stats
		] font-color green font-size 12
		return
		
		cam-list: drop-list 220 on-create [face/data: cam/data]
		
		toggle 90 "Start" false [	
			either cam/selected [
					cam/selected: none
					canvas/rate: none
					canvas/image: none
					face/text: "Start"
				][
					cam/selected: cam-list/selected
					canvas/rate: 0:0:0.04;  max 1/25 fps in ms
					face/text: "Stop"
					]	
		]
		do [cam-list/selected: 1 canvas/rate: none 
			canvas/para: make para! [align: 'right v-align: 'bottom] 
			cam/visible?: false
		]
]