#! /usr/local/bin/red
Red [
	Title:   "Virginia"
	Author:  "ldci"
	File: 	 %align.red
	needs:   view
]

; required libs
#include %../../../libs/thermal/Flir/rcvFlir.red

flirFile: 	none

loadImage: does [
	tmp: request-file 
	unless none? tmp [
		canvas1/image: canvas2/image: none
		canvas3/image: canvas4/image: none
		clear f0/text
		clear f1/text
		clear f2/text
		clear model/text
		clear lens/text
		clear iscale/text
		do-events/no-wait
		flirFile: to-string tmp
		rcvGetFlirMetaData flirFile 
		canvas1/image: load tmp
		canvas2/image: rcvGetVisibleImage flirFile
		canvas3/image: rcvAlignImages flirFile
		canvas4/image: rcvGetFlirPalette flirFile
		f0/text: form canvas1/image/size
		f1/text: form canvas2/image/size
		f2/text: form canvas3/image/size
		model/text: CameraModel
		lens/text: LensModel
		iscale/text: form round/to imgRatio 0.01
	]
]

view layout [
	title "Thermal Images Aligment"
	button "Load" 			[loadImage]
	text "Camera Model" 
	model: field 70
	text 40 "Lens"
	lens: field 60
	text "Image Scale"
	iscale: field 
	pad 350x0
	button "Quit" 			[rcvCleanThermal quit]
	return
	canvas1: base 320x240
	canvas2: base 320x240
	canvas3: base 320x240
	return
	canvas4: base 220x20 f0: field 90
	text 220 "Visible RGB Image" f1: field 90
	text 220 "Visible Image Aligment" f2: field 90
	at as-pair canvas1/offset/x + 160 canvas1/offset/y base 1x240 white
	at as-pair canvas1/offset/x canvas1/offset/y + 120 base 320x1 white
	at as-pair canvas3/offset/x + 160 canvas3/offset/y base 1x240 white
	at as-pair canvas3/offset/x canvas3/offset/y + 120 base 320x1 white
]
