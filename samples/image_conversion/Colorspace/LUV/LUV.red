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
		foreach [r g b] rgb [
			rf: (to float! r) / 255.0	
			gf: (to float! g) / 255.0
			bf: (to float! b) / 255.0	
			xf: (rf * 0.412453) + (gf *  0.357580) + (bf * 0.180423)
    		yf: (rf * 0.212671) + (gf *  0.715160) + (bf * 0.072169)
    		zf: (rf * 0.019334) + (gf *  0.119193) + (bf * 0.950227)
    		either yf > 0.008856 [l: (116.0 * power yf ratio) - 16.00] 
    				[l: 903.3 * yf]
    		;convert XYZ to CIE Luv
			uu: (4.0 * xf) / (xf + (15.00 * yf) + (3.0 * zf))			
    		vv: (9.0 * yf) / (xf + (15.00 * yf) + (3.0 * zf))
    		u: (13.00 * l) * (uu - 0.19793943)
			v: (13.00 * l) * (vv - 0.46831096)
			l: (l / 100.0) * 255.0	
			u: ((u + 134.0)  / 354.0) * 255.0 
			v: ((v + 140.0)  / 266.0) * 255.0 
			;print reduce [l u v]
			if l > 255 [l: 255]
			if u > 255 [u: 255]
			if v > 255 [v: 255]
			r: to integer! l
			g: to integer! u
			b: to integer! v
			append m1 reduce [l u v]	 					;--float values for reverse
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