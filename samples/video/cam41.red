#! /usr/local/bin/red
Red [
	Title:   "Test camera Red VID "
	Author:  "Francois Jouen"
	File: 	 %cam41.red
	Needs:	 'View
]
;'RedCV not required

iSize: 320x240
margins: 10x10
cam1: none ; for camera1
cam2: none ; for camera2
cam3: none ; for camera3
cam4: none ; for camera4
camList1: camList2: camList3: camList4: none

render: func [acam alist][
	either acam/selected [acam/selected: none b/color: black]
		  [acam/selected: alist/selected  b/color: green]
]

renderAll: does [
	render cam1 camList1
	render cam2 camList2
	render cam3 camList3
	render cam4 camList4
]


view win: layout [
	title "Red 4 Cameras"
	origin margins space margins
	button 100 "All Cameras" [renderAll]
	b: base 20x20 black
	
	pad 460x0 btnQuit: button "Quit" [quit]
	return
	cam1: camera iSize
	cam2: camera iSize
	return 
	camList1: drop-list 320 on-create [face/data: cam1/data]
	camList2: drop-list 320 on-create [face/data: cam2/data]
	return
	cam3: camera iSize
	cam4: camera iSize
	return
	camList3: drop-list 320 on-create [face/data: cam3/data]
	camList4: drop-list 320 on-create [face/data: cam4/data]
	do [camList1/selected: 1 camList2/selected: 2 camList3/selected: 3 camList4/selected: 4]
]