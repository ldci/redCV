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
            2 [pixD/value: ((a << 24) OR (g << 16 ) OR (g << 8) OR g)] 	;Green Channel 
            3 [pixD/value: ((a << 24) OR (b << 16 ) OR (b << 8) OR b)] 	;blue Channel
            4 [pixD/value: ((a << 24) OR (a << 16 ) OR (a << 8) OR a)] 	;alpha Channel
        ]
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

; scalar integer
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


; scalar Float TBT
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
				1 [pixD/value: FF000000h or as integer! (pow as float! pix1/Value v)]
			    2 [pixD/value: FF000000h or as integer! (sqrt as float! pix1/Value)]
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




; ********* Image Alpha **********

_rcvSetAlpha: routine [
	src1  	[image!]
    dst   	[image!]
    alpha 	[integer!]
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
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
        	b: pix1/value and FFh 
        	a: alpha
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



