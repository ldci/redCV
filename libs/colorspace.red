Red [
	Title:   "Red Computer Vision: Color Space"
	Author:  "Francois Jouen"
	File: 	 %colorspace.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]



; ********* Color space transformation **********

rcvRGBXYZ: routine [src1 [image!] return: [image!]
	/local 
		dst 
		stride1 
		stride2 
		bmp1 
		bmpDst 
		data1 
		dataDst 
		w 
		h
		x 
		y 
		pos
		a
		r
		g
		b
		rf
		gf
		bf
		xf
		yf
		zf
][
    dst: as red-image! stack/push*        ;-- create an new image slot
    image/copy src1 dst null yes null
    stride1: 0
    stride2: 0
    bmp1: OS-image/lock-bitmap as-integer src1/node no
    bmpDst: OS-image/lock-bitmap as-integer dst/node yes
    
    data1: OS-image/get-data bmp1 :stride1   
    dataDst: OS-image/get-data bmpDst :stride2

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            a: data1/pos >>> 24
            r: data1/pos and 00FF0000h >> 16
            g: data1/pos and FF00h >> 8 
           	b: data1/pos and FFh 
            rf: (integer/to-float r) / 255.0
			gf: (integer/to-float g) / 255.0
			bf: (integer/to-float b) / 255.0
			either (rf > 0.04045) [rf: pow ((rf + 0.055) / 1.055) 2.4] [rf: rf / 12.92]
			either (gf > 0.04045) [gf: pow ((gf + 0.055) / 1.055) 2.4] [gf: gf / 12.92]
			either (bf > 0.04045) [bf: pow ((bf + 0.055) / 1.055) 2.4] [bf: bf / 12.92]
			rf: rf * 100.0
    		gf: gf * 100.0
    		bf: bf * 100.0
    		;Observer. = 2¡, Illuminant = D65
			xf: (rf * 0.4124) + (gf *  0.3576) + (bf * 0.1805)
    		yf: (rf * 0.2126) + (gf *  0.7152) + (bf * 0.0722)
    		zf: (rf * 0.0193) + (gf *  0.1192) + (bf * 0.9505)
    		r: float/to-integer xf
    		g: float/to-integer yf
    		b: float/to-integer zf
            dataDst/pos: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)	
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    
    OS-image/unlock-bitmap as-integer src1/node bmp1
    OS-image/unlock-bitmap as-integer dst/node bmpDst
	as red-image! stack/set-last as cell! dst            ;-- return new image
]



rcvXYZRGB: routine [src1 [image!] return: [image!]
	/local 
		dst 
		stride1 
		stride2 
		bmp1 
		bmpDst 
		data1 
		dataDst 
		w 
		h
		x 
		y 
		pos
		a
		r
		g
		b
		rf
		gf
		bf
		xf
		yf
		zf
][
    dst: as red-image! stack/push*        ;-- create an new image slot
    image/copy src1 dst null yes null
    stride1: 0
    stride2: 0
    bmp1: OS-image/lock-bitmap as-integer src1/node no
    bmpDst: OS-image/lock-bitmap as-integer dst/node yes
    
    data1: OS-image/get-data bmp1 :stride1   
    dataDst: OS-image/get-data bmpDst :stride2

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            a: data1/pos >>> 24					
            r: data1/pos and 00FF0000h >> 16	;from 0 to  95.047(Observer = 2¡, Illuminant = D65)
            g: data1/pos and FF00h >> 8 		;Y from 0 to 100.000
           	b: data1/pos and FFh 				;Z from 0 to 108.883
           	
           	
            xf: (integer/to-float r) / 100.0 
			yf: (integer/to-float g) / 100.0
			zf: (integer/to-float b) / 100.0
			
			rf: (xf * 3.2406) + (yf * -1.5372) + (zf * -0.4986)			
			gf: (xf * -0.9689) + (yf * 1.8758) + (zf * 0.0415)
			bf: (xf * 0.05557)+ (yf * -0.2040) + (zf * 1.0570)
			
			
			either (rf > 0.0031308) [rf: (1.055 * (pow rf 1.0 / 2.4)) - 0.055] [rf: rf * 12.92]
			either (gf > 0.0031308) [gf: (1.055 * (pow gf 1.0 / 2.4)) - 0.055] [gf: gf * 12.92]
			either (bf > 0.0031308) [bf: (1.055 * (pow bf 1.0 / 2.4)) - 0.055] [bf: bf * 12.92]
			
			
			
    		r: float/to-integer (xf * 255.0) 
    		g: float/to-integer (yf * 255.0) 
    		b: float/to-integer (zf * 255.0)
    		;print [r " " g " " b lf]
            dataDst/pos: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)	
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    
    OS-image/unlock-bitmap as-integer src1/node bmp1
    OS-image/unlock-bitmap as-integer dst/node bmpDst
	as red-image! stack/set-last as cell! dst            ;-- return new image
]

