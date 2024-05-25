Red [
	Title:   "Red Computer Vision: Image Processing"
	Author:  "Francois Jouen"
	File: 	 %rcvColorSpace.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2020 Francois Jouen. All rights reserved."
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

;***********************RGB<=>HSV******************************

;R, G and B input range = 0..255
;H, S and V output range = 0..1.0

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
        v1 v2 v3 f				[float!]
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
		either s = 0.0 [r: g: b: (as integer! v * 255.0)][
    		hh: h * 6.0
    		if hh = 6.0 [hh: 0.0] 	;--H must be < 1.0
    		ii: floor hh	  		;--ii = floor hh ->int
    		f: 1.0 - s
    		v1: v * f
    		v2: v * f * (hh - ii)
    		v3: v * f * (1.0 - hh - ii)
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
			1 [r: as integer! rf * 255.0 g: as integer! gf * 255.0 b: as integer! bf * 255.0 ]
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
