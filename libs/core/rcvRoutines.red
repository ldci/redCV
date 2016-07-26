Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvRoutines.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


;***************** IMAGE CONVERSION ROUTINES *****************
;exported as functions in /libs/core/rcvCore.red
_rcvCopy: routine [
    src1 [image!]
    dst  [image!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
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
           pixD/value: pix1/value
           x: x + 1
           pix1: pix1 + 1
           pixD: pixD + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]


_rcvConvert: routine [
    src1 [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a s mini maxi
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    s: 0
    mini: 0
    maxi: 0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and 00FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh 
        switch op [
        	0 [pixD/value: pix1/value]
        	1 [s: (r + g + b) / 3 
            	pixD/value: ( (a << 24) OR (s << 16 ) OR (s << 8) OR s)] ;RGB2Gray average
          111 [ r: (r * 21) / 100
              		g: (g * 72) / 100 
              		b: (b * 7) / 100
              		s: r + g + b
                  	pixD/value: ( (a << 24) OR (s << 16 ) OR (s << 8) OR s)] ;RGB2Gray luminosity
          112 [ either r > g [mini: g][mini: r] 
              		  either b > mini [mini: mini][ mini: b] 
              		  either r > g [maxi: r][maxi: g] 
              		  either b > maxi [maxi: b][ maxi: maxi] 
              		  s: (mini + maxi) / 2
              		  pixD/value: ((a << 24) OR (s << 16 ) OR (s << 8) OR s)] ;RGB2Gray lightness
        	2 [pixD/value: ((a << 24) OR (b << 16 ) OR (g << 8) OR r)] ;2BGRA
            3 [pixD/value: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)] ;2RGBA
            4 [either r >= 128 [r: 255 g: 255 b: 255] [r: 0 g: 0 b: 0] 
            	   pixD/value: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)] ;2BW
        ]
        x: x + 1
        pix1: pix1 + 1
        pixD: pixD + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]

_rcvFilterBW: routine [
    src1 	[image!]
    dst  	[image!]
    thresh	[integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a
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
       	a: 255
       	r: pix1/value and 00FF0000h >> 16 
        g: 0 
        b: 0
        
        either r >= thresh [r: 255 g: 255 b: 255] [r: 0 g: 0 b: 0] 
        pixD/value: FF000000h or ((a << 24) OR (r << 16 ) OR (g << 8) OR b)
       
        x: x + 1
        pix1: pix1 + 1
        pixD: pixD + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]



_rcvChannel: routine [
    src  [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD

    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and 00FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh 
        switch op [
        	0 [pixD/value: pix1/value]
            1 [pixD/value: ((a << 24) OR (r << 16 ) OR (r << 8) OR r)]	;Red Channel
            2 [pixD/value: ((a << 24) OR (g << 16 ) OR (g << 8) OR g)] ;Green Channel 
            3 [pixD/value: ((a << 24) OR (b << 16 ) OR (b << 8) OR b)] ;blue Channel
        ]
        ;pixD/value: ((a << 24) OR (r << 16 ) OR (r << 8) OR r)
        x: x + 1
        pix1: pix1 + 1
        pixD: pixD + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


;***************** COLORSPACE CONVERSIONS ************

_rcvRGBXYZ: routine [
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
       	a: pix1/value >>> 24
       	r: pix1/value and 00FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh 
        rf: (integer/to-float r) / 255.0
		gf: (integer/to-float g) / 255.0
		bf: (integer/to-float b) / 255.0
		either (rf > 0.04045) [rf: pow ((rf + 0.055) / 1.055) 2.4] [rf: rf / 12.92]
		either (gf > 0.04045) [gf: pow ((gf + 0.055) / 1.055) 2.4] [gf: gf / 12.92]
		either (bf > 0.04045) [bf: pow ((bf + 0.055) / 1.055) 2.4] [bf: bf / 12.92]
		rf: rf * 100.0
    	gf: gf * 100.0
    	bf: bf * 100.0
    	;Observer. = 2°, Illuminant = D65
		xf: (rf * 0.4124) + (gf *  0.3576) + (bf * 0.1805)
    	yf: (rf * 0.2126) + (gf *  0.7152) + (bf * 0.0722)
    	zf: (rf * 0.0193) + (gf *  0.1192) + (bf * 0.9505)
    	r: float/to-integer xf
    	g: float/to-integer yf
    	b: float/to-integer zf

    	pixD/value: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)	
        x: x + 1
        pix1: pix1 + 1
        pixD: pixD + 1
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
       	a: pix1/value >>> 24
       	r: pix1/value and 00FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh 
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
    	pixD/value: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)	
        x: x + 1
        pix1: pix1 + 1
        pixD: pixD + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]


;***************** MATH OPERATOR ON IMAGE ROUTINES ************
; exported as functions in /libs/core/rcvCore.red

_rcvMath: routine [
	src1 [image!]
	src2 [image!]
	dst	 [image!]
	op [integer!]
	/local 
	pix1 [int-ptr!]
	pix2 [int-ptr!]
	pixD [int-ptr!]
	handle1 handle2 handleD h w x y
][
	handle1: 0
	handle2: 0
	handleD: 0
	pix1: image/acquire-buffer src1 :handle1
	pix2: image/acquire-buffer src2 :handle2
	pixD: image/acquire-buffer dst :handleD
	
	w: IMAGE_WIDTH(src1/size) 
	h: IMAGE_HEIGHT(src1/size)
	x: 0
	y: 0
	while [y < h] [
		while [x < w][
			switch op [
				0 [pixD/value: pix1/Value ]
				1 [pixD/value: FF000000h or (pix1/Value + pix2/value)]
				2 [pixD/value: FF000000h or (pix1/Value - pix2/Value)]
				3 [pixD/value: FF000000h or (pix1/Value * pix2/Value)]
				4 [pixD/value: FF000000h or (pix1/Value / pix2/Value)]
				5 [pixD/value: FF000000h or (pix1/Value // pix2/Value)]
				6 [pixD/value: FF000000h or (pix1/Value % pix2/Value)]
				7 [either pix1/Value > pix2/Value [pixD/value: FF000000h or (pix1/Value - pix2/Value) ]
				                       [pixD/value: FF000000h or (pix2/Value - pix1/Value)]]
			]
			x: x + 1
			pix1: pix1 + 1
			pix2: pix2 + 1
			pixD: pixD + 1
		]
		x: 0
		y: y + 1
	]
	image/release-buffer src1 handle1 no
	image/release-buffer src2 handle2 no
	image/release-buffer dst handleD yes
]


_rcvMathT: routine [
	src1 [image!]
	dst [image!]
	t	 [tuple!]
	op [integer!]
	/local 
	pix1 [int-ptr!]
	pix2 [int-ptr!]
	pixD [int-ptr!]
	handle1 handleD h w x y tp
][
	handle1: 0
	handleD: 0
	pix1: image/acquire-buffer src1 :handle1
	pixD: image/acquire-buffer dst :handleD
	tp: as red-tuple! t
	w: IMAGE_WIDTH(src1/size) 
	h: IMAGE_HEIGHT(src1/size)
	x: 0
	y: 0
	while [y < h] [
		while [x < w][
			switch op [
				0 [pixD/value: pix1/Value]
				1 [pixD/value: FF000000h or (pix1/Value + tp)]
				2 [pixD/value: FF000000h or (pix1/Value - tp)]
				3 [pixD/value: FF000000h or (pix1/Value * as integer! tp)]
				4 [pixD/value: FF000000h or (pix1/Value / as integer! tp)]
				5 [pixD/value: FF000000h or (pix1/Value // as integer! tp)]
				6 [pixD/value: FF000000h or (pix1/Value % as integer! tp)]
			]
			x: x + 1
			pix1: pix1 + 1
			pixD: pixD + 1
		]
		x: 0
		y: y + 1
		
	]
	image/release-buffer src1 handle1 no
	image/release-buffer dst handleD yes
]

; scalar
_rcvMathS: routine [
	src1 [image!]
	dst [image!]
	v	 [integer!]
	op [integer!]
	/local 
	pix1 [int-ptr!]
	pix2 [int-ptr!]
	pixD [int-ptr!]
	handle1 handleD h w x y 
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
			switch op [
				0 [pixD/value: pix1/Value ]
				1 [pixD/value: FF000000h or(pix1/Value + v)]
				2 [pixD/value: FF000000h or (pix1/Value - v)]
				3 [pixD/value: FF000000h or (pix1/Value * v)]
				4 [pixD/value: FF000000h or (pix1/Value / v)]
				5 [pixD/value: FF000000h or (pix1/Value // v)]
				6 [pixD/value: FF000000h or (pix1/Value % v)]
				7 [pixD/value: FF000000h or float/to-integer (pow integer/to-float pix1/Value integer/to-float v)]
				8 [pixD/value: FF000000h or (pix1/Value << v)]
				9 [pixD/value: FF000000h or (pix1/Value >> v)]
			   10 [pixD/value: FF000000h or float/to-integer ( sqrt integer/to-float pix1/Value >> v)]
			]
			x: x + 1
			pix1: pix1 + 1
			pixD: pixD + 1
		]
		x: 0
		y: y + 1
	]
	image/release-buffer src1 handle1 no
	image/release-buffer dst handleD yes
]


;***************** LOGICAL OPERATOR ON IMAGE ROUTINES ************
; exported as functions in /libs/core/rcvCore.red


_rcvNot: routine [
    src1 [image!]
    dst  [image!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
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
           pixD/value: FF000000h or NOT pix1/value
           x: x + 1
           pix1: pix1 + 1
           pixD: pixD + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]


_rvcLogical: routine [
	src1 [image!]
	src2 [image!]
	dst	 [image!]
	op [integer!]
	/local 
	pix1 [int-ptr!]
	pix2 [int-ptr!]
	pixD [int-ptr!]
	handle1 handle2 handleD h w x y
][
	handle1: 0
	handle2: 0
	handleD: 0
	pix1: image/acquire-buffer src1 :handle1
	pix2: image/acquire-buffer src2 :handle2
	pixD: image/acquire-buffer dst :handleD
	
	w: IMAGE_WIDTH(src1/size) 
	h: IMAGE_HEIGHT(src1/size)
	x: 0
	y: 0
	while [y < h] [
		while [x < w][
			switch op [
				1 [pixD/value: FF000000h or pix1/Value AND pix2/value]
				2 [pixD/value: FF000000h or pix1/Value OR pix2/Value]
				3 [pixD/value: FF000000h or (pix1/Value XOR pix2/Value)]
				4 [pixD/value: FF000000h or NOT (pix1/Value AND pix2/Value)]
				5 [pixD/value: FF000000h or NOT (pix1/Value OR pix2/Value)]
				6 [pixD/value: FF000000h or NOT (pix1/Value XOR pix2/Value)]
				7 [either pix1/Value > pix2/Value [pixD/value: pix2/Value][pixD/value: FF000000h or pix1/Value]]
           		8 [either pix1/Value > pix2/Value [pixD/value: pix1/Value] [pixD/value: FF000000h or pix2/Value]]
			]
			x: x + 1
			pix1: pix1 + 1
			pix2: pix2 + 1
			pixD: pixD + 1
		]
		x: 0
		y: y + 1
		
	]
	image/release-buffer src1 handle1 no
	image/release-buffer src2 handle2 no
	image/release-buffer dst handleD yes
]


;***************** STATISTICAL ROUTINES ***********************
; exported as functions in /libs/math/rcvStats.red
_rcvCount: routine [src1 [image!] return: [integer!]
	/local 
		stride1 
		bmp1 
		data1 
		w 
		x 
		y 
		h 
		pos
		r 
		g
		b
		a
		n
][
    stride1: 0
    bmp1: OS-image/lock-bitmap as-integer src1/node no
    data1: OS-image/get-data bmp1 :stride1   

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    n: 0
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            r: data1/pos and 00FF0000h >> 16
            g: data1/pos and FF00h >> 8
            b: data1/pos and FFh
            if (r > 0) and (g > 0) and (b > 0) [n: n + 1]
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    OS-image/unlock-bitmap as-integer src1/node bmp1;
    n
]

_rcvStdInt: routine [src1 [image!] return: [integer!]
	/local 
		stride1 
		bmp1 
		data1 
		w 
		x 
		y 
		h 
		pos
		r 
		g
		b
		a
		sr 
		sg
		sb
		sa
		fr 
		fg
		fb
		fa
		e
][
    stride1: 0
    bmp1: OS-image/lock-bitmap as-integer src1/node no
    data1: OS-image/get-data bmp1 :stride1   

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    sa: 0
    sr: 0
    sg: 0
    sb: 0
    fa: 0.0
    fr: 0.0
    fg: 0.0
    fb: 0.0
    ; Sigma X
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            sa: sa + (data1/pos >>> 24)
            sr: sr + (data1/pos and 00FF0000h >> 16)  
            sg: sg + (data1/pos and FF00h >> 8)
            sb: sb + (data1/pos and FFh)
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    ; mean values
    a: 0; 255 xor (sa / (w * h))
    r: sr / (w * h)
    g: sg / (w * h)
    b: sb / (w * h)
    x: 0
    y: 0
    e: 0
    ; x - m 
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            e: (data1/pos >>> 24) - a sa: sa + (e * e)
            e: (data1/pos and 00FF0000h >> 16) - r   sr: sr + (e * e)
            e: (data1/pos and FF00h >> 8) - g sg: sg + (e * e)
            e: (data1/pos and FFh) - b sb: sb + (e * e)
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    ; standard deviation
    fa: 0.0; 255 xor sa / ((w * h) - 1)
    fr: sqrt integer/to-float (sr / ((w * h) - 1))
    fg: sqrt integer/to-float (sg / ((w * h) - 1))
    fb: sqrt integer/to-float (sb / ((w * h) - 1))
    a: float/to-integer fa
    r: float/to-integer fr
    g: float/to-integer fg
    b: float/to-integer fb
    OS-image/unlock-bitmap as-integer src1/node bmp1;
    (a << 24) OR (r << 16 ) OR (g << 8) OR b 
]

_rcvMeanInt: routine [src1 [image!] return: [integer!]
	/local 
		stride1 
		bmp1 
		data1 
		w 
		x 
		y 
		h 
		pos
		r 
		g
		b
		a
		sr 
		sg
		sb
		sa
][
    stride1: 0
    bmp1: OS-image/lock-bitmap as-integer src1/node no
    data1: OS-image/get-data bmp1 :stride1   

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    sa: 0
    sr: 0
    sg: 0
    sb: 0
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            sa: sa + (data1/pos >>> 24)
            sr: sr + (data1/pos and 00FF0000h >> 16)  
            sg: sg + (data1/pos and FF00h >> 8)
            sb: sb + (data1/pos and FFh)
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    ;a: 255 xor (sa / (w * h))
    r: sr / (w * h)
    g: sg / (w * h)
    b: sb / (w * h)
    OS-image/unlock-bitmap as-integer src1/node bmp1;
    (255 << 24) OR (r << 16 ) OR (g << 8) OR b 
]

;***************** IMAGE TRANSFORMATION ROUTINES ***********************

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
            1 [idx: pix1 + (y * w) + (w - x)] 			;left/right
            2 [idx: pix1 + (w * h) - (y * w) + x - w] 	; up/down
            3 [idx: pix1 + (w * h) - (y * w) - x - 1]	; both flips
        ]
        
        pixD/value: idx/value
        x: x + 1
        pixD: pixD + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
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
Apart from using a kernel matrix, it also has a multiplier factor and a bias. 
After applying the filter, the factor will be multiplied with the result, and the bias added to it. 
So if you have a filter with an element 0.25 in it, but the factor is set to 2, all elements of the filter 
are  multiplied by two so that element 0.25 is actually 0.5. 
The bias can be used if you want to make the resulting image brighter. 
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
    kWidth: float/to-integer (sqrt integer/to-float (block/rs-length? kernel))
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
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		imx:  (x + (i - (kWidth / 2)) + w ) % w 
        			imy:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: pix1 + (imy * w) + imx  ; corrected pixel index
            		r: idx/value and 00FF0000h >> 16 
        			g: idx/value and FF00h >> 8 
       				b: idx/value and FFh  
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			accR: accR + ((integer/to-float r) * f/value)
        			accG: accG + ((integer/to-float g) * f/value)
        			accB: accB + ((integer/to-float b) * f/value)
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        
        r: float/to-integer (accR * factor)						 
        g: float/to-integer (accG * factor)	
        b: float/to-integer (accB * factor)					 
    	r: r + float/to-integer delta
    	g: g + float/to-integer delta
    	b: b + float/to-integer delta
        if r < 0 [r: 0]
        if r > 255 [r: 255]
        if g < 0 [g: 0]
        if g > 255 [g: 255]
        if b < 0 [b: 0]
        if b > 255 [b: 255]				 
        pixD/value: ((255 << 24) OR (r << 16 ) OR (g << 8) OR b)	
        x: x + 1
        pixD: pixD + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


; Similar to convolution but the sum of the weights is computed during the summation, and used to scale the result.

_rcvFilter2D: routine [
    src  	[image!]
    dst  	[image!]
    kernel 	[block!] 
    delta	[integer!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        handle1 handleD h w x y i j
        pixel
        r g b
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
    kWidth: float/to-integer (sqrt integer/to-float (block/rs-length? kernel))
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
        			; calculate weighted values
        			accR: accR + ((integer/to-float r) * f/value)
        			accG: accG + ((integer/to-float g) * f/value)
        			accB: accB + ((integer/to-float b) * f/value)
        			weightSum: weightSum + f/value
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        either (weightSum > 0.0) [r: float/to-integer (accR / weightSum)] 
        						 [r: float/to-integer (accR)]
        either (weightSum > 0.0) [g: float/to-integer (accG / weightSum)] 
        						 [g: float/to-integer (accG)]
        either (weightSum > 0.0) [b: float/to-integer (accB / weightSum)] 
        						 [b: float/to-integer (accB)]
        
        r: r + delta
        g: g + delta
        b: b + delta
        if r < 0 [r: 0]
        if r > 255 [r: 255]
        if g < 0 [g: 0]
        if g > 255 [g: 255]
        if b < 0 [b: 0]
        if b > 255 [b: 255]				 
        pixD/value: ((255 << 24) OR (r << 16 ) OR (g << 8) OR b)	
        x: x + 1
        pixD: pixD + 1
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
    kWidth: float/to-integer (sqrt integer/to-float (block/rs-length? kernel))
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
        			weightAcc: weightAcc + ((integer/to-float idx/value) * f/value)
        			weightSum: weightSum + f/value
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        either (weightSum > 0.0) [pixD/value: float/to-integer (weightAcc / weightSum)] 
        						 [pixD/value: float/to-integer (weightAcc)]
       
        x: x + 1
        pixD: pixD + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


; to be DONE
; ********* Image Random **********
;TBI
_rcvRandom: routine [size [pair!] value [tuple!] return: [image!]
	/local 
		dst 
		stride 
		bmpDst 
		dataDst 
		w 
		x 
		y 
		h 
		pos
		tp
		sz
		r
		g
		b
		a
][
    dst: as red-image! stack/push*        ;-- create an new image slot
    sz: as red-pair! size
    stride: 0
      
    bmpDst: OS-image/lock-bitmap as-integer dst/node yes
    
    dataDst: OS-image/get-data bmpDst :stride

    w: sz/x
    h: sz/y
    x: 0
    y: 0
    tp: as red-tuple! value

    while [y < h][
        while [x < w][
            pos: stride >> 2 * y + x + 1
            a: 0 r: 0 g: 0 b: 0
            dataDst/pos: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)
            ;dataDst/pos: as-integer tuple/random tp true false false
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    OS-image/unlock-bitmap as-integer dst/node bmpDst
	as red-image! stack/set-last as cell! dst            ;-- return new image
]


