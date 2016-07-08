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
rcvCopy: routine [
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


rcvConvert: routine [
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

rcvChannel: routine [
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

rcvRGBXYZ: routine [
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

rcvXYZRGB: routine [
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


;***************** MATH OPERATOR ON IMAGE ROUTINES ************
; exported as functions in /libs/core/rcvCore.red

rcvMath: routine [
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


rcvMathT: routine [
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
rcvMathS: routine [
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


rcvNot: routine [
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


rvcLogical: routine [
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
rcvCount: routine [src1 [image!] return: [integer!]
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

rcvStdInt: routine [src1 [image!] return: [integer!]
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

rcvMeanInt: routine [src1 [image!] return: [integer!]
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
