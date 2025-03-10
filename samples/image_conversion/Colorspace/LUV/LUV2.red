#!/usr/local/bin/red-view
Red [
	Author:  "ldci"
	Needs: 'view
]

;-LUV conversions

margins: 5x5
iSize: 512x512
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
;--RGB->LUV
;--Input 0..255 range 
;--Output 0..1 and 0..255 ranges 
;--https://www.easyrgb.com/en/math.php
RGB2LUV: function[] [
	tt: dt [
		rgb: img1/rgb
		clear m1 
		clear m2
		ratio: 1.0 / 3.0
		foreach [sR sG sB] rgb [
			var_R: (sR / 255)
			var_G: (sG / 255)
			var_B: (sB / 255)
			X: var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805
			Y: var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722
			Z: var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505
			var_U: (4 * X) / (X + (15 * Y) + (3 * Z) )
			var_V: (9 * Y) / (X + (15 * Y) + (3 * Z))
			var_Y: Y / 100
			either (var_Y > 0.008856) [var_Y: var_Y ** (1 / 3)]
				[var_Y: (7.787 * var_Y) + (16 / 116)]
			ref_U: (4 * x) / (X + (15 * Y) + (3 * Z))
			ref_V: (9 * Y) / (X + ( 5 * Y) + (3 * Z))
			CIE-l: (116 * var_Y) - 16
			CIE-u: (13 * CIE-l) * (var_U - ref_U)
			CIE-v: (13 * CIE-l) * (var_V - ref_V)
			attempt [
				r: to integer! (CIE-l * 255)
				g: to integer! (CIE-u * 255)
				b: to integer! (CIE-v * 255)
				if r > 255 [r: 255]
				if g > 255 [g: 255]
				if b > 255 [b: 255]
			]
			append m1 reduce [CIE-l CIE-u CIE-v]	 					;--float values for reverse
			append m2 reduce [r g b]						;--use RGB mode 
		]

		img2: make image! reduce [img1/size to binary! m2]	;--RGB image
		canvas/image: img2
	]
	;bt2/enabled?: true
	msec: (round/to third tt 0.01) * 1000
	f/text: rejoin ["Image Size: "  form img1/size " in: " msec " msec"]
]

;--LUV->RGB



; ***************** Test Program ****************************
view win: layout [
		title "RGB <-> LUV"
		origin margins space margins
		across
		button 100 "Load RGB"			[loadImage]
		bt1: button 100 "RGB -> LUV"	[if isfile? [RGB2LUV]]
		
		pad 215x0
		button 70 "Quit" 			[Quit]
		return
		canvas: base iSize
		return 
		f: field 512
		do [bt1/enabled?: false]
]