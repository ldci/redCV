#!/usr/local/bin/red-view
Red [
	Author: "ldci"
	Needs: 	view
]

;--RBG <->YCrCb conversion
;--we use OpenCV equations

delta: 128	;--solve problems with negative numbers by adding 128 to them
{
	delta: 
	128 for 8-bit images
	32768 for 16-bit images
	0.5 for floating-point images 
}

margins: 5x5
size: 512x512
m1: copy []  
m2: copy []

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
;--RGB->YCrCb
toYCrCb: function[] [
	clear m1 
	tt: dt [
		rgb: img1/rgb
		foreach [r g b] rgb [
			Y: to integer! (0.299 * r) + (0.587 * g) + (0.114 * b)		
			Cr: to integer! (r - Y) * 0.713 + delta 
			Cb: to integer! (b - Y) * 0.564 + delta	
			append append append m1 Y Cr Cb	
		]
		img2: make image! reduce [img1/size to binary! m1]	;--BGR image
		canvas/image: img2
	]
	bt2/enabled?: true
	f/text: rejoin ["Image Size: "  form img1/size " in: " round/to third tt 0.01 " sec"]
]

;--YCrCb->RGB
toRGB: function[] [
	clear m2
	tt: dt [
		foreach [Y Cr Cb] m1 [
			r:  to integer! Y + (1.403 * (Cr - delta))
			g:  to integer! Y - (0.714 * (Cr - delta)) - (0.344 * (Cb - delta))
			b:  to integer! Y + (1.773 * (cb - delta))
			append append append m2 r g b 							;--use RGB mode
		]
		img3: make image! reduce [img1/size to binary! m2]			;--RGB image
		canvas/image: img3
	]
	f/text: rejoin ["Image Size: "  form img1/size " in: " round/to third tt 0.01 " sec"]
]


; ***************** Test Program ****************************
view win: layout [
		title "RGB <> YCrCb"
		origin margins space margins
		across
		bt0: button 100 "Load RGB"		[loadImage]
		bt1: button 110 "RGB -> YCrCb"	[if isfile? [toYCrCb]]
		bt2: button 110 "YCrCb->RGB"		[if isfile? [toRGB]]
		pad 95x0
		button 65 "Quit" 				[Quit]
		return
		canvas: base size
		return 
		f: field 512
		do [bt1/enabled?: bt2/enabled?: false]
]