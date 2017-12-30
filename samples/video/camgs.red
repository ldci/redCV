#! /usr/local/bin/red
Red [
	Title:   "Test camera Red VID "
	Author:  "Francois Jouen"
	File: 	 %camera.red
	Needs:	 'View
]
{'}

#include %../../libs/redcv.red ; for red functions
iSize: 320x240
margins: 10x10
cam: none ; for camera
src: rcvCreateImage iSize
d1: rcvCreateImage iSize
d2: rcvCreateImage iSize
threshold: 127


view win: layout [
		title "Red Binary Cam"
		origin margins space margins
		sl1: slider 270 [filter/text: form to-integer sl1/data * 255  threshold: to integer! filter/data ]
		filter: field 40  
		text "Camera size " cSize: field 100
		pad 60x0
		btnQuit: button "Quit" 60x24 on-click [quit]
		return
		cam: camera iSize
		canvas: base 320x240 white on-time [
					canvas/text: form now/time/precise 
					rcv2gray/average to-image cam d1
					rcvThreshold/binary d1 d2 threshold 255
					canvas/image: d2
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
					canvas/text: ""
				][
					cam/selected: cam-list/selected
					src: to-image cam
					cSize/text: form src/size
					d1: d2: src
					canvas/rate: 0:0:0.04;  max 1/25 fps in ms
				]
		]
		do [cam-list/selected: 1 canvas/rate: none 
			canvas/para: make para! [align: 'right v-align: 'bottom]
			sl1/data: 0.5
			filter/text: form threshold
		]
]