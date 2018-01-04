#! /usr/local/bin/red
Red [
	Title:   "Test camera Red VID "
	Author:  "Francois Jouen"
	File: 	 %reccam.red
	Needs:	 View
]

iSize: 320x240
margins: 10x10
cam: none ; for camera
imgSize: 0
count: 0
cti: 0%
movie: copy []
t1: t2: now/time/precise
fn: %video.rvf
d: 0.0
fps: 0
compression: 0

; to-image seems to work only for rgb and not for argb

processCam: does [
	count: count + 1
	ct/text: form count
	if cb/data [
		img: to-image cam
		append movie img/rgb
	]
]

saveData: does [
	n: length? movie
	i: 1
	write/binary fn "RCAM"							;Four CC Red signature
	write/binary/append fn to-binary n				;Number of images
	write/binary/append fn to-binary img/size/x		;Image x size
	write/binary/append fn to-binary img/size/y		;Image y size
	write/binary/append fn to-binary d				;duration in sec
	write/binary/append fn to-binary fps			;FPS
	write/binary/append fn to-binary compression 	;compressed data (1) or not (0)
	foreach im movie [
		cti: to-percent i / to-float n
		write/binary/append fn movie/:i				;binary values
		p1/data: cti
	    i: i + 1
	]	
]



view win: layout [
		title "Red Cam"
		origin margins space margins
		cSize: field 100
		cb: check "Record Camera" true
		pad 25x0
		btnQuit: button "Quit" 60x24 on-click [quit]
		return
		ct: field 100
		button "Save" [saveData]
		p1: progress 130 
		return
		cam: camera iSize 
		return
		active: text 55 "Camera" rate 0:0:1 on-time [processCam]
		cam-list: drop-list 160 on-create [
				face/data: cam/data
		]
		onoff: button "Start/Stop" on-click [
				either cam/selected [
					t2: now/time/precise
					d: to-float t2 - t1
					fps: to-integer round count / d
					cam/selected: none
					active/rate: none
				][
					cam/selected: cam-list/selected
					active/rate: 0:0:0.04;  max 1/25 fps in ms
					img: to-image cam
					cSize/text: form img/size
					imgSize: (img/size/x * img/size/y) * 3 
					movie: copy []
					count: 0
					t1: now/time/precise
					
				]
		]
		do [cam-list/selected: 1 active/rate: none]
]