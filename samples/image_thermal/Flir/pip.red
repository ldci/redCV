#! /usr/local/bin/red
Red [
	Title:   "Flir PiP"
	Author:  "ldci"
	File: 	 %pip.red
	needs:   view
]

; required libs
#include %../../../libs/thermal/Flir/rcvFlir.red
#include %../../../libs/imgproc/rcvImgEffect.red

flirFile: 	none

loadImage: does [
	tmp: request-file 
	if not none? tmp [
		canvas1/image: canvas2/image: canvas3/image: none
		clear f0/text
		clear f1/text
		clear model/text
		clear lens/text
		clear iscale/text
		flirFile: to-string tmp
		
		rcvGetFlirMetaData flirFile 
		thermal: load to-file tmp			;--IR source image
		canvas1/image: thermal
		
		scaleFactor: 4						;--EmbeddedImage is 4 larger than RawThermalImage
		imgRatio: round/floor (EmbeddedImageWidth / RawThermalImageWidth / scaleFactor)
		if imgRatio = 0.0 [imgRatio: 1.0] 
		pipPos:  as-pair (PiPX1 + PiPX2) (PiPY1 + PiPY2)
		pipSize: as-pair (PiPX1 + PiPX2) * imgRatio (PiPY1 + PiPY2) * imgRatio
		if any 	[pipPos/x + pipSize/x > thermal/size/x pipPos/y + pipSize/y > thermal/size/y]
				[pipPos: 0x0 pipSize: thermal/size]
		
		;print [imgRatio PiPX1 PiPY1 PiPX2 PiPY2 pipSize]
		img: make image! pipSize
		rcvCropImage thermal img pipPos
		canvas2/image: img
		f0/text: form canvas1/image/size
		f1/text: form canvas2/image/size
		model/text: CameraModel
		lens/text: LensModel
		iscale/text: form round/to imgRatio 0.01
		canvas3/image: rcvGetFlirPalette flirFile

	]
]
view layout [
	title "Picture in Picture Mode"
	button "Load" 			[loadImage]
	text "Camera Model"  model: field 70
	text 40 "Lens" lens: field 60
	text "Image Scale" iscale: field 
	pad 30x0
	button "Quit" 			[rcvCleanThermal quit]
	return
	canvas1: base 320x240
	canvas2: base 320x240
	return
	canvas3: base 220x20 f0: field 90
	text 220 "Picture In Picture" f1: field 90
]
