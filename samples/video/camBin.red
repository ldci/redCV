Red [
	Title:   "Test camera Red VID "
	Author:  "ldci"
	File: 	 %camBin.red
	Needs:	 'View
]
;'we need RedCV

; required libs
#include %../../libs/core/rcvCore.red

camSize: 1280x720 			;default Apple FaceTime Camera size
iSize: camSize / 4
margins: 10x10
cam: none ; for camera
src: rcvCreateImage iSize
d1: rcvCreateImage iSize
d2: rcvCreateImage iSize
threshold: 127


view win: layout [
		title "Red Binary Camera"
		origin margins space margins
		text "Camera size " cSize: field 100
		pad 120x0
		sl1: slider 200 [filter/text: form to-integer sl1/data * 255  
						threshold: to integer! filter/data  
						do-events/no-wait]
		filter: field 40  
		btnQuit: button "Quit" 60x24 on-click [quit]
		return
		cam: camera iSize
		canvas: base iSize black on-time [ 
					;cImg: cam/image
					;cImg: to-image cam
					;src: rcvResizeImage cImg iSize
					src: rcvResizeImage to-image cam iSize
					rcv2gray/average src d1
					rcvThreshold/binary d1 d2 threshold 255
					canvas/image: d2
					cam/image: none
					tf/text: form now/time/precise
					canvas/text: tf/text
					recycle
				] font-color red font-size 12
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
					canvas/text: ""
				][
					cam/selected: cam-list/selected
					;camImg: to-image cam
					;src: rcvResizeImage camImg iSize
					;cSize/text: form src/size
					;d1: d2: src
					canvas/rate: 0:0:0.04;  max 1/25 fps in ms
				]
		]
		tf: field 220
		do [cam-list/selected: 1 canvas/rate: none 
			canvas/para: make para! [align: 'right v-align: 'bottom]
			sl1/data: 0.5
			filter/text: form threshold cSize/text: form iSize
		]
]