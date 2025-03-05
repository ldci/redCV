Red [
	Title:   "Red Computer Vision: Image Processing"
	Author:  "ldci"
	File: 	 %rcvColorSpace.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2020 ldci. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;***************** COLORSPACE CONVERSIONS ************

;******************* RGB<=>CIE XYZ.Rec 709 **************************
;X, Y and Z output refer to a D65/2° standard illuminant

rcvRGBXYZ: routine [
    src 	[image!]
    dst  	[image!]
    op	 	[integer!]
    /local
    	pixel xyz		[subroutine!]
        pixS pixD 		[int-ptr!]
        handleS handleD	[integer!] 
        i n				[integer!]
        r g b a			[integer!] 
        rf gf bf		[float!] 
        xf yf zf		[float!]
][
    handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    r: g: b: a: 0
    rf: gf: bf: 0.0
    xf: yf: zf: 0.0
    ;--subroutines
    pixel: [(a << 24) OR (r << 16 ) OR (g << 8) OR b]
    xyz: [
    	a: pixS/value >>> 24
       	r: pixS/value and FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh 
        rf: as float! r  gf: as float! g bf: as float! b 
		rf: rf / 255.0 gf: gf / 255.0 bf: bf / 255.0 
		either rf > 0.04045 [rf: pow ((rf + 0.055) / 1.055) 2.4] [rf: rf / 12.92] 
		either gf > 0.04045 [gf: pow ((gf + 0.055) / 1.055) 2.4] [gf: gf / 12.92] 
		either bf > 0.04045 [bf: pow ((bf + 0.055) / 1.055) 2.4] [bf: bf / 12.92] 
		rf: rf * 100.0 gf: gf * 100.0 bf: bf * 100.0	
		xf: (rf * 0.4124) + (gf *  0.3576) + (bf * 0.1805)
    	yf: (rf * 0.2126) + (gf *  0.7152) + (bf * 0.0722)
    	zf: (rf * 0.0193) + (gf *  0.1192) + (bf * 0.9505)	
    ]
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    i: 0
    while [i < n] [
    	xyz  	
    	switch op [
    		1 [r: as integer! xf g: as integer! yf b: as integer! zf] ;rgb
    		2 [r: as integer! zf g: as integer! yf b: as integer! yf] ;bgr
    	] 	
    	pixD/value: pixel
        pixS: pixS + 1
        pixD: pixD + 1
       	i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

rcvXYZRGB: routine [
"CIE XYZ to RBG/RGB color conversion"
    src 	[image!]
    dst  	[image!]
    op	 	[integer!]
    /local
    	rgba			[subroutine!]
        pixS 			[int-ptr!]
        pixD 			[int-ptr!]
        handleS handleD	[integer!] 
        i n				[integer!] 
        r g b a 		[integer!] 
        rf gf bf 		[float!]
        xf yf zf		[float!]
][
    handleS: 0 handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    r: g: b: a: 0
    xf: yf: zf: 0.0
    rf: gf: bf: 0.0
    ;--subroutines
    rgba: [
    	a: pixS/value >>> 24
       	r: pixS/value and FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh 
        xf: as float! r yf: as float! g zf: as float! b
        xf: xf / 100.0 yf: yf / 100.0 zf: zf / 100.0
        rf: (xf * 3.2406) + (yf * -1.5372) + (zf * -0.4986)			
		gf: (xf * -0.9689) + (yf * 1.8758) + (zf * 0.0415)
		bf: (xf * 0.0557)+ (yf * -0.2040) + (zf * 1.0570)  
		either rf > 0.0031308 [rf: 1.055 * (pow rf (1.0 / 2.4)) - 0.055] [rf: rf * 12.92]
		either gf > 0.0031308 [gf: 1.055 * (pow gf (1.0 / 2.4)) - 0.055] [gf: gf * 12.92] 
		either bf > 0.0031308 [bf: 1.055 * (pow bf (1.0 / 2.4)) - 0.055] [bf: bf * 12.92] 
		rf: rf * 255.0 gf: gf * 255.0 bf: bf * 255.0
		if rf < 0.0 [rf: 0.0]
		if gf < 0.0 [gf: 0.0]
		if bf < 0.0 [bf: 0.0]
		r: as integer! rf
    	g: as integer! gf
    	b: as integer! bf    
    ]
    i: 0
    while [i < n] [
    	rgba
    	switch op [
    		1 [pixD/value: (a << 24) OR (r << 16) OR (g << 8) OR b] ;rgb
    		2 [pixD/value: (a << 24) OR (b << 16) OR (g << 8) OR r] ;bgr
    	] 
        pixS: pixS + 1
        pixD: pixD + 1
       	i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

rcvXYZADOBE: routine [
"CIE XYZ to RBG/RGB color conversion"
    src 	[image!]
    dst  	[image!]
    op	 	[integer!]
    /local
    	rgba			[subroutine!]
        pixS 			[int-ptr!]
        pixD 			[int-ptr!]
        handleS handleD	[integer!] 
        i n				[integer!] 
        r g b a 		[integer!] 
        rf gf bf 		[float!]
        x y z			[float!]
][
    handleS: 0 handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    r: g: b: a: 0
    x: y: z: 0.0
    rf: gf: bf: 0.0
    ;--subroutines
    rgba: [
    	a: pixS/value >>> 24
       	r: pixS/value and FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh 
        x: (as float! r) / 100.0
		y: (as float! g) / 100.0
		z: (as float! b) / 100.0
        rf: (x * 2.04137) + (y * -0.56495) + (z * -0.34469)
		gf: (x * -0.96927) + (y * 1.87601) + (z * 0.04156)
		bf: (x *  0.01345) + (y * -0.11839) + (z * 1.01541)
		rf: pow rf (1.0 / 2.19921875)
		gf: pow gf (1.0 / 2.19921875)
		bf: pow bf (1.0 / 2.19921875)
        r: as integer! rf * 255.0 
		g: as integer! gf * 255.0 
		b: as integer! bf * 255.0 
    ]
    i: 0
    while [i < n] [
    	rgba
    	switch op [
    		1 [pixD/value: (a << 24) OR (r << 16) OR (g << 8) OR b] ;rgb
    		2 [pixD/value: (a << 24) OR (b << 16) OR (g << 8) OR r] ;bgr
    	] 
        pixS: pixS + 1
        pixD: pixD + 1
       	i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]


;RGB<=>CIE XYZ.Rec 709 functions

rcvRGB2XYZ: function [
"RGB to CIE XYZ color conversion"
	src [image!] 
	dst [image!]
][
	rcvRGBXYZ src dst 1
] 

rcvBGR2XYZ: function [
"BGR to CIE XYZ color conversion"
	src [image!] 
	dst [image!]
][
	rcvRGBXYZ src dst 2
] 

rcvXYZ2RGB: function [
"XYZ to RGB color conversion"
	src [image!] 
	dst [image!]
][
	rcvXYZRGB src dst 1
] 

rcvXYZ2BGR: function [
"XYZ to BGR color conversion"
	src [image!] 
	dst [image!]
][
	rcvXYZRGB src dst 2
] 

rcvXYZ2AdobeRGB: function [
"XYZ to RGB color conversion"
	src [image!] 
	dst [image!]
][
	rcvXYZADOBE src dst 1
] 

rcvXYZ2AdobeBGR: function [
"XYZ to RGB color conversion"
	src [image!] 
	dst [image!]
][
	rcvXYZADOBE src dst 2
] 

;********************************* RGB <> HSV ****************************

rcvRGBHSV: routine [
    src 	[image!]
    dst  	[image!]
    op	 	[integer!]
    /local
    	pixel hsv				[subroutine!]
        pixS 					[int-ptr!]
        pixD 					[int-ptr!]
        handleS handleD			[integer!] 
        r g b a n i				[integer!]
        rf gf bf 				[float!]
        mini maxi delta			[float!]
        h s v					[float!]
        deltaR deltaG deltaB 	[float!]
][
    handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    r: g: b: a: 0
    rf: gf: bf: 0.0
    h: s: v: 0.0
	mini: maxi: delta: deltaR: deltaG: deltaB: 0.0
	;--subroutines
    pixel: [(a << 24) OR (r << 16) OR (g << 8) OR b]
    hsv: [
    	a: pixS/value >>> 24
       	r: pixS/value and FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh   
        rf: (as float! r) / 255.0
		gf: (as float! g) / 255.0
		bf: (as float! b) / 255.0  
		either rf < gf [mini: rf] [mini: gf] if bf < mini [mini: bf]
		either rf > gf [maxi: rf] [maxi: gf] if bf > maxi [maxi: bf]
		v: maxi	
		delta: maxi - mini
		; either grayscale no chroma or color chromatic data
		either (delta = 0.0) [s: 0.0 h: 0.0][
			s: delta / maxi
			deltaR: (((maxi - rf) / 6.0) + (delta / 2.0)) / delta 
			deltaG: (((maxi - gf) / 6.0) + (delta / 2.0)) / delta 
			deltaB: (((maxi - bf) / 6.0) + (delta / 2.0)) / delta 
			if rf = maxi [h: deltaB -  deltaG]
			if gf = maxi [h: (1.0 / 3.0) + deltaR - deltaB]
			if bf = maxi [h: (2.0 / 3.0) + deltaG - deltaR]
			if h < 0.0 [h: h + 1.0]
			if h > 1.0 [h: h - 1.0]
		]
    ]
	i: 0
    while [i < n] [
       	hsv
		;--hsv values are in range 0.0..1.0 -> transform in range 0..255
		switch op [
			1 [r: as integer! h * 255.0 g: as integer! s * 255.0 b: as integer! v * 255.0]
			2 [r: as integer! v * 255.0 g: as integer! s * 255.0 b: as integer! h * 255.0]
		]
    	pixD/value: pixel	
        pixS: pixS + 1
        pixD: pixD + 1
        i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

rcvHSVRGB: routine [
    src 	[image!]
    dst  	[image!]
    op	 	[integer!]
    /local
    	pixel rgba				[subroutine!]
    	pixS 					[int-ptr!]
        pixD 					[int-ptr!]
        handleS handleD			[integer!] 
        r g b a n i 			[integer!]
        rf gf bf 				[float!]
        h hh s v ii				[float!]
        v1 v2 v3				[float!]
][
	handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    r: g: b: a: 0
    rf: gf: bf: 0.0
    h: s: v: v1: v2: v3: hh: ii: 0.0
    ;--subroutines
    pixel: [(a << 24) OR (r << 16) OR (g << 8) OR b]
    rgba: [
    	a: pixS/value >>> 24
       	r: pixS/value and FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh   
        ;--hsv values 0..1
        h: (as float! r) / 255.0
		s: (as float! g) / 255.0
		v: (as float! b) / 255.0
		either s = 0.0 [r: g: b: (as integer! (v * 255.0))][
    		hh: h * 6.0
    		if hh = 6.0 [hh: 0.0] 	;--H must be < 1.0
    		ii: floor hh	  		;--Or ... ii = floor hh
    		v1: v * (1.0 - s)
    		v2: v * (1.0 - s * (hh - ii))
    		v3: v * (1.0 - s * (1.0 - (hh - ii)))
    		if ii = 0.0 [rf: v  gf: v3 bf: v1]
    		if ii = 1.0 [rf: v2 gf: v  bf: v1]
    		if ii = 2.0 [rf: v1 gf: v  bf: v3]
    		if ii = 3.0 [rf: v1 gf: v2 bf: v]
    		if ii = 4.0 [rf: v3 gf: v1 bf: v]
    		if ii = 5.0 [rf: v  gf: v1 bf: v2]	
    	]  
    ]
    i: 0
    while [i < n] [
    	rgba
    	switch op [
			1 [r: as integer! rf * 255.0 g: as integer! gf * 255.0 b: as integer! bf * 255.0]
			2 [r: as integer! bf * 255.0 g: as integer! gf * 255.0 b: as integer! rf * 255.0]
		]
    	pixD/value: pixel	
        pixS: pixS + 1
        pixD: pixD + 1
    	i: i + 1
    ] 
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

rcvRGB2HSV: function [
"RBG color to HSV conversion"
	src [image!] 
	dst [image!]
][
	rcvRGBHSV src dst 1
] 

rcvBGR2HSV: function [
"BGR color to HSV conversion"
	src [image!] 
	dst [image!]
][
	rcvRGBHSV src dst 2
] 

rcvHSV2RGB: function [
"HSV to RGB conversion"
	src [image!] 
	dst [image!]
][
	rcvHSVRGB src dst 1
] 

rcvHSV2BGR: function [
"HSV to BGR conversion"
	src [image!] 
	dst [image!]
][
	rcvHSVRGB src dst 2
] 

;--new fonctions with blocks
;--R, G and B input range = 0..255
;--H output range (0..359) S and V output range = 0..1.0
;--https://www.cs.rit.edu/~ncs/color/t_convert.html
;--to be documented

rgbToHSVb: routine [
    r 				[integer!]
	g 				[integer!]
	b 				[integer!]
    /local
    rf gf bf 	 	[float!]
    mini maxi delta	[float!]
    h s v 			[float!]
    ff				[red-float!]
    blk  			[red-block!]				
][
	blk: as red-block! stack/push*	;--create a block in memory	
	block/make-at blk 3				;--3 values (for h s v) in block
    rf: (as float! r) / 255.0		;--we need float value
    gf: (as float! g) / 255.0		;--we need float value
    bf: (as float! b) / 255.0		;--we need float value
	either rf < gf [mini: rf] [mini: gf] if bf < mini [mini: bf]
	either rf > gf [maxi: rf] [maxi: gf] if bf > maxi [maxi: bf]
	v: maxi	
	delta: maxi - mini
	;--Compute Hue 
	;--modulo is not supported for float values by Red/System, so we use C-lib fmod
	either delta = 0.0 [h: 0.0] ;--grayscale image
	[	 case [
			maxi = rf [h: fmod (60.0 * ((gf - bf) / delta) + 360.0) 360.0]
			maxi = gf [h: fmod (60.0 * ((bf - rf) / delta) + 120.0) 360.0]
			maxi = bf [h: fmod (60.0 * ((rf - gf) / delta) + 240.0) 360.0]
		]
	]
	either maxi = 0.0 [s: 0.0][s: delta / maxi]	;--Compute Saturation
	v: maxi										;--Compute Value
	;--update block with h s v values
    ff: float/box h
    block/rs-append blk as red-value! ff		;--h value
    ff: float/box s
    block/rs-append blk as red-value! ff		;--s value
    ff: float/box v
    block/rs-append blk as red-value! ff  		;--v value
    as red-block! stack/set-last as cell! blk	;--return block
]


;--With  H [0..359], S [0..1] and V [0..1] (float values) as input
hsvToRGBb: routine [
	h			[float!]
	s			[float!]
	v			[float!]
	/local
	r g b  		[integer!]
	rf gf bf	[float!]
	c x m 		[float!]
	int			[red-integer!]	
	blk  		[red-block!]
][
	blk: as red-block! stack/push*	;--create a block	
	block/make-at blk 3				;--3 values (for h s v) in block
	c: v * s
	x: c * (1.0 - fabs (fmod (h / 60.0) 2.0) - 1.0)			
	m: v - c
	if all [h >=   0.0 h <  60.0][rf: c gf: x bf: 0.0]
	if all [h >=  60.0 h < 120.0][rf: x gf: c bf: 0.0]
	if all [h >= 120.0 h < 180.0][rf: 0.0 gf: c bf: x]
	if all [h >= 180.0 h < 240.0][rf: 0.0 gf: x bf: c]
	if all [h >= 240.0 h < 300.0][rf: x gf: 0.0 bf: c]
	if all [h >= 300.0 h < 360.0][rf: c gf: 0.0 bf: x]
	;--as integer! rounds values towards zero
	rf: rf + m r: as integer! (rf * 255.0) 
	gf: gf + m g: as integer! (gf * 255.0) 
	bf: bf + m b: as integer! (bf * 255.0)
	int: integer/box r
    block/rs-append blk as red-value! int
    int: integer/box g
    block/rs-append blk as red-value! int
    int: integer/box b
    block/rs-append blk as red-value! int  
    as red-block! stack/set-last as cell! blk
]

rcvRGB2HSVb: function [
"RBG color to HSV conversion"
	src 	[image!] 	;--RGB Image
	return:	[block!]	;--HSV Values
][
	hsv: copy []
	rgb: src/rgb
	foreach [r g b] rgb [append hsv rgbToHSVb r g b] ;--HSV Values	
	hsv
] 

rcvRGB2HSVImage: function [
"RBG color to HSV image conversion"
	src 	[image!] 	;--RGB Image
	return:	[image!]	;--HSV Image
][
	hsv: copy []
	crgb: copy []
	rgb: src/rgb
	foreach [r g b] rgb [
		blk: rgbToHSVb r g b 
		r: to integer! blk/1 / 360 * 255  
		g: to integer! blk/2 * 255 
		b: to integer! blk/3 * 255 
		if r > 255 [r: 255]
		if g > 255 [g: 255] 
		if b > 255 [b: 255]
		append crgb to-tuple reduce [r g b] ;--RGB value for pseudo visualisation	
	]
	make image! reduce [src/size to binary! crgb]	;--RGB image
] 

rcvBGR2HSVb: function [
"BGR color to HSV conversion"
	src 	[image!] 	;--BGR Image
	return:	[block!]	;--HSV Values
][
	hsv: copy []
	rgb: src/rgb
	foreach [r g b] rgb [append hsv rgbToHSVb b g r] ;--HSV Values
	hsv
] 

rcvBGR2HSVImage: function [
"BGR color to HSV image conversion"
	src 	[image!] 	;--BGR Image
	return:	[image!]	;--HSV Image
][
	hsv: copy []
	crgb: copy []
	rgb: src/rgb
	foreach [r g b] rgb [
		blk: rgbToHSVb r g b 
		r: to integer! blk/1 / 360 * 255 
		g: to integer! blk/2 * 255 
		b: to integer! blk/3 * 255 
		if r > 255 [r: 255]
		if g > 255 [g: 255]
		if b > 255 [b: 255]
		append crgb to-tuple reduce [b g r] ;--BGR value for pseudo visualisation	
	]
	make image! reduce [src/size to binary! crgb]	;--BGR image
] 


;--HSV->RGB or BGR
rcvHSV2RGBb: function [
"HSV color to RGB conversion"
	src		[image!]
	hsv		[block!]
	return: [image!]
] [
	m: copy []
	foreach [h s v] hsv [append m hsvToRGBb h s v]
	make image! reduce [src/size to binary! m]	;--RGB image
]

;***************************** RGB<=>HLS *****************************

rcvRGBHLS: routine [
    src [image!]
    dst  [image!]
    op	 [integer!]
    /local
    	pixel hls		[subroutine!]
        pixS 			[int-ptr!]
        pixD 			[int-ptr!]
        handleS handleD	[integer!] 
        n i				[integer!] 
        r g b a 		[integer!] 
        rf gf bf 		[float!]
        mini maxi l		[float!]
        h s delta		[float!]
        deltaR deltaG deltaB [float!]
][
    handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    r: g: b: a: 0
    h: s: l: mini: maxi: 0.0
    rf: gf: bf: 0.0
    
    ;--subroutines
    pixel: [(a << 24) OR (r << 16) OR (g << 8) OR b]
    hls: [
    	a: pixS/value >>> 24
       	r: pixS/value and FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh 
        rf: (as float! r) / 255.0
		gf: (as float! g) / 255.0
		bf: (as float! b) / 255.0
		either rf < gf [mini: rf] [mini: gf] if bf < mini [mini: bf] 
		either rf > gf [maxi: rf] [maxi: gf] if bf > maxi [maxi: bf]
		delta: maxi - mini
		l: (maxi + mini) / 2.0
		either delta = 0.0 [h: 0.0 s: 0.0][
		either l < 0.5 [s: delta / (maxi + mini)][s: delta / (2.0 - maxi - mini)]
		deltaR: (((maxi - rf) / 6.0) + (delta / 2.0)) / delta
		deltaG: (((maxi - gf) / 6.0) + (delta / 2.0)) / delta
		deltaB: (((maxi - bf) / 6.0) + (delta / 2.0)) / delta
		if rf = maxi [h: deltaB - deltaG]
		if gf = maxi [h: (1.0 / 3.0) + deltaR - deltaB]	
		if bf = maxi [h: (2.0 / 3.0) + deltaG - deltaR]	
		if h < 0.0 [ h: h + 1.0]   
		if h > 1.0 [ h: h - 1.0]]
    ]
    
	i: 0
    while [i < n] [
       	hls
		switch op [
			1 [r: as integer! h * 255.0 g: as integer! l * 255.0 b: as integer! s * 255.0]
			2 [r: as integer! s * 255.0 g: as integer! l * 255.0 b: as integer! h * 255.0]
		]
    	pixD/value: pixel	
        pixS: pixS + 1
        pixD: pixD + 1
        i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

_hue2RGB: routine [
	v1	[float!]
	v2	[float!]
	vH	[float!]
	return: [float!]
][
	if vH < 0.0 [vH: vH + 1.0]
	if vH > 1.0 [vH: vH - 1.0]
	if ((6.0 * vH) < 1.0) [return (v1 + (v2 - v1) * 6.0 * vH)]
	if ((2.0 * vH) < 1.0) [return (v2)]
	if ((3.0 * vH) < 2.0) [return (v1 + (v2 - v1) * ((2.0 / 3.0) - vH) * 6.0)]
	v1
]

rcvHLSRGB: routine [
    src [image!]
    dst  [image!]
    op	 [integer!]
    /local
    	pixel rgba		[subroutine!]
        pixS 			[int-ptr!]
        pixD 			[int-ptr!]
        handleS handleD	[integer!] 
        n i				[integer!] 
        r g b a 		[integer!] 
        rf gf bf 		[float!]
        h s l delta		[float!]
        v1 v2			[float!]
][
    handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    r: g: b: a: 0
    h: s: l: 0.0
    rf: gf: bf: 0.0
    
    ;--subroutines
    pixel: [(a << 24) OR (r << 16) OR (g << 8) OR b]
    rgba: [
    	a: pixS/value >>> 24
       	r: pixS/value and FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh 
        h: (as float! r) / 255.0
		s: (as float! g) / 255.0
		l: (as float! b) / 255.0
    	either s = 0.0 [r: g: b: (as integer! l) * 255][
    	either l < 0.5 [v2: l * (1.0 + s)] [v2: (l + s) - (s * l)]
    	v1: 2.0 * l - v2
    	rf: _hue2RGB v1 v2 h + (1.0 / 3.0)
    	gf: _hue2RGB v1 v2 h
    	bf: _hue2RGB v1 v2 h - (1.0 / 3.0)]
    ]
    
	i: 0
    while [i < n] [
       	rgba
		switch op [
			1 [r: as integer! rf * 255.0 g: as integer! gf * 255.0 b: as integer! bf * 255.0]
			2 [r: as integer! bf * 255.0 g: as integer! gf * 255.0 b: as integer! rf * 255.0]
		]
    	pixD/value: pixel	
        pixS: pixS + 1
        pixD: pixD + 1
        i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]


rcvRGB2HLS: function [
"RBG color to HLS conversion"
	src [image!] 
	dst [image!]
][
	rcvRGBHLS src dst 1
] 

rcvBGR2HLS: function [
"BGR color to HLS conversion"
	src [image!] 
	dst [image!]
][
	rcvRGBHLS src dst 2
]

rcvHLS2RGB: function [
"HSL to RGB conversion"
	src [image!] 
	dst [image!]
][
	rcvHLSRGB src dst 1
] 

rcvHLS2BGR: function [
"HSL to BGR conversion"
	src [image!] 
	dst [image!]
][
	rcvHLSRGB src dst 2
]

;--new
;--R, G and B input range = 0..255
;--H output range (0..359) S and L output range = 0..1.0
;--https://www.cs.rit.edu/~ncs/color/t_convert.html

rgbToHSLb: routine [
    r 				[integer!]
	g 				[integer!]
	b 				[integer!]
    /local
    rf gf bf 	 	[float!]
    mini maxi delta	[float!]
    h s l x 		[float!]
    ff				[red-float!]
    blk  			[red-block!]				
][
	blk: as red-block! stack/push*	;--create a block in memory	
	block/make-at blk 3				;--3 values (for h s v) in block
    rf: (as float! r) / 255.0		;--we need float value
    gf: (as float! g) / 255.0		;--we need float value
    bf: (as float! b) / 255.0		;--we need float value
	either rf < gf [mini: rf] [mini: gf] if bf < mini [mini: bf]
	either rf > gf [maxi: rf] [maxi: gf] if bf > maxi [maxi: bf]
	delta: maxi - mini
	l: (maxi + mini) / 2.0
	;--Compute Hue 
	;--modulo is not supported for float values by Red/System, so we use C-lib fmod
	either delta = 0.0 [h: 0.0]
	[	 case [
			maxi = rf [h: fmod (60.0 * ((gf - bf) / delta) + 360.0) 360.0]
			maxi = gf [h: fmod (60.0 * ((bf - rf) / delta) + 120.0) 360.0]
			maxi = bf [h: fmod (60.0 * ((rf - gf) / delta) + 240.0) 360.0]
		]
	]
	;--Compute Saturation
	x: fabs (2.0 * l - 1.0)
	either delta = 0.0 [s: 0.0][s: delta / (1.0 - x)]
	;--update block with h s l values
    ff: float/box h
    block/rs-append blk as red-value! ff		;--h value
    ff: float/box s
    block/rs-append blk as red-value! ff		;--s value
    ff: float/box l
    block/rs-append blk as red-value! ff  		;--l value
    as red-block! stack/set-last as cell! blk	;--return block
]

;--With  H [0..359], S [0..1] and L [0..1] (float values)
hslToRGBb: routine [
	h			[float!]
	s			[float!]
	l			[float!]
	/local
	r g b  		[integer!]
	rf gf bf	[float!]
	c x m 		[float!]
	int			[red-integer!]	
	blk  		[red-block!]
][
	blk: as red-block! stack/push*	;--create a block	
	block/make-at blk 3				;--3 values (for h s l) in block
	c: (1.0 - fabs (2.0 * l - 1.0)) * s
	x: c * (1.0 - fabs (fmod (h / 60.0) 2.0) - 1.0)
	m: l - (c / 2.0)		
	if all [h >=   0.0 h <  60.0][rf: c gf: x bf: 0.0]
	if all [h >=  60.0 h < 120.0][rf: x gf: c bf: 0.0]
	if all [h >= 120.0 h < 180.0][rf: 0.0 gf: c bf: x]
	if all [h >= 180.0 h < 240.0][rf: 0.0 gf: x bf: c]
	if all [h >= 240.0 h < 300.0][rf: x gf: 0.0 bf: c]
	if all [h >= 300.0 h < 360.0][rf: c gf: 0.0 bf: x]
	;--as integer! rounds values towards zero
	rf: rf + m r: as integer! (rf * 255.0) 
	gf: gf + m g: as integer! (gf * 255.0) 
	bf: bf + m b: as integer! (bf * 255.0)
	int: integer/box r
    block/rs-append blk as red-value! int
    int: integer/box g
    block/rs-append blk as red-value! int
    int: integer/box b
    block/rs-append blk as red-value! int  
    as red-block! stack/set-last as cell! blk
]

rcvRGB2HSLb: function [
"RBG color to HSV conversion"
	src 	[image!] 	;--RGB Image
	return:	[block!]	;--HSV Values
][
	hsv: copy []
	rgb: src/rgb
	foreach [r g b] rgb [append hsv rgbToHSLb r g b] ;--HSV Values	
	hsv
] 

rcvRGB2HSLImage: function [
"RBG color to HSV image conversion"
	src 	[image!] 	;--RGB Image
	return:	[image!]	;--HSL Image
][
	;hsl: copy []
	crgb: copy []
	rgb: src/rgb
	foreach [r g b] rgb [
		blk: rgbToHSLb r g b 
		r: to integer! blk/1 / 360 * 255  
		g: to integer! blk/2 * 255 
		b: to integer! blk/3 * 255 
		if r > 255 [r: 255]
		if g > 255 [g: 255] 
		if b > 255 [b: 255]
		append crgb to-tuple reduce [r g b] ;--RGB value for pseudo visualisation	
	]
	make image! reduce [src/size to binary! crgb]	;--RGB image
] 

rcvBGR2HSLb: function [
"BGR color to HSV conversion"
	src 	[image!] 	;--BGR Image
	return:	[block!]	;--HSV Values
][
	hsl: copy []
	rgb: src/rgb
	foreach [r g b] rgb [append hsl rgbToHSLb b g r] ;--HSV Values
	hsl
] 

rcvBGR2HSLImage: function [
"BGR color to HSV image conversion"
	src 	[image!] 	;--BGR Image
	return:	[image!]	;--Output
][
	;hsv: copy []
	crgb: copy []
	rgb: src/rgb
	foreach [r g b] rgb [
		blk: rgbToHSLb r g b 
		r: to integer! blk/1 / 360 * 255 
		g: to integer! blk/2 * 255 
		b: to integer! blk/3 * 255 
		if r > 255 [r: 255]
		if g > 255 [g: 255]
		if b > 255 [b: 255]
		append crgb to-tuple reduce [b g r] ;--BGR value for pseudo visualisation	
	]
	make image! reduce [src/size to binary! crgb]	;--BGR image
] 

;--HSL->RGB or BGR
rcvHSL2RGBb: function [
"HSL color to RGB conversion"
	src		[image!]
	hsl		[block!]
	return: [image!]
] [
	m: copy []
	foreach [h s l] hsl [append m hsvToRGBb h s l]
	make image! reduce [src/size to binary! m]	;--RGB image
]

;************************* RGB<=>YCrCb JPEG (a.k.a. YCC) *****************
rcvYCrCb: routine [
    src [image!]
    dst  [image!]
    op	 [integer!]
    /local
    	pixel rgba		[subroutine!]
        pixS pixD 		[int-ptr!]
        handleS handleD	[integer!] 
        n i				[integer!]
        r g b a 		[integer!]
        rf gf bf 		[float!]
        yy cr cb		[float!]
        delta			[float!]
][
    handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    r: g: b: a: 0
    pixel: [(a << 24) OR (r << 16) OR (g << 8) OR b]
    rgba: [
    	a: pixS/value >>> 24
       	r: pixS/value and FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh     
    ]
    Yy: 0.0
	cr: 0.0
	cb: 0.0
    delta: 128.0; for 8-bit image 
    i: 0
    while [i < n] [
       	rgba
        rf: (as float! r) 
		gf: (as float! g)
		bf: (as float! b)
		Yy: (0.299 * rf) + (0.587 * gf) + (0.114 * bf) 
		cr: ((rf - Yy) * 0.713) + delta
		cb: ((bf - Yy) * 0.514) + delta 
		switch op [
			1 [r: as integer! Yy g: as integer! cr b: as integer! cb]
			2 [r: as integer! cb g: as integer! cr b: as integer! Yy]
		]
		pixD/value: pixel
        pixS: pixS + 1
        pixD: pixD + 1
       	i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

rcvYCrCbRGB: routine [
    src [image!]
    dst  [image!]
    op	 [integer!]
    /local
    	pixel rgba		[subroutine!]
        pixS pixD 		[int-ptr!]
        handleS handleD	[integer!] 
        n i				[integer!]
        r g b a 		[integer!]
        rf gf bf 		[float!]
        yy cr cb		[float!]
        delta			[float!]
][
	delta: 128.0; for 8-bit image 
    handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    r: g: b: a: 0
    pixel: [(a << 24) OR (r << 16) OR (g << 8) OR b]
    rgba: [
    	a: pixS/value >>> 24
       	r: pixS/value and FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh     
    ]
    i: 0
    while [i < n] [
       	rgba
       	yy: as float! r
		cr: as float! g
		cb: as float! b
		r: as integer! (yy + (1.403 * (cr - delta)))
		g: as integer! (yy - (0.714 * (cr - delta)) - (0.344 * (cb - delta)))
		b: as integer! (yy + (1.773 * (cb - delta)))
		switch op [
			1 [r: r g: g b: b]
			2 [r: b g: g b: r]
		]
		pixD/value: pixel
        pixS: pixS + 1
        pixD: pixD + 1
       	i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]


rcvRGB2YCrCb: function [
"RBG color to YCrCb conversion"
	src [image!] 
	dst [image!]
][
	rcvYCrCb src dst 1
] 

rcvBGR2YCrCb: function [
"BGR color to YCrCb conversion"
	src [image!] 
	dst [image!]
][
	rcvYCrCb src dst 2
]

rcvYCrCb2RGB: function [
"RBG color to YCrCb conversion"
	src [image!] 
	dst [image!]
][
	rcvYCrCbRGB src dst 1
] 

rcvYCrCb2BGR: function [
"RBG color to YCrCb conversion"
	src [image!] 
	dst [image!]
][
	rcvYCrCbRGB src dst 2
] 

; A REVOIR

;************************ RGB<=>CIE L*a*b**********************
rcvLab: routine [
    srcS [image!]
    dst  [image!]
    op	 [integer!]
    /local
    	pixel rgba		[subroutine!]
        pixS 			[int-ptr!]
        pixD 			[int-ptr!]
        handleS handleD	[integer!] 
        n i				[integer!]
        r g b a 		[integer!]
        rf gf bf 		[float!]
        xf yf zf		[float!]
        l aa bb			[float!]
        delta 			[float!]
        ratio ratio2	[float!]
][
    handleS: handleD: 0
    pixS: image/acquire-buffer srcS :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(srcS/size) * IMAGE_HEIGHT(srcS/size)
    r: g: b: a: 0
    pixel: [(a << 24) OR (b << 16) OR (g << 8) OR r]
    rgba: [
    	a: pixS/value >>> 24
       	r: pixS/value and FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh     
    ]
    delta: 128.0
    ratio: 1.0 / 3.0
    ratio2: 16.0 / 116.0
    i: 0
    while [i < n] [
       	rgba
        rf: (as float! r) / 255.0
		gf: (as float! g) / 255.0
		bf: (as float! b) / 255.0
		xf: (rf * 0.412453) + (gf *  0.357580) + (bf * 0.180423)
    	yf: (rf * 0.212671) + (gf *  0.715160) + (bf * 0.072169)
    	zf: (rf * 0.019334) + (gf *  0.119193) + (bf * 0.950227)
    	xf: xf / 0.950456
    	zf: zf / 1.088754
    	either yf > 0.008856 [l: 116.0 *  pow yf ratio] [l: 903.3 * yf]			
    	either yf > 0.008856 [aa: 500.0 * (pow xf ratio) - (pow yf ratio) + delta
    						bb: 200.0 * (pow yf ratio) - (pow zf ratio) + delta] 
    				[aa: 500.0 * (7787.0 * xf + ratio2) - (7787.0 * yf + ratio2)
    				 bb: 200.0 * (7787.0 * yf + ratio2) - (7787.0 * zf + ratio2)
    				]
		l: l * 255.0 / 100.0
		aa: aa + 128.0
		bb: bb + 128.0
    	switch op [
    		1 [r: as integer! l g: as integer! aa b: as integer! bb] ;rgb
    		2 [r: as integer! bb g: as integer! aa b: as integer! l] ;bgr
    	]	
    	pixD/value: pixel	
        pixS: pixS + 1
        pixD: pixD + 1
        i: i + 1
    ]
    image/release-buffer srcS handleS no
    image/release-buffer dst handleD yes
]


rcvRGB2Lab: function [
"RBG color to CIE L*a*b conversion"
	src [image!] 
	dst [image!]
][
	rcvLab src dst 1
] 

rcvBGR2Lab: function [
"BGR color to CIE L*a*b conversion"
	src [image!] 
	dst [image!]
][
	rcvLab src dst 2
]

rcvLuv: routine [
    src [image!]
    dst  [image!]
    op	 [integer!]
    /local
    	pixel rgba		[subroutine!]
        pixS 			[int-ptr!]
        pixD 			[int-ptr!]
        handleS handleD	[integer!] 
        n i				[integer!]
        r g b a 		[integer!]
        rf gf bf 		[float!]
        xf yf zf 		[float!]
        l u v 			[float!]
        uu vv ratio		[float!]
][
    handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    r: g: b: a: 0
    pixel: [(a << 24) OR (b << 16) OR (g << 8) OR r]
    rgba: [
    	a: pixS/value >>> 24
       	r: pixS/value and FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh     
    ]
    ratio: 1.0 / 3.0
    i: 0
    while [i < n] [
       	rgba
        ; convert R,G,B to CIE XYZ
        rf: (as float! r) / 255.0
		gf: (as float! g) / 255.0
		bf: (as float! b) / 255.0
		xf: (rf * 0.412453) + (gf *  0.357580) + (bf * 0.180423)
    	yf: (rf * 0.212671) + (gf *  0.715160) + (bf * 0.072169)
    	zf: (rf * 0.019334) + (gf *  0.119193) + (bf * 0.950227)
    	either yf > 0.008856 [l: (116.0 * pow yf ratio) - 16.00] 
    				[l: 903.3 * yf]	
    	;convert XYZ to CIE Luv
    	uu: (4.0 * xf) / (xf + 15.00 * yf + 3.0 * zf)			
    	vv: (9.0 * yf) / (xf + 15.00 * yf + 3.0 * zf)
    	u: 13.00 * l * (uu - 0.19793943)
		v: 13.00 * l * (vv - 0.46831096)
		l: (l / 100.0) * 255.0
		u: ((u + 134.0)  / 354.0) * 255.0
		v: ((v + 140.0)  / 266.0) * 255.0    	 
    	switch op [
    		1 [r: as integer! l g: as integer! u b: as integer! v] ;rgb
    		2 [r: as integer! v g: as integer! u b: as integer! l] ;bgr
    	]	
    	pixD/value: pixel
        pixS: pixS + 1
        pixD: pixD + 1
       	i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

;**************************** RGB <> LUV ******************************
rcvRGB2Luv: function [
"RBG color to CIE L*u*v conversion"
	src [image!] 
	dst [image!]
][
	rcvLuv src dst 1
] 

rcvBGR2Luv: function [
"BGR color to CIE L*u*v conversion"
	src [image!] 
	dst [image!]
][
	rcvLuv src dst 2
]

_logOpp: routine [
	value [float!]
	return: [float!]
] [
	105.0 * log-10 (value + 1.0)
]

rcvIRgBy: routine [
"log-opponent conversion"
    src [image!]
    dst  [image!]
    val	 [integer!]
    /local
    	pixel rgba		[subroutine!]
        pixS 			[int-ptr!]
        pixD 			[int-ptr!]
        handleS handleD [integer!] 
        n i				[integer!] 
        r g b a 		[integer!] 
        rf gf bf 		[float!]
        int rG bY 		[float!]
][
    handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    r: g: b: a: 0
    rgba: [
    	a: pixS/value >>> 24
       	r: pixS/value and FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh     
    ]
    pixel: [(a << 24) OR (b << 16 ) OR (g << 8) OR r]
    i: 0
    while [i < n] [
       	a: pixS/value >>> 24
		r: pixS/value and FF0000h >> 16 
		g: pixS/value and FF00h >> 8 
		b: pixS/value and FFh 
		rf: as float! r * val
		gf: as float! g * val
		bf: as float! b * val
		int: (_logOpp rf + _logOpp bf + _logOpp gf) / 3.0
		rG: _logOpp rf - _logOpp gf 
		bY: _logOpp bf  - ((_logOpp gf + _logOpp rf) / 2.0)
		r: as integer! int
		g: as integer! rg
		b: as integer! by
		pixD/value: pixel	
		pixS: pixS + 1
		pixD: pixD + 1
		i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

rcvIR2RGB: routine [
"Pseudo-color to RGB image"
    src 	[image!]
    dst  	[image!]
    mat	 	[vector!]
    op		[integer!]
    /local
    	pixel rgba		[subroutine!]
        pixS pixD 		[int-ptr!]
        pMat 			[float-ptr!]
        handleS handleD	[integer!] 
        i n				[integer!]
        r g b a 		[integer!]
        rf gf bf 		[float!]
        xf yf zf		[float!]
][
    handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    pMat: as float-ptr! vector/rs-head mat
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    r: g: b: a: 0
    rgba: [
    	a: pixS/value >>> 24
       	r: pixS/value and FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh     
    ]
    pixel: [(a << 24) OR (r << 16) OR (g << 8) OR b]
    i: 0
    while [i < n] [
       	rgba     
        rf: as float! r 
		gf: as float! g 
		bf: as float! b   	
		xf: (rf * pMat/1) + (gf *  pMat/2) + (bf * pMat/3)
    	yf: (rf * pMat/4) + (gf *  pMat/5) + (bf * pMat/6)
    	zf: (rf * pMat/7) + (gf *  pMat/8) + (bf * pMat/9)	
    	switch op [
    		1 [r: as integer! xf g: as integer! yf b: as integer! zf] ;rgb
    		2 [r: as integer! zf g: as integer! yf b: as integer! xf] ;bgr
    	] 
    	pixD/value: pixel
        pixS: pixS + 1
        pixD: pixD + 1
        i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

;--new
;*********************** RGB<=>YIQ ******************************

{RGB to YIQ conversion is used in the NTSC encoder where the RGB inputs are converted to a luminance (Y) and two chrominance information (I,Q).}

;--OK
rcvRGBYIQ: routine [
    src 	[image!]
    dst  	[image!]
    /local
    	pixel yiq				[subroutine!]
        pixS 					[int-ptr!]
        pixD 					[int-ptr!]
        handleS handleD			[integer!] 
        r g b a n ct			[integer!]
        rf gf bf 				[float!]
        Y I Q					[float!]
        YY II QQ 				[integer!]
][
    handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    r: g: b: a: 0
    rf: gf: bf: 0.0
    Y: I: Q: 0.0
	YY: II: QQ: 0
	;--subroutines
    pixel: [(a << 24) OR (YY << 16) OR (II << 8) OR QQ] ;--use RGB mode 
    ;pixel: [(a << 24) OR (QQ << 16) OR (II << 8) OR YY] ;--use RGB mode 
    yiq: [
    	a: pixS/value >>> 24
       	r: pixS/value and FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh   
        rf: (as float! r) / 255.0							;--[0:1] normalization
		gf: (as float! g) / 255.0							;--[0:1] normalization
		bf: (as float! b) / 255.0 							;--[0:1] normalization 
		Y: (rf * 0.299) + (gf * 0.587) + (bf * 0.114) 		;--luminance
		I: (rf * 0.596) + (gf * -0.275) + (bf * -0.322)		;--chrominance 
		Q: (rf * 0.212) + (gf * -0.523) + (bf * 0.311) 		;--chrominance
		;i: -0.27 * (bf - y) + 0.74 * (rf - y)
		;q: 0.41 * (bf - y) + 0.48 * (rf - y)
		YY: as integer! (Y * 255.0) 
		II: as integer! (I * 255.0) 
		QQ: as integer! (Q * 255.0) 
		;print-wide [(yy + ii + qq) / 3 lf]
		if YY < 0 [YY: 0] 	;--[0:255] range
		if II < 0 [II: 0]		;--[0:255] range 
		if QQ < 0 [QQ: 0]		;--[0:255] range 
    ]
    
	ct: 0
    while [ct < n] [
       	yiq
    	pixD/value: pixel	
        pixS: pixS + 1
        pixD: pixD + 1
        ct: ct + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

;--some default in rendering

rcvYIQRGB: routine [
    src 	[image!]
    dst  	[image!]
	/local
    	pixel rgba				[subroutine!]
        pixS 					[int-ptr!]
        pixD 					[int-ptr!]
        handleS handleD			[integer!] 
        r g b a n ct			[integer!]
        Y I Q					[integer!]
        rf gf bf 				[float!]
        fy fi fq				[float!]
][
	handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    rf: gf: bf: 0.0
    fy: fi: fq: 0.0
    r: g: b: 0
    ;--subroutines
    pixel: [(a << 24) OR (r << 16) OR (g << 8) OR b] ;--rgb order
    ;pixel: [(a << 24) OR (b << 16) OR (g << 8) OR r] ;--bgr order
    rgba: [
    	a: pixS/value >>> 24
       	Y: pixS/value and FF0000h >> 16 
        I: pixS/value and FF00h >> 8 
        Q: pixS/value and FFh  
        fy: as float! Y fi: as float! I fq: as float! Q
        fy: fy / 255.0	;--[0:1] normalization
        fi: fi / 255.0	;--[0:1] normalization
        fq: fq / 255.0	;--[0:1] normalization
        
        rf: fy + (fi * 0.956) + (fq * 0.621)
        gf: fy - (fi * 0.272) - (fq * 0.647)
        bf: fy - (fi * 1.105) + (fq * 1.702)
        
    	r: as integer! (rf * 255.0)	;--[0:255] range
		g: as integer! (gf * 255.0)	;--[0:255] range
		b: as integer! (bf * 255.0)	;--[0:255] range
    ]
    ct: 0
    while [ct < n] [
       	rgba
    	pixD/value: pixel	
        pixS: pixS + 1
        pixD: pixD + 1
        ct: ct + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

rcvRGB2YIQ: function [
"RBG color to HSV conversion"
	src [image!] 
	dst [image!]
][
	rcvRGBYIQ src dst 
] 

rcvYIQ2RGB: function [
"RBG color to HSV conversion"
	src [image!] 
	dst [image!]
][
	rcvYIQRGB src dst 
] 

