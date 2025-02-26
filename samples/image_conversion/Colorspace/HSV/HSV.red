#!/usr/local/bin/red-view
Red [
	Author:  "ldci"
	Needs: 'view
	File: %HSV.red
]

do %rgbhsv.red ;--for conversions

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

;--RGB->HSV
toHSV: function [] [
	tt: dt [
		rgb: img1/rgb
		clear m1 
		clear m2
		foreach [r g b] rgb [
			blk: rgbToHsv r g b
			h: blk/1 s: blk/2 v: blk/3
			r: to integer! ((h / 360) * 255)
			g: to integer! (s * 255)
			b: to integer! (v * 255)
			append m1 blk					;--HSV Values
			append append append m2 r g b	;--RGB value for visualisation					
		]
		img2: make image! reduce [img1/size to binary! m2]	;--RGB image
		canvas/image: img2
	]
	bt2/enabled?: true
	f/text: rejoin ["Image Size: "  form img1/size " in: " round/to third tt 0.01 " sec"]
]


;--HSV->RGB
toRGB: function [] [
	tt: dt [
		clear m3
		foreach [h s v] m1 [append m3 hsvToRgb h s v]
		img3: make image! reduce [img1/size to binary! m3]	;--RGB image
		canvas/image: img3
	]
	f/text: rejoin ["Image Size: "  form img1/size " in: " round/to third tt 0.01 " sec"]
]


; ***************** Test Program ****************************
view win: layout [
		title "RGB <-> HSV"
		origin margins space margins
		across
		bt0: button 100 "Load RGB"		[loadImage]
		bt1: button 100 "RGB -> HSV"	[if isfile? [toHSV]]
		bt2: button 100 "HSV -> RGB"	[if isfile? [toRGB]]
		pad 115x0
		button 65 "Quit" 				[Quit]
		return
		canvas: base size
		return 
		f: field 512
		do [bt1/enabled?: bt2/enabled?: false]
]