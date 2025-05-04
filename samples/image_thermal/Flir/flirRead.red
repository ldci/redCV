#! /usr/local/bin/red
Red [
	Title:   "Flir"
	Author:  "ldci"
	File: 	 %flirRead.red
	needs:   view
]

; required libs
#include %../../../libs/thermal/Flir/rcvFlir.red

flirFile: 	none
isSorted?: 	false
isFile?: false

loadImage: does [
	tmp: request-file 
	isFile?: false
	if not none? tmp [
		clear tempList/data
		clear f0/text
		clear f1/text
		clear f2/text
		cb1/data: isSorted?
		canvas1/image: canvas2/image: none
		canvas3/image: canvas4/image: none
		do-events/no-wait
		flirFile: to-string tmp	
		rcvGetFlirMetaData flirFile 		
		canvas1/image: load tmp
		canvas2/image: rcvGetVisibleImage flirFile
		canvas3/image: rcvGetImageTemperatures flirFile
		canvas4/image: rcvGetFlirPalette flirFile
		b/text: CameraModel
		f0/text: form canvas1/image/size
		f1/text: form canvas2/image/size
		f2/text: form canvas3/image/size
		isFile?: true
	]
]

getTemperatures: does [
	if isFile? [ 
		clear tempList/data
		tempBlock: rcvGetTemperatureAsBlock flirFile
		blk: make block! []		
			repeat i length? tempBlock [append blk form round/to tempBlock/:i 0.01 
			;print [i tempBlock/:i ]
		]
		if isSorted? [sort blk]
		tempList/data: blk
	]
]

view layout [
	title "Thermal Images Reader"
	button "Load" 	[loadImage]
	text 60 "Camera" 
	b: base 100x21 white
	pad 410x0
	cb1: check 150 "Sort Temperatures" false [isSorted?: face/data]
	button 150 "Show Temperatures" [getTemperatures]
	pad 40x0
	button "Quit" 	[rcvCleanThermal quit]
	return
	canvas1: base 320x240				;--IR image
	canvas2: base 320x240				;--RGB image
	canvas3: base 320x240				;--Raw image
	tempList: text-list 100x240 data []	;--temperatures list
	return
	canvas4: base 220x20 				;--Palette image
	f0: base 90x21 white
	text 220 "Visible RGB Image" f1: base 90x21 white
	text 220 "Grayscale Temperature Image" f2: base 90x21 white
	text 100 "Temperatures"
]


