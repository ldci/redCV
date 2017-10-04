Red [
	Title:   "Cam test 2"
	Author:  "Francois Jouen"
	File: 	 %testCam2.red
	Needs:	 'View
]

; last Red Master required!
#include %../../../libs/redcv.red ; for redCV functions
margins: 10x10
threshold: 0
size: 640x480 ;1280x960
rimg: make image! reduce [size black]
rimg2: make image! reduce [size black]

cam: 0
isActive: false
to-text: function [val][form to integer! 0.5 + 255 * any [val 0]]

view win: layout [
		title "Camera"
		origin margins space margins
		wcam: drop-down 40 
			data ["0" "1" "2"] 
			on-change [sb/text: " " sb2/text: " " cam: to integer! face/selected - 1 isActive: false]
		btnActivate: button "Activate" on-click [
		if not isActive[
			handle: createCam cam
			cSize: rcvgetCamSize cam
			sb2/text: form cSize
			rcvSetCamSize cam size
			isActive: true
			sb/text: "Camera active" 
			clear win/text
			win/text: "Camera "
			append win/text form handle
			
		]
		]
		
		btnStart: button "Start" on-click [
			if isActive [canvas/rate: 0:0:0.04]; 1/25 fps in ms		
		]
		
		btnStop: button "Stop" on-click [
			canvas/rate: none
		]
		
		btnQuit: button "Quit" on-click [
			canvas/rate: none
			rcvReleaseImage rimg
			; 	releaseCamera
			quit
		]
		return
		sl1: slider 280 [filter/text: to-text sl1/data threshold: to integer! filter/data ]
		filter: field 30 "32"
		return
		canvas: base 320x240 rimg rate 0:0:1 on-time [
			rcvGetCamImage cam rimg
			either threshold > 0.0  [rcv2BWFilter rimg rimg2 threshold canvas/image: rimg2]
									[canvas/image: rimg]
			
		]
		return
		sb: field 220
		sb2: field 90 
		do [canvas/rate: none sl1/data: 0.0 wcam/selected: 1]
]