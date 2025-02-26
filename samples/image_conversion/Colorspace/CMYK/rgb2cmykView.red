#!/usr/local/bin/red-view
Red [
	Author:  "ldci"
	Need: View
	File: %rgb2cmykView.red
]

do %rgbcmyk.red

toCMYK: function [] [
	visu2/color: white
	r: to integer! fR/text
	g: to integer! fG/text
	b: to integer! fB/text
	blk: rgbToCmyk r g b
	fC/text: form c: round/to blk/1 0.01
	fM/text: form m: round/to blk/2 0.01
	fY/text: form y: round/to blk/3 0.01
	fK/text: form k: round/to blk/4 0.01
	r: to integer! (c * 255)
	g: to integer! (m * 255)
	b: to integer! (y * 255)
	color: as-color r g b
	visu1/color: color
	bt2/enabled?: true
]

toRGB: function [] [
	c: to float! fC/text
	m: to float! fM/text
	y: to float! fY/text
	k: to float! fK/text
	blk: cmykToRgb c m y k
	color: as-color blk/1 blk/2 blk/3
	visu2/color: color
]

margins: 5x5
mainWin: layout [
	title "Conversion RGB <> CMYK"
	origin margins space margins
	text "R" 33 bold fR: field 50 	[r: to integer! fR/text]
	text "G" 30 bold fG: field 50 	[g: to integer! fG/text]	
	text "B" 30 bold fB: field 50	[b: to integer! fB/text]
	pad 90x0
	bt1: button "RGB -> CMYK" 105 [toCMYK]
	return
	text "C" 33 bold fC: field 50	
	text "M" 30 bold fM: field 50	
	text "Y" 30 bold fY: field 50	
	text "K" 30 bold fK: field 50
	bt2: button "CMYK -> RGB" 105 [toRGB]
	return 
	text "HSL" 35 bold visu1: base 425x25 white
	return 
	text "RGB" 35 bold visu2: base 425x25 white
	return
	pad 410x0 button "Quit" [Quit]
	do [fR/text: form r: 200 fG/text: form g: 128 fB/text: form b: 16
		bt2/enabled?: false
		fC/enabled?: fM/enabled?: fY/enabled?: fK/enabled?: false
	]
]
view mainWin