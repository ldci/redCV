#! /usr/local/bin/red
Red [
	Title:   "Test camera Red VID "
	Author:  "Francois Jouen"
	File: 	 %camera.red
	Needs:	 'View
]
;'
iSize: 320x240
margins: 10x10
cam: none ; for camera

view win: layout [
		title "Red Cam"
		origin margins space margins
		btnQuit: button "Quit" 60x24 on-click [quit]
		return
		cam: camera iSize
		canvas: base 320x240 white on-time [canvas/text: form now/time 
					canvas/image: to-image cam ;cam/image;
					] font-color red font-size: 12
		return
		text 60 "Camera" 
		cam-list: drop-list 160 on-create [
				face/data: cam/data
		]
		onoff: button "Start/Stop" on-click [
				either cam/selected [
					cam/selected: none
					canvas/rate: none
					canvas/image: none
					;canvas/color: black
					canvas/text: ""
				][
					cam/selected: cam-list/selected
					canvas/rate: 0:0:0.04;  max 1/25 fps in ms
					]
		]
		do [cam-list/selected: 1 canvas/rate: none 
			canvas/para: make para! [align: 'right v-align: 'bottom]
		]
]