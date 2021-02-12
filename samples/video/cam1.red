Red [
	Title:   "Test camera Red VID "
	Author:  "Francois Jouen"
	File: 	 %camera.red
	Needs:	 'View
]
;'
iSize: 320x240
margins: 10x10
cam: none ; for camera object

view win: layout [
		title "Red Camera"
		origin margins space margins
		tF: field 100 on-time [face/text: form now/time ] 
				
		pad 160x0
		btnQuit: button "Quit" 50 on-click [quit]
		return
		cam: camera iSize  black 
		return
		
		cam-list: drop-list 220 on-create [face/data: cam/data]
		onoff: button "Start/Stop" on-click [
				either cam/selected [
					cam/selected: none
					tF/rate: none
					
				][
					cam/selected: cam-list/selected
					tF/rate: 0:0:0.04;  max 1/25 fps in ms
					]
		]
		do [cam-list/selected: 1 tF/rate: none]
]