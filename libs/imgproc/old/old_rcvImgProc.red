Red [
	Title:   "Red Computer Vision: Image Processing"
	Author:  "Francois Jouen"
	File: 	 %rcvImgProc.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;********************** NEW MATRIX OBJECT **************************

#include %../matrix/matrix-as-obj/matrix-obj.red
#include %../matrix/matrix-as-obj/routines-obj.red
#include %../core/rcvCore.red

;***************** COLORSPACE CONVERSIONS ************
; Based on  OpenCV 3.0 implementation for 8-bit image

;RGB<=>CIE XYZ.Rec 709 with D65 white point
rcvXYZ: routine [
    src1 [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a rf gf bf xf yf zf
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh         
        rf: as float! r 
		gf: as float! g 
		bf: as float! b   	
		xf: (rf * 0.412453) + (gf *  0.357580) + (bf * 0.180423)
    	yf: (rf * 0.212671) + (gf *  0.715160) + (bf * 0.072169)
    	zf: (rf * 0.019334) + (gf *  0.119193) + (bf * 0.950227)	
    	switch op [
    		1 [r: as integer! zf g: as integer! yf b: as integer! xf] ;rgb
    		2 [r: as integer! xf g: as integer! yf b: as integer! zf] ;bgr
    	] 	
    	pixD/value: ((a << 24) OR (b << 16 ) OR (g << 8) OR r)	
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]


rcvRGB2XYZ: function [
"RGB to CIE XYZ color conversion"
	src [image!] 
	dst [image!]
][
	rcvXYZ src dst 1
] 

rcvBGR2XYZ: function [
"BGR to CIE XYZ color conversion"
	src [image!] 
	dst [image!]
][
	rcvXYZ src dst 2
] 

rcvXYZ2RGB: routine [
"CIE XYZ to RBG color conversion"
    src1 [image!]
    dst  [image!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a rf gf bf xf yf zf
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24				; a
       	r: pix1/value and FF0000h >> 16		; X  
        g: pix1/value and FF00h >> 8 		; Y  
        b: pix1/value and FFh 				; Z 
        xf: as float! r
		yf: as float! g
		zf: as float! b
		rf: (xf * 3.240479) + (yf * -1.53715) + (zf * -0.498535)			
		gf: (xf * -0.969256) + (yf * 1.875991) + (zf * 0.041556)
		bf: (xf * 0.055648)+ (yf * -0.204043) + (zf * 1.057311)
		r: as integer! (xf * 255.0) 
    	g: as integer! (yf * 255.0) 
    	b: as integer! (zf * 255.0)
    	pixD/value: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)	
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]



;RGB<=>HSV

rcvHSV: routine [
    src1 [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a rf gf bf 
        mini maxi
        hh s v
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    hh: 0.0
	s: 0.0
	v: 0.0
	mini: 0.0
	maxi: 0.0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh 
        rf: (as float! r) / 255.0
		gf: (as float! g) / 255.0
		bf: (as float! b) / 255.0
		either rf < gf [mini: rf] [mini: gf]
		if bf < mini [mini: bf] 
		either rf > gf [maxi: rf] [maxi: gf]
		if bf > maxi [maxi: bf]	
		v: maxi	
		; either grayscale no chroma ... or color chromatic data
		either (maxi - mini = 0.0) [s: 0.0 hh: 0.0] 
			[s: (v - mini) / v
			if v = rf [hh: (gf - bf) * 60 / s ]
			if v = gf [hh: 180.0 + (bf - rf) * 60 / s ]
			if v = bf [hh: 240.0 + (rf - gf) * 60 / s ]]
		if hh < 0.0 [ hh: hh + 360.0]
		switch op [
			1 [r: as integer! hh / 2 g: as integer! s * 255 b: as integer! v * 255]
			2 [r: as integer! v * 255 g: as integer! s * 255 b: as integer! hh / 2 ]
		]
    	pixD/value: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)	
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]


rcvRGB2HSV: function [
"RBG color to HSV conversion"
	src [image!] 
	dst [image!]
][
	rcvHSV src dst 1
] 

rcvBGR2HSV: function [
"BGR color to HSV conversion"
	src [image!] 
	dst [image!]
][
	rcvHSV src dst 2
] 

;RGB<=>YCrCb JPEG (a.k.a. YCC)
rcvYCrCb: routine [
    src1 [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a rf gf bf 
        yy cr cb
        delta
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    Yy: 0.0
	cr: 0.0
	cb: 0.0
    delta: 128.0; for 8-bit image 
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh 
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
		pixD/value: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)	
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
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

;RGB<=>HLS
rcvHLS: routine [
    src1 [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a rf gf bf 
        mini maxi l
        hh s
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    hh: 0.0
	s: 0.0
	mini: 0.0
	maxi: 0.0
	l: 0.0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh 
        rf: (as float! r) / 255.0
		gf: (as float! g) / 255.0
		bf: (as float! b) / 255.0
		either rf < gf [mini: rf] [mini: gf]
		if bf < mini [mini: bf] 
		either rf > gf [maxi: rf] [maxi: gf]
		if bf > maxi [maxi: bf]
		l: (maxi + mini) / 2
		either l < 0.5 [s: (maxi - mini ) / (maxi + mini)]
				[ s: (maxi - mini ) / (2.0 - (maxi + mini))]
		if maxi = rf [hh: (gf - bf) * 60 / s]
		if maxi = gf [hh: 180.0 + (bf - rf) * 60 / s]	
		if maxi = bf [hh: 240.0 + (rf - gf) * 60 / s]	
		if hh < 0.0 [ hh: hh + 360.0]
		switch op [
			1 [r: as integer! hh / 2 g: as integer! l * 255 b: as integer! s * 255]
			2 [r: as integer! s * 255 g: as integer! l * 255 b: as integer! hh / 2 ]
		]
    	pixD/value: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)	
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]

rcvRGB2HLS: function [
"RBG color to HLS conversion"
	src [image!] 
	dst [image!]
][
	rcvHLS src dst 1
] 

rcvBGR2HLS: function [
"BGR color to HLS conversion"
	src [image!] 
	dst [image!]
][
	rcvHLS src dst 2
]

; A REVOIR
;RGB<=>CIE L*a*b* 
rcvLab: routine [
    src1 [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a rf gf bf xf yf zf l aa bb
        delta ratio ratio2
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    delta: 128.0
    ratio: 1.0 / 3.0
    ratio2: 16.0 / 116.0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh  
        rf: as float! r / 255.0
		gf: as float! g / 255.0
		bf: as float! b / 255.0
		xf: (rf * 0.412453) + (gf *  0.357580) + (bf * 0.180423)
    	yf: (rf * 0.212671) + (gf *  0.715160) + (bf * 0.072169)
    	zf: (rf * 0.019334) + (gf *  0.119193) + (bf * 0.950227)
    	xf: xf / 0.950456
    	zf: zf / 1.088754
    	either yf > 0.008856 [l: 116.0 *  (pow yf ratio)] [l: 903.3 * yf]			
    	either yf > 0.008856 [aa: 500.0 * ((pow xf ratio) - (pow yf ratio)) + delta
    						bb: 200.0 * ((pow yf ratio) - (pow zf ratio)) + delta] 
    				[aa: 500.0 * ((7787.0 * xf + ratio2) - (7787.0 * yf + ratio2))
    				 bb: 200.0 * ((7787.0 * yf + ratio2) - (7787.0 * zf + ratio2))
    				]
		l: l * 255.0 / 100.0
		aa: aa + 128.0
		bb: bb + 128.0
    	switch op [
    		1 [r: as integer! l g: as integer! aa b: as integer! bb] ;rgb
    		2 [r: as integer! bb g: as integer! aa b: as integer! l] ;bgr
    	]	
    	pixD/value: (a << 24) OR (b << 16) OR (g << 8) OR r	
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
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
    src1 [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a rf gf bf xf yf zf 
        l u v uu vv 
       ratio
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    ratio: 1.0 / 3.0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh 
        ; convert R,G,B to CIE XYZ
        rf: as float! r / 255.0
		gf: as float! g / 255.0
		bf: as float! b / 255.0
		xf: (rf * 0.412453) + (gf *  0.357580) + (bf * 0.180423)
    	yf: (rf * 0.212671) + (gf *  0.715160) + (bf * 0.072169)
    	zf: (rf * 0.019334) + (gf *  0.119193) + (bf * 0.950227)
    	either yf > 0.008856 [l: (116.0 * (pow yf ratio)) - 16.00] 
    				[l: 903.3 * yf]	
    	;convert XYZ to CIE Luv
    	uu: (4.0 * xf) / (xf + 15.00 * yf + 3.0 * zf)			
    	vv: (9.0 * yf) / (xf + 15.00 * yf + 3.0 * zf)
    	u: 13.00 * l * (uu - 0.19793943)
		v: 13.00 * l * (vv - 0.46831096)
		l: l / 100.0 * 255.0
		u: (u + 134.0)  / 354.0 * 255.0
		v: (v + 140.0)  / 266.0 * 255.0    	 
    	switch op [
    		1 [r: as integer! l g: as integer! u b: as integer! v] ;rgb
    		2 [r: as integer! v g: as integer! u b: as integer! l] ;bgr
    	]	
    	pixD/value: (a << 24) OR (b << 16 ) OR (g << 8) OR r	
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]


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
    src1 [image!]
    dst  [image!]
    val	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD 
        h w x y
        r g b a rf gf bf 
        i rG bY 
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
       		a: pix1/value >>> 24
       		r: pix1/value and FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
        	b: pix1/value and FFh 
        	rf: as float! r * val
			gf: as float! g * val
			bf: as float! b * val
			i: (_logOpp rf + _logOpp bf + _logOpp gf) / 3.0
			rG: _logOpp rf - _logOpp gf 
			bY: _logOpp bf  - ((_logOpp gf + _logOpp rf) / 2.0)
			r: as integer! i
			g: as integer! rg
			b: as integer! by
    		pixD/value: (a << 24) OR (b << 16 ) OR (g << 8) OR r	
        	pix1: pix1 + 1
        	pixD: pixD + 1
        	x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]

{mat: make vector! [
	0.1 0.9 0.0 
	0.3 0.0 0.7
	0.1 0.1 0.8
]}
rcvIR2RGB: routine [
"Pseudo-color to RGB image"
    src 	[image!]
    dst  	[image!]
    mat	 	[vector!]
    op		[integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        pMat [float-ptr!]
        handle1 handleD h w x y
        r g b a rf gf bf xf yf zf
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    pMat: as float-ptr! vector/rs-head mat
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh         
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
    	pixD/value: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)	
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


;******************* Image Transformations *****************************
rcvCropImage: routine [
"Crop source image to destination image"
    src 	[image!]
    dst  	[image!]
    origin	[pair!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y l idx
        pos
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    l: IMAGE_WIDTH(src/size)
    w: IMAGE_WIDTH(dst/size)
    h: IMAGE_HEIGHT(dst/size)
    y: 0
    pos: (origin/y * l) + origin/x
    idx: pix1 + pos
    while [y < h] [
    	x: 0
       	while [x < w][
       	 	pixD/value: idx/value
           	pixD: pixD + 1
           	idx: idx + 1
           	x: x + 1
       	]
       	origin/y: origin/y + 1
       	pos: (origin/y * l) + origin/x
       	idx: pix1 + pos
       	y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


rcvPyrDown: function [
"Performs downsampling step of Gaussian pyramid decomposition"
	src 	[image!]
][
	tmpImg: make image! reduce [src/size black]
	iSize: src/size
	nSize: iSize / 2
	knl: rcvMakeGaussian 5x5 1.0
	rcvFilter2D src tmpImg knl 1.0 0.0
	rcvResizeImage tmpImg nSize
]

rcvPyrUp: function [
"Performs up-sampling step of Gaussian pyramid decomposition"
	src 	[image!]
][
	tmpImg: make image! reduce [src/size black]
	iSize: src/size
	nSize: iSize * 2
	knl: rcvMakeGaussian 5x5 1.0
	rcvFilter2D src tmpImg knl 1.0 0.0
	rcvResizeImage tmpImg nSize
]

rcvScaleImage: function [
"Returns a Draw block for image scaling"
	factor [float!] 
	img [image!] 
][
	compose [scale (factor) (factor) image (img)]
]

rcvRotateImage: function [
"Returns a Draw block for image rotation"
	scaleValue 		[float!] 
	translateValue 	[pair!] 
	angle 			[float!] 
	center 			[pair!]  
	img 			[image!]
][
	compose [scale (scaleValue) (scaleValue) translate (translateValue) rotate (angle) (center) image (img)]
]

rcvTranslateImage: function [
"Returns a Draw block for image translation"
	scaleValue 		[float!] 
	translateValue 	[pair!] 
	img 			[image!]
][
	compose [scale (scaleValue) (scaleValue) translate (translateValue) image (img)]
]

rcvSkewImage: function [
"Returns a Draw block for image transformation"
	scaleValue 		[float!] 
	translateValue 	[pair!] 
	x 				[number!] 
	y 				[number!] 
	img 			[image!] 
][
	compose [scale (scaleValue) (scaleValue) translate (translateValue) skew (x) (y) image (img)]
]


rcvClipImage: function [
"Returns a Draw block for image clipping"
	translateValue 	[pair!] 
	start 			[pair!] 
	end 			[pair!] 
	img 			[image!]  
][
	compose [translate (translateValue) clip (start) (end) image (img)]
]

rcvFlipHV: routine [
"Left Right, Up down or both directions flip"
    src  [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        handle1 handleD h w x y        
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx: null
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
        switch op [
        	0 [idx: pix1 + (y * w) + x] 				; no change
            1 [idx: pix1 + (y * w) + (w - x) - 1] 		;left/right
            2 [idx: pix1 + (w * h) - (y * w) + x - w] 	;up/down
            3 [idx: pix1 + (w * h) - (y * w) - x - 1]	;both flips
        ]  
        pixD/value: idx/value
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]



rcvFlip: function [
"Left Right, Up down or both directions flip"
	src [image!] 
	dst [image!] 
	/horizontal /vertical /both 
][
	case [
		horizontal 	[rcvFlipHV src dst 1]
		vertical 	[rcvFlipHV src dst 2]
		both		[rcvFlipHV src dst 3]
	]	
]

;********************** Effects on Image *****************************
;General routine
rcvEffect: routine [
    src  	[image!]
    dst  	[image!]
    param1	[float!]
    op		[integer!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        idx2	[int-ptr!]
        handle1 handleD h w x y 
        xF yF  
        xm ym   
        xx yy  
        x0 y0 
        d theta
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x0: w / 2.0 
    y0: h / 2.0
    d: 0.0
    theta: 0.0
    y: 0
    while [y < h] [
    	x: 0
    	while [x < w][
    		xF: as float! x
    		yF: as float! y
        	switch op [
        		1 [	; Glass effect HZ
        			xF: xF + (randf param1 * 5.0) 
        			yF: as float! y
        		]
        		
        		2 [	; Glass effect Vx 
        			xF: as float! x
        		    yF: yF + (randf param1 * 5.0)
        		]
        		
        		3 [	; Glass effect both
        			xF: xF + (randf param1 * 5.0) 
        		    yF: yF + (randf param1 * 5.0)
        		]
        		
        		4 [	; Glass effect O1
        			xF: xF + (randf param1 * 5.0) 
        		    yF: yF - (randf param1 * 5.0)
        		]
        		5 [	; Glass effect O2
        			xF: xF - (randf param1 * 5.0) 
        		    yF: yF + (randf param1 * 5.0)
        		]
        		6 [; Swirl effect
        			xx: xF - x0 
					yy: yF - y0
					d: sqrt((xx * xx) + (yy * yy))
        			theta: pi / param1 * d
					xf: (xx * cos theta) - (yy * sin theta) + x0
					yf: (xx * sin theta) + (yy * cos theta) + y0 
        		]
        	]
        	xm: as integer! xF
        	ym: as integer! yF
        	if all [xm > 0 ym > 0 xm < w ym < h] [
        		idx:  pix1 + (y * w + x) 	; source pixel
        		idx2: pixD + (ym * w + xm) 	; dest pixel
        		idx2/value: idx/value
        	]
        	x: x + 1
       ]
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


rcvGlass: function [
"Glass effect on image"
	src [image!] 
	dst [image!] 
	v	[float!] ; random value
	op	[integer!]
][
	rcvEffect src dst v op
]


rcvSwirl: function [
"Swirl effect on image"
	src 	[image!] 
	dst 	[image!] 
	theta	[float!]
][
	rcvEffect src dst theta 6
]


; wave effects
rcvWave: routine [
    src  	[image!]
    dst  	[image!]
    param1	[float!]
    param2	[float!]
    op		[integer!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        idx2	[int-ptr!]
        handle1 handleD h w x y 
        yF xF
        xm ym 
        xx  yy 
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    y: 0
    while [y < h] [
    	yF: as float! y
    	yy: yF
    	x: 0
    	while [x < w][
        	xF: as float! x
        	xx: xF
        	yy: yF
        	switch op [
        		1 [yy: yF + (param1 * sin(2.0 * pi * xF / param2))]
        	 	2 [xx: xF + (param1 * sin(2.0 * pi * yF / param2))]
        	 	3 [xx: xF + (param1 * sin(2.0 * pi * yF / param2))
        	 		yy: yF + (param1 * sin (2.0 * pi * xF / param2))]
        	]
        	xm: as integer! xx 
        	ym: as integer! yy
        	if all [xm > 0 ym > 0 xm < w ym < h] [
        		idx:  pix1 + (y * w + x) 	; source pixel
        		idx2: pixD + (ym * w + xm) 	; dst pixel
				idx2/value: idx/value
			]
        	x: x + 1
       ]
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]

rcvWaveH: function [
"Wawe effect on image"
	src 	[image!] 
	dst 	[image!] 
	alpha	[float!]
	beta	[float!]
][
	rcvWave src dst alpha beta 1
]

rcvWaveV: function [
"Wave effect on image"
	src 	[image!] 
	dst 	[image!] 
	alpha	[float!]
	beta	[float!]
][
	rcvWave src dst alpha beta 2
]

rcvWaveHV: function [
"Wave effect on image"
	src 	[image!] 
	dst 	[image!] 
	alpha	[float!]
	beta	[float!]
][
	rcvWave src dst alpha beta 3
]





; *************** IMAGE CONVOLUTION *************************


{The 2D convolution operation isn't extremely fast, 
unless you use small filters. We'll usually be using 3x3 or 5x5 filters. 
There are a few rules about the filter:
Its size has to be uneven, so that it has a center, for example 3x3, 5x5, 7x7 or 9x9 are ok. 
The sum of all elements of the filter should be 1 if you want the resulting image to have the same brightness as the original
If the sum of the elements is larger than 1, the result will be a brighter image
If it's smaller than 1, a darker image. 
If the sum is 0, the resulting image isn't necessarily completely black, but it'll be very dark
Apart from using a kernel matrix, it also has a multiplier factor and a delta. 
After applying the filter, the factor will be multiplied with the result, and the bias added to it. 
So if you have a filter with an element 0.25 in it, but the factor is set to 2, all elements of the filter 
are  multiplied by two so that element 0.25 is actually 0.5. 
The delta can be used if you want to make the resulting image brighter. 
}

rcvConvolve: routine [
"Convolves an image with the kernel"
    src  	[image!]
    dst  	[image!]
    kernel 	[block!] 
    factor 	[float!]
    delta	[float!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        handle1 handleD h w x y i j
        pixel
        r g b
        accR accG accB
        f  imx imy 
		kWidth 
		kHeight 
		kBase 
		kValue  
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
    	accR: 0.0
        accG: 0.0 
        accB: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK  
            		imx:  (x + (i - (kWidth / 2)) + w ) % w 
        			imy:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: pix1 + (imy * w) + imx  ; corrected pixel index
            		r: idx/value and 00FF0000h >> 16 
        			g: idx/value and FF00h >> 8 
       				b: idx/value and FFh  
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted sums
        			accR: accR + ((as float! r) * f/value)
        			accG: accG + ((as float! g) * f/value)
        			accB: accB + ((as float! b) * f/value)
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        ; multiply and delta parameters
        r: as integer! ((accR * factor) + delta)				 
        g: as integer! ((accG * factor) + delta)
        b: as integer! ((accB * factor) + delta)				 
        if r < 0   [r: 0]
        if r > 255 [r: 255]
        if g < 0   [g: 0]
        if g > 255 [g: 255]
        if b < 0   [b: 0]
        if b > 255 [b: 255]				 
        pixD/value: (255 << 24) OR ( r << 16 ) OR (g << 8) OR b
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]

; Similar to convolution but the sum of the weights is computed during the summation, 
; and used to scale the result.

rcvFilter2D: routine [
"Basic convolution Filter"
    src  	[image!]
    dst  	[image!]
    kernel 	[block!] 
    factor	[float!]
    delta	[float!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        handle1 handleD h w x y i j
        ;pixel
        r g b
        rf gf bf
        accR accG accB
        weightSum
        f  imx imy 
		kWidth 
		kHeight 
		kBase 
		kValue  
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
    	weightSum: 0.0
    	accR: 0.0
        accG: 0.0 
        accB: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		imx:  (x + (i - (kWidth / 2)) + w ) % w 
        			imy:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: pix1 + (imy * w) + imx  ; corrected pixel index
            		r: idx/value and 00FF0000h >> 16 
        			g: idx/value and FF00h >> 8 
       				b: idx/value and FFh  
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate  Sigma of weighted values
        			accR: accR + ((as float! r) * f/value)
        			accG: accG + ((as float! g) * f/value)
        			accB: accB + ((as float! b) * f/value)
        			weightSum: weightSum + f/value
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        if weightSum = 0.0 [weightSum: 1.0]; no division by zero!
        rf: accR / weightSum	
        gf: accG / weightSum
        bf: accB / weightSum
        
        rf: rf * factor + delta
        gf: gf * factor + delta
        bf: bf * factor + delta
    						 						 
        r: as integer! rf
        g: as integer! gf
        b: as integer! bf
        if r < 0 [r: 0]
        if r > 255 [r: 255]
        if g < 0 [g: 0]
        if g > 255 [g: 255]
        if b < 0 [b: 0]
        if b > 255 [b: 255]	
       			 
        pixD/value: (255 << 24) OR (r << 16 ) OR (g << 8) OR b
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


; only for 1-channel image (8-bit)
rcvFastConvolve: routine [
"Convolves a 8-bit and 1-channel image with the kernel"
    src  	[image!]
    dst  	[image!]
    channel	[integer!]
    kernel 	[block!] 
    factor 	[float!]
    delta	[float!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        handle1 handleD h w x y i j
        pixel
        v
        accV 
        f  imx imy 
		kWidth 
		kHeight 
		kBase 
		kValue  
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
    	accV: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		imx:  (x + (i - (kWidth / 2)) + w ) % w 
        			imy:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: pix1 + (imy * w) + imx  ; corrected pixel index
            		switch channel [
						1 [v: idx/value and 00FF0000h >> 16 ]
						2 [v: idx/value and FF00h >> 8 ]
						3 [v: idx/value and FFh]
					]
					;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			accV: accV + ((as float! v) * f/value)
         			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        
        v: as integer! (accV * factor)						 
    	v: v + as integer! delta
        if v < 0 [v: 0]
        if v > 255 [v: 255]
        pixD/value: (255 << 24) OR (v << 16 ) OR (v << 8) OR v	
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]




; a faster version without controls on pixel value !
; basically for 1 channel gray scaled image
;the sum of the weights is computed during the summation, and used to scale the result

rcvFastFilter2D: routine [
"Faster convolution Filter"
    src  		[image!]
    dst  		[image!]
    kernel 		[block!] 
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        handle1 handleD h w x y i j
        pixel
        weightSum
        weightAcc
        f  imx imy 
		kWidth 
		kHeight 
		kBase 
		kValue  
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
       	weightAcc: 0.0 
    	weightSum: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		imx:  (x + (i - (kWidth / 2)) + w ) % w 
        			imy:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: pix1 + (imy * w) + imx  ; corrected pixel index
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			weightAcc: weightAcc + ((as float! idx/value) * f/value)
        			weightSum: weightSum + f/value
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        either (weightSum > 0.0) [pixD/value: as integer! (weightAcc / weightSum)] 
        						 [pixD/value: as integer! (weightAcc)]
       
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


; ********** spatial filters **************************

rcvPointDetector: function [
"Detects points"
	src 	[image! vector!] 
	dst 	[image! vector!] 
	param1 	[float!] 
	param2 [float!]
][
	knl: [-1.0 -1.0 -1.0 -1.0 8.0 -1.0 -1.0 -1.0 -1.0] ; OK
	t: type? src
	if t = vector! [
		rcvConvolveMat src dst 3x3 knl param1 param2
	]
	if t = image! [
		rcvConvolve src dst knl param1 param2
	]
]

rcvSharpen: function [
"Image sharpening"
	src 	[image! vector!] 
	dst 	[image! vector!] 
	iSize 	[pair!] 
] [
	
	knl: [0.0 -1.0 0.0 -1.0 5.0 -1.0 0.0 -1.0 0.0] ; OK
	t: type? src
	if t = vector! [
		rcvConvolveMat src dst iSize knl 1.0 0.0
	]
	if t = image! [
		rcvConvolve src dst knl 1.0 0.0
	]
]

rcvBinomialFilter: function [
"Binomial filter"
	src 	[image! vector!] 
	dst 	[image! vector!] 
	iSize 	[pair!]  
	f 		[float!]
][
	ff: negate f * (1.0 / 16.0)
	knl: reduce [ff 2.0 * ff ff 2.0 * ff (16 - f) * (1.0 / 16.0)  2.0 * ff ff 2.0 * ff ff]
	t: type? src
	if t = vector! [
		rcvConvolveMat src dst iSize knl 1.0 0.0
	]
	if t = image! [
		;rcvConvolve src dst knl 0.0 0.0
		rcvFilter2D src dst knl 1.0 0.0
	]
]



;Uniform Weight Convolutions
; Blurring is typical of low pass filters

rcvLowPass: function [
"This filter produces a simple average of the 9 nearest neighbors of each pixel in the image."
	src 	[image! vector!] 
	dst 	[image! vector!] 
	iSize 	[pair!]
][
	v: 1.0 / 9.0 ; since weights is  > zero 
	knl: reduce [v v v v v v v v v]
	t: type? src
	if t = vector! [
		rcvConvolveMat src dst iSize knl 1.0 0.0
	]
	if t = image! [
		rcvConvolve src dst knl 1.0 0.0
	]
]

;Non-Uniform (Binomial) Weight Convolution
rcvBinomialLowPass: function [
"Weights are formed from the coefficients of the binomial series."
	src 	[image! vector!] 
	dst 	[image! vector!] 
	iSize 	[pair!]
][
	l: 1.0 / 16.0; ; since weights is > zero
	knl: reduce [1.0 2.0 1.0 2.0 4.0 2.0 1.0 2.0 1.0]
	t: type? src
	if t = vector! [
		rcvConvolveMat src dst iSize knl l 0.0
	]
	if t = image! [
		rcvConvolve src dst knl l 0.0
	]
]

;shows the edges in the image
rcvHighPass: function [
"This filter produces a simple average  of the 9 nearest neighbors of each pixel in the image."
	src 	[image! vector!] 
	dst 	[image! vector!] 
	iSize 	[pair!]
][
	knl: [-1.0 -1.0 -1.0 -1.0 8.0 -1.0 -1.0 -1.0 -1.0]
	t: type? src
	if t = vector! [
		rcvConvolveMat src dst iSize knl 1.0 0.0
	]
	if t = image! [
		rcvConvolve src dst knl 1.0 0.0
	]
]

;subtraction of low pass from original image 
rcvHighPass2: function [
"This filter removes low pass values from original image."
	src 	[image! vector!] 
	dst 	[image! vector!] 
	iSize 	[pair!]
][
	knl: [-1.0 -1.0 -1.0 -1.0 8.0 -1.0 -1.0 -1.0 -1.0]
	t: type? src
	if t = vector! [
		rcvConvolveMat src dst iSize knl 1.0 0.0
	]
	if t = image! [
		tmp1: rcvCreateImage src/size
		rcvLowPass src tmp1 src/size;  same as rcvGaussianFilter src tmp1
		rcvSub src tmp1 dst
	]
]

;Non-Uniform (Binomial) Weight Convolutions
rcvBinomialHighPass: function [
"Non-Uniform (Binomial) Weight Convolution"
	src 	[image! vector!] 
	dst 	[image! vector!] 
	iSize 	[pair!]
][
	knl: [-1.0 -2.0 -1.0 -2.0 12.0 -2.0 -1.0 -2.0 -1.0]
	t: type? src
	if t = vector! [
		rcvConvolveMat src dst iSize knl 1.0 0.0
	]
	if t = image! [
		rcvConvolve src dst knl 1.0 0.0
	]
]

; for gaussian filters
; new function for Gaussian noise on image 

rcvGenerateNoise: routine [
"Generates Gaussian noise"
	src 	[image!]
	noise   [float!]
	t		[tuple!]
	/local
	pix		[int-ptr!] 
	idx		[int-ptr!] 
	handle 	[integer!]
	nPixels [float!] 	
	n		[integer!]
	x 		[integer!]
	y 		[integer!]
	pos 	[integer!]
	r 		[integer!]
	g		[integer!] 
	b		[integer!]
	w		[integer!]
	h		[integer!]
] [
	handle: 0
    pix: image/acquire-buffer src :handle 
    idx: pix
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
	nPixels: as float! (w * h) 
	nPixels: nPixels * noise 
	n: as integer! nPixels
	r: t/array1 and FFh 
	g: t/array1 and FF00h >> 8 
	b: t/array1 and 00FF0000h >> 16 
	loop n [
		x: as integer! ((as float! _random/rand) / 2147483647.0 * w)
      	y: as integer! ((as float! _random/rand) / 2147483647.0 * h)
      	pos: (y * w) + x
    	idx: pix + pos
		idx/Value: (255 << 24) OR (r << 16 ) OR (g << 8) OR b
	]
	image/release-buffer src handle yes	
]

rcvMakeGaussian: function [
"Creates a gaussian uneven kernel"
	kSize 	[pair!]
	sigma	[float!]
][
  gaussian: copy []
  n: kSize/x - 1 / 2
  sum: 0.0
  d: 0.0
  s2: 2.0 * power sigma 2.0
  j: negate n
  while [j <= n] [
  	i: negate n
  	while [i <= n] [
  		;(exp(-(r*r)/s))/(M_PI * s);
  		d: square-root (i * i) + (j * j)
  		g: exp (negate (d * d) / s2) / (pi * s2)
  		;g: (exp (negate(d * d) / s2)) / (pi * s2)
  		append gaussian g
  		sum: sum + g
  		i: i + 1
  	]
  	j: j + 1
  ]
  
  ; now normalize the kernel -> new sum = 1.0
  i: 1
  while [i <= (kSize/x * kSize/y)] [
  	gaussian/:i: gaussian/:i / sum
  	i: i + 1
  ] 
  gaussian	
]

; for testing 
rcvMakeGaussian2: function [
"Creates a gaussian uneven kernel"
	kSize 	[pair!]
	sigma	[float!]
][
  gaussian: copy []
  n: kSize/x - 1 / 2
  i: negate n
  j: negate n
  sum: 0.0
  d: 0.0
  s2: power sigma 2.0
  while [j <= n] [
  	i: negate n
  	while [i <= n] [
  		d: (power i 2.0) + (power j 2.0)
  		g1: 1.0 / (2.0 * pi * s2)
  		g2: exp (negate (d / (2.0 * s2)))
  		append gaussian g1 * g2
  		sum: sum + g1 * g2
  		i: i + 1
  	]
  	j: j + 1
  ]
  
  
  ; now normalize the kernel
  i: 1
  while [i <= (kSize/x * kSize/y)] [
  	gaussian/:i: gaussian/:i / sum
  	i: i + 1
  ] 
  gaussian	
]


rcvGaussianFilter: function [
"Gaussian 2D Filter"
	src 	[image! vector!] 
	dst 	[image! vector!]
	kSize 	[pair!]	 ;kernel size
	sigma	[float!] ;variance
][
	knl: rcvMakeGaussian kSize sigma
	t: type? src
	if t =  image!  [rcvFilter2D src dst knl 1.0 0.0]
	if t  = vector! [rcvConvolveMat src dst src dst knl 1.0 0.0]
]

rcvDoGFilter: function [
"Difference of Gaussian"
	src 	[image! vector!] 
	dst 	[image! vector!]
	iSize	[pair!] 	 
	kSize	[pair!]  
	sig1	[float!] 
	sig2	[float!] 
	factor 	[float!] 
][
	k1: rcvMakeGaussian kSize sig1
	k2: rcvMakeGaussian kSize sig2
	len: kSize/x * kSize/y
	i: 1
	k: copy []
	while [i <= len] [
		v: k1/(i) - k2/(i)
		append k v
		i: i + 1
	]
	t: type? src
	if t =  image!  [rcvConvolve src dst k factor 0.0]
	if t  = vector! [rcvConvolveMat src dst iSize k 1.0 0.0]
	
]


; median and mean filter for image smoothing
; new for image smoothing

_insertionSort: routine [
	arr 	[vector!]
	/local
	ptr		[int-ptr!]	
	n		[integer!]
	i 		[integer!]
	j		[integer!]
	j2		[integer!]
	tmp 	[integer!]
][
	n: vector/rs-length? arr
	ptr: as int-ptr! vector/rs-head arr
	i: 1
	while [i <= n] [
		j: 1
		while [j < i] [
			if ptr/i < ptr/j [
				j2: j + 1
				tmp: ptr/i
				ptr/i: ptr/j2
				ptr/j2: ptr/j
				ptr/j: tmp
			]
			j: j + 1
		]
		i: i + 1
	]
]

rcvMedianFiltering: routine [
"Median Filter for images"
    src  	[image!]
    dst  	[image!]
    kSize	[pair!]
    kernel 	[vector!]
    op	 	[integer!]
    /local
        pix1 	[int-ptr!]
        pix2	[int-ptr!]
        pixD 	[int-ptr!]
        idx 	[int-ptr!]
        kWidth 	[integer!]
    	kHeight	[integer!] 
        handle1 handleD h w x y n pos
        imx imy 
        kBase ptr
        edgex edgey
        fx fy 
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pix2: pix1	; for the current pixel 
    idx:  pix1	; for neighbor 
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    kWidth: kSize/x
    kHeight: kSize/y
    edgex: kWidth / 2
    edgey: kHeight / 2
    kBase: vector/rs-head kernel
    ptr: as int-ptr! kBase
    n: vector/rs-length? kernel
    pos: n / 2
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
       		;put neighbor values in kernel
           	vector/rs-clear kernel
    		fy: 0
    		while [fy < kHeight][
    			fx: 0
    			while [fx < kWidth][
    				;OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
    				imx: (x + fx - edgex + w) % w
    				imy: (y + fy - edgey + h) % h 
    				idx: pix1 + (imy * w) + imx 
    				vector/rs-append-int kernel idx/value
    				fx: fx + 1	
    			]
    			fy: fy + 1
    		]
    		_insertionSort kernel			; sort kernel
    		switch op [
    			0 [pixD/value: ptr/pos] 	; median filter
    			1 [pixD/value: ptr/1] 		; minimum filter
    			2 [pixD/value: ptr/n] 		; maximum filter
    			3 [if all [pix2/value >= ptr/1 pix2/value <= ptr/n] [pixD/value: pix2/value] 
    			   if pix2/value < ptr/1 [pixD/value: ptr/1]
    			   if pix2/value > ptr/n [pixD/value: ptr/n]
    			   ]; conservative non linear filter
    		]
    		pix2: pix2 + 1
    		pixD: pixD + 1
           	x: x + 1
       	]
       	y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


rcvMedianFilter: function [
"Median Filter for images"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!]
][	
	n: kSize/x * kSize/y
	kernel: make vector! n
	rcvMedianFiltering src dst kSize kernel 0
]


rcvMinFilter: function [
"Minimum Filter for images"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!]
][	n: kSize/x * kSize/y
	kernel: make vector! n
	rcvMedianFiltering src dst kSize kernel 1
]


rcvMaxFilter: function [
"Maximum Filter for images"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!]
][	
	n: kSize/x * kSize/y
	kernel: make vector! n
	rcvMedianFiltering src dst kSize kernel 2
]

rcvNLFilter: function [
"Non linear conservative filter for images"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!]
][	
	n: kSize/x * kSize/y
	kernel: make vector! n
	rcvMedianFiltering src dst kSize kernel 3
]


rcvMidPointFilter: routine [
"Midpoint Filter for images"
    src  	[image!]
    dst  	[image!]
    kSize	[pair!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx 	[int-ptr!]
        kWidth 	[integer!]
   		kHeight	[integer!] 
        handle1 handleD h w x y n 
        imx imy 
        edgex edgey
        kx ky
        r g b
        minr ming minb
        maxr maxg maxb
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx: pix1; 
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    kWidth: kSize/x
    kHeight: kSize/y
    edgex: kWidth / 2
    edgey: kHeight / 2
    n: kWidth * kHeight
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w ][
           	minr: 255
           	ming: 255
			minb: 255
           	maxr: 0
           	maxg: 0
           	maxb: 0
    		ky: 0
    		while [ky < kHeight][
    			kx: 0
    			while [kx < kWidth][
    				;OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
    				imx: (x + kx - edgex + w) % w
    				imy: (y + ky - edgey + h) % h 
    				idx: pix1 + (imy * w) + imx 
    				r: idx/value and 00FF0000h >> 16 
        			g: idx/value and FF00h >> 8 
       				b: idx/value and FFh  
       				if r > maxr [maxr: r]
       				if g > maxg [maxg: g]
       				if b > maxb [maxb: b]
       				if r < minr [minr: r]
       				if g < ming [ming: g]
       				if b < minb [minb: b]
    				kx: kx + 1	
    			]
    			ky: ky + 1
    		]
    		
    		r: minr + maxr / 2
    		g: ming + maxg / 2
    		b: minb + maxb / 2
    		
    		pixD/value: (255 << 24) OR ( r << 16 ) OR (g << 8) OR b
    		pixD: pixD + 1
           	x: x + 1
       	]
       	y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]

;op = 0 arithmetic, 1 harmonic, 2 geometric mean
;3 quadratic mean, 4 cubic mean, 5 rms
rcvMeanFilter: routine [
"Mean Filter for images"
    src  	[image!]
    dst  	[image!]
    kSize	[pair!]
    op	 	[integer!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx 	[int-ptr!]
        kWidth 	[integer!]
    	kHeight	[integer!] 
        handle1 handleD h w x y n 
        imx imy 
        edgex edgey
        kx ky
        sumr sumg sumb
        prodr prodg prodb
        r g b
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    kWidth: kSize/x
    kHeight: kSize/y
    edgex: kWidth / 2
    edgey: kHeight / 2
    n: kWidth * kHeight
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w ][
           	sumr: 0.0
           	sumg: 0.0
			sumb: 0.0
           	prodr: 1.0
           	prodg: 1.0
           	prodb: 1.0
    		ky: 0
    		while [ky < kHeight][
    			kx: 0
    			while [kx < kWidth][
    				;OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
    				imx: (x + kx - edgex + w) % w
    				imy: (y + ky - edgey + h) % h 
    				idx: pix1 + (imy * w) + imx 
    				r: idx/value and 00FF0000h >> 16 
        			g: idx/value and FF00h >> 8 
       				b: idx/value and FFh  
    				switch op [
    					0	[sumr: sumr + r
    						 sumg: sumg + g
    						 sumb: sumb + b]
    					1	[sumr: sumr + (1.0 / r)
    						 sumg: sumg + (1.0 / g)
    						 sumb: sumb + (1.0 / b)]
    					2	[prodr: prodr * r
    						 prodg: prodg * g
    						 prodb: prodb * b]
    					3	[sumr: sumr + as float! (r * r)
    						 sumg: sumg + as float! (g * g)
    						 sumb: sumb + as float! (b * b)]
    					4	[sumr: sumr + as float! (r * r * r)
    						 sumg: sumg + as float! (g * g * g)
    						 sumb: sumb + as float! (b * b * b)]
    					5	[sumr: sumr + as float! (r * r)
    						 sumg: sumg + as float! (g * g)
    						 sumb: sumb + as float! (b * b)]
    				]
    				kx: kx + 1	
    			]
    			ky: ky + 1
    		]
    		switch op [
    			0 	[r: as integer! 1.0 / n * sumr
    				 g: as integer! 1.0 / n * sumg
    				 b: as integer! 1.0 / n * sumb]				; arithmetic mean
    			1 	[r: as integer! (1.0 * n / sumr)
    				 g: as integer! (1.0 * n / sumg)
    				 b: as integer! (1.0 * n / sumb)]			; harmonic mean
    			2	[r: as integer! pow  prodr  (1.0 / n)
    				 g: as integer! pow  prodg  (1.0 / n)
    				 b: as integer! pow  prodb  (1.0 / n)]		; geometric mean
    			3	[r: as integer! sqrt (sumr / n)
    			     g: as integer! sqrt (sumg / n)
    			     b: as integer! sqrt (sumb / n)]			;quadratic mean
    			4	[r: as integer! pow (sumr / n) (1.0 / 3.0)
    			     g: as integer! pow (sumg / n) (1.0 / 3.0)
    			     b: as integer! pow (sumb / n) (1.0 / 3.0)]	;cubic mean
    			5 	[r: as integer! sqrt (1.0 / n * sumr)
    				 g: as integer! sqrt (1.0 / n * sumg)
    				 b: as integer! sqrt (1.0 / n * sumb)]				;rms 
    		]
    		pixD/value: (255 << 24) OR ( r << 16 ) OR (g << 8) OR b
    		pixD: pixD + 1
           	x: x + 1
       	]
       	y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


;***************** Fast edges detectors*******************
;G= Sqrt Gx^2 +Gy^2 Gets Gradient 

rcvMagnitude: routine [
    srcX  	[image!]
    srcY  	[image!]
    dst  	[image!]
    /local
        pixX 	[int-ptr!]
        pixY 	[int-ptr!]
        pixD 	[int-ptr!]
        handle1 handle2 handleD 
        h w x y
        r1 g1 b1
        r2 g2 b2
        r3 g3 b3
][
	handle1: 0
	handle2: 0
    handleD: 0
    pixX: image/acquire-buffer srcX :handle1
    pixY: image/acquire-buffer srcY :handle2
    pixD: image/acquire-buffer dst  :handleD
	w: IMAGE_WIDTH(srcX/size)
    h: IMAGE_HEIGHT(srcY/size)
    x: 0
    y: 0
    r3: 0
    g3: 0
    b3: 0
    while [y < h] [
		while [x < w][
       			r1: pixX/value and 00FF0000h >> 16 
        		g1: pixX/value and FF00h >> 8 
        		b1: pixX/value and FFh 
       			r2: pixY/value and 00FF0000h >> 16 
        		g2: pixY/value and FF00h >> 8 
        		b2: pixY/value and FFh 
        		r3: as integer! sqrt as float! ((r1 * r1) + (r2 * r2)) 
        		g3: as integer! sqrt as float! ((g1 * g1) + (g2 * g2))
        		b3: as integer! sqrt as float! ((b1 * b1) + (b2 * b2))
        		pixD/value: (255 << 24) OR (r3 << 16 ) OR (g3 << 8) OR b3
				pixX: pixX + 1
				pixY: pixY + 1
				pixD: pixD + 1
				x: x + 1
		]
		x: 0
		y: y + 1
	]
	image/release-buffer srcX handle1 no
	image/release-buffer srcY handle1 no
	image/release-buffer dst handleD yes
]

; atan Gy / Gx -> angle in degrees
rcvDirection: routine [
    srcX  	[image!]
    srcY  	[image!]
    dst  	[image!]
    /local
        pixX 	[int-ptr!]
        pixY 	[int-ptr!]
        pixD 	[int-ptr!]
        handle1 handle2 handleD 
        h w x y
        r1 g1 b1
        r2 g2 b2
        r3 g3 b3
][
	handle1: 0
	handle2: 0
    handleD: 0
    pixX: image/acquire-buffer srcX :handle1
    pixY: image/acquire-buffer srcY :handle2
    pixD: image/acquire-buffer dst :handleD
	w: IMAGE_WIDTH(srcX/size)
    h: IMAGE_HEIGHT(srcY/size)
    x: 0
    y: 0
    r3: 0
    g3: 0
    b3: 0
    while [y < h] [
		while [x < w][
       			r1: as float! pixX/value and 00FF0000h >> 16 
        		g1: as float! pixX/value and FF00h >> 8 
        		b1: as float! pixX/value and FFh 
       			r2: as float! pixY/value and 00FF0000h >> 16 
        		g2: as float! pixY/value and FF00h >> 8 
        		b2: as float! pixY/value and FFh 
        					  
        		either r1 > 0.0 [r3: 180 * (atan (r2 / r1) / 3.14159)]
        		 			  [r3: 0]
        		either g1 > 0.0 [g3: 180 * (atan (g2 / g1) / 3.14159)]
        		     		  [g3: 0]
        		either b1 > 0.0 [b3: 180 * (atan (b2 / b1) / 3.14159)]
        					  [b3: 0]
        		;print [r3 " " g3 " " b3 lf]
        		pixD/value: (255 << 24) OR (r3 << 16 ) OR (g3 << 8) OR b3
				pixX: pixX + 1
				pixY: pixY + 1
				pixD: pixD + 1
				x: x + 1
		]
		x: 0
		y: y + 1
	]
	image/release-buffer srcX handle1 no
	image/release-buffer srcY handle1 no
	image/release-buffer dst handleD yes
]

;Gx*Gy product
rcvProduct: routine [
    srcX  	[image!]
    srcY  	[image!]
    dst  	[image!]
    /local
        pixX 	[int-ptr!]
        pixY 	[int-ptr!]
        pixD 	[int-ptr!]
        handle1 handle2 handleD 
        h w x y
        r1 g1 b1
        r2 g2 b2
        r3 g3 b3
][
	handle1: 0
	handle2: 0
    handleD: 0
    pixX: image/acquire-buffer srcX :handle1
    pixY: image/acquire-buffer srcY :handle2
    pixD: image/acquire-buffer dst :handleD
	w: IMAGE_WIDTH(srcX/size)
    h: IMAGE_HEIGHT(srcY/size)
    x: 0
    y: 0
    r3: 0
    g3: 0
    b3: 0
    while [y < h] [
		while [x < w][
       			r1: pixX/value and 00FF0000h >> 16 
        		g1: pixX/value and FF00h >> 8 
        		b1: pixX/value and FFh 
       			r2: pixY/value and 00FF0000h >> 16 
        		g2: pixY/value and FF00h >> 8 
        		b2: pixY/value and FFh 
        		r3: r1 * r2 
        		g3: g1 * g2 
        		b3: b1 + b2		  
        		pixD/value: (255 << 24) OR (r3 << 16 ) OR (g3 << 8) OR b3
				pixX: pixX + 1
				pixY: pixY + 1
				pixD: pixD + 1
				x: x + 1
		]
		x: 0
		y: y + 1
	]
	image/release-buffer srcX handle1 no
	image/release-buffer srcY handle2 no
	image/release-buffer dst handleD yes
]



;First derivative filters

rcvKirsch: function [
"Computes an approximation of the gradient magnitude of the input image"
	src			[image! vector!] 
	dst			[image! vector!] 
	iSize 		[pair!] 
	direction 	[integer!] 
	op 			[integer!]
][
	k: [[-3.0 -3.0 5.0 -3.0 0.0 5.0 -3.0 -3.0 5.0]
		[5.0 -3.0 -3.0 5.0 0.0 -3.0 5.0 -3.0 -3.0]
		[-3.0 -3.0 -3.0 -3.0 0.0 -3.0 5.0 5.0 5.0]
		[5.0 5.0 5.0 -3.0 0.0 -3.0 -3.0 -3.0 -3.0]]
	
	switch op [
			1 [k1: k/1 k2: k/3]
			2 [k1: k/2 k2: k/4]
			3 [k1: k/1 k2: k/2]
			4 [k1: k/3 k2: k/4]
	]
	
	t: type? src
	if t = vector! [
		bitSize: (rcvGetMatBitSize src) * 8
		mat1: rcvCreateMat 'integer! bitSize iSize
		mat2: rcvCreateMat 'integer! bitSize iSize
		mat3: rcvCreateMat 'integer! bitSize iSize
		rcvConvolveMat src mat1 iSize k1 1.0 0.0
		rcvConvolveMat src mat2 iSize k2 1.0 0.0
		switch direction [
				1 [rcvCopyMat mat1 dst] 	; X
				2 [rcvCopyMat mat2 dst]		; Y
				3 [mat3: mat1 + mat2 rcvCopyMat mat3 dst] ;  X and Y
				
		]
		rcvReleaseMat mat1
		rcvReleaseMat mat2
		rcvReleaseMat mat3
	]
	if t = image! [
		img1: rcvCreateImage iSize
		img2: rcvCreateImage iSize
		rcvConvolve src img1 k1 1.0 0.0
		rcvConvolve src img2 k2 1.0 0.0
		switch direction [
				1 [rcvCopyImage img2 dst] ; HZ
				2 [rcvCopyImage img1 dst]	; VT
				3 [rcvAdd img1 img2 dst] ; Both
				4 [rcvMagnitude img1 img2 dst]
				5 [rcvDirection img1 img2 dst] ; T= atan(Gx/gy)
		]
		rcvReleaseImage img1
		rcvReleaseImage img2
	]
]


rcvSobel: function [
"Direct Sobel Edges Detection"
	src 		[image! vector!]  
	dst 		[image! vector!] 
	iSize 		[pair!] 
	direction 	[integer!] 
	op 			[integer!]
][
	k: [[-1.0 -2.0 -1.0 0.0 0.0 0.0 1.0 2.0 1.0]
		[1.0 2.0 1.0 0.0 0.0 0.0 -1.0 -2.0 -1.0]
		[-1.0 0.0 1.0 0.0 0.0 0.0 -1.0 0.0 1.0]
		[1.0 0.0 -1.0 0.0 0.0 0.0 1.0 0.0 -1.0]]
		
	switch op [
			1 [k1: k/1 k2: k/3]
			2 [k1: k/2 k2: k/4]
			3 [k1: k/1 k2: k/2]
			4 [k1: k/3 k2: k/4]
	]
	
	t: type? src
	if t = vector! [
		bitSize: (rcvGetMatBitSize src) * 8
		mat1: rcvCreateMat 'integer! bitSize iSize
		mat2: rcvCreateMat 'integer! bitSize iSize
		mat3: rcvCreateMat 'integer! bitSize iSize
		rcvConvolveMat src mat1 iSize k1 1.0 0.0
		rcvConvolveMat src mat2 iSize k2 1.0 0.0
		switch direction [
				1 [rcvCopyMat mat1 dst] 	; hx
				2 [rcvCopyMat mat2 dst]		; hy
				3 [mat3: mat1 OR mat2 rcvCopyMat mat3 dst] ;  XY
		]
		rcvReleaseMat mat1
		rcvReleaseMat mat2
		rcvReleaseMat mat3
	]
	
	if t = image! [
		img1: rcvCreateImage iSize
		img2: rcvCreateImage iSize
		rcvConvolve src img1 k1 1.0 0.0
		rcvConvolve src img2 k2 1.0 0.0
		switch direction [
			1 [rcvCopyImage img1 dst] ; HZ:Gx
			2 [rcvCopyImage img2 dst]	; VT:Gy
			3 [rcvAdd img1 img2 dst] ; G = abs(Gx) + abs(Gy).
			4 [rcvMagnitude img1 img2 dst] ; G= Sqrt Gx^2 +Gy^2
			5 [rcvDirection img1 img2 dst] ; T= atan(Gx/gy)
			6 [rcvProduct img1 img2 dst]	; Gx*Gy product
		]
		rcvReleaseImage img1
		rcvReleaseImage img2
	]
]

rcvPrewitt: function [
"Computes an approximation of the gradient magnitude of the input image "
	src 		[image! vector!] 
	dst 		[image! vector!] 
	iSize 		[pair!] 
	direction 	[integer!] 
	op 			[integer!]
][
	{hx1: [-1.0 0.0 1.0 -1.0 0.0 1.0 -1.0 0.0 1.0]
	hx2: [1.0 0.0 -1.0 1.0 0.0 -1.0 1.0 0.0 -1.0]
	hy1: [-1.0 -1.0 -1.0 0.0 0.0 0.0 1.0 1.0 1.0]
	hy2: [1.0 1.0 1.0 0.0 0.0 0.0 -1.0 -1.0 -1.0]}
	
	k: [[-1.0 0.0 1.0 -1.0 0.0 1.0 -1.0 0.0 1.0]
		[1.0 0.0 -1.0 1.0 0.0 -1.0 1.0 0.0 -1.0]
		[-1.0 -1.0 -1.0 0.0 0.0 0.0 1.0 1.0 1.0]
		[1.0 1.0 1.0 0.0 0.0 0.0 -1.0 -1.0 -1.0]]
	
	switch op [
			1 [k1: k/1 k2: k/3]
			2 [k1: k/2 k2: k/4]
			3 [k1: k/1 k2: k/2]
			4 [k1: k/3 k2: k/4]
	]
	
	t: type? src
	if t = vector! [
		bitSize: (rcvGetMatBitSize src) * 8
		mat1: rcvCreateMat 'integer! bitSize iSize
		mat2: rcvCreateMat 'integer! bitSize iSize
		mat3: rcvCreateMat 'integer! bitSize iSize
		rcvConvolveMat src mat1 iSize k1 1.0 0.0
		rcvConvolveMat src mat2 iSize k2 1.0 0.0
		switch direction [
				1 [rcvCopyMat mat2 dst] ; HZ
				2 [rcvCopyMat mat1 dst] ; VT
				3 [mat3: mat1 + mat2 rcvCopyMat mat3 dst]; Both
				
		]
		rcvReleaseMat mat1
		rcvReleaseMat mat2
		rcvReleaseMat mat3
	]
	if t = image! [
		img1: rcvCreateImage iSize
		img2: rcvCreateImage iSize
		rcvConvolve src img1 k1 1.0 0.0
		rcvConvolve src img2 k2 1.0 0.0
		switch direction [
				1 [rcvCopyImage img2 dst] ; HZ
				2 [rcvCopyImage img1 dst]	; VT
				3 [rcvAdd img1 img2 dst] ; Both
				4 [rcvMagnitude img1 img2 dst]
				5 [rcvDirection img1 img2 dst] ; T= atan(Gx/gy)
		]
		rcvReleaseImage img1
		rcvReleaseImage img2
	]
]

rcvMDIF: function [
"Computes an approximation of the gradient magnitude of the input image "
	src 		[image! vector!] 
	dst 		[image! vector!] 
	iSize 		[pair!] 
	direction 	[integer!]

][
	hx: [0.0 -1.0 0.0 1.0 0.0
		-1.0 -2.0 0.0 2.0 1.0
		-1.0 -3.0 0.0 3.0 1.0
		-1.0 -2.0 0.0 2.0 1.0
		0.0 -1.0 0.0 1.0 0.0
	]
	hy: [0.0 -1.0 -1.0 -1.0 0.0
		-1.0 -2.0 -3.0 -2.0 -1.0
		0.0 0.0 0.0 0.0 0.0
		1.0 2.0 3.0 2.0 1.0
		0.0 1.0 1.0 1.0 0.0
	]
	t: type? src
	if t = vector! [
		bitSize: (rcvGetMatBitSize src) * 8
		mat1: rcvCreateMat 'integer! bitSize iSize
		mat2: rcvCreateMat 'integer! bitSize iSize
		mat3: rcvCreateMat 'integer! bitSize iSize
		rcvConvolveMat src mat1 iSize hx 1.0 0.0
		rcvConvolveMat src mat2 iSize hy 1.0 0.0
		switch direction [
				1 [rcvCopyMat mat2 dst] ; HZ
				2 [rcvCopyMat mat1 dst] ; VT
				3 [mat3: mat1 + mat2 rcvCopyMat mat3 dst]; Both
				
		]
		rcvReleaseMat mat1
		rcvReleaseMat mat2
		rcvReleaseMat mat3
	]
	if t = image! [
		img1: rcvCreateImage iSize
		img2: rcvCreateImage iSize
		rcvConvolve src img1 hx 1.0 0.0
		rcvConvolve src img2 hy 1.0 0.0
		switch direction [
				1 [rcvCopyImage img2 dst] ; HZ
				2 [rcvCopyImage img1 dst]	; VT
				3 [rcvAdd img1 img2 dst] ; Both
				4 [rcvMagnitude img1 img2 dst]
				5 [rcvDirection img1 img2 dst] ; T= atan(Gx/gy)
		]
		rcvReleaseImage img1
		rcvReleaseImage img2
	]
]


rcvRoberts: function [
"Robert's Cross Edges Detection"
	src 		[image! vector!] 
	dst 		[image! vector!] 
	iSize 		[pair!] 
	direction 	[integer!]
][
	h1: [0.0 1.0 -1.0 0.0]
	h2: [1.0 0.0 0.0 -1.0]
	t: type? src
	if t = vector! [
			bitSize: (rcvGetMatBitSize src) * 8
			mat1: rcvCreateMat 'integer! bitSize iSize
			mat2: rcvCreateMat 'integer! bitSize iSize
			mat3: rcvCreateMat 'integer! bitSize iSize
			rcvConvolveMat src mat1 iSize h1 1.0 0.0
			rcvConvolveMat src mat2 iSize h2 1.0 0.0
			switch direction [
				1 [rcvCopyMat mat1 dst]
				2 [rcvCopyMat mat2 dst]
				3 [mat3: mat1 + mat2 rcvCopyMat mat3 dst]
			]
			rcvReleaseMat mat1
			rcvReleaseMat mat2	
			rcvReleaseMat mat3	
	]
	if t = image! [
			img1: rcvCreateImage iSize
			img2: rcvCreateImage iSize
			rcvConvolve src img1 h1 1.0 0.0
			rcvConvolve src img2 h2 1.0 0.0
			switch direction [
				1 [rcvCopyImage img2 dst] ; HZ:Gx
				2 [rcvCopyImage img1 dst]	; VT:Gy
				3 [rcvAdd img1 img2 dst] ; G = abs(Gx) + abs(Gy).
				4 [rcvMagnitude img1 img2 dst] ; G= Sqrt Gx^2 +Gy^2
			]
			rcvReleaseImage img1
			rcvReleaseImage img2
	]
]

;TBD
rcvRobinson: function [
"Robinson Filter"
	src 	[image! vector!]
	dst 	[image! vector!]
	iSize 	[pair!] 
][
	knl: [1.0 1.0 1.0 1.0 -2.0 1.0 -1.0 -1.0 -1.0]
	t: type? src 
	if t = image!  [rcvConvolve src dst knl 1.0 0.0]
	if t = vector! [rcvConvolveMat src dst iSize knl 1.0 0.0]
]


;TBD
rcvGradientMasks: function [
"Fast gradient mask filter with 8 directions"
	src 		[image! vector!] 
	dst 		[image! vector!] 
	iSize 		[pair!] 
	direction 	[integer!]

][
	;"North" "Northeast" "East" "Southeast" "South" "Southwest" "West" "Northwest"
	gradientMasks: [
		[-1.0 -2.0 -1.0 0.0 0.0 0.0 1.0 2.0 1.0]
		[0.0 -1.0 -2.0 1.0 0.0 -1.0 2.0 1.0 0.0]
		[1.0 0.0 -1.0 2.0 0.0 -2.0 1.0 0.0 -1.0]
		[2.0 1.0 0.0 1.0 0.0 -1.0 0.0 -1.0 -2.0]
		[1.0 2.0 1.0 0.0 0.0 0.0 -1.0 -2.0 -1.0]
		[0.0 1.0 2.0 -1.0 0.0 1.0 -2.0 -1.0 0.0]
		[-1.0 0.0 1.0 -2.0 0.0 2.0 -1.0 0.0 1.0]
		[-2.0 -1.0 0.0 -1.0 0.0 1.0 0.0 1.0 2.0]
	]
	mask: gradientMasks/:direction
	t: type? src
	if t = image!  [rcvConvolve src dst mask 1.0 0.0]
	if t = vector! [rcvConvolveMat src dst iSize mask 1.0 0.0]
]

;TBD
rcvLineDetection: function [
"Fast line detection with 4 directions"
	src 		[image! vector!] 
	dst 		[image! vector!] 
	iSize 		[pair!] 
	direction 	[integer!]

][
	knl: [[-1.0 -1.0 -1.0 2.0 2.0 2.0 -1.0 -1.0 -1.0]
		  [-1.0 2.0 -1.0 -1.0 2.0 -1.0 -1.0 2.0 -1.0]
		  [2.0 -1.0 -1.0 -1.0 2.0 -1.0 -1.0 -1.0 2.0]
		  [-1.0 -1.0 2.0 -1.0 2.0 -1.0 2.0 -1.0 -1.0]]
	
	mask: knl/:direction
	t: type? src
	if t = image!  [rcvConvolve src dst mask 1.0 0.0]
	if t = vector! [rcvConvolveMat src dst iSize mask 1.0 0.0]
]

;only for images

;op= 1 ; rcvGradNeumann Computes the discrete gradient 
;by forward finite differences and Neumann boundary conditions. 
;op = 2 Computes the divergence by backward finite differences. 

{old_rcvNeumann: routine [
    src  	[image!]
    dst1  	[image!]
    dst2  	[image!]
    op      [integer!]
    /local
    	stride1 
		bmp1 
		data1 
		pos
        pixD1 	[int-ptr!]
        pixD2 	[int-ptr!]
        handleD1 handleD2 
        h w x y 
        v1 v2 v3
] [
	
	stride1: 0
    bmp1: OS-image/lock-bitmap src no
    data1: OS-image/get-data bmp1 :stride1   
	handleD1: 0
    handleD2: 0
    pixD1: image/acquire-buffer dst1 :handleD1
    pixD2: image/acquire-buffer dst2 :handleD2
	w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size) 
    y: 0 
    x: 0
    
    ;im_out(i,j) = (im_in1(i,j)-im_in1(i-1,j)) + (im_in2(i,j)-im2(i,j-1))
    while [y < h] [
		while [x < w][
				pos: stride1 >> 2 * y + x + 1
			    v1: data1/pos
			    v2: data1/pos
			    v3: data1/pos
			    
			    switch op [
			    	1 [ if x < (w - 1) [pos: stride1 >> 2 * y + x + 2 v2: data1/pos]
			   			if y < (h - 1) [pos: stride1 >> 2 * (y + 1) + x + 1 v3: data1/pos]
			    	]
			    	
			    	2 [ if x > 0 [pos: stride1 >> 2 * y + x v2: data1/pos]
			    		if y > 0 [pos: stride1 >> 2 * (y - 1) + x + 1 v3: data1/pos]
			    	]
			    ]
			    pixD1/value: v2 - v1
			    pixD2/value: v3 - v1
				pixD1: pixD1 + 1
				pixD2: pixD2 + 1
				x: x + 1
		]
		x: 0
		y: y + 1
	]
	;OS-image/unlock-bitmap as-integer src/node bmp1;
	OS-image/unlock-bitmap src bmp1; MB
	image/release-buffer dst1 handleD1 yes
	image/release-buffer dst2 handleD2 yes
]}

rcvNeumann: routine [
    src  	[image!]
    dst1  	[image!]
    dst2  	[image!]
    op      [integer!]
    /local
		pos
		pixS	[int-ptr!]
        pixD1 	[int-ptr!]
        pixD2 	[int-ptr!]
        handleS handleD1 handleD2 
        h w x y 
        v1 v2 v3
] [
	
    handleS:  0 
	handleD1: 0
    handleD2: 0
    
    pixS:  image/acquire-buffer src :handleD1
    pixD1: image/acquire-buffer dst1 :handleD1
    pixD2: image/acquire-buffer dst2 :handleD2
	w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size) 
    y: 0 
    ;im_out(i,j) = (im_in1(i,j)-im_in1(i-1,j)) + (im_in2(i,j)-im2(i,j-1))
    while [y < h] [
    	x: 0
		while [x < w][
				pos: pixS + (y * w + x + 1)
			    v1: pos/value
			    switch op [
			    	1 [ if x < (w - 1) [pos: pixS + (w * y + x + 2) v2: pos/value]
			   			if y < (h - 1) [pos: pixS + (w * (y + 1) + x + 1) v3: pos/value]
			    	]
			    	
			    	2 [ if x > 0 [pos: pixS + (w * y + x) v2: pos/value]
			    		if y > 0 [pos: pixS + (w * (y - 1) + x + 1) v3: pos/value]
			    	]
			    ]
			    pixD1/value: v2 - v1
			    pixD2/value: v3 - v1
				pixD1: pixD1 + 1
				pixD2: pixD2 + 1
				x: x + 1
		]
		y: y + 1
	]
	image/release-buffer src handleD1 no
	image/release-buffer dst1 handleD1 yes
	image/release-buffer dst2 handleD2 yes
]




rcvGradNeumann: function [
"Computes the discrete gradient by forward finite differences and Neumann boundary conditions"
	src [image!] 
	d1  [image!] 
	d2  [image!]
][
	rcvNeumann src d1 d2 1
]

rcvDivNeumann: function [
"Computes the divergence by backward finite differences"
	src [image!] 
	d1  [image!] 
	d2  [image!]
][
	rcvNeumann src d1 d2 2
]


; Second derivative filter

rcvDerivative2: function [
"Computes the 2nd derivative of an image or a matrix"
	src 		[image! vector!] 
	dst 		[image! vector!] 
	iSize 		[pair!] 
	delta 		[float!] 
	direction 	[integer!]
][
	hx: [0.0 0.0 0.0 1.0 -2.0 1.0 0.0 0.0 0.0]
	hy: [0.0 1.0 0.0 0.0 -2.0 0.0 0.0 1.0 0.0]
	
	t: type? src
	if t = vector! [
		mat1: rcvCreateMat 'integer! 8 iSize
		mat2: rcvCreateMat 'integer! 8 iSize
		mat3: rcvCreateMat 'integer! 8 iSize
		rcvConvolveMat src img1 iSize hx 1.0 delta
		rcvConvolveMat src img1 iSize hy 1.0 delta
		switch direction [
			1 [rcvCopyMat mat1 dst]
			2 [rcvCopyMat mat2 dst]
			3 [mat3: mat1 + mat2 rcvCopyMat mat3 dst]
		]
		rcvReleaseMat mat1
		rcvReleaseMat mat2	
		rcvReleaseMat mat3
	]
	if t = image! [
		img1: rcvCreateImage iSize
		img2: rcvCreateImage iSize
		rcvConvolve src img1 hx 1.0 delta
		rcvConvolve src img2 hy 1.0 delta
		switch direction [
				1 [rcvCopyImage img2 dst] ; HZ:Gx
				2 [rcvCopyImage img1 dst] ; VZ:GY
				3 [rcvAdd img1 img2 dst] X+Y
		]
		rcvReleaseImage img1
		rcvReleaseImage img2
	]
]



rcvLaplacian: function [
"Computes the Laplacian of an image or a matrix"
	src 		[image! vector!] 
	dst 		[image! vector!] 
	iSize 		[pair!] 
	connexity 	[integer!]
] [
	if connexity = 4  [knl: [0.0 -1.0 0.0 -1.0 4.0 -1.0 0.0 -1.0 0.0]]
	if connexity = 8  [knl: [-1.0 -1.0 -1.0 -1.0 8.0 -1.0 -1.0 -1.0 -1.0]]
	if connexity = 16 [knl: [-1.0 0.0 0.0 -1.0 0.0 1.0 1.0 0.0 0.0 1.0 1.0 0.0 -1.0 0.0 0.0 -1.0 ]]
	t: type? src
	if t = vector! [rcvConvolveMat src dst iSize knl 1.0 128.0]
	if t = image! [rcvConvolve src dst knl 1.0 128.0]
]

;TBD
rcvDiscreteLaplacian: function [
"Discrete Laplacian Filter"
	src 	[image! vector!] 
	dst 	[image! vector!]
	iSize 	[pair!]

][
	knl: [1.0 1.0 1.0 1.0 -8.0 1.0 1.0 1.0 1.0]
	t: type? src
	if t = image! 	[rcvConvolve src dst knl 1.0 0.0]
	if t = vector! 	[rcvConvolveMat src dst iSize knl 1.0 0.0]
]
;TBD
rcvLaplacianOfRobinson: function [
"Laplacian of Robinson Filter"
	src 	[image! vector!] 
	dst 	[image! vector!]
	iSize 	[pair!]
][
	knl: [1.0 -2.0 1.0 -2.0 4.0 -2.0 1.0 -2.0 1.0]
	t: type? src
	if t = image! 	[rcvConvolve src dst knl 1.0 0.0]
	if t = vector! 	[rcvConvolveMat src dst iSize knl 1.0 0.0]
]

;TBD
rcvLaplacianOfGaussian: function [
"Laplacian of Gaussian"
	src 	[image! vector!] 
	dst 	[image! vector!]
	iSize 	[pair!]
	op		[integer!]
][
	if op = 1 [knl: [0.0 -1.0 0.0 -1.0 4.0 -1.0 0.0 -1.0 0.0]]
	if op = 2 [
	knl: [0.0 0.0 -1.0 0.0 0.0
		  0.0 -1.0 -2.0 -1.0 0.0
		  -1.0 -2.0 16.0 -2.0 -1.0
		  0.0 -1.0 -2.0 -1.0 0.0
		  0.0 0.0 -1.0 0.0 0.0	
		]
	]
	t: type? src
	if t = image! 	[rcvConvolve src dst knl 1.0 0.0]
	if t = vector! 	[rcvConvolveMat src dst iSize knl 1.0 0.0]
]

;Kuwahara filter (image only)
rcvKuwahara: routine [
"Kuwahara non-linear smoothing filter"
    src  	[image!]
    dst  	[image!]
    kSize	[pair!]
    /local
    pix1 	[int-ptr!]
    pixD 	[int-ptr!]
    idx	 	[int-ptr!]
    handle1 
    handleD
    n i j x y w h nr
    imx imy
    sumA sumB sumC sumD
    sum2A sum2B sum2C sum2D
    sumAR sumBR sumCR sumDR
    sumAG sumBG sumCG sumDG
    sumAB sumBB sumCB sumDB
    meanA meanB meanC meanD
    meanAR meanBR meanCR meanDR
    meanAG meanBG meanCG meanDG
    meanAB meanBB meanCB meanDB
    varA varB varC varD
    minVar
    minMean
    a r g b lum
][
	n: kSize/x - 1 / 2
	nr: n * n
	handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
       		j:  0 - n
       		sumA: 0.0 sumB: 0.0 sumC: 0.0 sumD: 0.0
       		sum2A: 0.0 sum2B: 0.0 sum2C: 0.0 sum2D: 0.0
       		sumAR: 0 sumBR: 0 sumCR: 0 sumDR: 0
       		sumAG: 0 sumBG: 0 sumCG: 0 sumDG: 0
       		sumAB: 0 sumBB: 0 sumCB: 0 sumDB: 0

       		while [j <= n] [
  				i: 0 - n
  				while [i <= n] [
  					; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
  					; pixel ;idx: pix1 + (y * w) + x  
  					imx:  (x + i - n + w ) % w 
        			imy:  (y + j - n + h ) % h 
        			idx: pix1 + (imy * w) + imx
        			;argb values
        			a: idx/value >>> 24
       				r: idx/value and 00FF0000h >> 16 
        			g: idx/value and FF00h >> 8 
        			b: idx/value and FFh 
        			;lumen value for variance estimation
        			lum: (0.3 * r) + (0.59 * g) + (0.11 * b)
        			;  region by region
  					if all [j < 0 i < 0] [sumC: sumC + lum sum2C: sum2C + (lum * lum) 
  							sumCR: sumCR + r sumCG: sumCG + g
  							sumCB: sumCB + b] ;C
  					if all [j > 0 i > 0] [sumD: sumD + lum sum2D: sum2D + (lum * lum) 
  							sumDR: sumDR + r sumDG: sumDG + g
  							sumDB: sumDB + b] ;D
  					if all [j > 0 i < 0] [sumA: sumA + lum sum2A: sum2A + (lum * lum) 
  							sumAR: sumAR + r sumAG: sumAG + g
  							sumAB: sumAB + b] ;A
  					if all [j > 0 i > 0] [sumB: sumB + lum sum2B: sum2B + (lum * lum) 
  							sumBR: sumBR + r sumBG: sumBG + g
  							sumBB: sumBB + b] ;B
  					i: i + 1
  				]
  				j: j + 1
  			]
  			;mean rgb by region
  			meanAR: sumAR / nr
  			meanBR: sumBR / nr
  			meanCR: sumCR / nr
  			meanDR: sumDR / nr
  			meanAG: sumAG / nr
  			meanBG: sumBG / nr
  			meanCG: sumCG / nr
  			meanDG: sumDG / nr
  			meanAB: sumAB / nr
  			meanBB: sumBB / nr
  			meanCB: sumCB / nr
  			meanDB: sumDB / nr
			;mean color value by region
  			meanA: (255 << 24) OR (meanAR << 16) OR (meanAG << 8) OR meanAB
  			meanB: (255 << 24) OR (meanBR << 16) OR (meanBG << 8) OR meanBB 
  			meanC: (255 << 24) OR (meanCR << 16) OR (meanCG << 8) OR meanCB 
  			meanD: (255 << 24) OR (meanCR << 16) OR (meanCG << 8) OR meanCB 
    		;minimal variance
    		minvar: 2147483647.0
    		; calculate variance
    		varA: sum2A - ((SumA * SumA) / nr)
    		if varA < minVar [minVar: varA]
    		varB: sum2B - ((SumB * SumB) / nr)
    		if varB < minVar [minVar: varB]
    		varC: sum2C - ((SumC * SumC) / nr)
    		if varC < minVar [minVar: varC]
    		varD: sum2D - ((SumD * SumD) / nr)
    		if varD < minVar [minVar: varD]
    		; region with minimal variance
    		if minVar = varA [minMean: meanA]
			if minVar = varB [minMean: meanB]
    		if minVar = varC [minMean: meanC]
    		if minVar = varD [minMean: meanD]
    		; update destination value
    		pixD/value: minMean
  			pixD: pixD + 1
       		x: x + 1
       	]
       	y: y + 1
    ] 
    image/release-buffer src handle1 no
	image/release-buffer dst handleD yes
]


;******************* tools for Canny edges detection *****************
;TBD
; Canny detector
; for grayscale image -> just process R channel
; gradient 0..255
rcvEdgesGradient: routine [
"Image gradients with hypot function"
    srcX  	[image!]	;X Sobel Derivative
    srcY  	[image!]	;Y Sobel Derivative
    mat		[vector!]	;G result matrix (float)
    /local
        pixX 	[int-ptr!]
        pixY 	[int-ptr!]
        mValue 	[byte-ptr!]
        handle1 handle2 
        h w x y
        derivX
        derivY
        grd
        unit
][
	handle1: 0
	handle2: 0
    pixX: image/acquire-buffer srcX :handle1
    pixY: image/acquire-buffer srcY :handle2
    mValue: vector/rs-head mat	; a byte ptr
	unit: rcvGetMatBitSize mat ; bit size
	w: IMAGE_WIDTH(srcX/size)
    h: IMAGE_HEIGHT(srcX/size)
    y: 0
    while [y < h] [
    	x: 0
		while [x < w][
       			derivX: as float! (pixX/value and 00FF0000h >> 16)
       			derivY: as float! (pixY/value and 00FF0000h >> 16)
       			grd: rcvHypot derivX derivY
        		rcvSetFloatValue as integer! mValue grd unit
				pixX: pixX + 1
				pixY: pixY + 1
				mValue: mValue + unit
				x: x + 1
		]
		y: y + 1
	]
	image/release-buffer srcX handle1 no
	image/release-buffer srcY handle1 no
]

rcvEdgesDirection: routine [
"Angles in degrees with atan2 functions"
    srcX  	[image!]	;X Sobel Derivative
    srcY  	[image!]	;Y Sobel Derivative
    matA	[vector!]	;Angles matrix
    /local
        pixX 	[int-ptr!]
        pixY 	[int-ptr!]
        mValue 	[byte-ptr!]
        handle1 handle2 
        h w x y
        derivX 
        derivY 
        angle 
        unit
][
	handle1: 0
	handle2: 0
    pixX: image/acquire-buffer srcX :handle1
    pixY: image/acquire-buffer srcY :handle2
    mValue: vector/rs-head matA	; a byte ptr
	unit: rcvGetMatBitSize matA ; bit size
	w: IMAGE_WIDTH(srcX/size)
    h: IMAGE_HEIGHT(srcY/size)
    y: 0
    while [y < h] [
    	x: 0
		while [x < w][
       			derivX: as float! (pixX/value and 00FF0000h >> 16) 
       			derivY: as float! (pixy/value and 00FF0000h >> 16)
       			angle: atan2 derivY  derivX 	; radians
       			angle: angle  * 180.0 / pi 		; degrees
       			rcvSetFloatValue as integer! mValue angle unit
       			pixX: pixX + 1
				pixY: pixY + 1
				mValue: mValue + unit
				x: x + 1
		]
		y: y + 1
	]
	image/release-buffer srcX handle1 no
	image/release-buffer srcY handle1 no
]

rcvEdgesSuppress: routine [
"Non-maximum suppression"
	matA	[vector!]	; Angles matrix
	matG	[vector!]	; gradient matrix
	matS	[vector!]	; result matrix
	mSize	[pair!]
	/local
	mSValue [byte-ptr!]
	mAValue [byte-ptr!]
	mGValue [byte-ptr!]
	w
	h
	x y
	unit
	angle 
	idx 
	v1 v2 v3
][
	mAValue: vector/rs-head matA	; a byte ptr
	mGValue: vector/rs-head matG	; a byte ptr
	mSValue: vector/rs-head matS	; a byte ptr
	unit: rcvGetMatBitSize matS 	; bit size
	w: mSize/x - 1
	h: mSize/y - 1
	y: 1
    while [y < h] [
    	x: 1
		while [x < w][
			idx: ((y * w) + x) * unit
			angle: rcvGetFloatValue as integer! (mAValue + idx)
			if angle < 0.0 [ angle: 0.0 + angle] ; abs value
			v1: rcvGetFloatValue as integer! (mGValue + idx)
			case [
				;0° E-W (horizontal)
				any [angle < 22.5 (angle >= 157.5) AND (angle <= 180.0)][
					idx: (y * w + x - 1) * unit
					v2: rcvGetFloatValue as integer! (mGValue + idx)
					idx: (y * w + x + 1) * unit
					v3: rcvGetFloatValue as integer! (mGValue + idx)
				]
				;45° NE-SW
				all [angle >= 22.5 angle < 67.5] [
					idx: (y - 1 * w + x + 1) * unit
					v2: rcvGetFloatValue as integer! (mGValue + idx)
					idx: (y + 1 * w + x - 1) * unit
					v3: rcvGetFloatValue as integer! (mGValue + idx)
				]
				; 90° N-S (vertical)
			 	all [angle >= 67.5 angle < 112.5] [
					idx: (y - 1 * w + x) * unit
					v2: rcvGetFloatValue as integer! (mGValue + idx)
					idx: (y + 1 * w + x) * unit
					v3: rcvGetFloatValue as integer! (mGValue + idx)
				]
				;135° NW-SE
				 all [angle >= 112.5 angle < 157.5] [
					idx: (y - 1 * w + x - 1) * unit
					v2: rcvGetFloatValue as integer! (mGValue + idx)
					idx: (y + 1 * w + x + 1) * unit
					v3: rcvGetFloatValue as integer! (mGValue + idx)
				]
			]
			idx: ((y * w) + x) * unit
			rcvSetFloatValue as integer! (mSValue + idx) 0.0 unit
			if all [v1 >= v2 v1 >= v3] [rcvSetFloatValue as integer! (mSValue + idx) v1 unit]
			x: x + 1
		]
		y: y + 1
	]
]

rcvDoubleThresh: routine [
"Double thresholding"
	gradS			[vector!] ; Non-maximum suppression matrix
	doubleT			[vector!] ; integer matrix for result
	lowThreshold	[integer!]
	highThreshold	[integer!]
	weak			[integer!]
	strong			[integer!]			
	/local
	mSValue 		[byte-ptr!]
	mDTValue		[byte-ptr!]
	v len i
	unit1
	unit2
][
	mSValue: 	vector/rs-head gradS	; a byte ptr
	mDTValue: 	vector/rs-head doubleT	; a byte ptr
	unit1: rcvGetMatBitSize gradS
	unit2: rcvGetMatBitSize doubleT
	len: vector/rs-length? gradS
	i: 0
	while [i < len] [
		v: as integer! (rcvGetFloatValue as integer! mSValue)
		if v < lowThreshold [rcvSetIntValue as integer! mDTValue 0 unit2]
		if all [v >= lowThreshold v <= highThreshold]
				[rcvSetIntValue as integer! mDTValue weak unit2]
		if v >= highThreshold [rcvSetIntValue as integer! mDTValue strong unit2]		
		mDTValue: mDTValue + unit2
		mSValue: mSValue + unit1
		i: i + 1
	]
]

rcvHysteresis: routine [
"non-maximum suppression to thin out the edges"
	doubleT		[vector!] ; integer matrix
	finalEdges	[vector!] ; integer matrix
	iSize		[pair!]	  ; image size
	weak		[integer!]; weak value
	strong		[integer!]; strong value
	/local
	mDTValue 	[byte-ptr!]
	mFEValue	[byte-ptr!]
	x y 
	w h
	v
	idx idx2
	unit
	strong?
][
	mDTValue: vector/rs-head doubleT	; a byte ptr
	mFEValue: vector/rs-head finalEdges	; a byte ptr
	unit: 	rcvGetMatBitSize doubleT
	w: iSize/x
	h: iSize/y
	y: 1 
	while [y < h] [
		x: 1
		while [x < w] [
			idx: (y * w + x) * unit
			v: rcvGetIntValue as integer! (mDTValue + idx) unit
			if v = 0 [rcvSetIntValue as integer! (mFEValue + idx) 0 unit]
			if v = strong [rcvSetIntValue as integer! (mFEValue + idx) strong unit]
			if v = weak [
				strong?: false
				idx2: (y - 1 * w + x + 1) * unit
				if (rcvGetIntValue as integer! (mDTValue + idx2) unit) = strong [strong?: true]
				idx2: (y * w + x + 1) * unit
				if (rcvGetIntValue as integer! (mDTValue + idx2) unit) = strong [strong?: true]
				idx2: (y + 1 * w + x + 1) * unit
				if (rcvGetIntValue as integer! (mDTValue + idx2) unit) = strong [strong?: true]
				idx2: (y - 1 * w + x ) * unit
				if (rcvGetIntValue as integer! (mDTValue + idx2) unit) = strong [strong?: true]
				idx2: (y + 1 * w + x) * unit 
				if (rcvGetIntValue as integer! (mDTValue + idx2) unit) = strong [strong?: true]
				idx2: (y - 1 * w + x - 1) * unit
				if (rcvGetIntValue as integer! (mDTValue + idx2) unit) = strong [strong?: true]
				idx2: (y * w + x - 1) * unit
				if (rcvGetIntValue as integer! (mDTValue + idx2) unit) = strong [strong?: true]
				idx2: (y + 1 * w + x - 1) * unit
				if (rcvGetIntValue as integer! (mDTValue + idx2) unit) = strong [strong?: true]
				if strong? [rcvSetIntValue as integer! (mFEValue + idx) strong unit]
			]
			x: x + 1
		]
		y: y + 1
	]
]

; Harris corner detection

rcvHarris: routine [
    srcX  	[image!]
    srcY  	[image!]
    dst  	[image!]
    k		[float!] ; 0.04 ... 0.15.
    t		[integer!]; threhold
    /local
        pixX 	[int-ptr!]
        pixY 	[int-ptr!]
        pixD 	[int-ptr!]
        handle1 handle2 handleD 
        h w x y
        i j
        detM 
        traceM  
        px px2 py py2 pxy
        n p
        imx imy idxX idxY
        sumpx2 sumpy2 sumpxy
][
	handle1: 0
	handle2: 0
    handleD: 0
    pixX:  image/acquire-buffer srcX :handle1
    pixY:  image/acquire-buffer srcY :handle2
    pixD:  image/acquire-buffer dst :handleD
	w: IMAGE_WIDTH(srcX/size)
    h: IMAGE_HEIGHT(srcY/size)
    n: 2
    y: 0
    while [y < h] [
    	x: 0
		while [x < w][
       			sumpx2: 0.0
       			sumpy2: 0.0
        		sumpxy: 0.0
        		j:  0 - n
        		while [j <= n] [
  					i: 0 - 2
  					while [i <= n] [
  						imx:  (x + i - n + w ) % w 
        				imy:  (y + j - n + h ) % h 
        				idxX: pixX + (imy * w) + imx
        				idxY: pixY + (imy * w) + imx
        				px: as float! idxX/value and 00FF0000h >> 16 
       					py: as float! idxY/value and 00FF0000h >> 16 
        				pxy: px * py
        				px2: px * px
        				py2: py * py
        				sumpx2: sumpx2 + px2
        				sumpy2: sumpy2 + py2
        				sumpxy: sumpxy + pxy
  						i: i + 1
  					]
  					j: j + 1
  				]
        		detM: (sumpx2 * sumpy2) - (sumpxy * sumpxy)
        		traceM: k * (pow (sumpx2 + sumpy2) 2.0)
        		p: as integer! (detM - traceM) / 2147483647
        		if p < 0 [p: 0 - p]
        		p: p AND FFh
        		either p >= t [p: 255] [p: 0]
        		pixD/value: (255 << 24) OR (p << 16 ) OR (p << 8) OR p
				pixD: pixD + 1
				x: x + 1
		]
		y: y + 1
	]
	image/release-buffer srcX  handle1 no
	image/release-buffer srcY  handle2 no
	image/release-buffer dst handleD yes
]

;******************* Matrix Convolution ***************************
{ Convolution on matrices:  Non normalized convolution 
includes a  filter values < 0: 0 and values > 255: 255
can be used with 8,16 and 32-bit matrices
factor and delta modify convolution result
}

_rcvConvolveMat: routine [
"Classical matrix convolution"
    src  		[vector!]
    dst  		[vector!]
    mSize		[pair!]
    kernel 		[block!] 
    factor 		[float!]
    delta		[float!]
    /local
    svalue 		[byte-ptr!]
    dvalue 		[byte-ptr!]
    idx			[byte-ptr!] 
    kBase		[red-value!]
    kValue		[red-value!]
    h 			[integer!]
    w			[integer!] 
    x 			[integer!]
    y 			[integer!]
    i 			[integer!]
    j			[integer!]
    mx			[integer!] 
    my 			[integer!]
	kWidth 		[integer!]
	kHeight  	[integer!]  
	unit		[integer!] 
	v			[integer!] 
    weightAcc	[float!]
    vc			[float!]
    f			[red-float!] 
][
    ;get mat size will be improved in future
    w: mSize/x
    h: mSize/y
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
	svalue: vector/rs-head src   ; get pointer address of the source matrix first value
	dvalue: vector/rs-head dst	; a byte ptr
	;vector/rs-clear dst 		; clears destination matrix
	unit: rcvGetMatBitSize src
    x: 0
    y: 0
    v: 0
    while [y < h] [
       while [x < w][
    	weightAcc: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		mx:  (x + (i - (kWidth / 2)) + w ) % w 
        			my:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: svalue + (((my * w) + mx) * unit)  ; corrected pixel index
           			v: rcvGetIntValue as integer! idx unit 
           			if unit = 1 [v: v and FFh] ; for 8-bit image
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			weightAcc: weightAcc + (f/value * v)
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        
        vc: (weightAcc * factor) + delta						 			 
    	; classical convolution cut off
    	if vc < 0.0 [vc: 0.0]
    	if vc > 255.0 [vc: 255.0]
        rcvSetIntValue as integer! dvalue as integer! vc unit
        dvalue: dvalue + unit
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
]

rcvConvolveMat: func [
"Classical matrix convolution"
	mx			[object!] 
	kernel 		[block!] 
    factor 		[float!]
    delta		[float!]
	return:		[object!]
	/local
	_mx			[object!]
	mSize		[pair!]
][
	mSize: as-pair  mx/cols mx/rows
	_mx: matrix/init mx/type mx/bits as-pair mx/cols mx/rows
	_rcvConvolveMat mx/data _mx/data mSize kernel factor delta
	_mx
]

{ Convolution on matrices:  Normalized convolution 
two-pass : first looks for maxi and mini 
can be used with 8,16 and 32-bit matrices
}

rcvConvolveNormalizedMat: routine [
"Normalized fast matrix convolution"
    src  	[vector!]
    dst  	[vector!]
    mSize	[pair!]
    kernel 	[block!] 
    factor 	[float!]
    delta	[float!]
    /local
    svalue	[byte-ptr!] 
    dvalue 	[byte-ptr!]
    idx		[byte-ptr!]
    kBase	[red-value!]	 
    kValue	[red-value!]
    h		[integer!] 
    w		[integer!] 
    x		[integer!] 
    y 		[integer!]
    i		[integer!] 
    j		[integer!]
    mx 		[integer!]
    my 		[integer!]
	kWidth 	[integer!]
	kHeight	[integer!] 
	unit	[integer!]
	v 		[integer!] 
	mini 	[float!]
	maxi	[float!]
	scale	[float!]
    weightAcc	[float!]
    vc			[float!] 
    vcc			[float!]
	f			[red-float!]
][
    ;get mat size will be improved in future
    w: mSize/x
    h: mSize/y
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
	svalue: vector/rs-head src   ; get pointer address of the source matrix first value
	dvalue: vector/rs-head dst	; a byte ptr
	unit: rcvGetMatBitSize src
    x: 0
    y: 0
    v: 0
    maxi: -16777215.0
    mini: 16777215.0
    while [y < h][
    	x: 0
       	while [x < w][
    	weightAcc: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		mx:  (x + (i - (kWidth / 2)) + w ) % w 
        			my:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: svalue + (((my * w) + mx) * unit)  ; corrected pixel index
           			v: rcvGetIntValue as integer! idx unit 
           			if unit = 1 [v: v and FFh] ; for 8-bit image
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			weightAcc: weightAcc + (f/value * v)
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
       	vc: (weightAcc * factor) + delta					 			 
    	if vc > maxi [maxi: vc] 
    	if vc <= mini [mini: vc]
        x: x + 1
       ]
       y: y + 1
    ]
    
    scale: 255.0 / (maxi - mini) 
    
    x: 0
    y: 0
    v: 0
    while [y < h] [
       while [x < w][
    	weightAcc: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		mx:  (x + (i - (kWidth / 2)) + w ) % w 
        			my:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: svalue + (((my * w) + mx) * unit)  ; corrected pixel index
           			v: rcvGetIntValue as integer! idx unit 
           			if unit = 1 [v: v and FFh] ; for 8-bit image
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			weightAcc: weightAcc + (f/value * v)
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
    
    	vcc: (((weightAcc * factor) + delta) - mini) * scale 						 			 
        rcvSetIntValue as integer! dvalue as integer! vcc unit
        dvalue: dvalue + unit
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
]



; Fast Sobel Detector on Matrix
; Computes the x component of the gradient vector
; at a given point in a matrix.
; returns gradient in the x direction

_xSMGradient: routine [
	p		[integer!]
	mSize	[pair!]
	x		[integer!]
	y		[integer!]
	return:	[integer!]
	/local
	h w idx sum v
][
	w: mSize/x
    h: mSize/y
    if x < 1 [x: w - 1]
    if y < 1 [y: h - 1]
    if x >= (w - 1) [x: 1]
	if y >= (h - 1) [y: 1]
    sum: 0
    idx: p + (y - 1 * w) + (x - 1) 
    v: rcvGetIntValue idx 1
    sum: sum + v
    idx: p + (y * w) + (x - 1) 
    v: rcvGetIntValue idx 1
    sum: sum + (v * 2)
    idx: p + (y + 1 * w) + (x - 1) 
    v: rcvGetIntValue idx 1
    sum: sum + v
    idx: p + (y - 1 * w) + (x + 1) 
    v: rcvGetIntValue idx 1
    sum: sum - v
    idx: p + (y  * w) + (x + 1)
    v: rcvGetIntValue idx 1 
    sum: sum - (v * 2)
    idx: p + (y + 1 * w) + (x + 1) 
    v: rcvGetIntValue idx 1
    sum: sum - v
    sum 
]


;Computes the x component of the gradient vector
; at a given point in a matrix.
;returns gradient in the y direction

_ySMGradient: routine [
	p		[integer!]
	mSize	[pair!]
	x		[integer!]
	y		[integer!]
	return:	[integer!]
	/local
	h w idx sum v
][
	w: mSize/x
    h: mSize/y
    if x < 1 [x: w - 1]
    if y < 1 [y: h - 1]
    if x >= (w - 1) [x: 1]
	if y >= (h - 1) [y: 1]
    sum: 0
    idx: p + (y - 1 * w) + (x - 1)
    v: rcvGetIntValue idx 1 
    sum: sum + v
    idx: p + (y - 1 * w) + x 
    v: rcvGetIntValue idx 1
    sum: sum + (v * 2)
    idx: p + (y - 1 * w) + (x + 1) 
    v: rcvGetIntValue idx 1
    sum: sum + v
    idx: p + (y + 1 * w) + (x - 1) 
    v: rcvGetIntValue idx 1
    sum: sum - v
    idx: p + (y + 1 * w) + x 
    v: rcvGetIntValue idx 1
    sum: sum - (v * 2)
    idx: p + (y + 1 * w) + (x + 1) 
    v: rcvGetIntValue idx 1
    sum: sum - v
    sum
]

; Sobel Edges detector
rcvSobelMat: routine [
"Fast Sobel on Matrix"
    src  	[vector!]
    dst  	[vector!]
    mSize	[pair!]
    /local
    svalue	[byte-ptr!]
    dvalue 	[byte-ptr!]
    idx 	[byte-ptr!]
    h		[integer!]
    w		[integer!] 
    x 		[integer!]
    y		[integer!]
    gX 		[integer!]
    gY 		[integer!]
    sum		[integer!]
    unit	[integer!]
][
    ;get mat size will be improved in future with matrix! type
    w: mSize/x
    h: mSize/y
	svalue: vector/rs-head src   ; get byte pointer address of the source matrix first value
	dvalue: vector/rs-head dst	; a byte ptr
	unit: rcvGetMatBitSize src
    x: 0
    y: 0
    gX: 0
    gY: 0
    sum: 0
    while [y < h] [	
       	while [x < w][
    		gx: _xSMGradient as integer! svalue mSize x y
    		gy: _ySMGradient as integer! svalue mSize x y
    		sum: gX + gY ; faster approximation but requires absolute difference
    		;sum: as integer! (sqrt ((as float! gx * gx) + (as float! gy * gy)))
    		if sum < 0 [sum:  0]
    		if sum > 255 [sum: 255]
    		dvalue/value: as-byte sum
        	dvalue: dvalue + unit
        	x: x + 1
       ]
       x: 0
       y: y + 1
    ]
]

;median filter 

_sortMKernel: function [knl][sort knl]

rcvMatrixMedianFilter: routine [
"Median Filter for matrices"
    src  	[vector!]
    dst  	[vector!]
    mSize	[pair!]
    kWidth 	[integer!]
    kHeight	[integer!] 
    kernel 	[vector!]
    /local
    svalue	[byte-ptr!]
    dvalue 	[byte-ptr!]
    idx 	[byte-ptr!]
    kBase	[byte-ptr!] 
    kValue 	[byte-ptr!]
    ptr 	[int-ptr!]
    h		[integer!]
    w		[integer!] 
    x 		[integer!]
    y		[integer!]
    i		[integer!] 
    j		[integer!]
    edgex	[integer!]
    edgey	[integer!]
    pos 	[integer!]
    n		[integer!]
    mx 		[integer!]
    my 		[integer!]
	unit	[integer!]
][
    ;get mat size will be improved in future
    w: mSize/x
    h: mSize/y
    edgex: kWidth / 2
    edgey: kHeight / 2
	kBase: vector/rs-head kernel ; get pointer address of the kernel first value
	svalue: vector/rs-head src   ; get pointer address of the source matrix first value
	dvalue: vector/rs-head dst	 ; a byte ptr
	;vector/rs-clear dst 		 ; clears destination matrix
	unit: rcvGetMatBitSize src
	ptr: as int-ptr! kBase
    n: vector/rs-length? kernel
    pos: n / 2
    y: 0
    while [y < h] [
    	x: 0
        while [x < w][
   		j: 0
		vector/rs-clear kernel
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		mx: (x + i - edgex + w) % w
    				my: (y + j - edgey + h) % h 
    				idx: svalue + (((my * w) + mx) * unit)
       				vector/rs-append-int kernel as integer! idx/value
           			i: i + 1
            	]
            	j: j + 1 
        ]
        #call [_sortMKernel kernel]
        rcvSetIntValue as integer! dvalue ptr/pos unit
        dvalue: dvalue + unit
        x: x + 1
       ]
    y: y + 1
    ]
]

