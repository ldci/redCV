#!/usr/local/bin/red-view
Red [
	Author:  "ldci"
	Needs: 'view
]

{RGB to YIQ conversion is used in the NTSC encoder where the RGB inputs are converted to a luminance (Y) and two chrominance information (I,Q).}

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
;--RGB->YIQ
RGB2YIQ: function[] [
	tt: dt [
		rgb: img1/rgb
		clear m1 
		clear m2
		foreach [r g b] rgb [
			r: r / 255.0 g: g / 255.0 b: b / 255.0			;--[0:1] normalization
			Y: (r * 0.299) + (g * 0.587) + (b * 0.114) 		;--luminance
			I: (r * 0.596) + (g * -0.275) + (b * -0.321)	;--chrominance 
			Q: (r * 0.212) + (g * -0.523) + (b * 0.311) 	;--chrominance
			YY: to integer! (Y * 255) if YY < 0 [YY: 0] 	;--[0:255] range
			II: to integer! (I * 255) if II < 0 [II: 0]		;--[0:255] range 
			QQ: to integer! (Q * 255) if QQ < 0 [QQ: 0]		;--[0:255] range 
			append append append m1 Y I Q 					;--float values for reverse
			append append append m2 YY II QQ				;--use RGB mode  
		]
		img2: make image! reduce [img1/size to binary! m2]	;--RGB image
		canvas/image: img2
	]
	bt2/enabled?: true
	f/text: rejoin ["Image Size: "  form img1/size " in: " round/to third tt 0.01 " sec"]
]

;--YIQ->RGB
YIQ2RGB: function[] [
	tt: dt [
		clear m3
		foreach [Y I Q] m1 [
			r: to integer! (Y + (I * 0.956) + (Q * 0.619)) * 255	;--[0:255] range
			g: to integer! (Y - (I * 0.272) - (Q * 0.647)) * 255	;--[0:255] range
			b: to integer! (Y - (I * 1.106) + (Q * 1.703)) * 255	;--[0:255] range
			append append append m3 r g b							;--use RGB mode
		]
		img3: make image! reduce [img1/size to binary! m3]			;--RGB image
		canvas/image: img3
	]
	f/text: rejoin ["Image Size: "  form img1/size " in: " round/to third tt 0.01 " sec"]
]


; ***************** Test Program ****************************
view win: layout [
		title "RGB <-> YIQ"
		origin margins space margins
		across
		button 100 "Load RGB"			[loadImage]
		bt1: button 100 "RGB -> YIQ"	[if isfile? [RGB2YIQ]]
		bt2: button 100 "YIQ -> RGB"	[if isfile? [YIQ2RGB]]
		pad 115x0
		button 70 "Quit" 			[Quit]
		return
		canvas: base iSize
		return 
		f: field 512
		do [bt1/enabled?: bt2/enabled?: false]
]