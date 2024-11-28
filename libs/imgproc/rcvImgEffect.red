Red [
	Title:   "Red Computer Vision: Image Processing"
	Author:  "Francois Jouen"
	File: 	 %rcvImgEffect.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;--used libs
;#include %rcvGaussian.red
;#include %rcvConvolutionImg.red

;******************* Image Transformations *****************************

_randf: routine [
"returns a decimal value beween 0 and 1"
	m [float!]
	return: [float!]
][
	(m * as float! _random/rand) / 2147483647.0 - 1.0
]

rcvResizeImage: routine [
"Resizes image"
	src 	[image!] 
	iSize 	[pair!] 
	return: [image!]
][
	as red-image! stack/set-last as cell! image/resize src iSize/x iSize/y
]
rcvCropImage: routine [
"Crop source image to destination image"
    src 	[image!]
    dst  	[image!]
    origin	[pair!]
    /local
        pix1 pixD idx					[int-ptr!]
        handle1 handleD h w x y l pos	[integer!]
][
    handle1:	 handleD: 0
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
	factor	[integer!]
][
	tmpImg: make image! reduce [src/size black]
	iSize: src/size
	nSize: iSize / factor
	knl: rcvMakeGaussian 5x5 1.0
	rcvFilter2D src tmpImg knl 1.0 0.0
	rcvResizeImage tmpImg nSize
]

rcvPyrUp: function [
"Performs up-sampling step of Gaussian pyramid decomposition"
	src 	[image!]
	factor	[integer!]
][
	tmpImg: make image! reduce [src/size black]
	iSize: src/size
	nSize: iSize * factor
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
        pix1 pixD idx 			[int-ptr!]
        handle1 handleD h w x y	[integer!]        
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
        pix1 pixD idx idx2 		[int-ptr!]
        handle1 handleD h w x y	[integer!] 
        xm ym x0 y0 			[integer!]
        xF yF  xx yy d theta	[float!]  			
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x0: w / 2 
    y0: h / 2
    d: 0.0
    theta: 0.0
    y: 0
    while [y < h] [
    	x: 0
    	while [x < w][
    		xF: (as float! x)
    		yF: (as float! y)
        	switch op [
        		1 [	; Glass effect HZ
        			xF: xF + (_randf param1 * 5.0) 
        			yF: (as float! y)
        		]
        		
        		2 [	; Glass effect Vx 
        			xF: (as float! x)
        		    yF: yF + (_randf param1 * 5.0)
        		]
        		
        		3 [	; Glass effect both
        			xF: xF + (_randf param1 * 5.0) 
        		    yF: yF + (_randf param1 * 5.0)
        		]
        		
        		4 [	; Glass effect O1
        			xF: xF + (_randf param1 * 5.0) 
        		    yF: yF - (_randf param1 * 5.0)
        		]
        		5 [	; Glass effect O2
        			xF: xF - (_randf param1 * 5.0) 
        		    yF: yF + (_randf param1 * 5.0)
        		]
        		6 [; Swirl effect
        			xx: xF - (as float! x0) 
					yy: yF - (as float! y0)
					d: sqrt((xx * xx) + (yy * yy))
        			theta: pi / param1 * d
					xf: (xx * cos theta) - (yy * sin theta) + (as float! x0)
					yf: (xx * sin theta) + (yy * cos theta) + (as float! y0) 
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
        pix1 pixD idx idx2		[int-ptr!]
        handle1 handleD h w x y	[integer!] 
        yF xF xx yy				[float!]
        xm ym 					[integer!]
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
