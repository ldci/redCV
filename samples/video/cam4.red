#!/usr/local/bin/red-view
Red [
	Title:   "Test camera Red VID "
	Author:  "ldci"
	File: 	 %cam4.red
	Needs:	 'View
]
;'RedCV not required

camSize: 1280x720 			;default Apple FaceTime Camera size
iSize: camSize / 4
margins: 10x10
cam1: none ; for camera1
cam2: none ; for camera2
cam3: none ; for camera3
cam4: none ; for camera4

render: func [acam alist][
	either acam/selected [acam/selected: none]
		  [acam/selected: alist/selected]
]

view win: layout [
	title "Red 4 Cameras"
	origin margins space margins
	button 100 "All Cameras" [
		render cam1 camList1
		render cam2 camList2
		render cam3 camList3
		render cam4 camList4
	]
	
	pad 480x0 btnQuit: button "Quit" [quit]
	return
	cam1: camera iSize
	cam2: camera iSize
	return 
	camList1: drop-list 220 on-create [face/data: cam1/data]
	onoff1: button "Start/Stop" on-click [render cam1 camList1]
	camList2: drop-list 220 on-create [face/data: cam2/data]
	onoff2: button "Start/Stop" on-click [render cam2 camList2]
	return
	cam3: camera iSize
	cam4: camera iSize
	return
	camList3: drop-list 220 on-create [face/data: cam3/data]
	onoff3: button "Start/Stop"  on-click [render cam3 camList3]
	camList4: drop-list 220 on-create [face/data: cam4/data]
	onoff4: button "Start/Stop" on-click [render cam4 camList4]
	do [camList1/selected: 1 camList2/selected: 2 camList3/selected: 3 camList4/selected: 4]
]