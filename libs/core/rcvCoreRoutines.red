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


;***************** PIXEL ACCESS *****************************
	

_rcvGetPixel: routine [src1 [image!] coordinate [pair!] return: [integer!]
	/local 
		pix1 [int-ptr!]
		handle1 
		w x y h pos
		a r g b
][
    handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: coordinate/x
    y: coordinate/y
    pos: (y * w) + x
    pix1: pix1 + pos
    a: 255 - (pix1/value >>> 24)
    r: pix1/value and 00FF0000h >> 16
    g: pix1/value and FF00h >> 8
    b: pix1/value and FFh
    image/release-buffer src1 handle1 no
    (a << 24) OR (r << 16 ) OR (g << 8) OR b
]


_rcvSetPixel: routine [src1 [image!] coordinate [pair!] val [integer!]
	/local 
		pix1 [int-ptr!]
		handle1 
		w x y h pos
][
    handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: coordinate/x
    y: coordinate/y
    pos: (y * w) + x
    pix1: pix1 + pos
    pix1/Value: FF000000h or val
    image/release-buffer src1 handle1 yes
]

_rcvIsAPixel: routine [src [image!] coordinate [pair!] threshold [integer!] return: [logic!]
	/local 
		v a r g b
		mean
][
	v: _rcvGetPixel src coordinate
	a: 255 - (v >>> 24)
    r: v and 00FF0000h >> 16 
    g: v and FF00h >> 8 
    b: v and FFh
    mean: (r + g + b) / 3
    either mean > threshold [true] [false]
]



;***************** IMAGE CONVERSION ROUTINES *****************
;exported as functions in /libs/core/rcvCore.red 

_rcvReleaseImage: routine [src [image!]] [
	image/delete src
]

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


_rcvConvert: routine [
    src1 [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a s mini maxi
        rf gf bf sf
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
    sf: 0.0
    mini: 0
    maxi: 0
    while [y < h] [
       x: 0
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and 00FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh 
        rf: as float! r
        gf: as float! g
        bf: as float! b
        switch op [
        	0 [pixD/value: pix1/value]
        	1 [s: (r + g + b) / 3 
            	pixD/value: (a << 24) OR (s << 16 ) OR (s << 8) OR s] ;RGB2Gray average
          111 [ r: (r * 21) / 100
              		g: (g * 72) / 100 
              		b: (b * 7) / 100
              		s: r + g + b
                  	pixD/value: (a << 24) OR (s << 16 ) OR (s << 8) OR s] ;RGB2Gray luminosity
          112 [ either r > g [mini: g][mini: r] 
              		  either b > mini [mini: mini][ mini: b] 
              		  either r > g [maxi: r][maxi: g] 
              		  either b > maxi [maxi: b][ maxi: maxi] 
              		  s: (mini + maxi) / 2
              		  pixD/value: (a << 24) OR (s << 16 ) OR (s << 8) OR s] ;RGB2Gray lightness
          113 [sf: rf + gf + bf 
          		r: as integer! ((rf / sf) * 255)
          		g: as integer! ((gf / sf) * 255)
          		b: as integer! ((bf / sf) * 255)
          		pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b
          	] ; Normalized RGB by sum
          114 [ sf: sqrt((pow rf 2.0) + (pow gf 2.0) + (pow bf 2.0))
          		r: as integer! ((rf  / sf) * 255)
          		g: as integer! ((gf  / sf) * 255)
          		b: as integer! ((bf  / sf) * 255)
          		pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b
          	] ; Normalized RGB by square sum
        	2 [pixD/value: (a << 24) OR (b << 16 ) OR (g << 8) OR r] ;2BGRA
            3 [pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b] ;2RGBA
            4 [either r > 127 [r: 255 g: 255 b: 255] [r: 0 g: 0 b: 0] 
            	   pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b] ;2BW
            5 [either r > 127 [r: 0 g: 0 b: 0] [r: 255 g: 255 b: 255] 
            	   pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b] ;2WB
        ]
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]

_rcvFilterBW: routine [
    src1 		[image!]
    dst  		[image!]
    thresh		[integer!]
    maxValue 	[integer!]
    op	 		[integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a v
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
        v: (r + g + b) / 3
        r: v
        g: v
        b: v
        switch op [
        	0 [either v >= thresh [r: 255 g: 255 b: 255] [r: 0 g: 0 b: 0]]
        	1 [either v > thresh [r: maxValue g: maxValue b: maxValue] [r: 0 g: 0 b: 0]]
        	2 [either v > thresh [r: 0 g: 0 b: 0] [r: maxValue g: maxValue b: maxValue]]
        	3 [either v > thresh [r: thresh g: thresh b: thresh] [r: r g: g b: b]]
        	4 [either v > thresh [r: r g: g b: b] [r: 0 g: 0 b: 0]]
        	5 [either v > thresh [r: 0 g: 0 b: 0] [r: r g: g b: b]]
        ]  
        pixD/value: FF000000h or ((a << 24) OR (r << 16 ) OR (g << 8) OR b)    
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
            1 [pixD/value: (a << 24) OR (r << 16 ) OR (r << 8) OR r]	;Red Channel
            2 [pixD/value: (a << 24) OR (g << 16 ) OR (g << 8) OR g] 	;Green Channel 
            3 [pixD/value: (a << 24) OR (b << 16 ) OR (b << 8) OR b] 	;blue Channel
            4 [pixD/value: (a << 24) OR (a << 16 ) OR (a << 8) OR a] 	;alpha Channel
        ]
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

_rcvMerge: routine [
    src1  [image!]
    src2  [image!]
    src3  [image!]
    dst   [image!]
    /local
        pix1 [int-ptr!]
        pix2 [int-ptr!]
        pix3 [int-ptr!]
        pixD [int-ptr!]
        handle1 handle2 handle3 handleD 
        h w x y
        r g b a
][
    handle1: 0
    handle2: 0
    handle3: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pix2: image/acquire-buffer src2 :handle2
    pix3: image/acquire-buffer src3 :handle3
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
       		a: pix1/value >>> 24
       		r: pix1/value and 00FF0000h >> 16 
       	 	g: pix2/value and FF00h >> 8 
        	b: pix3/value and FFh 
        	pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b
        	pix1: pix1 + 1
        	pix2: pix2 + 1
        	pix3: pix3 + 1
        	pixD: pixD + 1
        	x: x + 1
       ]
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer src2 handle2 no
    image/release-buffer src3 handle3 no
    image/release-buffer dst handleD yes
]


;***************** MATH OPERATOR ON IMAGE ROUTINES ************
; exported as functions in /libs/core/rcvCore.red

; images 
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
				0 [pixD/value: pix1/Value]
				1 [pixD/value: FF000000h or (pix1/Value + pix2/value)]
				2 [pixD/value: FF000000h or (pix1/Value - pix2/Value)]
				3 [pixD/value: FF000000h or (pix1/Value * pix2/Value)]
				4 [pixD/value: FF000000h or (pix1/Value / pix2/Value)]
				5 [pixD/value: FF000000h or (pix1/Value // pix2/Value)]
				6 [pixD/value: FF000000h or (pix1/Value % pix2/Value)]
				7 [either pix1/Value > pix2/Value [pixD/value: FF000000h or (pix1/Value - pix2/Value) ]
				                       [pixD/value: FF000000h or (pix2/Value - pix1/Value)]]
				8 [pixD/value: FF000000h or ((pix1/Value + pix2/value) / 2)]
			]
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

; tuples
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
				1 [pixD/value: FF000000h or (pix1/Value + as integer! tp)]
				2 [pixD/value: FF000000h or (pix1/Value - as integer! tp)]
				3 [pixD/value: FF000000h or (pix1/Value * as integer! tp)]
				4 [pixD/value: FF000000h or (pix1/Value / as integer! tp)]
				5 [pixD/value: FF000000h or (pix1/Value // as integer! tp)]
				6 [pixD/value: FF000000h or (pix1/Value % as integer! tp)]
			]
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

; integer scalar
_rcvMathS: routine [
	src1 	[image!]
	dst 	[image!]
	v	 	[integer!]
	op 		[integer!]
	/local 
	pix1 	[int-ptr!]
	pix2 	[int-ptr!]
	pixD 	[int-ptr!]
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
				1 [pixD/value: FF000000h or (pix1/Value + v)]
				2 [pixD/value: FF000000h or (pix1/Value - v)]
				3 [pixD/value: FF000000h or (pix1/Value * v)]
				4 [pixD/value: FF000000h or (pix1/Value / v)]
				5 [pixD/value: FF000000h or (pix1/Value // v)]
				6 [pixD/value: FF000000h or (pix1/Value % v)]
				7 [pixD/value: FF000000h or (pix1/Value << v)]
				8 [pixD/value: FF000000h or (pix1/Value >> v)]
				9 [pixD/value: FF000000h or as integer! (pow as float! pix1/Value as float! v)]
			   10 [pixD/value: FF000000h or as integer! (sqrt as float! pix1/Value >> v)]
			]
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


; Float scalar
_rcvMathF: routine [
	src1 	[image!]
	dst 	[image!]
	v	 	[float!]
	op 		[integer!]
	/local 
	pix1 	[int-ptr!]
	pix2 	[int-ptr!]
	pixD 	[int-ptr!]
	handle1 handleD h w x y 
	a r g b
	fa fr fg fb
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
			switch op [
				1 [ fa: as integer! (pow as float! a v)
					fr: as integer! (pow as float! r v)
					fg: as integer! (pow as float! g v)
					fb: as integer! (pow as float! b v)
				  ]
			    2 [ fa: as integer! (sqrt as float! a >> as integer! v)
			    	fr: as integer! (sqrt as float! r >> as integer! v)
					fg: as integer! (sqrt as float! g >> as integer! v)
					fb: as integer! (sqrt as float! b >> as integer! v)]
				3  [fa: as integer! (v * a)
					fr: as integer! (v * r)
					fg: as integer! (v * g)
					fb: as integer! (v * b)] ; for image intensity
			]
			pixD/value: FF000000h or ((fa << 24) OR (fr << 16 ) OR (fg << 8) OR fb)
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

;*************Logarithmic Image Processing Model ************
; exported as functions in /libs/core/rcvCore.red

_rcvLIP: routine [
	src1 [image!]
	src2 [image!]
	dst	 [image!]
	op [integer!]
	/local 
	pix1 [int-ptr!]
	pix2 [int-ptr!]
	pixD [int-ptr!]
	handle1 handle2 handleD h w x y
	a1 r1 g1 b1
	a2 r2 g2 b2 
	fa fr fg fb
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
			a1: pix1/value >>> 24
    		r1: pix1/value and 00FF0000h >> 16 
    		g1: pix1/value and FF00h >> 8 
    		b1: pix1/value and FFh 	
    		a2: pix2/value >>> 24
    		r2: pix2/value and 00FF0000h >> 16 
    		g2: pix2/value and FF00h >> 8 
    		b2: pix2/value and FFh
			switch op [
				1 [fr: (r1 + r2) - ((r1 * r2) / 256) 
				   fg: (g1 + g2) - ((g1 * g2) / 256)
			       fb: (b1 + b2) - ((b1 * b2) / 256)
			    ]
			    2 [ fr: (256 * (r1 - r2)) / (256 - r2)
			    	fg: (256 * (g1 - g2)) / (256 - g2)
			    	fb: (256 * (b1 - b2)) / (256 - b2)
			    ]
			]
			pixD/value: (255 << 24) OR (fr << 16 ) OR (fg << 8) OR fb
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
				3 [pixD/value: FF000000h or pix1/Value XOR pix2/Value]
				4 [pixD/value: FF000000h or NOT pix1/Value AND pix2/Value]
				5 [pixD/value: FF000000h or NOT pix1/Value OR pix2/Value]
				6 [pixD/value: FF000000h or NOT pix1/Value XOR pix2/Value]
				7 [either pix1/Value > pix2/Value [pixD/value: pix2/Value][pixD/value: FF000000h or pix1/Value]]
           		8 [either pix1/Value > pix2/Value [pixD/value: pix1/Value] [pixD/value: FF000000h or pix2/Value]]
			]
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


; ********* Image Alpha **********
; exported as functions in /libs/core/rcvCore.red

_rcvSetAlpha: routine [
	src  	[image!]
    dst   	[image!]
    alpha 	[integer!]
    /local
	pixS 	[int-ptr!]
    pixD 	[int-ptr!]
    handleS handleD 
    h w x y 
    r g b 
][
	handleS: 0
    handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
       		r: pixS/value and 00FF0000h >> 16 
    		g: pixS/value and FF00h >> 8 
    		b: pixS/value and FFh 	
       		;pixD/value: 00FFFFFFh AND pixS/value  OR (alpha << 24) ; pbs macOS 
       		pixD/value: (alpha << 24) OR (r << 16 ) OR (g << 8) OR b ; pbs macOS
           	pixS: pixS + 1
           	pixD: pixD + 1
           	x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

;********** SUB-ARRAYS ************************
; exported as functions in /libs/core/rcvCore.red

_rcvInRange: routine [
	src1  	[image!]
    dst   	[image!]
    lowr 	[integer!]
    lowg 	[integer!]
    lowb 	[integer!]
    upr 	[integer!]
    upg 	[integer!]
    upb 	[integer!]
    op		[integer!]
    /local
	pix1 	[int-ptr!]
    pixD 	[int-ptr!]
    handle1 handleD 
    h w x y r g b a
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
        	either (((r > lowr) and (r <= upr)) and ((g > lowg) and (g <= upg)) and ((b > lowb) and (b <= upb)))
        	[if op = 0 [r: FFh g: FFh b: FFh]
        	 if op = 1 [r: r g: g b: b]]
        	[r: 0 g: 0 b: 0] 
        	
       		pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b
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

; Random New To be documented

_rcvRandImage: routine [
	src1	[image!]
	/local
    pix1 [int-ptr!]
    handle1 h w x y
    r g b int
][
	handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h] [
    	 x: 0
      	 while [x < w][
      	 	r: _random/rand and FFh
      	 	g: _random/rand and FFh
      	 	b: _random/rand and FFh
      	 	x: x + 1
      	 	pix1/value: (255 << 24) OR (r << 16 ) OR (g  << 8) OR b
           	pix1: pix1 + 1
      	 ]
      	 y: y + 1
	]  
	image/release-buffer src1 handle1 yes	
]





