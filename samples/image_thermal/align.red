#! /usr/local/bin/red
Red [
	Title:   "Virginia"
	Author:  "Francois Jouen"
	File: 	 %align.red
	needs:   view
]

; required libs
#include %../../libs/thermal/rcvFlir.red

flirFile: 	none

loadImage: does [
	tmp: request-file 
	if not none? tmp [
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

cleanThermal: does [
	if exists? to-file rgbimg 	[delete to-file rgbimg]
	if exists? to-file irimg  	[delete to-file irimg]
	if exists? to-file palimg 	[delete to-file palimg]
	if exists? to-file rawimg 	[delete to-file rawimg]
	if exists? to-file tempimg 	[delete to-file tempimg]
	if exists? to-file exifFile [delete to-file exifFile]
	if exists? to-file exifFile2 [delete to-file exifFile2]
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
	button "Quit" 			[cleanThermal quit]
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
