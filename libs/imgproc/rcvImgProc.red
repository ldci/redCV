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


;#include %../core/rcvCore.red ;--for stand alone test
;#include %../tools/rcvTools.red ;--for stand alone test
;#include %../matrix/rcvMatrix.red ;--for stand alone test
	
;********************** NEW MATRIX OBJECT **************************
#include %rcvConvolutionImg.red
#include %rcvConvolutionMat.red
#include %rcvGaussian.red

;********************** spatial filters *****************************

rcvPointDetector: function [
"Detects points"
	src 	[image! object!] 
	dst		[image! object!]
	param1 	[float!] 
	param2 	[float!]
][
	knl: [-1.0 -1.0 -1.0 -1.0 8.0 -1.0 -1.0 -1.0 -1.0] ; OK
	t: type? src
	if t = object! [
		rcvConvolveMat src dst knl param1 param2
	]
	if t = image! [
		rcvConvolve src dst knl param1 param2
	]
]

;--image enhancement
rcvSharpen: function [
"Image sharpening"
	src 	[image! object!] 
	dst		[image! object!]
] [
	
	knl: [0.0 -1.0 0.0 -1.0 5.0 -1.0 0.0 -1.0 0.0] ; OK
	t: type? src
	if t = object! [
		rcvConvolveMat src dst knl 1.0 0.0
	]
	if t = image! [
		rcvConvolve src dst knl 1.0 0.0
	]
]

rcvBinomialFilter: function [
"Binomial filter"
	src 	[image! object!] 
	dst		[image! object!]
	f 		[float!]
][
	ff: negate f * (1.0 / 16.0)
	knl: reduce [ff 2.0 * ff ff 2.0 * ff (16 - f) * (1.0 / 16.0)  2.0 * ff ff 2.0 * ff ff]
	t: type? src
	if t = object! [
		rcvConvolveMat src dst knl 1.0 0.0
	]
	if t = image! [
		;rcvConvolve src dst knl 1.0 0.0
		rcvFilter2D src dst knl 1.0 0.0
	]
]

;Uniform Weight Convolutions
; Blurring is typical of low pass filters

rcvLowPass: function [
"This filter produces a simple average of the 9 nearest neighbors of each pixel in the image."
	src 	[image! object!] 
	dst		[image! object!]
][
	v: 1.0 / 9.0 ; since weights is  > zero 
	knl: reduce [v v v v v v v v v]
	t: type? src
	if t = object! [
		rcvConvolveMat src dst knl 1.0 0.0
	]
	if t = image! [
		rcvConvolve src dst knl 1.0 0.0
	]
]

;Non-Uniform (Binomial) Weight Convolution
; similar to lowPass
rcvBinomialLowPass: function [
"Weights are formed from the coefficients of the binomial series."
	src 	[image! object!] 
	dst		[image! object!] 
][
	l: 1.0 / 16.0; 0.0625 since weights is > zero
	knl: reduce [1.0 2.0 1.0 2.0 4.0 2.0 1.0 2.0 1.0]
	t: type? src
	if t = object! [
		rcvConvolveMat src dst knl l 0.0
	]
	if t = image! [
		rcvConvolve src dst knl l 0.0
	]
]

;--Gaussian blurring
rcvGaussianFilter: function [
"Gaussian 2D Filter"
	src 	[image! object!] 
	dst		[image! object!]
	kSize 	[pair!]	 ;kernel size
	sigma	[float!] ;variance
][
	knl: rcvMakeGaussian kSize sigma
	t: type? src
	if t = image!  [rcvFilter2D src dst knl 1.0 0.0]
	if t = object! [rcvConvolveMat src dst knl 1.0 0.0]
	dst
]

;shows the edges in the image
rcvHighPass: function [
"This filter produces a simple average  of the 9 nearest neighbors of each pixel in the image."
	src 	[image! object!] 
	dst		[image! object!] 
][
	knl: [-1.0 -1.0 -1.0 -1.0 8.0 -1.0 -1.0 -1.0 -1.0]
	t: type? src
	if t = object! [
		rcvConvolveMat src dst knl 1.0 0.0
	]
	if t = image! [
		rcvConvolve src dst knl 1.0 0.0
	]
]


;subtraction of low pass from original image 
rcvHighPass2: function [
"This filter removes low pass values from original image."
	src 	[image! object!] 
	dst		[image! object!]
][
	knl: [-1.0 -1.0 -1.0 -1.0 8.0 -1.0 -1.0 -1.0 -1.0]
	t: type? src
	if t = object! [
		rcvConvolveMat src dst knl 1.0 0.0
	]
	if t = image! [
		tmp1: make image! src/size
		rcvLowPass src tmp1 src/size;  same as rcvGaussianFilter src tmp1
		rcvSub src tmp1 dst
	]
]

;Non-Uniform (Binomial) Weight Convolutions
rcvBinomialHighPass: function [
"Non-Uniform (Binomial) Weight Convolution"
	src 	[image! object!] 
	dst		[image! object!]
][
	knl: [-1.0 -2.0 -1.0 -2.0 12.0 -2.0 -1.0 -2.0 -1.0]
	t: type? src
	if t = object! [
		rcvConvolveMat src dst knl 1.0 0.0
	]
	if t = image! [
		rcvConvolve src dst knl 1.0 0.0
	]
]

rcvDoGFilter: function [
"Difference of Gaussian"
	src 	[image! object!] 
	dst		[image! object!]	 
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
	if t = image!  [rcvConvolve src dst k factor 0.0]
	if t = object! [rcvConvolveMat src dst k 1.0 0.0]
	dst
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
][	
	n: kSize/x * kSize/y
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
        sumr sumg sumb nf
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
    nf: (as float! n)
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
    					0	[sumr: sumr + (as float! r)
    						 sumg: sumg + (as float! g)
    						 sumb: sumb + (as float! b)]
    					1	[sumr: sumr + (1.0 / (as float! r))
    						 sumg: sumg + (1.0 / (as float! g))
    						 sumb: sumb + (1.0 / (as float! b))]
    					2	[prodr: prodr * (as float! r)
    						 prodg: prodg * (as float! g)
    						 prodb: prodb * (as float! b)]
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
    			0 	[r: as integer! 1.0 / nf * sumr
    				 g: as integer! 1.0 / nf * sumg
    				 b: as integer! 1.0 / nf * sumb]				; arithmetic mean
    			1 	[r: as integer! (1.0 * nf / sumr)
    				 g: as integer! (1.0 * nf / sumg)
    				 b: as integer! (1.0 * nf / sumb)]			; harmonic mean
    			2	[r: as integer! pow  prodr  (1.0 / nf)
    				 g: as integer! pow  prodg  (1.0 / nf)
    				 b: as integer! pow  prodb  (1.0 / nf)]		; geometric mean
    			3	[r: as integer! sqrt (sumr / nf)
    			     g: as integer! sqrt (sumg / nf)
    			     b: as integer! sqrt (sumb / nf)]			;quadratic mean
    			4	[r: as integer! pow (sumr / nf) (1.0 / 3.0)
    			     g: as integer! pow (sumg / nf) (1.0 / 3.0)
    			     b: as integer! pow (sumb / nf) (1.0 / 3.0)]	;cubic mean
    			5 	[r: as integer! sqrt (1.0 / nf * sumr)
    				 g: as integer! sqrt (1.0 / nf * sumg)
    				 b: as integer! sqrt (1.0 / nf * sumb)]				;rms 
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
        pixX pixY pixD			[int-ptr!]
        handle1 handle2 handleD	[integer!] 
        h w x y					[integer!] 
        r1 g1 b1				[float!]
        r2 g2 b2				[float!]
        r3 g3 b3 				[integer!]
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
        					  
        		either r1 > 0.0 [r3: as integer! (180.0 * (atan (r2 / r1) / 3.14159))]
        		 			  [r3: 0]
        		either g1 > 0.0 [g3: as integer! (180.0 * (atan (g2 / g1) / 3.14159))]
        		     		  [g3: 0]
        		either b1 > 0.0 [b3: as integer! (180.0 * (atan (b2 / b1) / 3.14159))]
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
	src			[image! object!] 
	dst			[image! object!]
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
	if t = object! [
		mx1: matrix/init 2 src/bits as-pair src/cols src/rows
		mx2: matrix/init 2 src/bits as-pair src/cols src/rows
		rcvConvolveMat src mx1 k1 1.0 0.0
		rcvConvolveMat src mx2 k2 1.0 0.0
		mx3: matrix/addition mx1 mx2
		switch direction [
				1 [rcvCopyMat mx1 dst]	;X
				2 [rcvCopyMat mx2 dst]	; Y
				3 [rcvCopyMat mx3 dst]	; X and Y	
		]
		rcvReleaseMat mx1
		rcvReleaseMat mx2
		rcvReleaseMat mx3
	]
	if t = image! [
		img1: make image! src/size
		img2: make image! src/size
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
	src 		[image! object!]  
	dst 		[image! object!]
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
	if t = object! [
		mx1: matrix/init 2 src/bits as-pair src/cols src/rows
		mx2: matrix/init 2 src/bits as-pair src/cols src/rows
		rcvConvolveMat src mx1 k1 1.0 0.0
		rcvConvolveMat src mx2 k2 1.0 0.0
		mx3: matrix/addition mx1 mx2 
		switch direction [
				1 [rcvCopyMat mx1 dst]	; hx
				2 [rcvCopyMat mx2 dst]	; hy
				3 [rcvCopyMat mx3 dst] ;  XY
		]
		rcvReleaseMat mx1
		rcvReleaseMat mx2
		rcvReleaseMat mx3
	]
	
	if t = image! [
		img1: make image! src/size
		img2: make image! src/size
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
	src 		[image! object!]  
	dst			[image! object!] 
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
	if t = object! [
		mx1: matrix/init 2 src/bits as-pair src/cols src/rows
		mx2: matrix/init 2 src/bits as-pair src/cols src/rows
		rcvConvolveMat src mx1 k1 1.0 0.0
		rcvConvolveMat src mx2 k2 1.0 0.0
		mx3: matrix/addition mx1 mx2 
		switch direction [
				1 [rcvCopyMat mx2 dst] ; HZ
				2 [rcvCopyMat mx1 dst] ; VT
				3 [rcvCopyMat mx3 dst] ; Both
				
		]
		rcvReleaseMat mx1
		rcvReleaseMat mx2
		rcvReleaseMat mx3
	]
	if t = image! [
		img1: make image! src/size
		img2: make image! src/size
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
	src 		[image! object!] 
	dst			[image! object!]
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
	if t = object! [
		mx1: matrix/init 2 src/bits as-pair src/cols src/rows
		mx2: matrix/init 2 src/bits as-pair src/cols src/rows
		rcvConvolveMat src mx1 hx 1.0 0.0
		rcvConvolveMat src mx2 hy 1.0 0.0
		mx3: matrix/addition mx1 mx2
		switch direction [
				1 [rcvCopyMat mx1 dst] ; HZ
				2 [rcvCopyMat mx2 dst] ; VT
				3 [rcvCopyMat mx3 dst]; Both
				
		]
		rcvReleaseMat mx1
		rcvReleaseMat mx2
		rcvReleaseMat mx3
	]
	if t = image! [
		img1: make image! src/size
		img2: make image! src/size
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
	src 		[image! object!] 
	dst			[image! object!]
	direction 	[integer!]
][
	h1: [0.0 1.0 -1.0 0.0]
	h2: [1.0 0.0 0.0 -1.0]
	t: type? src
	if t = object! [
			mx1: matrix/init 2 src/bits as-pair src/cols src/rows
			mx2: matrix/init 2 src/bits as-pair src/cols src/rows
			rcvConvolveMat src mx1 h1 1.0 0.0
			rcvConvolveMat src mx2 h2 1.0 0.0
			mx3: matrix/addition mx1 mx2
			switch direction [
				1 [rcvCopyMat mx1 dst]
				2 [rcvCopyMat mx2 dst]
				3 [rcvCopyMat mx3 dst]
			]
			rcvReleaseMat mx1
			rcvReleaseMat mx2	
			rcvReleaseMat mx3	
	]
	if t = image! [
			img1: make image! src/size
			img2: make image! src/size
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

rcvRobinson: function [
"Robinson Filter"
	src [image! object!]
	dst	[image! object!]
][
	knl: [1.0 1.0 1.0 1.0 -2.0 1.0 -1.0 -1.0 -1.0]
	t: type? src 
	if t = image!  [rcvConvolve src dst knl 1.0 0.0]
	if t = object! [rcvConvolveMat src dst knl 1.0 0.0]
]

rcvGradientMasks: function [
"Fast gradient mask filter with 8 directions"
	src 		[image! object!]  
	dst		 	[image! object!]
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
	if t = object! [rcvConvolveMat src dst mask 1.0 0.0]
]

rcvLineDetection: function [
"Fast line detection with 4 directions"
	src 		[image! object!] 
	dst		 	[image! object!]
	direction 	[integer!]

][
	knl: [[-1.0 -1.0 -1.0 2.0 2.0 2.0 -1.0 -1.0 -1.0]
		  [-1.0 2.0 -1.0 -1.0 2.0 -1.0 -1.0 2.0 -1.0]
		  [2.0 -1.0 -1.0 -1.0 2.0 -1.0 -1.0 -1.0 2.0]
		  [-1.0 -1.0 2.0 -1.0 2.0 -1.0 2.0 -1.0 -1.0]]
	
	mask: knl/:direction
	t: type? src
	if t = image!  [rcvConvolve src dst mask 1.0 0.0]
	if t = object! [rcvConvolveMat src dst mask 1.0 0.0]
]

;only for images
;op= 1 ; rcvGradNeumann Computes the discrete gradient 
;by forward finite differences and Neumann boundary conditions. 
;op = 2 Computes the divergence by backward finite differences. 
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
    
    pixS:  image/acquire-buffer src  :handleS
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
	image/release-buffer src handleS no
	image/release-buffer dst1 handleD1 yes
	image/release-buffer dst2 handleD2 yes
]

rcvGradNeumann: function [
"Computes the discrete gradient by forward finite differences and Neumann boundary conditions"
	src 	[image!] 
	return:	[block!]
][
	d1: make image! src/size
	d2: make image! src/size
	rcvNeumann src d1 d2 1
	reduce [d1 d2]
]

rcvDivNeumann: function [
"Computes the divergence by backward finite differences"
	src 	[image!] 
	return:	[block!]
][	
	d1: make image! src/size
	d2: make image! src/size
	rcvNeumann src d1 d2 2
	reduce [d1 d2]
]


; Second derivative filter

rcvDerivative2: function [
"Computes the 2nd derivative of an image or a matrix"
	src 		[image! object!] 
	dst		 	[image! object!]
	delta 		[float!] 
	direction 	[integer!]
][
	hx: [0.0 0.0 0.0 1.0 -2.0 1.0 0.0 0.0 0.0]
	hy: [0.0 1.0 0.0 0.0 -2.0 0.0 0.0 1.0 0.0]
	
	t: type? src
	if t = object! [
		mx1: matrix/init 2 src/bits as-pair src/cols src/rows
		mx2: matrix/init 2 src/bits as-pair src/cols src/rows
		mx3: matrix/init 2 src/bits as-pair src/cols src/rows
		rcvConvolveMat src mx1 hx 1.0 delta
		rcvConvolveMat src mx2 hy 1.0 delta
		mx3: matrix/addition mx1 mx2
		switch direction [
			1 [rcvCopyMat mx1 dst]
			2 [rcvCopyMat mx2 dst]
			3 [rcvCopyMat mx3 dst]
		]
		rcvReleaseMat mx1
		rcvReleaseMat mx2	
		rcvReleaseMat mx3
	]
	if t = image! [
		img1: make image! src/size
		img2: make image! src/size
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
	src 		[image! object!] 
	dst			[image! object!]
	connexity 	[integer!]
] [
	switch connexity[
		4  [knl: [0.0 -1.0 0.0 -1.0 4.0 -1.0 0.0 -1.0 0.0]]
		8  [knl: [-1.0 -1.0 -1.0 -1.0 8.0 -1.0 -1.0 -1.0 -1.0]]
		16 [knl: [-1.0 0.0 0.0 -1.0 0.0 1.0 1.0 0.0 0.0 1.0 1.0 0.0 -1.0 0.0 0.0 -1.0 ]]
	]
	t: type? src
	if t = object!	[rcvConvolveMat src dst knl 1.0 128.0]
	if t = image!	[rcvConvolve src dst knl 1.0 128.0]
]

rcvDiscreteLaplacian: function [
"Discrete Laplacian Filter"
	src 		[image! object!] 
	dst			[image! object!]
][
	knl: [1.0 1.0 1.0 1.0 -8.0 1.0 1.0 1.0 1.0]
	t: type? src
	if t = image! 	[rcvConvolve src dst knl 1.0 0.0]
	if t = object! 	[rcvConvolveMat src dst knl 1.0 0.0]
]

rcvLaplacianOfRobinson: function [
"Laplacian of Robinson Filter"
	src 		[image! object!] 
	dst			[image! object!]
][
	knl: [1.0 -2.0 1.0 -2.0 4.0 -2.0 1.0 -2.0 1.0]
	t: type? src
	if t = image! 	[rcvConvolve src dst knl 1.0 0.0]
	if t = object! 	[rcvConvolveMat src dst knl 1.0 0.0]
]

rcvLaplacianOfGaussian: function [
"Laplacian of Gaussian"
	src 	[image! vector!] 
	dst		[image! object!]
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
	if t = object! 	[rcvConvolveMat src dst knl 1.0 0.0]
	dst
]

;Kuwahara filter (image only)
rcvKuwahara: routine [
"Kuwahara non-linear smoothing filter"
    src  	[image!]
    dst  	[image!]
    kSize	[pair!]
    /local
    pix1 pixD idx	 			[int-ptr!]
    handle1 handleD				[integer!]
    n i j x y w h nr			[integer!]
    imx imy						[integer!]
    sumA sumB sumC sumD			[float!]
    sum2A sum2B sum2C sum2D		[float!]
    sumAR sumBR sumCR sumDR		[integer!]
    sumAG sumBG sumCG sumDG		[integer!]
    sumAB sumBB sumCB sumDB		[integer!]
    meanA meanB meanC meanD		[integer!]
    meanAR meanBR meanCR meanDR	[integer!]
    meanAG meanBG meanCG meanDG	[integer!]
    meanAB meanBB meanCB meanDB [integer!]
    varA varB varC varD			[float!]
    minVar minMean 				[float!]
    a r g b 					[integer!]
    lum							[float!]
    
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
        			lum: (0.3 * as float! r) + (0.59 * as float! g) + (0.11 * as float! b)
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
    		varA: sum2A - ((SumA * SumA) / as float! nr)
    		if varA < minVar [minVar: varA]
    		varB: sum2B - ((SumB * SumB) / as float! nr)
    		if varB < minVar [minVar: varB]
    		varC: sum2C - ((SumC * SumC) / as float! nr)
    		if varC < minVar [minVar: varC]
    		varD: sum2D - ((SumD * SumD) / as float! nr)
    		if varD < minVar [minVar: varD]
    		; region with minimal variance
    		if minVar = varA [minMean: as float! meanA]
			if minVar = varB [minMean: as float! meanB]
    		if minVar = varC [minMean: as float! meanC]
    		if minVar = varD [minMean: as float! meanD]
    		; update destination value
    		pixD/value: as integer! minMean
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
        pixX pixY 			[int-ptr!]
        mValue 				[byte-ptr!]
        handle1 handle2		[integer!] 
        h w x y	unit		[integer!]
        derivX derivY grd	[float!]
        s					[series!]
        dx dy
][
	handle1: 0
	handle2: 0
    pixX: image/acquire-buffer srcX :handle1
    pixY: image/acquire-buffer srcY :handle2
    mValue: vector/rs-head mat	; a byte ptr
	s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	w: IMAGE_WIDTH(srcX/size)
    h: IMAGE_HEIGHT(srcX/size)
    y: 0
    while [y < h] [
    	x: 0
		while [x < w][
				dx: pixX/value and 00FF0000h >> 16
				dy: pixY/value and 00FF0000h >> 16 
       			derivX: (as float! dx)
       			derivY: (as float! dy)
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
        s
][
	handle1: 0
	handle2: 0
    pixX: image/acquire-buffer srcX :handle1
    pixY: image/acquire-buffer srcY :handle2
    mValue: vector/rs-head matA	; a byte ptr
    s: GET_BUFFER(matA)
	unit: GET_UNIT(s)
	
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
	s
][
	mAValue: vector/rs-head matA	; a byte ptr
	mGValue: vector/rs-head matG	; a byte ptr
	mSValue: vector/rs-head matS	; a byte ptr
	s: GET_BUFFER(matS)				; bit size
	unit: GET_UNIT(s)
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
	s
][
	mSValue: 	vector/rs-head gradS	; a byte ptr
	mDTValue: 	vector/rs-head doubleT	; a byte ptr
	s: GET_BUFFER(gradS)				; bit size
	unit1: GET_UNIT(s)
	s: GET_BUFFER(doubleT)
	unit2: GET_UNIT(s)
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
	s
][
	mDTValue: vector/rs-head doubleT	; a byte ptr
	mFEValue: vector/rs-head finalEdges	; a byte ptr
	s: GET_BUFFER(doubleT)
	unit: GET_UNIT(s)
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
        pixX pixY pixD idxX idxY	[int-ptr!]
        handle1 handle2 handleD		[integer!] 
        h w x y i j					[integer!]
        detM traceM  				[float!]
        px px2 py py2 pxy			[float!]
        imx imy n p dx dy			[integer!]
        sumpx2 sumpy2 sumpxy		[float!]
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
        				dx: idxX/value and 00FF0000h >> 16
        				dy: idxY/value and 00FF0000h >> 16
        				px: as float! (dx) 
       					py: as float! (dy)
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
        		p: as integer! (detM - traceM / 2147483647.0)
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
