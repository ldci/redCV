Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvImgProcRoutines.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;***************** COLORSPACE CONVERSIONS ************
; Based on  OpenCV 3.0 implementation for 8-bit image
; exported as functions in /libs/imgproc/rcvImgProc.red

;RGB<=>CIE XYZ.Rec 709 with D65 white point
_rcvXYZ: routine [
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

_rcvXYZRGB: routine [
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
       	a: pix1/value >>> 24				; 
       	r: pix1/value and FF0000h >> 16	; X  
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


;RGB<=>YCrCb JPEG (a.k.a. YCC)
_rcvYCrCb: routine [
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


;RGB<=>HSV

_rcvHSV: routine [
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



;RGB<=>HLS
_rcvHLS: routine [
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

; A REVOIR
;RGB<=>CIE L*a*b* 
_rcvLab: routine [
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


_rcvLuv: routine [
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


_logOpp: routine [
	value [float!]
	return: [float!]
] [
	105.0 * log-10 (value + 1.0)
]

_rcvIRgBy: routine [
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



;***************** IMAGE TRANSFORMATION ROUTINES ***********************
; exported as functions in /libs/imgproc/rcvImgProc.red

_rcvFlipHV: routine [
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

; Image effects
_rcvEffect: routine [
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

_rcvWave: routine [
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




; *************** IMAGE CONVOLUTION *************************
; exported as functions in /libs/imgproc/rcvImgProc.red

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

_rcvConvolve: routine [
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



; only for 1-channel image (8-bit)
_rcvFastConvolve: routine [
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


; Similar to convolution but the sum of the weights is computed during the summation, 
; and used to scale the result.

_rcvFilter2D: routine [
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


; a faster version without controls on pixel value !
; basically for 1 channel gray scaled image
;the sum of the weights is computed during the summation, and used to scale the result

_rcvFastFilter2D: routine [
    src  [image!]
    dst  [image!]
    kernel 	[block!] 
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


; ****************integral image************************
; exported as functions in /libs/imgproc/rcvImgProc.red

_rcvIntegral: routine [
    src  [image!]
    dst  [image!]
    dst2 [image!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        pixD2 	[int-ptr!]
        idxD	[int-ptr!]
        idxD2	[int-ptr!]
        handle1 handleD handleD2 h w x y pindex pindex2 val
        sum sqsum     
][
    handle1: 0
    handleD: 0
    handleD2: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    pixD2: image/acquire-buffer dst2 :handleD2
    idxD: pixD
    idxD2: pixD2
    pindex: 0
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    while [x < w] [
    	y: 0
    	sum: 0
    	sqsum: 0
       	while [y < h][
       		pindex: x + (y * w) 
       		sum: sum + pix1/value
       		sqsum: sqsum + (pix1/value * pix1/value)
       		either x = 0 [pixD/value: sum pixD2/value: sqsum] 
       					 [
       					 ;sum
       					 pixD: idxD + pindex - 1
       					 val: pixD/value + sum
       					 pixD: idxD + pindex
       					 pixD/value: val
       					 ; square sum
       					 pixD2: idxD2 + pindex - 1
       					 val: pixD2/value + sqsum
       					 pixD2: idxD2 + pindex
       					 pixD2/value: val
       					 ]
        	pix1: pix1 + 1
        	y: y + 1
       ]
       x: x + 1
       
    ]
    
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
    image/release-buffer dst2 handleD2 yes
]



; ******************* morphological Operations**************************
; exported as functions in /libs/imgproc/rcvImgProc.red

_rcvErode: routine [
    src  	[image!]
    dst  	[image!]
    cols	[integer!]
    rows	[integer!]
    kernel 	[block!] 
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        idx2	[int-ptr!]
        idxD	[int-ptr!]
        handle1 handleD h w x y i j
        mini
        k  imx imy imx2 imy2
       	radiusX radiusY
		kBase 
		kValue  
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    idx2: pix1
    idxD: pixD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
	radiusX: cols / 2
	radiusY: rows / 2
    x: radiusX
    y: radiusY
    j: 0
    i: 0
    while [y < (h - radiusY)] [
       while [x < (w - radiusX)][
       		idx: pix1 + (y * w) + x  
       		kValue: kBase
        	j: 0 
        	mini: 0
        	; process neightbour
        	while [j < rows][
        		i: 0
        		while [i < cols][
        			imx2: x + i - radiusX
        			imy2: y + j - radiusY
        			idx2: pix1 + (imy2 * w) + imx2
        			k: as red-integer! kValue
        			if k/value = 1 [
        				if idx2/value < mini [mini: idx2/value]
        			]
        			kValue: kBase + (j * cols + i + 1)
        			i: i + 1
        		]
        		j: j + 1
        	]
       		pixD: idxD + (y * w) + x
           	pixD/value: mini
           	x: x + 1
       ]
       x: 0
       y: y + 1    
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


_rcvDilate: routine [
    src  	[image!]
    dst  	[image!]
    cols	[integer!]
    rows	[integer!]
    kernel 	[block!] 
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        idx2	[int-ptr!]
        idxD	[int-ptr!]
        handle1 handleD h w x y i j
        maxi
        k  imx imy imx2 imy2
       	radiusX radiusY
		kBase 
		kValue  
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    idx2: pix1
    idxD: pixD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
	radiusX: cols / 2
	radiusY: rows / 2
    x: radiusX
    y: radiusY
    j: 0
    i: 0
    while [y < (h - radiusY)] [
       while [x < (w - radiusX)][
       		idx: pix1 + (y * w) + x  
       		kValue: kBase
        	j: 0 
        	maxi: (255 << 24) OR (0 << 16) or (0 << 8) OR 0
        	; process neightbour
        	while [j < rows][
        		i: 0
        		while [i < cols][
        			imx2: x + i - radiusX
        			imy2: y + j - radiusY
        			idx2: pix1 + (imy2 * w) + imx2
        			k: as red-integer! kValue
        			
        			if k/value = 1 [
        				if idx2/value > maxi [maxi: idx2/value]
        			]
        			kValue: kBase + (j * cols + i + 1)
        			i: i + 1
        		]
        		j: j + 1
        	]
       		pixD: idxD + (y * w) + x
           	pixD/value: maxi
           	x: x + 1
       ]
       x: 0
       y: y + 1 
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]



_rcvMMean: routine [
    src  	[image!]
    dst  	[image!]
    cols	[integer!]
    rows	[integer!]
    kernel 	[block!] 
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        idx2	[int-ptr!]
        idxD	[int-ptr!]
        handle1 handleD h w x y i j
        r g b
        minr ming minb
        maxr maxg maxb
        count
        k  imx imy imx2 imy2
       	radiusX radiusY
		kBase 
		kValue  
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    idx2: pix1
    idxD: pixD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
	radiusX: cols / 2
	radiusY: rows / 2
    x: radiusX
    y: radiusY
    j: 0
    i: 0
    while [y < (h - radiusY)] [
       while [x < (w - radiusX)][
       		idx: pix1 + (y * w) + x  
       		kValue: kBase
        	j: 0 
        	count: 0
        	minr: 255
           	ming: 255
			minb: 255
           	maxr: 0
           	maxg: 0
           	maxb: 0
        	; process neightbour
        	while [j < rows][
        		i: 0
        		while [i < cols][
        			imx2: x + i - radiusX
        			imy2: y + j - radiusY
        			idx2: pix1 + (imy2 * w) + imx2
        			k: as red-integer! kValue
        			
        			if k/value = 1 [
        				count: count + 1
        				r: idx2/value and 00FF0000h >> 16 
        				g: idx2/value and FF00h >> 8 
       					b: idx2/value and FFh  
        				maxr: maxr + r
        				maxg: maxg + g
        				maxb: maxb + b
        			]
        			kValue: kBase + (j * cols + i + 1)
        			i: i + 1
        		]
        		j: j + 1
        	]
       		pixD: idxD + (y * w) + x
       		r: maxr / count
       		g: maxg / count
       		b: maxb / count
           	pixD/value: (255 << 24) OR ( r << 16 ) OR (g << 8) OR b
           	x: x + 1
       ]
       x: 0
       y: y + 1 
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


; new for image smoothing
_sortKernel: function [knl][sort knl]

_rcvMedianFilter: routine [
    src  	[image!]
    dst  	[image!]
    kWidth 	[integer!]
    kHeight	[integer!] 
    kernel 	[vector!]
    op	 	[integer!]
    /local
        pix1 	[int-ptr!]
        pix2	[int-ptr!]
        pixD 	[int-ptr!]
        idx 	[int-ptr!]
        handle1 handleD h w x y n pos
        imx imy 
        kBase ptr
        edgex edgey mcenter ct
        fx fy 
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pix2: pix1; image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx: image/acquire-buffer src :handle1
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    edgex: kWidth / 2
    edgey: kHeight / 2
    mcenter: (kWidth * kHeight) / 2
    kBase: vector/rs-head kernel
    ptr: as int-ptr! kBase
    n: vector/rs-length? kernel
    pos: n / 2
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w ][
           	vector/rs-clear kernel
    		fy: 0
    		ct: 0
    		while [fy < kHeight][
    			fx: 0
    			while [fx < kWidth][
    				;OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
    				imx: (x + fx - edgex + w) % w
    				imy: (y + fy - edgey + h) % h 
    				idx: pix1 + (imy * w) + imx 
    				;if ct <> mcenter [vector/rs-append-int kernel idx/value]
    				vector/rs-append-int kernel idx/value
    				fx: fx + 1	
    				ct: ct + 1
    			]
    			fy: fy + 1
    		]
    		#call [_sortKernel kernel]
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




_rcvMeanFilter: routine [
    src  	[image!]
    dst  	[image!]
    kWidth 	[integer!]
    kHeight	[integer!] 
    op	 	[integer!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx 	[int-ptr!]
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
    idx: image/acquire-buffer src :handle1
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
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



_rcvMidPointFilter: routine [
    src  	[image!]
    dst  	[image!]
    kWidth 	[integer!]
    kHeight	[integer!] 
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx 	[int-ptr!]
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
    idx: image/acquire-buffer src :handle1
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
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




_rcvBlend: routine [
    src1  	[image!]
    src2  	[image!]
    dst  	[image!]
    alpha	[float!]
    /local
        pix1 	[int-ptr!]
        pix2 	[int-ptr!]
        pixD 	[int-ptr!]
        handle1 handle2 handleD 
        h w x y
        a1 r1 g1 b1
        a2 r2 g2 b2
        a3 r3 g3 b3
        calpha
][
	handle1: 0
	handle2: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pix2: image/acquire-buffer src2 :handle1
    pixD: image/acquire-buffer dst  :handleD
	w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    a3: 0
    r3: 0
    g3: 0
    b3: 0
    calpha: 1.0 - alpha
    while [y < h] [
		while [x < w][
				a1: pix1/value >>> 24
       			r1: pix1/value and 00FF0000h >> 16 
        		g1: pix1/value and FF00h >> 8 
        		b1: pix1/value and FFh 
        		a2: pix2/value >>> 24
       			r2: pix2/value and 00FF0000h >> 16 
        		g2: pix2/value and FF00h >> 8 
        		b2: pix2/value and FFh 
        		a3: as integer! (alpha * a1) + (calpha * a2) 
        		r3: as integer! (alpha * r1) + (calpha * r2) 
        		g3: as integer! (alpha * g1) + (calpha * g2)
        		b3: as integer! (alpha * b1) + (calpha * b2)
        		pixD/value: (a3 << 24) OR (r3 << 16 ) OR (g3 << 8) OR b3
				pix1: pix1 + 1
				pix2: pix2 + 1
				pixD: pixD + 1
				x: x + 1
		]
		x: 0
		y: y + 1
	]
	image/release-buffer src1 handle1 no
	image/release-buffer src2 handle2 no
	image/release-buffer dst handleD yes
]




; ************tools for edges detection***********
; exported as functions in /libs/imgproc/rcvImgProc.red
;G= Sqrt Gx^2 +Gy^2 Gets Gradient 

_rcvMagnitude: routine [
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


; atan Gy / Gx 
_rcvDirection: routine [
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

_rcvProduct: routine [
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




; for Canny detector
; for grayscale image -> just process R channel
; gradient 0..255
_rcvEdgesGradient: routine [
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
	unit: _rcvGetMatBitSize mat ; bit size
	w: IMAGE_WIDTH(srcX/size)
    h: IMAGE_HEIGHT(srcX/size)
    y: 0
    while [y < h] [
    	x: 0
		while [x < w][
       			derivX: as float! (pixX/value and 00FF0000h >> 16)
       			derivY: as float! (pixY/value and 00FF0000h >> 16)
       			grd: rcvHypot derivX derivY
        		_setFloatValue as integer! mValue grd unit
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

; for grayscale image -> just process R channel
_rcvEdgesDirection: routine [
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
	unit: _rcvGetMatBitSize matA ; bit size
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
       			_setFloatValue as integer! mValue angle unit
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

_rcvEdgesSuppress: routine [
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
	unit: _rcvGetMatBitSize matS 	; bit size
	w: mSize/x - 1
	h: mSize/y - 1
	y: 1
    while [y < h] [
    	x: 1
		while [x < w][
			idx: ((y * w) + x) * unit
			angle: _getFloatValue as integer! (mAValue + idx)
			if angle < 0.0 [ angle: 0.0 + angle] ; abs value
			v1: _getFloatValue as integer! (mGValue + idx)
			case [
				;0° E-W (horizontal)
				any [angle < 22.5 (angle >= 157.5) AND (angle <= 180.0)][
					idx: (y * w + x - 1) * unit
					v2: _getFloatValue as integer! (mGValue + idx)
					idx: (y * w + x + 1) * unit
					v3: _getFloatValue as integer! (mGValue + idx)
				]
				;45° NE-SW
				all [angle >= 22.5 angle < 67.5] [
					idx: (y - 1 * w + x + 1) * unit
					v2: _getFloatValue as integer! (mGValue + idx)
					idx: (y + 1 * w + x - 1) * unit
					v3: _getFloatValue as integer! (mGValue + idx)
				]
				; 90° N-S (vertical)
			 	all [angle >= 67.5 angle < 112.5] [
					idx: (y - 1 * w + x) * unit
					v2: _getFloatValue as integer! (mGValue + idx)
					idx: (y + 1 * w + x) * unit
					v3: _getFloatValue as integer! (mGValue + idx)
				]
				;135° NW-SE
				 all [angle >= 112.5 angle < 157.5] [
					idx: (y - 1 * w + x - 1) * unit
					v2: _getFloatValue as integer! (mGValue + idx)
					idx: (y + 1 * w + x + 1) * unit
					v3: _getFloatValue as integer! (mGValue + idx)
				]
			]
			idx: ((y * w) + x) * unit
			_setFloatValue as integer! (mSValue + idx) 0.0 unit
			if all [v1 >= v2 v1 >= v3] [_setFloatValue as integer! (mSValue + idx) v1 unit]
			x: x + 1
		]
		y: y + 1
	]
]

_doubleThresholding: routine [
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
	unit1: _rcvGetMatBitSize gradS
	unit2: _rcvGetMatBitSize doubleT
	len: vector/rs-length? gradS
	i: 0
	while [i < len] [
		v: as integer! (_getFloatValue as integer! mSValue)
		if v < lowThreshold [_setIntValue as integer! mDTValue 0 unit2]
		if all [v >= lowThreshold v <= highThreshold]
				[_setIntValue as integer! mDTValue weak unit2]
		if v >= highThreshold [_setIntValue as integer! mDTValue strong unit2]		
		mDTValue: mDTValue + unit2
		mSValue: mSValue + unit1
		i: i + 1
	]
]

_hysteresis: routine [
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
	unit: 	_rcvGetMatBitSize doubleT
	w: iSize/x
	h: iSize/y
	y: 1 
	while [y < h] [
		x: 1
		while [x < w] [
			idx: (y * w + x) * unit
			v: _getIntValue as integer! (mDTValue + idx) unit
			if v = 0 [_setIntValue as integer! (mFEValue + idx) 0 unit]
			if v = strong [_setIntValue as integer! (mFEValue + idx) strong unit]
			if v = weak [
				strong?: false
				idx2: (y - 1 * w + x + 1) * unit
				if (_getIntValue as integer! (mDTValue + idx2) unit) = strong [strong?: true]
				idx2: (y * w + x + 1) * unit
				if (_getIntValue as integer! (mDTValue + idx2) unit) = strong [strong?: true]
				idx2: (y + 1 * w + x + 1) * unit
				if (_getIntValue as integer! (mDTValue + idx2) unit) = strong [strong?: true]
				idx2: (y - 1 * w + x ) * unit
				if (_getIntValue as integer! (mDTValue + idx2) unit) = strong [strong?: true]
				idx2: (y + 1 * w + x) * unit 
				if (_getIntValue as integer! (mDTValue + idx2) unit) = strong [strong?: true]
				idx2: (y - 1 * w + x - 1) * unit
				if (_getIntValue as integer! (mDTValue + idx2) unit) = strong [strong?: true]
				idx2: (y * w + x - 1) * unit
				if (_getIntValue as integer! (mDTValue + idx2) unit) = strong [strong?: true]
				idx2: (y + 1 * w + x - 1) * unit
				if (_getIntValue as integer! (mDTValue + idx2) unit) = strong [strong?: true]
				if strong? [_setIntValue as integer! (mFEValue + idx) strong unit]
			]
			x: x + 1
		]
		y: y + 1
	]
]



;op= 1 ; rcvGradNeumann Computes the discrete gradient 
;by forward finite differences and Neumann boundary conditions. 
;op = 2 Computes the divergence by backward finite differences. 

; exported as functions in /libs/imgproc/rcvImgProc.red
_rcvNeumann: routine [
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
    ;bmp1: OS-image/lock-bitmap as-integer src/node no
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
]


;Kuwahara filter (image only)

_rcvKuwahara: routine [
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



; Hough Transform routines

_rcvHoughTransform: routine [
	mat [vector!] 
	accu [vector!] 
	w [integer!] 
	h [integer!]
	treshold [integer!]
	/local
	cx cy x y xf yf
	i ii idx idx2 
	t r
	unit1 unit2
	matValue accValue accTail
	cosAngle sinAngle deg2Rad
	maxRho maxTheta indexRho
][
	cx: as float! w / 2.0
	cy: as float! h / 2.0
	either h > w [maxRho: ((sqrt 2.0) * as float! h) / 2.0] 
				 [maxRho: ((sqrt 2.0) * as float! w) / 2.0]			 
	maxTheta: 180
    deg2Rad:  pi / 180.0
    matValue: vector/rs-head mat ; get pointer address of the vector
    unit1: _rcvGetMatBitSize mat ; bit size
    accValue: vector/rs-head accu; get pointer address of the vector
    accTail:  vector/rs-tail accu
    unit2: _rcvGetMatBitSize accu ; bit size
	y: 0
	while [y < h] [
		yf: as float! y - cy
		x: 0
		while [x < w][
			xf: as float! x - cx
			idx: ((y * w) + x) * unit1
			i: _getIntValue as integer! (matValue + idx) unit1
			if i > treshold [ 
				t: 0
				while [t < maxTheta] [
					cosAngle: cos (deg2Rad * t); in radian
					sinAngle: sin (deg2Rad * t); in radian
					r: (xf * cosAngle) + (yf * sinAngle)
					indexRho: as integer! (r + maxRho + 0.5)
					idx: ((indexRho * maxTheta) + t) * unit2
					idx2: accValue + idx
					;assert idx2 < accTail
					if (idx2 >= accValue)  and (idx2 < accTail) [
						ii: _getIntValue as integer! idx2 unit2 
						_setIntValue as integer! idx2 ii + 1 unit2
					]
					t: t + 1
				]
			]
			x: x + 1
		]
		y: y + 1
	]
]


_rcvHough2Image: routine [
	mat			[vector!]
	dst			[image!]
	contrast 	[float!]
	/local
	pixD 	[int-ptr!]
	handle	[integer!]
	unit   ; 1 2 or 4
	i ii svalue  stail 
	maxa
	coef c
	
] [
	handle: 0
    pixD: image/acquire-buffer dst :handle
    maxa: 0.0
    svalue: vector/rs-head mat 	; get pointer address of accumulator matrix
    stail:  vector/rs-tail mat	; last
    unit: _rcvGetMatBitSize mat ; bit size
    ; get first max value
    while [svalue < stail][
		i: vector/get-value-int as int-ptr! svalue unit
		if i > as integer! maxa [maxa: as float! i]
		svalue: svalue + unit
	]
    coef: 255.0 / maxa * contrast
    ; update maxRho space image
    svalue: vector/rs-head mat 	; get pointer address of accumulator
    stail:  vector/rs-tail mat	; last value address
    
    while [svalue < stail][
    	i: vector/get-value-int as int-ptr! svalue unit
    	ii: as float! i * coef
       	either ii < 255.0 [c: as integer! ii] [c: 255]
       	pixD/value: ((255 << 24) OR ((255 - c) << 16 ) OR ((255 - c) << 8) OR (255))
       	svalue: svalue + unit
        pixD: pixD + 1
    ]
    image/release-buffer dst handle yes
]


_rcvGetHoughLines: routine [
	accu 		[vector!] 
	img			[image!]	
	threshold 	[integer!] 
	lines 		[block!]
	/local
	r t v vv vMax
	lx ly
	deg2Rad
	svalue
	unit idx
	cosAngle
	sinAngle
	a b x1 y1 x2 y2
	cx cy
	maxRho accw acch
	imw			
	imh	
	][
	
	imw: IMAGE_WIDTH(img/size)
    imh: IMAGE_HEIGHT(img/size)
    either imh > imw [maxRho: ((sqrt 2.0) * as float! imh) / 2.0] 
				 [maxRho: ((sqrt 2.0) * as float! imw) / 2.0]
    accw: 180
	acch: as integer! maxRho * 2
	deg2Rad: pi / accw
	cx: imw / 2.0
	cy: imh / 2.0
	block/rs-clear lines
	svalue: vector/rs-head accu
	unit: _rcvGetMatBitSize accu
	
	r: 0
	while [r < acch] [
		t: 0
		while [t < accw] [
			idx: ((r * accw) + t) * unit
			v: vector/get-value-int as int-ptr! (sValue + idx) unit
			if (v >= threshold) [
				;is the point a local maxima (9x9 kernel)
				vMax: v
				ly: -4 
				while [ly <= 4] [
					lx: -4 
					while [lx <= 4] [
					 if (((ly + r >= 0) and (ly + r < acch)) and ((lx + t >= 0) and (lx + t < accw))) 
						[	idx: (((r + ly) * accw) + t + lx) * unit
							vv: vector/get-value-int as int-ptr! (sValue + idx) unit
							if vv > vMax [
								vMax: vv
								ly: 5 
								lx: 5
							]
						]
						lx: lx + 1
					]
					ly: ly + 1
				]
				if vMax > v [t: t +1] ; pbs with if vMax > v [continue] 
				if vMax <= v 
				[
					cosAngle: cos (deg2Rad * t)	; in radian
					sinAngle: sin (deg2Rad * t)	; in radian
					a:  0.0 + r - maxRho
					either (t >= 45) and (t <= 135)
						[ 	;y = (r - x*cos(t)) / sin(t) ;sin t always <> 0
							x1: 0.0
							b: x1 - cx
							y1: (a - (b * cosAngle) / sinAngle) + cy
							x2: 0.0 + imw
							b: x2 - cx
							y2: (a - (b * cosAngle) / sinAngle) + cy
						] 
						[	;x = (r - y*sin(t)) / cos(t); ;cos t always <> 0
							y1: 0.0
							b: y1 - cy
							x1: (a - (b * sinAngle) / cosAngle) + cx
							y2: 0.0 + imh
							b: y2 - cy
							x2: (a - (b * sinAngle) / cosAngle) + cx
					]
					pair/make-in lines as integer! x1 as integer! y1
					pair/make-in lines as integer! x2 as integer! y2 
				] 
			] 
			t: t + 1
		] 
		r: r + 1
	]
]


; new routine for Gaussian noise on image

_rcvGenerateNoise: routine [
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



; doesn't work yet, OS-IMAGE not updated
_rcvResize: routine [src [image!] w [integer!] h [integer!] return: [image!]
][
	image/resize src w h
]



    







