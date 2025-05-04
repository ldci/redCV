#!/usr/local/bin/red-view
Red [
	Author: "ldci"
	Needs: 	view
	File: 	%CMYK.red
]

do %rgbcmyk.red ;--for conversions

margins: 5x5
size: 512x512
m1: copy []  
m2: copy []
m3: copy []
isFile?: false

loadImage: does [
	canvas/image: black
	tmp: request-file
	unless none? tmp [
		img1: load tmp
		canvas/image: img1
		f/text: rejoin ["Image Size: "  form img1/size]
		isFile?: true 
		bt1/enabled?: true
	]
]

;--RGB->CMYK
toCMYK: function [] [
	tt: dt [
		rgb: img1/rgb
		clear m1 
		clear m2
		foreach [r g b] rgb [
			blk: rgbToCmyk r g b
			r: to integer! (blk/1 * 255)
			g: to integer! (blk/2 * 255)
			b: to integer! (blk/3 * 255)
			append m1 blk						;--CMYK Values
			append append append m2 r g b		;--RGB value for visualisation					
		]
		img2: make image! reduce [img1/size to binary! m2]	;--RGB image
		canvas/image: img2
		bt2/enabled?: true
	]
	f/text: rejoin ["Image Size: "  form img1/size " in: " round/to third tt 0.01 " sec"]
]


;--CMYK->RGB
toRGB: function [] [
	tt: dt [
		clear m3
		foreach [c m y k] m1 [
			blk: cmykToRgb c m y k
			color: as-color blk/1 blk/2 blk/3				;--RGB Values
			append m3 color		
		]
		img3: make image! reduce [img1/size to binary! m3]	;--RGB image
		canvas/image: img3
	]
	f/text: rejoin ["Image Size: "  form img1/size " in: " round/to third tt 0.01 " sec"]
]


; ***************** Test Program ****************************
view win: layout [
		title "RGB <-> CMYK"
		origin margins space margins
		across
		bt0: button 100 "Load RGB"		[loadImage]
		bt1: button 110 "RGB -> CMYK"	[if isfile? [toCMYK]]
		bt2: button 110 "CMYK -> RGB"	[if isfile? [toRGB]]
		pad 95x0
		button 65 "Quit" 				[Quit]
		return
		canvas: base size
		return 
		f: field 512
		do [bt1/enabled?: bt2/enabled?: false]
]