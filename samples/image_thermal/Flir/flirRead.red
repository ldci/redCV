#! /usr/local/bin/red
Red [
	Title:   "Flir"
	Author:  "Francois Jouen"
	File: 	 %flirRead.red
	needs:   view
]

; required libs
#include %../../../libs/thermal/Flir/rcvFlir.red

flirFile: 	none
isSorted?: 	false

loadImage: does [
	tmp: request-file 
	if not none? tmp [
		clear tempList/data
		clear f0/text
		clear f1/text
		clear f2/text
		cb/data: false
		canvas1/image: canvas2/image: none
		canvas3/image: canvas4/image: none
		do-events/no-wait
		flirFile: to-string tmp	
		rcvGetFlirMetaData flirFile 		
		canvas1/image: load tmp
		canvas2/image: rcvGetVisibleImage flirFile
		canvas3/image: rcvGetImageTemperatures flirFile
		canvas4/image: rcvGetFlirPalette flirFile
		f0/text: form canvas1/image/size
		f1/text: form canvas2/image/size
		f2/text: form canvas3/image/size
	]
]

getTemperatures: does [
	clear tempList/data
	tempBlock: rcvGetTemperatureAsBlock flirFile
	blk: make block! []		
	repeat i length? tempBlock [append blk form round/to tempBlock/:i 0.01]
	if isSorted? [sort blk]
	tempList/data: blk
]

view layout [
	title "Thermal Images Reader"
	button "Load" 	[loadImage]
	pad 750x0
	cb: check 150 "Show Temperatures" false [
		do-events/no-wait
		unless face/data [clear tempList/data]
		if face/data [getTemperatures]
	]
	pad 40x0
	button "Quit" 	[rcvCleanThermal quit]
	return
	canvas1: base 320x240
	canvas2: base 320x240
	canvas3: base 320x240
	tempList: text-list 100x240 data []
	return
	canvas4: base 220x20 f0: field 90
	text 220 "Visible RGB Image" f1: field 90
	text 220 "Grayscale Temperature Image" f2: field 90
	text 100 "Temperatures"
]


