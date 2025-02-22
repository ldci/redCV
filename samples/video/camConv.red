#! /usr/local/bin/red
Red [
	Title:   "Test camera Red VID "
	Author:  "ldci"
	File: 	 %camConv.red
	Needs:	 'View
]
;'we need RedCV

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red


camSize: 1280x720 			;default Apple FaceTime Camera size
iSize: camSize / 4
margins: 10x10
cam: none ; for camera
src: rcvCreateImage iSize
dst: rcvCreateImage iSize
threshold: 0.0

knl: [1.0 1.0 1.0 1.0 -2.0 1.0 -1.0 -1.0 -1.0] ; Robinson Filter

process: does [
	tf/text: form now/time/precise
	camImg: to-image cam
	src: rcvResizeImage camImg iSize
	rcvConvolve src dst knl 1.0 threshold
	canvas/image: dst
]

view win: layout [
		title "Red Binary Camera"
		origin margins space margins
		text "Camera size " cSize: field 100
		pad 120x0
		sl1: slider 200 [filter/text: form to-integer sl1/data * 255  
						threshold: sl1/data * 255.0  
						process]
		filter: field 40  
		btnQuit: button "Quit" 60x24 on-click [quit]
		return
		cam: camera iSize
		canvas: base iSize black on-time [process] 
		return
		text 60 "Camera" 
		cam-list: drop-list 250 on-create [
				face/data: cam/data
		]
		onoff: toggle 85 "Start/Stop" false [
				either cam/selected [
					cam/selected: none
					canvas/rate: none
					canvas/image: none
					canvas/text: ""
				][
					cam/selected: cam-list/selected
					;camImg: to-image cam
					canvas/rate: 0:0:0.04;  max 1/25 fps in ms
				]
		]
		tf: field 220
		do [cam-list/selected: 1 canvas/rate: none 
			sl1/data: 0.0
			filter/text: form threshold cSize/text: form iSize
		]
]